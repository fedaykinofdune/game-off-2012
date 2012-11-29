'use strict'

define ->

    class Utils

        @tileDistance: (tile1, tile2) ->

            @distance tile1.position, tile2.position

        @distance: (position1, position2) ->

            position2.clone().subSelf(position1).length()

        @tileChebyshev: (tile1, tile2) ->

            @chebyshev tile1.position, tile2.position

        @chebyshev: (position1, position2) ->

            Math.max Math.abs(position1.x - position2.x),
                Math.abs(position1.z - position2.z)

        @random: (min, max) ->

            Math.floor(Math.random() * (max - min + 1)) + min

        # Copies a THREE.Vector3 but preserves the y value.
        @translate: (pos1, pos2) ->

            pos1.x = pos2.x
            pos1.z = pos2.z
