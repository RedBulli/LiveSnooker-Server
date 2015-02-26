express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

module.exports = ->
  router = express.Router()

  router.get '/leagues', (request, response) ->
    models.League.all().then (leagues) ->
      response.json(leagues)

  router.post '/leagues', (request, response) ->
    models.League.create(request.body).then (league) ->
      response.status(201).json(league)

  router
