expect = require('chai').expect
PotForm = rootRequire 'forms/pot_form'
ValidationError = rootRequire('forms/validators/validation_error')

describe 'PotForm', ->
  form = null

  beforeEach ->
    form = new PotForm()

  describe 'parameter: ball_value', ->
    it 'accepts integers from 1-7', ->
      expect(form.getValidatedValues(ball_value: 1)).to.eql(ball_value: 1)
      expect(form.getValidatedValues(ball_value: 7)).to.eql(ball_value: 7)

    it 'throws a ValidationError if it is not given', ->
      expect(-> form.getValidatedValues(ball_value: null))
        .to.throw ValidationError
      expect(-> form.getValidatedValues()).to.throw ValidationError

    it 'throws a ValidationError if it off limits', ->
      expect(-> form.getValidatedValues(ball_value: 0))
        .to.throw ValidationError
      expect(-> form.getValidatedValues(ball_value: 8))
        .to.throw ValidationError
