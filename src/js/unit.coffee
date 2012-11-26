'use strict'

define [
    
    'lib/three'
    'lib/tween'
    'lib/stim'
    'graphics'
    'constants'

], (THREE, TWEEN, Stim, Graphics, Const) ->

    class Unit

        @type:
            attacker: 0
            enemy:    1
            block:    2
            flag:     3

        constructor: (@_speed = 0.2) ->

            @position ?= new THREE.Vector3()
            @rotation ?= new THREE.Vector3()

            @active = false
            @_patrolling = false

        stop: ->

            @_patrolling = false
            @_stopAnimation()

        patrolTo: (targetTile) ->

            @_patrolling = true

            currentTile = @tile

            do move = =>

                return unless @_patrolling

                # Swap start and end tiles.
                temp = targetTile
                targetTile = currentTile
                currentTile = temp

                @moveTo currentTile, @_attackNearby, -> move()

        follow: (unit) ->

            # TODO: This is really laggy. Implement D* to handle this.
            # do move = =>

            #     @stop()
            #     @moveTo unit.tile
            #     setTimeout move, 200

        moveTo: (targetTile, beforeMoveAction, doneAction) ->

            return if @_speed is 0

            path = @_pathTo targetTile

            return unless path.length

            @_stopAnimation()

            tile = @tile
            for nextTile in path

                tween = @_moveToAdjacent tile, nextTile, beforeMoveAction
                break unless tween

                @_tweenQueue.enqueue tween
                tile = nextTile

            @_tweenQueue.last().onComplete =>

                @_tweenQueue.clear()

                doneAction? targetTile

            @_tweenQueue.peek().start()

            path

        update: (graphics) ->

            @mesh ?= @_makeMesh graphics

            if @active

                @activeSprite ?= @_makeActiveSprite()
                @_updateActiveSprite()
            
            else

                @_hideActiveSprite()

        _pathTo: (targetTile) ->

            @_grid.graph.aStar @tile, targetTile, (vertex) ->

                # The Chebyshev distance heuristic.
                Math.max Math.abs(vertex.position.x - targetTile.position.x),
                    Math.abs(vertex.position.z - targetTile.position.z)

        _attackNearby: ->

            # Check nearby tiles for an opposing unit.

        _stopAnimation: ->

            @_tweenQueue ?= new Stim.Queue()
            @_tweenQueue.peek()?.stop()

            # TODO: This is inefficient because TWEEN.remove runs in linear
            # time. Fix this if it becomes a bottleneck.
            until @_tweenQueue.length() is 0
                TWEEN.remove @_tweenQueue.dequeue()

         # TODO: Consider rewriting this function. The whole system of chaining
         # tweens seems messy.
        _moveToAdjacent: (tile, nextTile, beforeMoveAction) ->

            # Check if @position is adjacent to tile.position based on
            # hexagonal movement.
            unless @_isAdjacent tile, nextTile

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            start = tile.position.clone()
            speed = @_distance(tile, nextTile) / @_speed

            # Tween the unit position.
            new TWEEN.Tween(start)
                .to(nextTile.position, speed)
                .easing(TWEEN.Easing.Linear.None)
                .onStart( =>
                                beforeMoveAction?()

                                @mesh.lookAt nextTile.position
                                @position.copy nextTile.position
                                nextTile.addObject @

                                # On the last movement we want to immediately
                                # occupy the square.
                                if @_tweenQueue.length() is 1
                                    @_grid.graph.removeVertex nextTile
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

            @_direction(tile1, tile2).length()

        _direction: (tile1, tile2) ->

            tile2.position.clone().subSelf tile1.position
