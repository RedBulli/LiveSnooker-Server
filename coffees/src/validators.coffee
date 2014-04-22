getProperty = (options, key, default_value) ->
  if options.hasOwnProperty(key)
    return options[key]
  else
    return default_value

class ValidationError extends Error
  constructor: (@message) ->

class Required
  validate: (value) ->
    if (value == undefined || value == null)
      throw new ValidationError 'Required parameter'

class Integer
  constructor: (options) ->
    @min = getProperty(options, 'min', -Infinity)
    @max = getProperty(options, 'max', Infinity)

  validate: (value) ->
    if isNaN(value)
      throw new ValidationError 'Should be an integer'
    if value < @min || value > @max
      throw new ValidationError(
        'Should be an integer between ' + @min + '-' + @max
      )

  parser: (value) ->
    return parseInt(value)

module.exports = {
  ValidationError: ValidationError,
  Integer: Integer,
  Required: Required,
}
