module.exports = class Form
  getValidatedValues: (requestBody) ->
    values = if @parentForm
      @parentForm.getValidatedValues(requestBody)
    else
      {}
    for key, validators of @fields
      values[key] = @getValidatedValue(requestBody, key, validators)
    values

  getValidatedValue: (requestBody, key) ->
    value = requestBody?[key]
    parser = -> value
    for validator in @fields[key]
      validator.validate(value, key)
      if validator.parse
        parser = validator.parse
    parser value
