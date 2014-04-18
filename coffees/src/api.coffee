errors = require './errors'

module.exports = (app) ->
  app.post '/pot', (request, response) ->
    try
      ball_value = request.handler.requireInt 'ball_value'
      response.send 204
    catch error
      if error instanceof errors.HttpError
        response.send error.statusCode, error.message
      else
        throw error
