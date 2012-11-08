'use strict'

define [

    'unit'
    'tile'
    'constants'
    
], (Unit, Tile, Const) ->

    class Grid

        constructor: (@tilesX = 32, @tilesY = 32) ->

            @position = x: 0, y: 0, z:0
            @lastActiveTile = null

            @_gridOffsetX = Const.tileSize * @tilesX / 2 - (Const.tileSize / 2)
            @_gridOffsetY = Const.tileSize * @tilesY / 2 - (Const.tileSize / 2)

            @_setupTiles()

            centerX = Math.floor @tilesX / 2
            centerY = Math.floor @tilesY / 2
            @centerTile = @tiles[centerX][centerY]

            @tiles[centerX][@tilesY - 2].unit = new Unit()

        activateTile: (vector) ->

            xIndex = Math.round (vector.x + @_gridOffsetX) / @tilesX * 2
            yIndex = Math.round (vector.z + @_gridOffsetY) / @tilesY * 2

            tile = @tiles[xIndex][yIndex]

            return if tile is @lastActiveTile

            tile.active = true
            @lastActiveTile?.active = false
            @lastActiveTile = tile

        _setupTiles: ->

            @tiles = []
            for x in [0...@tilesX]
                @tiles[x] ?= []
                for z in [0...@tilesY]
                    position =
                        x: Const.tileSize * x - @_gridOffsetX
                        z: Const.tileSize * z - @_gridOffsetY
                        y: @position.y + 1

                    @tiles[x][z] = new Tile position
