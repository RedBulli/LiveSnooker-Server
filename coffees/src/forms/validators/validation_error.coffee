module.exports = class ValidationError extends Error
  constructor: (message, key) ->
    if key
      @message = {}
      @message[key] = message
    else
      @message = message
