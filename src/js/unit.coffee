'use strict'

define [
    
    'graphics'

], (Graphics) ->

    class Unit

        constructor: (@position = {}) ->

            @position.x ?= 0
            @position.y ?= 0
            @position.z ?= 0

            @active = false

        update: (graphics) ->

            unless @mesh
                @mesh = Graphics.makeSphere @position
                graphics.scene.add @mesh

            if @active

                # Create the active mesh if its not already created.
                # ...
            
            else

                # Hide the active mesh.
                # ...

