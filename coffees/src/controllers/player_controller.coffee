express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

module.exports = ->
  router = express.Router()

  router.get '/players', (request, response) ->
    models.Player.all().then (players) ->
      response.json(players)

  router.post '/players', (request, response) ->
    models.Player.create(request.body).then((player) ->
      response.status(201).json(player)
    ).catch((error) ->
      if error.name == "SequelizeValidationError" || error.name == "SequelizeUniqueConstraintError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)
    )

  router
