define [

    'graphics'
    'unit'
    'constants'
    
], (Graphics, Unit, Const) ->

    class Attacker extends Unit

        constructor: (@_grid, @position, @rotation) ->

            super 0.2

        _makeMesh: (graphics) ->

            super graphics, Graphics.makeDebugMesh Const.debug.unitBodyColor
