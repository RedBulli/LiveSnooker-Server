errors = require './errors'

module.exports = (app) ->
  app.post '/pot', (request, response) ->
    ball_value = request.handler.requireInt 'ball_value'
    if ball_value < 1 or ball_value > 7
      throw new errors.BadRequest {
        ball_value: 'Should be an integer between 1-7'
      }
    response.send 204

  app.post '/missed_pot', (request, response) ->
    response.send 204

  app.post '/safety', (request, response) ->
    response.send 204
