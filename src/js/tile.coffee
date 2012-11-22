'use strict'

define ->

    class Tile

        constructor: (@position) ->

            @highlighted = false
            @mesh = null

        addUnit: (unit) ->

            @unit = unit
            unit.tile = @
