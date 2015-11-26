express = require 'express'
models  = require '../../models'
authMiddleware = require '../middleware/authentication'

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
    validatePlayersBelongToLeague request, response, () ->
      validatePlayersDontHaveUnfinishedFrames request, response, next

validatePlayersDontHaveUnfinishedFrames = (request, response, next) ->
  playersIds = [request.body["Player1Id"], request.body["Player2Id"]]
  models.Frame.count(
    where:
      WinnerId: null
      $or: [
        { Player1Id: { $in: playersIds } },
        { Player2Id: { $in: playersIds } }
      ]
  ).then (count) ->
    if count != 0
      response.status(400).json(error: "Players cannot have incomplete frames when creating a new frame")
      response.end()
    else
      next()

validatePlayersBelongToLeague = (request, response, next) ->
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

FrameScope = (request) ->
  models.Frame.scope({ method: ['inLeague', request.league.id]})

module.exports = ->
  router = express.Router()

  router.get '/', (request, response) ->
    FrameScope(request).findAll().then (frames) ->
      response.json(frames)

  router.post '/', validateLeaguePrivileges, validateNewFrame, (request, response) ->
    frameData =
      LeagueId: request.league.id
      Player1Id: request.body["Player1Id"]
      Player2Id: request.body["Player2Id"]

    models.Frame.create(frameData).then (frame) ->
      data =
        event: "frameStart"
        frame: frame.toJSON()
      request.app.get('redisClient').publish(frame.LeagueId, JSON.stringify(data))
      response.status(201).json(frame)

  router.all '/:frameId/:op?', (request, response, next) ->
    FrameScope(request).findOne(
      where: {id: request.params.frameId},
      include: [
        { model: models.Player, as: 'Winner', required: false },
        { model: models.Player, as: 'Player1', required: false },
        { model: models.Player, as: 'Player2', required: false },
        { model: models.League, required: false },
        { model: models.Shot, required: false }
      ]
    ).then((frame) ->
      request.frame = frame
      next()
    ).catch( ->
      response.status(400).json(error: 'cannot find user ' + request.params.frameId)
      response.end()
    )

  router.get '/:frameId', (request, response) ->
    response.json(request.frame)

  router.delete '/:frameId', (request, response) ->
    if request.frame.WinnerId
      response.status(400).json(error: "Deleting completed frames is not allowed.")
    else
      request.frame.destroy()
      data =
        event: "frameDelete"
        frame: request.frame.toJSON()
      request.app.get('redisClient').publish(request.frame.LeagueId, JSON.stringify(data))
      response.status(204).json("")

  router.patch '/:frameId', (request, response) ->
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
        request.app.get('redisClient').publish(request.frame.LeagueId, JSON.stringify(data))
        response.status(200).json(request.frame)
      else
        response.status(400).json(error: "WinnerId is not a player in this frame")

  router.patch '/:frameId/playerchange', (request, response) ->
    playerId = request.body.currentPlayer.id
    if playerId == request.frame.get('Player1Id') || playerId == request.frame.get('Player2Id')
      data =
        event: "changePlayer"
        frame: request.frame.toJSON()
        playerId: playerId
      request.app.get('redisClient').publish(request.frame.get('id'), JSON.stringify(data))
      response.status(200).json(request.frame)
    else
      response.status(400).json(error: "Player must be in the frame")

  router.use('/:frameId/shots', require('./shot_controller')())

  router
