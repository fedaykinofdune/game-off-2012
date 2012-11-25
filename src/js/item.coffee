'use strict'

define [

    'lib/three'
    
], (THREE) ->

    class Item

        @type:

            coin: 0

        constructor: (@position = new THREE.Vector3(), @type) ->

            @type ?= Item.type.coin

            console.log 'Item loaded! /tumbleweed'

        update: (graphics) ->

            @mesh ?= @_makeMesh graphics

        _makeMesh: ->

            switch @type

                when Item.type.coin

                    'make coin'
