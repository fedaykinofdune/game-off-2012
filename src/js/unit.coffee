'use strict'

define [
    
    'lib/three'
    'lib/tween'
    'graphics'
    'utils'
    'constants'

], (THREE, TWEEN, Graphics, Utils, Const) ->

    # TODO: Use a mixin to give Attacker and other mobile units the movement
    # related code here?
    class Unit

        @mode:
            patrolling: 0
            following:  1
            seeking:    2
            idle:       3

        @type:
            attacker:   0
            enemy:      1
            block:      2
            flag:       3

        @texture:
            active: THREE.ImageUtils.loadTexture \
                "#{Const.imageDir}/active-unit.png"

        constructor: (@_speed = 0.2) ->

            @position ?= new THREE.Vector3()
            @rotation ?= new THREE.Vector3()
            @active = false

            @_readyAction = null

            @stop()

        ready: (action) ->

            if @mesh
                action()
            else
                @_readyAction = action

        stop: ->

            @path = null
            @targetTile = null
            @_moving = false
            @_setMode Unit.mode.idle

        update: (graphics) ->

            unless @mesh
                @mesh = @_makeMesh graphics
                @_readyAction?()

            @_base?.material.visible = if @active then true else false

        patrolTo: (targetTile) ->

            @_setMode Unit.mode.patrolling

            currentTile = @tile
            do move = =>

                return unless @_mode is Unit.mode.patrolling

                # Swap start and end tiles.
                temp = targetTile
                targetTile = currentTile
                currentTile = temp

                @_moveTo currentTile,

                    beforeTween: @_attackNearby,
                    done: =>
                        @_moveTween = null
                        move()

        follow: (unit) ->

            @_setMode Unit.mode.following

            intervalID = null

            do follow = =>

                unless @_mode is Unit.mode.following
                    return clearInterval intervalID

                distance = Utils.tileDistance @tile, unit.tile
                tiles = distance / Const.tileCrossDistance

                if tiles > 4

                    @_moveTo @_grid.nearestEmptyTile unit.tile, @position

                else if tiles > 1

                    return unless unit.path
                    return if unit.path[0] is unit.tile

                    # If we're close enough to the unit, just jump on his
                    # current path. But start at a tile only a few away from
                    # his current one to prevent going on a wild breadcrumb
                    # trail.
                    pathIndex = unit.path?.indexOf(unit.tile)
                    pathIndex = Math.max 0, pathIndex - 3
                    path = unit.path.slice pathIndex
                    path.pop()

                    return unless path.length

                    clearInterval intervalID
                    target = unit.targetTile
                    @_moveTween?.stop()

                    @_moveAlongPath path,

                        beforeTween: =>

                            # As we follow along, check if the other unit makes
                            # any sudden path changes. Notice that stopping
                            # triggers the done action of this _moveAlongPath
                            # call, setting us back into normal follow mode.
                            @stop() if unit.targetTile isnt target

                        done: =>

                            @_setMode Unit.mode.following
                            # TODO: Get this to work. There are synchronization
                            # issues if there is an immediate follow after a
                            # path change. If all fails fix it by allowing
                            # multiple units in a tile?
                            # follow()
                            intervalID = setInterval follow, 500

            intervalID = setInterval follow, 500

        # Wrapper for _moveTo used by external modules. Functions like
        # Unit.follow and Unit.patrolTo rely on _moveTo because it doesn't
        # reset unit state.
        moveTo: (targetTile, actions) ->

            @_setMode Unit.mode.seeking
            @_moveTo targetTile, actions

        _moveTo: (targetTile, actions) ->

            return if @_speed is 0
            return if targetTile is @targetTile

            @path = @_pathTo targetTile

            return unless @path.length

            @targetTile = targetTile
            @_moveTween?.stop()
            @_moveAlongPath @path, actions

        _moveAlongPath: (path, actions = {}) ->

            return actions.done?() unless (path.length and @_moving)

            nextTile = path[0]
            start = @mesh.position.clone()
            speed = Utils.distance(@mesh.position, nextTile.position) / @_speed

            @_moveTween = new TWEEN.Tween(start)
                .to(nextTile.position, speed)
                .easing(TWEEN.Easing.Linear.None)

            @_moveTween.onStart =>

                actions.beforeTween?()

                Utils.translate @position, nextTile.position
                @mesh.lookAt @position

                # On the last movement we want to immediately occupy the
                # square.
                @_grid.graph.removeVertex nextTile unless path[1]

            @_moveTween.onUpdate =>

                Utils.translate @mesh.position, start

            @_moveTween.onComplete =>
                
                @tile.unit = null
                nextTile.addObject @
                @_moveAlongPath path.slice(1), actions

            @_moveTween.start()

        _setMode: (@_mode) ->

            @_moving = if @_mode is Unit.mode.idle then false else true

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

                Utils.tileChebyshev vertex, targetTile

        _attackNearby: ->

            # Check nearby tiles for an opposing unit.
            
        _isAdjacent: (tile, nextTile) ->

            distance = Utils.tileDistance tile, nextTile

            return false if distance > Const.tileCrossDistance

            # TODO: Check the angle of distanceVector to determine true
            # adjacency. This probably won't be needed since the game
            # environment is a flat plane and distance is enough of a
            # determining factor.

            true

