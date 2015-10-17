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

  router.get '/leagues', (request, response) ->
    models.League.findAll(
      include: [
        { model: models.Player, required: false },
        {
          model: models.Admin,
          required: true,
          include: [
            { model: models.User, required: false }
          ],
          where: { UserId: request.user.id }
        },
        { model: models.Frame, required: false, include: [
          { model: models.Player, as: 'Player1', required: false },
          { model: models.Player, as: 'Player2', required: false },
          { model: models.Player, as: 'Winner', required: false },
          { model: models.League, required: false }
        ]}
      ]
    )
    request.user.getLeagues(include: leagueIncludes).then (leagues) ->
      response.json(leagues)

  router.post '/leagues', (request, response) ->
    createLeagueQuery = models.League.create(request.body)
    createLeagueQuery.then (league) ->
      createAdminQuery = models.Admin.create
        UserId: request.user.id
        LeagueId: league.id
        write: true
      createAdminQuery.then ->
        findLeague(league.id).then (league) -> response.status(201).json(league)
      createAdminQuery.catch (error) ->
        response.status(500).json(error: error)
    createLeagueQuery.catch (error) ->
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
    }).then (frames) ->
      response.json(frames)

  router
