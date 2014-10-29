Field = require './field'
ValidationError = require './validation_error'

module.exports = class StringValidator extends Field
  defaults: ->
    minLength: 0
    maxLength: 4000

  validate: (value, key) ->
    parsedValue = @parse(value)
    if parsedValue?
      if parsedValue.length < @options.minLength
        throw new ValidationError(
          'Length should be at least ' + @options.min + ' characters',
          key
        )
      if parsedValue.length > @options.maxLength
        throw new ValidationError(
          'Length should be at maximum ' + @options.max + ' characters',
          key
        )
    parsedValue

  parse: (value) ->
    if value?
      value.toString()
    else
      value
