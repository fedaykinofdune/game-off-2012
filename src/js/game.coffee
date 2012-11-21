'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/three': 'exports': 'THREE'
        'lib/tween': 'exports': 'TWEEN'
        'lib/zepto': 'exports': '$'

define [

    'lib/zepto'
    'grid'
    'unit'
    'graphics'

], ($, Grid, Unit, Graphics) ->

    class Game

        constructor: (container) ->

            @_grid = new Grid()
            @_graphics = new Graphics container, @_grid

            @_offset = $(container).offset()
            @_setupEvents()

        run: ->
            requestAnimationFrame @run.bind @
            @_step()
            @_graphics.update()

        _step: ->

        _setupEvents: ->

            $(window).keydown (event) ->

            $(container).mousedown (event) =>

                @_grid.clickTile @_graphics.mouse2vec @_getMousePos(event)...

            $(container).mousemove (event) =>

                intersection = @_graphics.mouse2vec @_getMousePos(event)...
                unless intersection
                    @_grid.clearTile()
                    return

                @_grid.highlightTile intersection

            $(container).mouseleave (event) =>

                @_grid.clearTile()

        _getMousePos: (event) ->

            x = event.offsetX or event.layerX - @_offset.left
            y = event.offsetY or event.layerY - @_offset.top

            [x, y]

    container = document.getElementById 'game'
    new Game(container).run()
