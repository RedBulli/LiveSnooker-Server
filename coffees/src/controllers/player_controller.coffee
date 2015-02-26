express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

module.exports = ->
  router = express.Router()

  router.get '/players', (request, response) ->
    models.Player.all().then (players) ->
      response.json(players)

  router.post '/players', (request, response) ->
    models.Player.create(request.body).then (player) ->
      response.status(201).json(player)

  router
