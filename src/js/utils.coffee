'use strict'

define ->

    class Utils

        @distance: (tile1, tile2) ->

            tile2.position.clone().subSelf(tile1.position).length()

        @chebyshev: (tile1, tile2) ->

            Math.max Math.abs(tile1.position.x - tile2.position.x),
                Math.abs(tile1.position.z - tile2.position.z)

        @random: (min, max) ->

            Math.floor(Math.random() * (max - min + 1)) + min

        # Copies a THREE.Vector3 but preserves the y value.
        @copyPosition: (pos1, pos2) ->

            pos1.x = pos2.x
            pos1.z = pos2.z
