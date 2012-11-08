'use strict'

define [

    'lib/zepto'
    'lib/three'
    'lib/tween'
    'lib/stim'
    'constants'

], ($, THREE, TWEEN, Stim, Const) ->

    class Graphics

        constructor: (@_container, @_grid) ->

            @_setupScene()
            @_setupAxis()
            @_setupGrid()
            @_projector = new THREE.Projector()

            # TODO: Use Stimpack.HashMap.
            @_mesh2tile = {}

            @_camera.lookAt @_gridMesh.position

            # TODO: Get Stimpack to import properly.
            console.log Stim

        update: ->

            for column in @_grid.tiles
                for tile in column
                    @_updateMesh tile

            @_renderer.render @_scene, @_camera

        setMouse: (x, y) ->

            # Convert to NDC (normalized device coordinates).
            x = (x / @_container.clientWidth) * 2 - 1
            y = -(y / @_container.clientHeight) * 2 + 1

            # 0.5 is an arbitrary value for the projection.
            vector = new THREE.Vector3 x, y, 0.5
            @_projector.unprojectVector vector, @_camera

            ray = new THREE.Ray @_camera.position,
                vector.subSelf(@_camera.position).normalize()

            intersects = ray.intersectObject @_gridMesh

            unless intersects.length
                @clearMouse()
                return

            @_grid.activateTile intersects[0].point

        clearMouse: ->

        _setupGrid: ->

            @_gridMesh = @_setupPlane @_grid.tilesX * Const.tileSize,
                @_grid.tilesY * Const.tileSize, 0xa5c9f3, @_grid.position
            
            @_scene.add @_gridMesh

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

        _setupCamera: (ratio) ->

            @_camera = new THREE.PerspectiveCamera 75, ratio, 50, 10000
            @_camera.position.set -380, 350, 380
            @_scene.add @_camera

        _setupPlane: (length, width, color, pos) ->

            geometry = new THREE.PlaneGeometry length, width
            material = new THREE.MeshLambertMaterial color: color
            plane = new THREE.Mesh geometry, material
            plane.position.copy(pos) if pos
            plane.material.side = THREE.DoubleSide
            plane.rotation.x = Math.PI / 2

            plane

        _updateMesh: (tile) ->

            if tile.active
                @_setupTileMesh(tile) unless tile.mesh
                tile.mesh.visible = true
            else
                tile.mesh?.visible = false

        _setupTileMesh: (tile) ->

            tile.mesh = @_setupPlane Const.tileSize, Const.tileSize, 0x9586DE,
                tile.position

            pos = tile.mesh.position
            hash = "#{pos.x}#{pos.y}#{pos.z}"
            @_mesh2tile[hash] = tile

            @_scene.add tile.mesh
