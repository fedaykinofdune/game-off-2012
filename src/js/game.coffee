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

            @grid = new Grid()
            @graphics = new Graphics container, @grid

            @_offset = $(container).offset()
            @_setupMouse()

        run: ->
            requestAnimationFrame @run.bind @
            @_step()
            @graphics.update()

        _step: ->

        _setupMouse: ->

            $(container).mousemove (event) =>
                x = event.offsetX or event.layerX - @_offset.left
                y = event.offsetY or event.layerY - @_offset.top
                @graphics.setMouse x, y

            $(container).mouseleave (event) =>
                @graphics.clearMouse()

    container = document.getElementById 'game'
    new Game(container).run()
