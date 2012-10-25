module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-requirejs'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.initConfig

        shell:
            link:
                command: 'ln -fs ../node_modules/grunt-requirejs/node_modules/requirejs/require.js lib/ && \ 
                    ln -fs ../src/lib/threejs/build/three.js lib/'
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

            fileExclusionRegExp: /^threejs$/
            skipModuleInsertion: false
            optimizeAllPluginResources: true
            findNestedDependencies: true
            preserveLicenseComments: false

    grunt.registerTask 'default', 'shell requirejs'
