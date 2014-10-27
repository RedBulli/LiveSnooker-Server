validators = require './validators'
Form = require './form'

module.exports = class SafetyForm extends Form
  fields:
    pot: [new validators.IntegerValidator({min: 1, max: 7})]
