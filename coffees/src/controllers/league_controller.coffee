express = require 'express'
models  = require '../../../models'
authMiddleware = require '../authentication_middleware'
Sequelize = require 'sequelize'

module.exports = ->
  router = express.Router()

  findLeague = (leagueId) -> new Promise (resolve, reject) ->
    models.League.find({
      where: {id: leagueId},
      include: [
        { model: models.Player, required: false },
        { model: models.User, as: 'Admins', required: false },
        { model: models.Frame, required: false, include: [
          { model: models.Player, as: 'Player1', required: false },
          { model: models.Player, as: 'Player2', required: false },
          { model: models.Player, as: 'Winner', required: false },
          { model: models.League, required: false }
        ]}
      ]
    }).then(resolve).catch(reject)

  router.get '/leagues', (request, response) ->
    models.Admin.all({
      where: { UserId: request.user.id }
    }).then (admins) ->
      leagueIds = Sequelize.Utils._.map admins, (admin) ->
        admin.LeagueId
      models.League.all({
        include: [
          { model: models.Player, required: false },
          { model: models.User, as: 'Admins', required: false }
        ],
        where:
          $or: [
            { public: true },
            { id: { $in: leagueIds } }
          ]
      }).then (leagues) ->
        response.json(leagues)

  router.post '/leagues', (request, response) ->
    models.League.create(request.body).then((league) ->
      models.Admin.create({
        UserId: request.user.id
        LeagueId: league.id
      }).then ->
        findLeague(league.id).then (league) -> response.status(201).json(league)
    ).catch((error) ->
      if error.name == "SequelizeValidationError"
        response.status(400).json(error: error)
      else
        response.status(500).json(error: error)
    )

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
