validators = require './validators'
errors = require './errors'

class Form
  constructor: (@request) ->
    @values = {}
  validate: () ->
    try
      for key, value of @fields
        @validateKey(key)
    catch err
      if err instanceof validators.ValidationError
        message = {}
        message[key] = err.message
        throw new errors.BadRequest message
      else
        throw err

  validateKey: (key) ->
    for validator in @fields[key]
      value = @request.body[key]
      validator.validate(value)
      if validator.parser
        value = validator.parser value
      @values[key] = value

class PotForm extends Form
  fields: {
    ball_value: [
      new validators.Required,
      new validators.Integer({min: 1, max: 7}),
    ],
  }

class SafetyForm extends Form
  fields: {
    pot: [new validators.Integer({min: 1, max: 7})],
  }

module.exports = {
  PotForm: PotForm,
  SafetyForm: SafetyForm,
}
