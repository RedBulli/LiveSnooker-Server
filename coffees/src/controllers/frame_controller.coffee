express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

newFrame = (request) ->
  Frame = request.app.get('models').Frame
  Frame.create (data)

validateNewFrame = (request, response, next) ->
  if request.body["Player1Id"] == request.body["Player2Id"]
    response.status(400).json(error: "Player cannot play against self")
    response.end()
  else if request.body["WinnerId"]
    response.status(400).json(error: "Cannot set winner before shots have been played")
    response.end()
  else
    models.Player.count(
      where:
        id: {$in: [request.body["Player1Id"], request.body["Player2Id"]]}
        LeagueId: request.body["LeagueId"]
    ).then (count) ->
      if count != 2
        response.status(400).json(error: "Player(s) do not belong to the given League")
        response.end()
      else
        next()

validateLeaguePrivileges = (request, response, next) ->
  next() # TODO: Check if the user is in the league

module.exports = ->
  router = express.Router()

  router.get '/frames', (request, response) ->
    models.Frame.all().then (frames) ->
      response.json(frames)

  router.post '/frames', validateLeaguePrivileges, validateNewFrame, (request, response) ->
    models.Frame.create(request.body).then (frame) ->
      data =
        event: "frameStart"
        frame: frame.toJSON()
      request.app.get('redisClient').publish("updates", JSON.stringify(data))
      response.status(201).json(frame)

  router.all '/frames/:id/:op?', validateLeaguePrivileges
  router.all '/frames/:id/:op?', (request, response, next) ->
    models.Frame.findOne(
      where: {id: request.params.id},
      include: [
        { model: models.Player, as: 'Player1' },
        { model: models.Player, as: 'Player2' },
        { model: models.League },
        { model: models.Player, as: 'Winner' },
        { model: models.Shot }
      ]
    ).then((frame) ->
      request.frame = frame
      next()
    ).catch( ->
      response.status(400).json(error: 'cannot find user ' + request.params.id)
      response.end()
    )

  router.get '/frames/:id', (request, response) ->
    response.json(request.frame)

  router.delete '/frames/:id', (request, response) ->
    if request.frame.WinnerId
      response.status(400).json(error: "Deleting completed frames is not allowed.")
    else
      request.frame.destroy()
      data =
        event: "frameDelete"
        frame: request.frame.toJSON()
      request.app.get('redisClient').publish("updates", JSON.stringify(data))
      response.status(204)

  router.patch '/frames/:id', (request, response) ->
    if request.frame.WinnerId
      response.status(400).json(error: "Changing the winner is not allowed.")
    else
      winnerId = request.body["WinnerId"]
      if winnerId in [request.frame.Player1Id, request.frame.Player2Id]
        request.frame.set('WinnerId', winnerId)
        request.frame.set('endedAt', new Date())
        request.frame.save()
        data =
          event: "frameEnd"
          frame: request.frame.toJSON()
        request.app.get('redisClient').publish("updates", JSON.stringify(data))
        response.status(200).json(request.frame)
      else
        response.status(400).json(error: "WinnerId is not a player in this frame")
  router
