'use strict'

define [

    'unit'
    'graphics'
    'constants'
    
], (Unit, Graphics, Const) ->

    class Tile

        constructor: (@position) ->

            @highlighted = false
            @mesh = null

        update: (graphics) ->

            if @highlighted
                @mesh ?= @_makeMesh graphics
                @mesh.visible = true
            else
                @mesh?.visible = false

            @unit?.update graphics

        isEmpty: ->

            not @unit?

        addObject: (@unit) ->

            @unit.tile = @

        # Used to create a unique hash of this object. Used heavily in the
        # Graph module.
        toString: -> '' + @position.x + @position.y + @position.z

        _makeMesh: (graphics) ->

            mesh = Graphics.makePlane \
                Const.tileSize,
                Const.tileSize,
                0x9586DE,
                @position

            graphics.scene.add mesh

            mesh
