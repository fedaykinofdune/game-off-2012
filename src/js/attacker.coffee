define [

    'graphics'
    'unit'
    'constants'
    
], (Graphics, Unit, Const) ->

    class Attacker extends Unit

        constructor: (@position, @rotation) ->

            super 0.2

        _makeMesh: (graphics) ->

            body = Graphics.makeSphere \
                Const.debug.unitBodyRadius,
                Const.debug.unitBodyColor

            headOffset = new THREE.Vector3 \
                0,
                0,
                Const.debug.unitBodyRadius + Const.debug.unitHeadRadius

            head = Graphics.makeSphere \
                Const.debug.unitHeadRadius,
                Const.debug.unitHeadColor,
                headOffset

            mesh = new THREE.Object3D()
            mesh.add body
            mesh.add head
            mesh.position.copy @position
            mesh.rotation.copy @rotation

            graphics.scene.add mesh

            mesh

        # TODO: Instead make the sprite part of an Object3D group in makeMesh.
        # Then just show or hide it based on unit activity.
        _makeActiveSprite: ->

            # Load the sprite.
            # For now we just modify the object color and return a temporary
            # string.
            @mesh.children[0].material.color.setHex Const.debug.activeUnitColor

            'no sprite'

        _updateActiveSprite: ->

            # Update the position of @activeSprite to match @position
            # For now we just modify the object color.
            @mesh.children[0].material.color.setHex Const.debug.activeUnitColor

        _hideActiveSprite: ->

            # For now we just reset the color of the unit.
            @mesh.children[0].material.color.setHex Const.debug.unitBodyColor
