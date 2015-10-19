express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'
Sequelize = require 'sequelize'

module.exports = ->
  router = express.Router()

  leagueIncludes = [
    { model: models.Player, required: false },
    { model: models.Admin, required: false, include: [
      { model: models.User, required: false }
    ]},
    { model: models.Frame, required: false, include: [
      { model: models.Player, as: 'Player1', required: false },
      { model: models.Player, as: 'Player2', required: false },
      { model: models.Player, as: 'Winner', required: false },
      { model: models.League, required: false }
    ]}
  ]

  findLeague = (leagueId) ->
    models.League.find
      where: { id: leagueId }
      include: leagueIncludes

  router.get '/leagues', authMiddleware.requireAuth, (request, response) ->
    request.user.getLeagues(include: leagueIncludes).then (leagues) ->
      response.json(leagues)

  router.post '/leagues', (request, response) ->
    models.sequelize.transaction(->
      models.League.create(request.body).then (league) ->
        models.Admin.create
          UserEmail: request.user.email
          LeagueId: league.id
          write: true
    )
    .then (admin) ->
      findLeague(admin.LeagueId).then (league) -> response.status(201).json(league)
    .catch (error) ->
      console.error error
      if error.name == "SequelizeValidationError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)

  router.all '/leagues/:id/:op?', (req, resp, next) -> authMiddleware.validateLeagueAuth(req.params.id, req, resp, next)

  router.get '/leagues/:id', (request, response) ->
    findLeague(request.params.id)
      .then (league) -> response.json(league)
      .catch (error) -> response.status(500).json(error: error)

  router.get '/leagues/:id/frames', (request, response) ->
    models.Frame.findAll({
      where: {LeagueId: request.params.id},
      include: [
        { model: models.Player, as: 'Player1', required: false },
        { model: models.Player, as: 'Player2', required: false },
        { model: models.League, required: false },
        { model: models.Player, as: 'Winner', required: false },
        { model: models.Shot, required: false }
      ]
    })
      .then (frames) -> response.json(frames)
      .catch (error) -> response.status(500).json(error: error)

  router.post '/leagues/:id/admins', (request, response) ->
    models.Admin.create(request.body)
      .then (admin) -> response.status(201).json(admin)
      .catch (error) -> response.status(500).json(error: error)

  router.delete '/leagues/:id/admins/:adminId', (request, response) ->
    models.Admin.destroy(where: {
      LeagueId: request.params.id
      id: request.params.adminId
    })
      .then -> response.status(204).json("")
      .catch (error) -> response.status(500).json(error: error)

  router
