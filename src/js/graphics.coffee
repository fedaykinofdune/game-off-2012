'use strict'

define [

    'lib/three'
    'lib/tween'

], (THREE, TWEEN) ->

    class Graphics

        constructor: (@grid) ->

            # Render the initial grid.

        update: ->

            for column in @grid
                for tile in column
                    @_highlight tile if tile.mouse

        _highlight: (tile) ->
