errors = require './errors'

module.exports = (request, response, next) ->
  createParamObject = (parameter, message) ->
      content = {}
      content[parameter] = message
      return content

  requireParameter = (parameter) ->
    if parameter of request.body
      return request.body[parameter]
    else
      throw new errors.BadRequest createParamObject(
        parameter, 'Required parameter'
      )

  requireInt = (parameter) ->
    value = requireParameter parameter
    if not isNaN value
      return value
    else
      throw new errors.BadRequest createParamObject(
        parameter, 'Should be an integer'
      )

  request.handler = {
    requireParameter: requireParameter,
    requireInt: requireInt
  }
  next()
