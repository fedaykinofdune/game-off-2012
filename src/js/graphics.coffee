'use strict'

define [

    'lib/three'
    'lib/tween'
    'constants'

], (THREE, TWEEN, Const) ->

    class Graphics

        constructor: (@_container, @_grid) ->

            @_setupScene()
            @_setupAxis()
            @_setupGrid()

        update: ->

            for column in @_grid
                for tile in column
                    @_highlight tile if tile.mouse

            @_renderer.render @_scene, @_camera

        _highlight: (tile) ->

        _setupScene: ->

            @_scene = new THREE.Scene()

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.clientWidth
            sceneHeight = @_container.clientHeight
            @_setupCamera sceneWidth / sceneHeight

            light1 = new THREE.PointLight 0xffffff
            light1.position.set 500, 500, 500
            @_scene.add light1

            # TODO: Detect support for WebGLRenderer and use it when
            # appropriate.
            @_renderer = new THREE.WebGLRenderer()
            @_renderer.setSize sceneWidth, sceneHeight
            @_container.appendChild @_renderer.domElement

        _setupAxis: ->

            axis = new THREE.AxisHelper 50
            axis.scale.multiplyScalar 2
            @_scene.add axis
            @_camera.lookAt axis.position

        _setupGrid: ->

            geometry = new THREE.PlaneGeometry @_grid.tilesX * Const.tileSize,
                @_grid.tilesY * Const.tileSize
            material = new THREE.MeshLambertMaterial color: 0xA5C9F3
            @_gridMesh = new THREE.Mesh geometry, material
            @_gridMesh.material.side = THREE.DoubleSide
            @_gridMesh.rotation.x = Math.PI / 2
            
            @_scene.add @_gridMesh
            @_camera.lookAt @_gridMesh.position

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_camera.position.set -380, 350, 380
            @_scene.add @_camera
