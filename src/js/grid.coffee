'use strict'

define [

    'lib/three'
    'lib/stim'
    'graphics'
    'unit'
    'tile'
    'constants'
    
], (THREE, Stim, Graphics, Unit, Tile, Const) ->

    class Grid

        constructor: (@tilesX = 32, @tilesY = 32) ->

            centerX = Math.floor @tilesX / 2
            centerY = Math.floor @tilesY / 2

            @position =
                x: centerX * Const.tileSize
                y: 0
                z: centerY * Const.tileSize

            @_halfTile = (Const.tileSize / 2)
            @_setupTiles()
            @_setupGraph()

            @centerTile = @tiles[centerX][centerY]

            unitPosition = new THREE.Vector3 \
                (@tilesY - 2) * Const.tileSize + @_halfTile,    # x
                Const.unitSphereRadius,                         # y
                centerX * Const.tileSize + @_halfTile           # z

            @tiles[@tilesY - 2][centerX].addUnit new Unit unitPosition

        update: (graphics) ->

            return if @mesh

            @mesh = Graphics.makePlane \
                @tilesX * Const.tileSize,
                @tilesY * Const.tileSize,
                0xa5c9f3,
                @position
            
            graphics.scene.add @mesh

        moveUnit: (vector) ->

            return unless @_activePrevious

            tile = @_vec2tile vector

            return unless tile

            @_activePrevious.moveTo tile, @_graph

        clickUnit: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile?.unit, 'active'

        highlightTile: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile, 'highlighted'

        clearTile: ->

        # Tile iterator. Exposes the (x, y) position on the grid and the tile
        # itself.
        eachTile: (callback) ->

            @tiles ?= []
            for x in [0...@tilesX]

                @tiles[x] ?= []
                for y in [0...@tilesY]

                    callback x, y, @tiles[x][y]

        # Sets a property on an object. The function ensures the property is
        # only ever active on one of those objects. For example, only one tile
        # can have the highlighted property or currently only one unit can have
        # the active property.
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

            xIndex = Math.round (vector.x - @_halfTile) / @tilesX * 2
            yIndex = Math.round (vector.z - @_halfTile) / @tilesY * 2

            @tiles[xIndex][yIndex]

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

            @_graph = new Stim.Graph()
            @eachTile (x, y, tile) =>

                @_graph.addVertex tile, tile.neighbours

        # Builds a list of neighbouring tiles.
        _makeFriends: (x, y) ->

            neighbours = []

            for i in [-1, 0, 1]
                for j in [-1, 0, 1]

                    continue if i is 0 and j is 0

                    newX = x + i
                    newY = y + j

                    if @tiles[newX]?[newY]?
                        neighbours.push @tiles[newX][newY]

            neighbours
