'use strict'

requirejs [

    'lib/three'
    'lib/tween'
    'unit'

], (THREE, TWEEN, Unit) ->

    class Game

        constructor: ->

            console.log 'Game created! /tumbleweed'
            console.log THREE

    new Game()
