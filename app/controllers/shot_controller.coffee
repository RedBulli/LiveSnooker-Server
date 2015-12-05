express = require 'express'
models  = require '../../models'
authMiddleware = require '../middleware/authentication'

newShot = (request) ->
  Shot = request.app.get('models').Shot
  Shot.create (data)

validateShotNumber = (request, response, next) ->
  models.Shot.max('shotNumber', { where: {FrameId: request.body['FrameId']} }).then (max) ->
    if isNaN(max) && parseInt(request.body['shotNumber']) == 1
      next()
    else
      nextShotNumber = parseInt(max) + 1
      if parseInt(request.body['shotNumber']) != nextShotNumber
        response.status(400).json(error: 'next shotNumber should be ' + nextShotNumber)
      else
        next()

ShotScope = (request) ->
  models.Shot.scope({ method: ['inFrame', request.frame.id]})

module.exports = ->
  router = express.Router()

  router.get '/', (request, response) ->
    ShotScope(request).findAll().then (shots) ->
      response.json(shots)

  router.post '/', validateShotNumber, (request, response) ->
    shotData =
      FrameId: request.frame.id
      PlayerId: request.body["PlayerId"]
      attempt: request.body["attempt"]
      points: request.body["points"]
      result: request.body["result"]
      shotNumber: request.body["shotNumber"]

    models.Shot.create(shotData).then (shot) ->
      data =
        event: "newShot"
        shot: shot.toJSON()
      request.app.get('redisClient').publish(shot.FrameId, JSON.stringify(data));
      response.status(201).json(shot)
    .catch (error) ->
      if error.name == "SequelizeValidationError" || error.name == "SequelizeUniqueConstraintError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)

  router.get '/:id', (request, response) ->
    models.Shot.find({
      where: {id: request.params.id},
      include: [
        { model: models.Player },
        { model: models.League }
      ]
    }).then (shot) ->
      response.json(shot)

  router.delete '/:id', (request, response) ->
    models.Shot.findOne({
      where: {id: request.params.id},
    }).then (shot) ->
      models.Shot.max('shotNumber', { where: {FrameId: shot.FrameId} }).then (max) ->
        if shot.shotNumber == max
          shot.destroy().then ->
            data =
              event: "deleteShot"
              shot: shot.toJSON()
            request.app.get('redisClient').publish(shot.FrameId, JSON.stringify(data))
            response.status(204).json("")
        else
          response.status(400).json(error: "you can only delete the last shot in the frame")

  router
