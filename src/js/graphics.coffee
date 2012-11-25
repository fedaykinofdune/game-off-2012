'use strict'

define [

    'lib/zepto'
    'lib/three'
    'lib/tween'
    'lib/stim'
    'constants'
    'flycontrols'

], ($, THREE, TWEEN, Stim, Const, FlyControls) ->

    class Graphics

        constructor: (@_container, @_grid) ->

            @_setupScene()
            @_setupAxis()
            @_grid.update @

            @_projector = new THREE.Projector()
            @_clock = new THREE.Clock()

            @_camera.lookAt @_grid.mesh.position

        @makeCube: (size, color, pos) ->

            geometry = new THREE.CubeGeometry size, size, size
            material = new THREE.MeshLambertMaterial color: color
            cube = new THREE.Mesh geometry, material
            cube.position.copy pos

            cube

        @makePlane: (length, width, color, pos) ->

            geometry = new THREE.PlaneGeometry length, width
            material = new THREE.MeshLambertMaterial color: color
            plane = new THREE.Mesh geometry, material
            plane.position.copy pos if pos
            plane.material.side = THREE.DoubleSide
            plane.rotation.x = Math.PI / 2

            plane

        @makeSphere: (radius, color, pos) ->

            geometry = new THREE.SphereGeometry radius, 10, 10
            material = new THREE.MeshLambertMaterial color: color
            sphere = new THREE.Mesh geometry, material
            sphere.position.copy(pos) if pos
            sphere.overdraw = true

            sphere

        update: ->

            for column in @_grid.tiles
                for tile in column
                    @_updateTile tile

            # @_controls.update @_clock.getDelta()
            TWEEN.update()
            @_renderer.render @scene, @_camera

        # TODO: Move this code to Grid object or Graphics class?
        mouse2vec: (x, y) ->

            # Convert to NDC (normalized device coordinates).
            x = (x / @_container.clientWidth) * 2 - 1
            y = -(y / @_container.clientHeight) * 2 + 1

            # 0.5 is an arbitrary value for the projection.
            vector = new THREE.Vector3 x, y, 0.5
            @_projector.unprojectVector vector, @_camera

            ray = new THREE.Ray @_camera.position,
                vector.subSelf(@_camera.position).normalize()

            intersects = ray.intersectObject @_grid.mesh

            intersects?[0]?.point

        _setupScene: ->

            @scene = new THREE.Scene()

            # TODO: Make this more cross-browser without bringing in jQuery
            sceneWidth = @_container.clientWidth
            sceneHeight = @_container.clientHeight
            @_setupCamera sceneWidth / sceneHeight

            light1 = new THREE.PointLight 0xffffff
            light1.position.set 500, 500, 500
            @scene.add light1

            @_renderer =
                if @_supportWebGL()
                    new THREE.WebGLRenderer()
                else
                    new THREE.CanvasRenderer()

            @_renderer.setSize sceneWidth, sceneHeight
            @_container.appendChild @_renderer.domElement

        _setupAxis: ->

            axis = new THREE.AxisHelper 50
            axis.scale.multiplyScalar 2
            @scene.add axis
            @_camera.lookAt axis.position

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_camera.position.set 600, 350, 200

            # TODO: The controls are temporary for debugging.
            ###
            @_controls = new THREE.FlyControls @_camera
            @_controls.movementSpeed = 1000
            @_controls.domElement = @_container
            @_controls.rollSpeed = Math.PI / 2
            @_controls.autoForward = false
            @_controls.dragToLook = false
            ###

            @scene.add @_camera

        _updateTile: (tile) ->

            if tile.highlighted
                @_setupTileMesh tile unless tile.mesh
                tile.mesh.visible = true
            else
                tile.mesh?.visible = false

            tile.unit?.update @

        _setupTileMesh: (tile) ->

            tile.mesh = Graphics.makePlane \
                Const.tileSize,
                Const.tileSize,
                0x9586DE,
                tile.position

            @scene.add tile.mesh

        _supportWebGL: ->

            canvas = document.createElement 'canvas'
            do ->
                try
                    window.WebGLRenderingContext? and
                        canvas.getContext('experimental-webgl')?

                catch e
                    false
