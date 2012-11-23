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
            @_keyStates = {}
            @_setupEvents()

        run: ->
            requestAnimationFrame @run.bind @
            @_step()
            @_graphics.update()

        _step: ->

        _setupEvents: ->

            $(window).keydown (event) => @_setKeyState event.which, true
            $(window).keyup (event) => @_setKeyState event.which, false

            # Disables browser popup on right click.
            $(container).bind 'contextmenu', (event) -> event.preventDefault()

            $(container).mousedown (event) =>

                vector = @_graphics.mouse2vec @_getMousePos(event)...

                switch event.which

                    when Const.mouse.leftClick then @_grid.clickUnit vector
                    when Const.mouse.rightClick then @_grid.moveUnit vector

            $(container).mousemove (event) =>

                intersection = @_graphics.mouse2vec @_getMousePos(event)...
                unless intersection
                    @_grid.clearTile()
                    return

                @_grid.highlightTile intersection

            $(container).mouseleave (event) => @_grid.clearTile()

        _setKeyState: (keyCode, bool) ->

            return unless keyCode in Const.keys

            event.preventDefault()

            @_keyStates[keyCode] = bool

        _getMousePos: (event) ->

            x = event.offsetX or event.layerX - @_offset.left
            y = event.offsetY or event.layerY - @_offset.top

            [x, y]

    container = document.getElementById 'game'
    new Game(container).run()
