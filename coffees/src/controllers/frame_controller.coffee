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
        { model: models.Player, as: 'Player1' },
        { model: models.Player, as: 'Player2' },
        { model: models.League },
        { model: models.Player, as: 'Winner' },
        { model: models.Shot }
      ]
    }).then (frame) ->
      response.json(frame)

  checkAuthorizationToModifyFrame = (user, frame) ->
    true # TODO implement this

  router.post '/frames', (request, response) ->
    models.Frame.create(request.body).then (frame) ->
      response.status(201).json(frame)

  router.delete '/frames/:id', (request, response) ->
    models.Frame.findOne({where: {id: request.params.id}}).then (frame) ->
      if frame.WinnerId
        response.status(400).json(error: "Deleting completed frames is not allowed.")
      else
        frame.destroy()
        response.status(204)

  router.patch '/frames/:id', (request, response) ->
    models.Frame.findOne({where: {id: request.params.id}}).then (frame) ->
      if frame.WinnerId
        response.status(400).json(error: "Changing the winner is not allowed.")
      else
        winnerId = request.body["WinnerId"]
        if winnerId in [frame.Player1Id, frame.Player2Id]
          frame.set('WinnerId', winnerId)
          frame.set('endedAt', new Date())
          frame.save()
          data =
            event: "frameEnd"
            frame: frame.toJSON()
          request.app.get('redisClient').publish("updates", JSON.stringify(data));
          response.status(200).json(frame)
        else
          response.status(400).json(error: "WinnerId is not a player in this frame")
  router
