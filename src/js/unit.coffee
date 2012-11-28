'use strict'

define [
    
    'lib/three'
    'lib/tween'
    'lib/stim'
    'graphics'
    'utils'
    'constants'

], (THREE, TWEEN, Stim, Graphics, Utils, Const) ->

    # TODO: Use a mixin to give Attacker and other mobile units the movement
    # related code here?
    class Unit

        @type:
            attacker: 0
            enemy:    1
            block:    2
            flag:     3

        @texture:
            active: THREE.ImageUtils.loadTexture \
                "#{Const.imageDir}/active-unit.png"

        constructor: (@_speed = 0.2) ->

            @position ?= new THREE.Vector3()
            @rotation ?= new THREE.Vector3()

            @active = false
            @stop()

        stop: ->

            @_patrolling = false
            @_following = false
            @_resetTweens()

        patrolTo: (targetTile) ->

            @stop()
            @_patrolling = true

            currentTile = @tile
            do move = =>

                return unless @_patrolling

                # Swap start and end tiles.
                temp = targetTile
                targetTile = currentTile
                currentTile = temp

                @_moveTo currentTile, @_attackNearby, -> move()

        follow: (unit) ->

            @stop()
            @_following = true

            do follow = =>

                unless @_following
                    clearInterval intervalID
                    return

                distance = Utils.distance @tile, unit.tile
                return if distance <= Const.tileCrossDistance

                tile = @_grid.nearestEmptyTile unit.tile, @position

                @_resetTweens()
                @_moveTo tile

            intervalID = setInterval follow, 100

        moveTo: (targetTile, beforeMoveAction, doneAction) ->

            @stop()
            @_moveTo arguments...

        _moveTo: (targetTile, beforeMoveAction, doneAction) ->

            return if @_speed is 0

            path = @_pathTo targetTile

            return unless path.length

            @_enqueueTweens path, beforeMoveAction

            @_tweenQueue.last().onComplete =>

                @_tweenQueue.clear()
                doneAction? targetTile

            @_tweenQueue.peek().start()

            path

        update: (graphics) ->

            @mesh ?= @_makeMesh graphics
            @_base?.material.visible = if @active then true else false

        _makeMesh: (graphics, mesh) ->

            @_base = Graphics.makePlane \
                Const.tileSize * 2,
                Const.tileSize * 2

            @_base.material.map = Unit.texture.active
            @_base.material.transparent = true
            @_base.material.visible = false
            @_base.position.y = -@position.y + 2

            mesh.add @_base

            mesh.position.copy @position
            mesh.rotation.copy @rotation

            graphics.scene.add mesh

            mesh

        _pathTo: (targetTile) ->

            @_grid.graph.aStar @tile, targetTile, (vertex) ->

                Utils.chebyshev vertex, targetTile

        _attackNearby: ->

            # Check nearby tiles for an opposing unit.

        _resetTweens: ->

            @_tweenQueue ?= new Stim.Queue()
            @_tweenQueue.peek()?.stop()

            # TODO: This is inefficient because TWEEN.remove runs in linear
            # time. Fix this if it becomes a bottleneck.
            until @_tweenQueue.length() is 0
                TWEEN.remove @_tweenQueue.dequeue()

        _enqueueTweens: (path, beforeMoveAction) ->

            tile = @tile
            for nextTile in path

                tween = @_makeTween tile, nextTile, beforeMoveAction
                break unless tween

                @_tweenQueue.enqueue tween
                tile = nextTile

         # TODO: Consider rewriting this function. The whole system of chaining
         # tweens seems messy.
        _makeTween: (tile, nextTile, beforeMoveAction) ->

            # Check if @position is adjacent to tile.position based on
            # hexagonal movement.
            unless @_isAdjacent tile, nextTile

                console.warn 'Shortest path algorithm gave non-adjacent tile.'
                return

            start = tile.position.clone()
            speed = Utils.distance(tile, nextTile) / @_speed

            # Tween the unit position.
            new TWEEN.Tween(start)
                .to(nextTile.position, speed)
                .easing(TWEEN.Easing.Linear.None)
                .onStart( =>
                                beforeMoveAction?()

                                Utils.copyPosition @position, nextTile.position
                                @mesh.lookAt @position

                                nextTile.addObject @
                                tile.unit = null

                                # On the last movement we want to immediately
                                # occupy the square.
                                if @_tweenQueue.length() is 1
                                    @_grid.graph.removeVertex nextTile
                )
                .onUpdate( =>
                                Utils.copyPosition @mesh.position, start
                )
                .onComplete =>
                                @_tweenQueue.dequeue()
                                @_tweenQueue.peek().start()

        _isAdjacent: (tile, nextTile) ->

            distance = Utils.distance tile, nextTile

            return false if distance > Const.tileCrossDistance

            # TODO: Check the angle of distanceVector to determine true
            # adjacency. This probably won't be needed since the game
            # environment is a flat plane and distance is enough of a
            # determining factor.

            true

