define [
    
    'graphics'
    'unit'
    'constants'

], (Graphics, Unit, Const) ->

    class Block extends Unit

        @texture: THREE.ImageUtils.loadTexture "#{Const.imageDir}/block.jpg"

        constructor: (@_grid, @position) ->

            @position ?= new THREE.Vector3()
            @_color = 0xcccccc
            @_size = 16

            super 0

        _makeMesh: (graphics) ->

            mesh = Graphics.makeCube \
                @_size,
                @_color,
                @position

            mesh.material.map = Block.texture

            super graphics, mesh
