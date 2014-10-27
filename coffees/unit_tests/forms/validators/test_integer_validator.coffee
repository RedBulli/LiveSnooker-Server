expect = require('chai').expect
IntegerValidator = rootRequire 'forms/validators/integer_validator'
ValidationError = rootRequire 'forms/validators/validation_error'

describe 'IntegerValidator', ->
  intValidator = null
  beforeEach ->
    intValidator = new IntegerValidator()

  it 'returns integers or null', ->
    expect(intValidator.validate(-2929.9)).to.equal -2929
    expect(intValidator.validate(0)).to.equal 0
    expect(intValidator.validate(412414.5)).to.equal 412414
    expect(intValidator.validate('100')).to.equal 100
    expect(intValidator.validate(null)).to.equal null

  it 'throws ValidationError if the value is NaN', ->
    expect(-> intValidator.validate('')).to.throw ValidationError
    expect(-> intValidator.validate('f')).to.throw ValidationError
