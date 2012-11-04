'use strict'

requirejs [

    'grid'
    'unit'
    'graphics'

], (Grid, Unit, Graphics) ->

    class Game

        constructor: (container) ->

            @grid = new Grid()
            @graphics = new Graphics @grid

            console.log 'Game created! /tumbleweed'

        run: ->

            requestAnimationFrame => @step() and @run()

        step: ->

            @graphics.update()

    new Game().run()
