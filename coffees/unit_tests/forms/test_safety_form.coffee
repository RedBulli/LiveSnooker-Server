expect = require('chai').expect
SafetyForm = rootRequire 'forms/safety_form'
ValidationError = rootRequire('forms/validators/validation_error')

describe 'SafetyForm', ->
  form = null

  beforeEach ->
    form = new SafetyForm()

  describe 'parameter: pot', ->
    it 'accepts integers from 1-7', ->
      expect(form.getValidatedValues(pot: 1)).to.eql(pot: 1)
      expect(form.getValidatedValues(pot: 7)).to.eql(pot: 7)

    it 'is not required', ->
      expect(form.getValidatedValues(pot: null)).to.eql(pot: null)
      expect(form.getValidatedValues()).to.eql(pot: undefined)

    it 'throws a ValidationError if it off limits', ->
      expect(-> form.getValidatedValues(pot: 0)).to.throw ValidationError
      expect(-> form.getValidatedValues(pot: 8)).to.throw ValidationError
