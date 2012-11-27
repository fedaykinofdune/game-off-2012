define [

    'graphics'
    'unit'
    'constants'
    
], (Graphics, Unit, Const) ->

    class Attacker extends Unit

        constructor: (@_grid, @position, @rotation) ->

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

            super graphics, mesh
