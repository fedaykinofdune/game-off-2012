'use strict'

define [
    
    'graphics'
    'constants'

], (Graphics, Const) ->

    class Unit

        constructor: (@position = {}) ->

            @position.x ?= 0
            @position.y ?= 0
            @position.z ?= 0

            @active = false

        update: (graphics) ->

            unless @mesh
                @mesh = Graphics.makeSphere @position, Const.debug.unitColor
                graphics.scene.add @mesh

            if @active

                @activeSprite ?= @_makeActiveSprite()
                @_updateActiveSprite()
            
            else

                @_hideActiveSprite()

        _makeActiveSprite: ->

            # Load the sprite. 
            # For now we just modify the object color and return a temporary 
            # string.
            @mesh.material.color.setHex Const.debug.activeUnitColor

            'no sprite'

        _updateActiveSprite: ->

            # Update the position of @activeSprite to match @position
            # For now we just modify the object color.
            @mesh.material.color.setHex Const.debug.activeUnitColor

        _hideActiveSprite: ->

            # For now we just reset the color of the unit.
            @mesh.material.color.setHex Const.debug.unitColor
