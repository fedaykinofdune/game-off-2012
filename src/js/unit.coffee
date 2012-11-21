'use strict'

define ->

    class Unit

        constructor: (@position = {}) ->

            @position.x ?= 0
            @position.y ?= 0
            @position.z ?= 0

