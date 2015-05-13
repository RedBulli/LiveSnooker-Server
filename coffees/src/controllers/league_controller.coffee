express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

module.exports = ->
  router = express.Router()

  router.get '/leagues', (request, response) ->
    models.League.all({
      include: [
        { model: models.Player },
        { model: models.User, as: 'Admins' }
      ]
    }).then (leagues) ->
      response.json(leagues)

  router.get '/leagues/:id', (request, response) ->
    models.League.find({
      where: {id: request.params.id},
      include: [
        { model: models.Player },
        { model: models.User, as: 'Admins' }
      ]
    }).then((league) ->
      response.json(league)
    ).catch((error) ->
      response.status(500).json(error: error)
    )

  router.post '/leagues', (request, response) ->
    models.League.create(request.body).then((league) ->
      response.status(201).json(league)
    ).catch((error) ->
      if error.name == "SequelizeValidationError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)
    )

  router
