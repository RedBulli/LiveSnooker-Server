errors = require './errors'

module.exports = (app) ->
  app.post '/pot', (request, response) ->
    ball_value = request.handler.requireInt 'ball_value'
    response.send 204
