validators = require './validators'
Form = require './form'

module.exports = class PotForm extends Form
  fields:
    ball_value: [
      new validators.RequiredValidator,
      new validators.IntegerValidator({min: 1, max: 7})
    ]
