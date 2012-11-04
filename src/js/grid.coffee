'use strict'

define [

    'unit'
    'tile'
    
], (Unit, Tile) ->

    class Grid

        constructor: (@tilesX = 32, @tilesY = 32) ->

            @tiles = ((new Tile() for [0...@tilesY]) for [0...@tilesX])

            centerX = Math.floor @tilesX / 2
            @tiles[centerX][@tilesY - 2].unit = new Unit()
