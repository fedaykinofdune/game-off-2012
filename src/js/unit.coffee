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

        moveTo: (targetTile, graph) ->

            return if @_speed is 0

            path = graph.aStar @tile, targetTile, (vertex) ->

                Math.max Math.abs(vertex.position.x - targetTile.position.x),
                    Math.abs(vertex.position.z - targetTile.position.z)

            return unless path.length

            @_stopAnimation()

            tile = @tile
            for nextTile in path

                tween = @_moveToAdjacent tile, nextTile
                break unless tween

                @_tweenQueue.enqueue tween
                tile = nextTile

            @_tweenQueue.last().onComplete =>

                graph.removeVertex targetTile
                @_tweenQueue.clear()

            @_tweenQueue.peek().start()

        update: (graphics) ->

            @mesh ?= @_makeMesh graphics

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

            # Tween the unit position.
            new TWEEN.Tween(start)
                .to(nextTile.position, speed)
                .easing(TWEEN.Easing.Linear.None)
                .onStart( =>
                                @mesh.lookAt nextTile.position
                                @position.copy nextTile.position
                                nextTile.addObject @
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
