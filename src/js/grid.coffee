'use strict'

define [

    'lib/three'
    'lib/stim'
    'graphics'
    'unit'
    'attacker'
    'enemy'
    'block'
    'tile'
    'utils'
    'constants'
    
], (THREE, Stim, Graphics, Unit, Attacker, Enemy, Block, Tile, Utils, Const) ->

    class Grid

        # TODO: Make these textures object members. I Doubt there's a
        # performance boost by making it a class member.
        @texture: THREE.ImageUtils.loadTexture "#{Const.imageDir}/grass.jpg"

        constructor: (@tilesX = 24, @tilesY = 24) ->

            @width = @tilesX * Const.tileSize
            @height = @tilesY * Const.tileSize

            @_centerX = Math.floor @tilesX / 2
            @_centerY = Math.floor @tilesY / 2

            @position =
                x: @_centerX * Const.tileSize
                y: 0
                z: @_centerY * Const.tileSize

            @_halfTile = (Const.tileSize / 2)

            @_setupTiles()
            @_setupGraph()
            @_setupObjects()

        update: (graphics) ->

            return if @mesh

            @mesh = Graphics.makePlane \
                @tilesX * Const.tileSize,
                @tilesY * Const.tileSize,
                0xa5c9f3,
                @position

            # TODO: Repeat the texture in relation to grid size.
            Grid.texture.wrapS = THREE.RepeatWrapping
            Grid.texture.wrapT = THREE.RepeatWrapping
            Grid.texture.repeat.x = 4
            Grid.texture.repeat.y = 4

            @mesh.material.map = Grid.texture
            
            graphics.scene.add @mesh

        addObject: (x, y, objectType = Unit.type.attacker) ->

            position = new THREE.Vector3 \
                x * Const.tileSize + @_halfTile,    # x
                Const.debug.unitBodyRadius,         # y
                y * Const.tileSize + @_halfTile     # z

            @graph.removeVertex @tiles[x][y]

            # TODO: For now we just add units, but later we will deal with
            # items. A tile can have many items.
            object =
                switch objectType
                    when Unit.type.attacker then new Attacker @, position
                    when Unit.type.enemy    then new Enemy @, position
                    when Unit.type.block    then new Block @, position

            @tiles[x][y].addObject object

            object

        putBlock: (vector) ->

            return unless vector

            [x, y] = @_vec2index vector

            return unless @tiles[x][y].isEmpty()

            @addObject x, y, Unit.type.block

        moveUnit: (vector) ->

            return unless @_activePrevious?.active

            tile = @_vec2tile vector

            return unless tile

            @_activePrevious.moveTo tile

        clickUnit: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile?.unit, 'active'

        highlightTile: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile, 'highlighted'

        clearTile: ->

        # Checks the immediate radius around tile for an empty tile. Tiles
        # closer to pos are prefered. If no empty tile is found, the provided
        # tile itself is returned.
        nearestEmptyTile: (tile, pos) ->

            nearest = tile
            distance = Infinity

            @around tile, 1, (x, y, neighbour) ->

                return unless neighbour.isEmpty()

                tileDistance = Utils.distance neighbour.position, pos

                if pos and tileDistance < distance
                    nearest = neighbour
                    distance = tileDistance

            nearest

        # Tile iterator. Exposes the (x, y) position on the grid and the tile
        # itself.
        eachTile: (callback) ->

            @tiles ?= []
            for x in [0...@tilesX]

                @tiles[x] ?= []
                for y in [0...@tilesY]

                    callback x, y, @tiles[x][y]

        # Tile iterator. Traverses tiles around the given tile up to a given
        # distance.
        around: (tile, distance, callback) ->

            [x, y] = @_vec2index tile.position
            @_around x, y, distance, callback

        _around: (x, y, distance, callback) ->

            for i in [-distance..distance]
                for j in [-distance..distance]

                    continue if i is 0 and j is 0

                    newX = x + i
                    newY = y + j

                    continue unless @tiles[newX]?[newY]

                    return if false is callback newX, newY, @tiles[newX][newY]

        # Sets a property on an object. The function ensures the property is
        # only ever active on one of those objects. For example, only one tile
        # can have the highlighted property or currently only one unit can have
        # the active property.
        #
        # TODO: This is probably way too abstract. How to rewrite this without
        # introducing duplicated code in clickUnit and highlightTile?
        _setSingletonProperty: (object, property) ->

            previousObjectName = "_#{property}Previous"
            previousObject = @[previousObjectName]

            unless object is previousObject

                previousObject?[property] = false

            return unless object

            object[property] = true
            @[previousObjectName] = object

        _vec2tile: (vector) ->

            return unless vector

            [x, y] = @_vec2index vector
            @tiles[x][y]

        _vec2index: (vector) ->

            x = Math.round (vector.x - @_halfTile) / Const.tileSize
            y = Math.round (vector.z - @_halfTile) / Const.tileSize

            [x, y]

        _setupObjects: ->

            # Setup the player.
            # TODO: player is a temporary variable. It will go once there is a
            # notion of multiple player units.
            @player = @addObject @tilesX - 2, @_centerX

            # Setup some blocks.
            # TODO: These are for demo purposes and will probably go in the
            # final release.
            for i in [1..30]
                rand = Utils.random(@tilesX / 3, 2 * @tilesX / 3)
                rand = Math.max 0, rand - 1
                rand = Math.floor rand
                @addObject rand, Utils.random(0, @tilesY - 1), Unit.type.block

        # TODO: Make _setupTiles and _setupGraph more efficient. We shouldn't
        # have to make three passes over the tiles to set everything up.
        _setupTiles: ->

            @eachTile (x, z) =>

                position = new THREE.Vector3 \
                    Const.tileSize * x + @_halfTile,    # x
                    @position.y + 1,                    # y
                    Const.tileSize * z + @_halfTile     # z

                @tiles[x][z] = new Tile position
                @tiles[x][z].neighbours = @_makeFriends x, z
                
            @eachTile (x, z, tile) =>

                tile.neighbours = @_makeFriends x, z

        _setupGraph: ->

            @graph = new Stim.Graph()
            @eachTile (x, y, tile) =>

                @graph.addVertex tile, tile.neighbours

        # Builds a list of neighbouring tiles.
        _makeFriends: (x, y) ->

            neighbours = []

            @_around x, y, 1, (newX, newY, tile) =>

                # Squares with diagonal edges get more weight to represent
                # a longer distance.
                weight = if newX is x or newY is y then 1 else 2
                neighbours.push [tile, weight] if tile

            neighbours
