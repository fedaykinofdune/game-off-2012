'use strict'

define [

    'unit'
    
], (Unit) ->

    class Tile

        constructor: (@position) ->

            @highlighted = false
            @mesh = null

        isEmpty: ->

            not @unit?

        addObject: (@unit) ->

            @unit.tile = @

        # Used to create a unique hash of this object. Used heavily in the
        # Graph module.
        toString: -> '' + @position.x + @position.y + @position.z
