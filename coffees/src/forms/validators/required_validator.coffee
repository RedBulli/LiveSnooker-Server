Field = require './field'
ValidationError = require './validation_error'

module.exports = class RequiredValidator extends Field
  validate: (value, key) ->
    if value == undefined || value == null
      throw new ValidationError 'Required parameter', key
    value
