BadRequest = require('./../../errors').BadRequest

module.exports = class ValidationError extends BadRequest
  constructor: (message, key) ->
    validationMessage = message
    if key
      validationMessage = {}
      validationMessage[key] = message
    super(validationMessage)
