Field = require './field'
ValidationError = require './validation_error'

module.exports = class OptionValidator extends Field
  validate: (value, key) ->
    if value not in @options
      throw new ValidationError(
        'Should be one of the following: ' + @options.toString(),
        key
      )
    else
      value
