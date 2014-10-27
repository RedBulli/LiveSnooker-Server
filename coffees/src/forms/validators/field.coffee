_ = require('underscore')

module.exports = class Field
  constructor: (options = {}) ->
    @options = _.defaults(options, @defaults?())
