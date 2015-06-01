express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

newFrame = (request) ->
  Frame = request.app.get('models').Frame
  Frame.create (data)

module.exports = ->
  router = express.Router()

  router.get '/frames', (request, response) ->
    models.Frame.all().then (frames) ->
      response.json(frames)

  router.get '/frames/:id', (request, response) ->
    models.Frame.find({
      where: {id: request.params.id},
      include: [
        { model: models.Player, as: 'Player1'},
        { model: models.Player, as: 'Player2'},
        { model: models.League }
      ]
    }).then (frame) ->
      response.json(frame)

  router.post '/frames', (request, response) ->
    models.Frame.create(request.body).then (frame) ->
      response.status(201).json(frame)

  router
