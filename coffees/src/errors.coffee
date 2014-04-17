class HttpError extends Error
  constructor: (@message) ->

class BadRequest extends HttpError
  statusCode: 400
  constructor: (@message) ->

module.exports.HttpError = HttpError
module.exports.BadRequest = BadRequest
