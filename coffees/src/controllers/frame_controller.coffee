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
      for frame in frames
        console.log frame
         # console.log "players", players
      response.json(frames)

  router.post '/frames', (request, response) ->
    models.Frame.create(request.body).then (frame) ->
      response.status(201).json(frame)

  router
