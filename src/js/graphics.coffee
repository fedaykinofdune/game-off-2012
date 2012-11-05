'use strict'

define [

    'lib/three'
    'lib/tween'

], (THREE, TWEEN) ->

    class Graphics

        constructor: (@_container, @_grid) ->

            @_setupScene()

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
            @_renderer = new THREE.CanvasRenderer()
            @_renderer.setSize sceneWidth, sceneHeight
            @_container.appendChild @_renderer.domElement

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_camera.position.set -200, 150, 200
            @_scene.add @_camera

            geometry = new THREE.CubeGeometry 50, 50, 50
            material = new THREE.MeshLambertMaterial color: 0xA5C9F3
            @_cube = new THREE.Mesh geometry, material
            @_scene.add @_cube

            @_camera.lookAt @_cube.position
