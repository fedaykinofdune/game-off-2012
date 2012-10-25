module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        shell:
            setup:
                command: 'ln -fs ../node_modules/grunt-requirejs/node_modules/requirejs/require.js lib/'
            compile:
                command: "coffee -c $(find src/js/ -name '*.coffee')"

        requirejs:
            almond: true

            modules: [name: 'game']
            dir: 'build'
            appDir: 'src'
            baseUrl: 'js'

            paths: {}
            ###
            paths:
                underscore: '../vendor/underscore'
                jquery    : '../vendor/jquery'
                backbone  : '../vendor/backbone'
            ###

            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false

    grunt.registerTask 'default', 'shell requirejs'
