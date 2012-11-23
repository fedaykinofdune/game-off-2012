'use strict'

define [
    
    'lib/three'
    'lib/tween'
    'graphics'
    'constants'

], (THREE, TWEEN, Graphics, Const) ->

    class Unit

        constructor: (@position = new THREE.Vector3()) ->

            @active = false

            # Tiles per second.
            @_speed = 1

        moveTo: (targetTile, graph) ->

            # TODO: Replace Dijkstra's with A*.
            path = graph.dijkstra @tile, targetTile

            return unless path.length

            @_tweenStart?.stop()
            @_tweenStart = null
            @_tweenHead = null
            TWEEN.removeAll()

            tile = @tile
            for nextTile in path
                tween = @_moveToAdjacent tile, nextTile
                @_tweenStart ?= tween
                @_tweenHead?.chain tween
                @_tweenHead = tween
                tile = nextTile

            @_tweenHead.onComplete => @_tweenStart = null
            @_tweenStart.start()

        update: (graphics) ->

            unless @mesh
                @mesh = Graphics.makeSphere @position, Const.debug.unitColor
                graphics.scene.add @mesh

            if @active

                @activeSprite ?= @_makeActiveSprite()
                @_updateActiveSprite()
            
            else

                @_hideActiveSprite()

        _moveToAdjacent: (tile, nextTile) ->

            # Check if @position is adjacent to tile.position based on
            # hexagonal movement.
            unless @_isAdjacent tile, nextTile

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            start = tile.position.clone()

            # However, we still animate the mesh.
            new TWEEN.Tween(start)
                .to(nextTile.position, 200)
                .easing(TWEEN.Easing.Linear.None)
                .onStart( =>
                                @position.copy nextTile.position
                                nextTile.addUnit @
                )
                .onUpdate =>
                                @mesh.position.copy start

        _isAdjacent: (tile, nextTile) ->

            distanceVector = nextTile.position.clone().subSelf tile.position

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
