'use strict'

define [
    
    'lib/three'
    'lib/tween'
    'lib/stim'
    'graphics'
    'constants'

], (THREE, TWEEN, Stim, Graphics, Const) ->

    class Unit

        constructor: (@position = new THREE.Vector3()) ->

            @active = false

            # Tiles per second.
            @_speed = 0.2

        moveTo: (targetTile, graph) ->

            # TODO: Replace Dijkstra's with A*.
            path = graph.dijkstra @tile, targetTile

            return unless path.length

            @_stopAnimation()

            tile = @tile
            for nextTile in path

                tween = @_moveToAdjacent tile, nextTile
                break unless tween

                @_tweenQueue.enqueue tween
                tile = nextTile

            @_tweenQueue.last().onComplete => @_tweenQueue.clear()
            @_tweenQueue.peek().start()

        update: (graphics) ->

            unless @mesh
                @mesh = Graphics.makeSphere @position, Const.debug.unitColor
                graphics.scene.add @mesh

            if @active

                @activeSprite ?= @_makeActiveSprite()
                @_updateActiveSprite()
            
            else

                @_hideActiveSprite()

        _stopAnimation: ->

            @_tweenQueue ?= new Stim.Queue()
            @_tweenQueue.peek()?.stop()

            # TODO: This is inefficient because TWEEN.remove runs in linear
            # time. Fix this if it becomes a bottleneck.
            until @_tweenQueue.length() is 0
                TWEEN.remove @_tweenQueue.dequeue()

        _moveToAdjacent: (tile, nextTile) ->

            # Check if @position is adjacent to tile.position based on
            # hexagonal movement.
            unless @_isAdjacent tile, nextTile

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            start = tile.position.clone()
            speed = @_distance(tile, nextTile) / @_speed

            new TWEEN.Tween(start)
                .to(nextTile.position, speed)
                .easing(TWEEN.Easing.Linear.None)
                .onStart( =>
                                @position.copy nextTile.position
                                nextTile.addUnit @
                )
                .onUpdate( =>
                                @mesh.position.copy start
                )
                .onComplete =>
                                @_tweenQueue.dequeue()
                                @_tweenQueue.peek().start()

        _isAdjacent: (tile, nextTile) ->

            distance = @_distance tile, nextTile

            return false if distance > Const.tileCrossDistance

            # TODO: Check the angle of distanceVector to determine true
            # adjacency. This probably won't be needed since the game
            # environment is a flat plane and distance is enough of a
            # determining factor.

            true

        _distance: (tile1, tile2) ->

            tile2.position.clone().subSelf(tile1.position).length()

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
