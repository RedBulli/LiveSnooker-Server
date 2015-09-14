express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

newShot = (request) ->
  Shot = request.app.get('models').Shot
  Shot.create (data)

validateShotNumber = (request, response, next) ->
  models.Shot.max('shotNumber', { where: {FrameId: request.body['FrameId']} }).then (max) ->
    nextShotNumber = parseInt(max) + 1
    if parseInt(request.body['shotNumber']) != nextShotNumber
      response.status(400).json(error: 'next shotNumber should be ' + nextShotNumber)
      response.end()
    else
      next()

module.exports = ->
  router = express.Router()

  router.get '/shots', (request, response) ->
    models.Shot.all().then (shots) ->
      response.json(shots)

  router.get '/shots/:id', (request, response) ->
    models.Shot.find({
      where: {id: request.params.id},
      include: [
        { model: models.Player },
        { model: models.League }
      ]
    }).then (shot) ->
      response.json(shot)

  router.post '/shots', validateShotNumber, (request, response) ->
    models.Shot.create(request.body).then (shot) ->
      data =
        event: "newShot"
        shot: shot.toJSON()
      request.app.get('redisClient').publish("updates", JSON.stringify(data));
      response.status(201).json(shot)
    .catch((error) ->
      if error.name == "SequelizeValidationError" || error.name == "SequelizeUniqueConstraintError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)
    )

  router.delete '/shots/:id', (request, response) ->
    models.Shot.destroy({
      where: {id: request.params.id},
    }).then (shot) ->
      response.status(204).json("")

  router
