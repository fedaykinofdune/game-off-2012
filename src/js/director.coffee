'use strict'

define [
    
    'unit'
    'utils'

], (Unit, Utils) ->

    # Handles enemy AI and level progression.
    class Director

        constructor: (@_grid) ->

            @_maxEnemies = 10
            @_enemies = []

        update: ->

            @_spawnEnemy() if @_enemies.length < @_maxEnemies

        # Spawn an enemy along the back edge of the game board.
        # TODO: Don't spawn an enemy on a block that is already occupied.
        _spawnEnemy: ->

            x = 0
            y = Utils.random 0, @_grid.tilesY - 1

            enemy = @_grid.addObject x, y, Unit.type.enemy
            enemy.rotation.y += Math.PI / 2

            @_enemies.push enemy

            enemy.patrolTo @_grid.tiles[@_grid.tilesX - 1][y]
