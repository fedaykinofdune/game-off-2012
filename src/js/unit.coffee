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

        moveTo: (targetTile, graph) ->

            # TODO: Replace Dijkstra's with A*.
            path = graph.dijkstra @tile, targetTile

            console.log path

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
            unless @_isAdjacent tile

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            # Tween the position of the unit at a rate of @speed.
            # For now just instantly move the unit there.
            @position.copy tile.position
            @mesh.position.copy tile.position
            tile.addUnit @

        _isAdjacent: (tile) ->

            distanceVector = tile.position.clone().subSelf @position

            return false if distanceVector.length() > Const.tileCrossDistance

            # TODO: Check the angle of distanceVector to determine true
            # adjacency. This probably won't be needed since the game
            # environment is a flat plane and distance is enough of a
            # determining factor.

            true

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
