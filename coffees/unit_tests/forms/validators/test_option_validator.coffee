expect = require('chai').expect
OptionValidator = rootRequire 'forms/validators/option_validator'
ValidationError = rootRequire 'forms/validators/validation_error'

describe 'OptionValidator', ->
  optionValidator = null
  beforeEach ->
    optionValidator = new OptionValidator(["first", 2, "third"])

  it 'validates if the value is found in the list', ->
    expect(optionValidator.validate("first")).to.equal "first"
    expect(optionValidator.validate(2)).to.equal 2
    expect(optionValidator.validate("third")).to.equal "third"

  it 'throws ValidationError if the value is not in the list', ->
    expect(-> optionValidator.validate(1)).to.throw ValidationError
    expect(-> optionValidator.validate("three")).to.throw ValidationError

  it 'throws ValidationError if the value is null or undefined', ->
    expect(-> optionValidator.validate(null)).to.throw ValidationError
    expect(-> optionValidator.validate(undefined)).to.throw ValidationError
