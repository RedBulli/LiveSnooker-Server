class HttpError extends Error
  constructor: (@message) ->
  toString: () ->
    return 'HttpError ' + @statusCode

class BadRequest extends HttpError
  statusCode: 400
  constructor: (@message) ->

module.exports.HttpError = HttpError
module.exports.BadRequest = BadRequest
