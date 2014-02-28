module.exports = function(grunt) {
  require('load-grunt-tasks')(grunt);
  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    notify: {
      unit_tests: {
        options: {
          message: 'Unit tests passed!'
        }
      },
    },
    coffee: {
      compile: {
        files: [{
          expand: true,
          cwd: 'coffees/',
          src: '{,*/}*.coffee',
          dest: 'build',
          ext: '.js'
        }]
      },
    },
    mochaTest: {
      options: {
        reporter: 'spec'
      },
      unit: {
        src: ['build/unit_tests/**/*.js']
      },
      integration: {
        src: ['build/integration_tests/**/*.js']
      }
    },
    watch: {
      coffee: {
        files: 'coffees/**/*.coffee',
        tasks: ['coffee', 'mochaTest', 'notify:unit_tests']
      }
    },
    clean: {
      js: {
        src: ['build/**/*.js']
      }
    }
  });

  grunt.registerTask('recompile', ['clean:js', 'coffee']);
  grunt.registerTask('cleanjs', ['clean:js']);

  grunt.registerTask('test', ['test:unit', 'test:integration']);
  grunt.registerTask('test:unit', ['coffee', 'mochaTest:unit', 'notify:unit_tests']);
  grunt.registerTask('test:integration', ['coffee', 'mochaTest:integration', 'notify:unit_tests']);

  // Default task(s).
  grunt.registerTask('default', ['coffee', 'watch']);
  grunt.registerTask('test', ['coffee', 'mochaTest']);

};
