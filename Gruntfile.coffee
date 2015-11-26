module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)
  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    notify:
      specs_passed:
        options:
          message: 'Tests passed!'

    coffee:
      build:
        options:
          bare: true
        files: [
          {
            expand: true
            cwd: 'app'
            src: ['**/*.coffee']
            dest: 'build'
            ext: '.js'
          }
        ]
      tmp:
        options:
          bare: true
        files: [
          {
            expand: true
            cwd: 'app'
            src: ['**/*.coffee']
            dest: 'tmp'
            ext: '.js'
          }
        ]

    mochaTest:
      test:
        src: ['spec/**/*.coffee']
        options:
          reporter: 'spec'
          require: [
            'coffee-script/register'
            ->
              global.rootRequire = (name) ->
                require(__dirname + '/tmp/src/' + name)
            ->
              global.appInit = rootRequire('./application').initApplication()
          ]
          timeout: 10000

    watch:
      build:
        files: 'app/**/*.coffee'
        tasks: ['clean', 'coffee']
      spec:
        files: ['app/**/*.coffee', 'spec/**/*.coffee']
        tasks: ['test']

    clean:
      build:
        src: ['build/**/*.js']
      tmp:
        src: ['tmp/**/*.js']

    nodemon:
      server:
        script: 'build/server.js'
      options:
        watch: ["build/server.js"]

    concurrent:
      serve: ['nodemon:server', 'watch:build']
      options:
        logConcurrentOutput: true

    execute:
      server:
        src: ['build/server.js']

    env:
      dev:
        src: 'environments/development.env'
      test:
        src: 'environments/test.env'
      production:
        src: 'environments/production.env'

    copy:
      ci:
        files: [
          {src: ['config/config.json.sample'], dest: 'config/config.json'}
        ]

  grunt.registerTask 'compile', (target) ->
    if target == 'test'
      grunt.task.run ['clean:tmp', 'coffee:tmp']
    else
      grunt.task.run ['clean:build', 'coffee']

  grunt.registerTask('cleanjs', ['clean:build'])

  grunt.registerTask 'test',
    ['env:test', 'compile:test', 'mochaTest:test', 'notify:specs_passed']

  grunt.registerTask 'tdd',
    ['watch:spec']

  grunt.registerTask 'serve', (target) ->
    if target == 'production'
      grunt.task.run(['env:production', 'coffee', 'execute:server'])
    else
      grunt.task.run(['env:dev', 'coffee', 'concurrent:serve'])

  # Default task(s).
  grunt.registerTask('default', ['coffee', 'test', 'serve'])
