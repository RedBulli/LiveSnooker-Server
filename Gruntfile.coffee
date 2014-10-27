module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    notify:
      unit_tests:
        options:
          message: 'Unit tests passed!'
      all_tests:
        options:
          message: 'All tests passed!'
      integration_tests:
        options:
          message: 'Integration tests passed!'

    coffee:
      config:
        options:
          bare: true
        files: [
          {
            expand: true
            cwd: 'coffees'
            src: ['**/*.coffee']
            dest: 'build'
            ext: '.js'
          }
        ]

    mochaTest:
      options:
        reporter: 'spec'
        require:
          ->
            global.rootRequire = (name) ->
              require(__dirname + '/build/src/' + name)
      unit:
        src: ['build/unit_tests/**/*.js']
      integration:
        src: ['build/integration_tests/**/*.js']

    watch:
      coffee:
        files: 'coffees/**/*.coffee'
        tasks: ['clean', 'coffee', 'test:unit']

    clean:
      js:
        src: ['build/**/*.js']

    nodemon:
      server:
        script: 'build/server.js'

    concurrent:
      serve: ['nodemon:server', 'watch']
      options:
        logConcurrentOutput: true

  grunt.registerTask('compile', ['clean:js', 'coffee'])
  grunt.registerTask('cleanjs', ['clean:js'])

  grunt.registerTask 'test',
    ['test:unit', 'test:integration', 'notify:all_tests']

  grunt.registerTask 'test:unit',
    ['compile', 'mochaTest:unit', 'notify:unit_tests']
    
  grunt.registerTask 'test:integration',
    ['compile', 'mochaTest:integration', 'notify:integration_tests']
  # Default task(s).
  grunt.registerTask('default', ['coffee', 'test:unit', 'concurrent:serve'])