'use strict'

define ->

    class Tile

        constructor: (@position) ->

            @highlighted = false
            @mesh = null
