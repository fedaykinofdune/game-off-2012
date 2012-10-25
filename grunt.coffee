module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        shell:
            setup:
                command: 'ln -fs ../node_modules/grunt-requirejs/node_modules/requirejs/require.js lib/'

        requirejs:
            ###
            # almond specific contents
            # *insert almond in all your modules
            almond: true
            # *replace require script calls, with the almond modules
            # in the following files
            replaceRequireScript: [
                files: ['build/game.html']
                module: 'main'
            ]
            # "normal" require config
            # *create at least a 'main' module
            # thats necessary for using the almond auto insertion
            ###
            modules: [name: 'game']

            dir: 'build'
            appDir: 'src'
            baseUrl: 'js'
            ###
            paths:
                underscore: '../vendor/underscore'
                jquery    : '../vendor/jquery'
                backbone  : '../vendor/backbone'
            ###

            # skipModuleInsertion: false
            # optimizeAllPluginResources: true
            # findNestedDependencies: true
            preserveLicenseComments: false

    grunt.registerTask 'default', 'shell requirejs'
