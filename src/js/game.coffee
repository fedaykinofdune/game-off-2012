'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/three': 'exports': 'THREE'
        'lib/tween': 'exports': 'TWEEN'
        'lib/zepto': 'exports': '$'

requirejs [

    'lib/zepto'
    'grid'
    'unit'
    'graphics'

], ($, Grid, Unit, Graphics) ->

    class Game

        constructor: (container) ->

            @grid = new Grid()
            @graphics = new Graphics container, @grid

            @_setupMouse()

        run: ->

            requestAnimationFrame @run.bind @
            @_step()
            @graphics.update()

        _step: ->

        _setupMouse: ->

    container = document.getElementById 'game'
    new Game(container).run()
