'use strict'

define ->

    class Tile

        constructor: (@position) ->

            @highlighted = false
            @mesh = null

        addUnit: (unit) ->

            @unit = unit
            unit.tile = @

        # Used to create a unique hash of this object. Used heavily in the
        # Graph module.
        toString: -> '' + @position.x + @position.y + @position.z
