'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/three': 'exports': 'THREE'
        'lib/tween': 'exports': 'TWEEN'

requirejs [

    'grid'
    'unit'
    'graphics'

], (Grid, Unit, Graphics) ->

    class Game

        constructor: (container) ->

            @grid = new Grid()
            @graphics = new Graphics container, @grid

            console.log 'Game created! /tumbleweed'

        run: ->

            requestAnimationFrame @run.bind @
            @step()
            @graphics.update()

        step: ->

    container = document.getElementById 'game'
    new Game(container).run()
