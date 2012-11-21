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

            # TODO: Use Stimpack.Map.
            @_mesh2tile = {}
            @_clock = new THREE.Clock()

            @_camera.lookAt @_grid.mesh.position

        @makePlane: (length, width, color, pos) ->

            geometry = new THREE.PlaneGeometry length, width
            material = new THREE.MeshLambertMaterial color: color
            plane = new THREE.Mesh geometry, material
            plane.position.copy pos if pos
            plane.material.side = THREE.DoubleSide
            plane.rotation.x = Math.PI / 2

            plane

        update: ->

            for column in @_grid.tiles
                for tile in column
                    @_updateTile tile

            # @_controls.update @_clock.getDelta()
            @_renderer.render @scene, @_camera

        clickTile: (x, y) ->

            @_grid.clickTile @_mouse2vec x, y

        activateTile: (x, y) ->

            intersection = @_mouse2vec x, y

            unless intersection
                @clearMouse()
                return

            @_grid.activateTile intersection

        clearMouse: ->

        # TODO: Move this code to Grid object or Graphics class?
        _mouse2vec: (x, y) ->

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

        _makeSphere: (pos) ->

            geometry = new THREE.SphereGeometry Const.unitSphereRadius, 10, 10
            material = new THREE.MeshLambertMaterial color: 0x7FDC50
            sphere = new THREE.Mesh geometry, material
            sphere.position.copy(pos) if pos
            sphere.overdraw = true

            sphere

        _updateTile: (tile) ->

            if tile.active
                @_setupTileMesh tile unless tile.mesh
                tile.mesh.visible = true
            else
                tile.mesh?.visible = false

            if tile.unit?
                @_setupUnitMesh tile.unit unless tile.unit.mesh
                @_updateUnit tile.unit

        _updateUnit: (unit) ->

        _setupTileMesh: (tile) ->

            tile.mesh = Graphics.makePlane \
                Const.tileSize,
                Const.tileSize,
                0x9586DE,
                tile.position

            pos = tile.mesh.position
            hash = "#{pos.x}#{pos.y}#{pos.z}"
            @_mesh2tile[hash] = tile

            @scene.add tile.mesh

        _setupUnitMesh: (unit) ->

            unit.mesh = @_makeSphere unit.position
            @scene.add unit.mesh

        _supportWebGL: ->

            canvas = document.createElement 'canvas'
            do ->
                try
                    window.WebGLRenderingContext? and
                        canvas.getContext('experimental-webgl')?

                catch e
                    false
