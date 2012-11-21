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

            @lastActiveTile = null

            @_halfTile = (Const.tileSize / 2)
            @_setupTiles()

            @centerTile = @tiles[centerX][centerY]

            unitPosition =
                x: (@tilesY - 2) * Const.tileSize + @_halfTile
                y: Const.unitSphereRadius
                z: centerX * Const.tileSize + @_halfTile

            @tiles[centerX][@tilesY - 2].unit = new Unit unitPosition

        update: (graphics) ->

            return if @mesh

            @mesh = Graphics.makePlane \
                @tilesX * Const.tileSize,
                @tilesY * Const.tileSize,
                0xa5c9f3,
                @position
            
            graphics.scene.add @mesh

        clickTile: (vector) ->

        activateTile: (vector) ->

            xIndex = Math.round (vector.x - @_halfTile) / @tilesX * 2
            yIndex = Math.round (vector.z - @_halfTile) / @tilesY * 2

            tile = @tiles[xIndex][yIndex]

            return if tile is @lastActiveTile

            tile.active = true
            @lastActiveTile?.active = false
            @lastActiveTile = tile

        clearTile: ->

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
