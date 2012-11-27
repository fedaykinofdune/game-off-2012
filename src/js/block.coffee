define [
    
    'graphics'
    'unit'

], (Graphics, Unit) ->

    class Block extends Unit

        constructor: (@_grid, @position) ->

            @position ?= new THREE.Vector3()
            @_color = 0xcccccc
            @_height = 16

            super 0

        _makeMesh: (graphics) ->

            mesh = Graphics.makeCube \
                @_height,
                @_color,
                @position

            super graphics, mesh
