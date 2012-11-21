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
            @_setupMouse()

        run: ->
            requestAnimationFrame @run.bind @
            @_step()
            @_graphics.update()

        _step: ->

        _setupMouse: ->

            $(container).mousedown (event) =>
                @_graphics.clickTile @_getMousePos(event)...

            $(container).mousemove (event) =>
                @_graphics.activateTile @_getMousePos(event)...

            $(container).mouseleave (event) =>
                @_graphics.clearMouse()

        _getMousePos: (event) ->

            x = event.offsetX or event.layerX - @_offset.left
            y = event.offsetY or event.layerY - @_offset.top

            [x, y]

    container = document.getElementById 'game'
    new Game(container).run()
