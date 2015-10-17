express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'

module.exports = ->
  router = express.Router()

  playerIncludes = [{ model: models.League }]

  router.get '/players', (request, response) ->
    models.Player.all(include: playerIncludes).then (players) ->
      response.json(players)

  router.post '/players', (request, response) ->
    models.Player.create(request.body).then((player) ->
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

  router.all '/players/:id/:op?', (request, response, next) ->
    models.Player.findOne(
      where: {id: request.params.id}
    ).then((player) ->
      request.player = player
      next()
    ).catch( ->
      response.status(400).json(error: 'cannot find player ' + request.params.id)
      response.end()
    )

  router.delete '/players/:id', (request, response) ->
    request.player.set("deleted", true)
    request.player.save()
    data =
      event: "playerDelete"
      player: request.player.toJSON()
    request.app.get('redisClient').publish(request.player.LeagueId, JSON.stringify(data))
    response.status(204).json("")

  router.put '/players/:id', (request, response) ->
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
