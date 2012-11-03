module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        shell:
            link:
                command: 'ln -fs ../node_modules/grunt-requirejs/node_modules/requirejs/require.js lib/ && \ 
                    ln -fs ../src/lib/threejs/build/three.js lib/ && \ 
					ln -fs ../src/lib/tweenjs/build/Tween.js lib/tween.js'
            compile:
                command: "coffee -c $(find src/js/ -name '*.coffee')"

        requirejs:
            almond: true

            modules: [name: 'game']
            dir: 'build'
            appDir: 'src'
            baseUrl: 'js'

            paths: {}
            shim:
                'lib/Three.js': 'exports': 'THREE'
                'lib/Tween.js': 'exports': 'TWEEN'

            fileExclusionRegExp: /^threejs$/
            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false

    grunt.registerTask 'default', 'shell requirejs'
