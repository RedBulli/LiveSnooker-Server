errors = require './errors'

module.exports = (request, response, next) ->
  throwParameterError = (parameter, message) ->
      content = {error: {}}
      content.error[parameter] = message
      throw new errors.BadRequest(content)

  requireParameter = (parameter) ->
    if parameter of request.body
      return request.body[parameter]
    else
      throwParameterError parameter, 'Required parameter'

  requireInt = (parameter) ->
    value = requireParameter(parameter)
    if isNaN value
      throwParameterError parameter, 'Should be an integer'
    else
      return value

  request.handler = {
    requireParameter: requireParameter,
    requireInt: requireInt
  }
  next()
