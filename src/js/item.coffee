'use strict'

define [

    'lib/three'
    
], (THREE) ->

    class Item

        @type:

            block: 0
            flag:  1

        constructor: (@position = new THREE.Vector3(), @type) ->

            @type ?= Item.type.block

            console.log 'Item loaded! /tumbleweed'

        update: (graphics) ->

            @mesh ?= @_makeMesh graphics

        _makeMesh: ->

            switch @type

                when Item.type.block

                    'make block'

                when Item.type.flag

                    'make flag'
