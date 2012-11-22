'use strict'

# TODO: Can we build AMD module versions of these libraries to prevent having
# to shim?
require.config
    shim:
        'lib/three': 'exports': 'THREE'
        'lib/tween': 'exports': 'TWEEN'
        'lib/zepto': 'exports': '$'

define [

    'lib/zepto'
    'grid'
    'unit'
    'graphics'
    'constants'

], ($, Grid, Unit, Graphics, Const) ->

    class Game

        constructor: (container) ->

            @_grid = new Grid()
            @_graphics = new Graphics container, @_grid

            @_offset = $(container).offset()
            @_setupEvents()

        run: ->
            requestAnimationFrame @run.bind @
            @_step()
            @_graphics.update()

        _step: ->

        _setupEvents: ->

            $(window).keydown (event) ->

            # Disables browser popup on right click.
            $(container).bind 'contextmenu', (event) ->

                event.preventDefault()

            $(container).mousedown (event) =>

                vector = @_graphics.mouse2vec @_getMousePos(event)...

                switch event.which

                    when Const.events.leftClick then @_grid.clickUnit vector
                    when Const.events.rightClick then @_grid.moveUnit vector

            $(container).mousemove (event) =>

                intersection = @_graphics.mouse2vec @_getMousePos(event)...
                unless intersection
                    @_grid.clearTile()
                    return

                @_grid.highlightTile intersection

            $(container).mouseleave (event) =>

                @_grid.clearTile()

        _getMousePos: (event) ->

            x = event.offsetX or event.layerX - @_offset.left
            y = event.offsetY or event.layerY - @_offset.top

            [x, y]

    container = document.getElementById 'game'
    new Game(container).run()
