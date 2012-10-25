module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'

    grunt.initConfig
        requirejs:
            std:
                # almond specific contents
                # *insert almond in all your modules
                almond: true
                # *replace require script calls, with the almond modules
                # in the following files
                replaceRequireScript: [
                    files: ['build/index.html']
                    module: 'main'
                ]
                # "normal" require config
                # *create at least a 'main' module
                # thats necessary for using the almond auto insertion
                modules: [name: 'main']

                dir: 'build'
                appDir: 'src'
                baseUrl: 'js'
                ###
                paths:
                    underscore: '../vendor/underscore'
                    jquery    : '../vendor/jquery'
                    backbone  : '../vendor/backbone'
                ###

                pragmas:
                    doExclude: true

                skipModuleInsertion: false,
                optimizeAllPluginResources: true,
                findNestedDependencies: true

    grunt.registerTask 'default', 'requirejs'
