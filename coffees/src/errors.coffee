class HttpError extends Error
  constructor: (message) ->
    @message = {error: message}
  toString: () ->
    return 'HttpError ' + @statusCode

class BadRequest extends HttpError
  statusCode: 400

module.exports = 
  HttpError: HttpError
  BadRequest: BadRequest
