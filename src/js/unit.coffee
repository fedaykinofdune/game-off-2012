'use strict'

define [
    
    'lib/three'
    'graphics'
    'constants'

], (THREE, Graphics, Const) ->

    class Unit

        constructor: (@position = new THREE.Vector3()) ->

            @active = false

            # Tiles per second.
            @_speed = 1

        moveTo: (targetTile) ->

            # Use A* to find a path to tile.
            # ...
            path = [targetTile]

            @_moveToAdjacent tile for tile in path

        update: (graphics) ->

            unless @mesh
                @mesh = Graphics.makeSphere @position, Const.debug.unitColor
                graphics.scene.add @mesh

            if @active

                @activeSprite ?= @_makeActiveSprite()
                @_updateActiveSprite()
            
            else

                @_hideActiveSprite()

        _moveToAdjacent: (tile) ->

            # Check if @position is adjacent to tile.position based on
            # hexagonal movement. 
            # ...
            adjacent = true

            unless adjacent

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            console.log "moving to tile:"
            console.log tile

            # Tween the position of the unit at a rate of @speed
            # For now just instantly move the unit there.
            @position.copy tile.position
            @mesh.position.copy tile.position
            tile.addUnit @

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
