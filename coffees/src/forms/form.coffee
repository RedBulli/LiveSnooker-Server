module.exports = class Form
  getValidatedValues: (requestBody) ->
    values = {}
    for key, value of @fields
      values[key] = @getValidatedValue(requestBody, key)
    values

  getValidatedValue: (requestBody, key) ->
    value = requestBody?[key]
    parser = -> value
    for validator in @fields[key]
      validator.validate(value, key)
      if validator.parse
        parser = validator.parse
    parser value
