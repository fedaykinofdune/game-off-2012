'use strict'

define [

    'unit'
    'tile'
    
], (Unit, Tile) ->

    class Grid

        constructor: (@tilesX = 32, @tilesY = 32) ->

            @tiles = ((new Tile() for [0...@tilesY]) for [0...@tilesX])
            @lastActiveTile = null

            centerX = Math.floor @tilesX / 2
            @tiles[centerX][@tilesY - 2].unit = new Unit()

        setMouse: (x, y) ->

            # Do magic computation to figure out which tile to highlight
            index = 24
            @tiles[index].active = true
            @lastActiveTile?.active = false
            @lastActiveTile = @tiles[index]

        clearMouse: ->

            @setMouse null, null
