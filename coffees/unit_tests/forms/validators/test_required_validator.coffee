expect = require('chai').expect
RequiredValidator = rootRequire 'forms/validators/required_validator'
ValidationError = rootRequire 'forms/validators/validation_error'

describe 'RequiredValidator', ->
  requiredValidator = null
  beforeEach ->
    requiredValidator = new RequiredValidator()

  it 'returns integers or null', ->
    expect(requiredValidator.validate("")).to.equal ""
    expect(requiredValidator.validate(0)).to.equal 0
    expect(requiredValidator.validate(412414.5)).to.equal 412414.5

  it 'throws ValidationError if the value is null or undefined', ->
    expect(-> requiredValidator.validate(null)).to.throw ValidationError
    expect(-> requiredValidator.validate(undefined)).to.throw ValidationError
