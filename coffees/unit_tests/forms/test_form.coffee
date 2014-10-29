expect = require('chai').expect
Form = rootRequire 'forms/form'
ValidationError = rootRequire('forms/validators/validation_error')

describe 'Form', ->
  succeedingValidator = validate: ->
  failingValidator = validate: -> throw new ValidationError()

  it 'populates the values attribute from field validations', ->
    form = new Form()
    form.fields =
      first: [succeedingValidator]
      second: [succeedingValidator]

    requestBody =
      first: 1
      second: "test"
      third: "this is not a field and shouldn't be populated"

    expect(form.getValidatedValues(requestBody)).to.eql
      first: 1
      second: "test"

  it 'throws an error if any of the validators fail', ->
    form = new Form()
    requestBody =
      first: 1
      second: "test"
    form.fields =
      first: [succeedingValidator]
      second: [failingValidator]
    
    expect(-> form.getValidatedValues(requestBody)).to.throw ValidationError

  it 'if one validator has a parse function, it is used', ->
    form = new Form()
    requestBody =
      integer: "1"
    form.fields =
      integer: [
        {
          validate: ->
          parse: (value) -> parseInt(value)
        },
        { validate: -> }
      ]
    expect(form.getValidatedValues(requestBody)).to.eql integer: 1
