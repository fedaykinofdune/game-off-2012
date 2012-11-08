'use strict'

define ->

    class Tile

        constructor: (@position) ->

            @active = false
            @mesh = null
