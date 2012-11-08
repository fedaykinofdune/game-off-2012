module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        coffeelint:
            app:
                files: ['src/js/*.coffee']
                options:
                    indentation:
                        value: 4
                    no_plusplus:
                        level: 'error'

        shell:
            setup: command: 'mkdir -p src/js/lib'
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
                'lib/three': 'exports': 'THREE'
                'lib/tween': 'exports': 'TWEEN'

            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false
            logLevel: 0

    grunt.registerTask 'default', 'shell coffeelint requirejs'
