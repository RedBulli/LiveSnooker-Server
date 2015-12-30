express = require 'express'
models  = require '../../models'
authMiddleware = require '../middleware/authentication'

module.exports = ->
  router = express.Router()

  playerIncludes = [{ model: models.League }]

  PlayersScope = (request) ->
    models.Player.scope({ method: ['inLeague', request.league.id]})

  router.get '/', (request, response) ->
    PlayersScope(request).findAll(include: playerIncludes).then (players) ->
      response.json(players)

  router.post '/', (request, response) ->
    playerData =
      LeagueId: request.league.id
      name: request.body["name"]

    if request.body["id"]
      playerData.id = request.body["id"]

    models.Player.create(playerData).then((player) ->
      data =
        event: "newPlayer"
        player: player.toJSON()
      request.app.get('redisClient').publish(player.LeagueId, JSON.stringify(data))
      player.reload(include: playerIncludes).then (pl) ->
        response.status(201).json(pl)
    ).catch((error) ->
      if error.name == "SequelizeValidationError" || error.name == "SequelizeUniqueConstraintError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)
    )

  router.all '/:id*', (request, response, next) ->
    PlayersScope(request).findOne(
      where: {id: request.params.id}
    ).then((player) ->
      request.player = player
      next()
    ).catch( ->
      response.status(400).json(error: 'cannot find player ' + request.params.id)
    )

  router.get '/:id', (request, response) ->
    response.json(request.player)

  router.delete '/:id', (request, response) ->
    request.player.set("deleted", true)
    request.player.save()
    data =
      event: "playerDelete"
      player: request.player.toJSON()
    request.app.get('redisClient').publish(request.player.LeagueId, JSON.stringify(data))
    response.status(204).json("")

  router.put '/:id', (request, response) ->
    request.player.set("name", request.body["name"]);
    request.player.save(
    ).then( ->
      data =
        event: "playerUpdate"
        player: request.player.toJSON()
      request.app.get('redisClient').publish(request.player.LeagueId, JSON.stringify(data))
      response.status(200).json("")
    ).catch (error) ->
      if error.name == "SequelizeValidationError" || error.name == "SequelizeUniqueConstraintError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)

  router
