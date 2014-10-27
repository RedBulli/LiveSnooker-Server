Field = require './field'
ValidationError = require './validation_error'

module.exports = class IntegerValidator extends Field
  defaults: ->
    min: -Infinity
    max: Infinity

  validate: (value, key) ->
    parsedValue = @parse(value)
    if parsedValue?
      if isNaN(parsedValue)
        throw new ValidationError 'Should be an integer', key
      if parsedValue < @options.min || parsedValue > @options.max
        throw new ValidationError(
          'Should be an integer between ' + @options.min + '-' + @options.max,
          key
        )
    parsedValue

  parse: (value) ->
    if value?
      parseInt(value)
    else
      value
