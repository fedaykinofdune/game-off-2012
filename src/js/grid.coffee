'use strict'

define [

    'lib/three'
    'graphics'
    'unit'
    'tile'
    'constants'
    
], (THREE, Graphics, Unit, Tile, Const) ->

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

            @_activePrevious.moveTo tile

        clickUnit: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile?.unit, 'active'

        highlightTile: (vector) ->

            tile = @_vec2tile vector
            @_setSingletonProperty tile, 'highlighted'

        clearTile: ->

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

        _setupTiles: ->

            @tiles = []
            for x in [0...@tilesX]
                @tiles[x] ?= []
                for z in [0...@tilesY]
                    position =
                        x: Const.tileSize * x + @_halfTile
                        z: Const.tileSize * z + @_halfTile
                        y: @position.y + 1

                    @tiles[x][z] = new Tile position
