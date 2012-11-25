define [
    
    'graphics'
    'unit'

], (Graphics, Unit) ->

    class Block extends Unit

        @size:  16
        @color: 0xcccccc

        constructor: (@position = new THREE.Vector3()) ->

            super 0

        _makeMesh: (graphics) ->

            mesh = Graphics.makeCube \
                Block.size,
                Block.color,
                @position

            graphics.scene.add mesh

            mesh

        # TODO: Instead make the sprite part of an Object3D group in makeMesh.
        # Then just show or hide it based on unit activity.
        _makeActiveSprite: ->

            'no sprite'

        _updateActiveSprite: ->

        _hideActiveSprite: ->

