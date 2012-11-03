module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        shell:
            link:
                command: 'ln -fs ../../../node_modules/grunt-requirejs/node_modules/requirejs/require.js src/js/lib/ && \ 
                    ln -fs ../../../sub/threejs/build/three.js src/js/lib/ && \ 
                    ln -fs ../../../sub/tweenjs/build/tween.min.js src/js/lib/tween.js'
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
                'lib/three.js': 'exports': 'THREE'
                'lib/tween.js': 'exports': 'TWEEN'

            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false
            logLevel: 0

    grunt.registerTask 'default', 'shell requirejs'
