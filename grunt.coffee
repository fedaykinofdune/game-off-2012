module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig
        coffeelint:
            app:
                files: ['src/js/*.coffee']
                options: grunt.file.readJSON 'coffeelint.json'

        shell:
            setup:   command: 'bin/grunt/setup'
            link:    command: 'bin/grunt/link'
            compile: command: 'bin/grunt/compile'

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
                'lib/zepto': 'exports': '$'

            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false
            logLevel: 0

    grunt.registerTask 'default', 'shell coffeelint requirejs'
