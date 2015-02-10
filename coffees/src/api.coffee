ActionForm = require('./forms/action_form')
FrameController = require('./controllers/frame_controller')
JWT = require('jsonwebtoken')
request = require('request')
authMiddleware = require './authentication_middleware'
express = require('express')

parseGoogleToken = (token, callback) ->
  request('https://www.googleapis.com/oauth2/v2/tokeninfo?id_token=' + token, (error, response, body) ->
    if (!error && response.statusCode == 200)
      callback(null, JSON.parse(body))
    else
      callback("ERROR!")
  )
  # TODO: cache the certs and do decode the JWT more efficiently
  # JSON.parse(JWT.verify(token, cert))

module.exports = ->
  router = express.Router()
  actionForm = new ActionForm()
  frameController = new FrameController()

  router.post '/action', (request, response) ->
    action = actionForm.getPopulatedModel request.body
    frameController.act action, ->
      # TODO get errors from the callback
      response.sendStatus 204

  router.get '/account', authMiddleware.requireAuth, (request, response) ->
    response.json({ user: request.user });
  router
