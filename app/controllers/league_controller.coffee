express = require 'express'
models  = require '../../models'
authMiddleware = require '../middleware/authentication'
isEmail = require('./../utils').isEmail

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

  router.get '/', authMiddleware.requireAuth, (request, response) ->
    request.user.getLeagues(include: leagueIncludes)
      .then (leagues) -> response.json(leagues)
      .catch (error) -> response.status(500).json(error: error)

  router.post '/', (request, response) ->
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

  router.get '/:leagueId', (request, response) ->
    response.json(request.league)

  router.post '/:leagueId/admins', (request, response) ->
    if isEmail(request.body.UserEmail)
      models.Admin.create(request.body)
        .then (admin) -> response.status(201).json(admin)
        .catch (error) -> response.status(500).json(error: error)
    else
      response.status(400).json(error: "Invalid email")

  router.delete '/:leagueId/admins/:adminId', (request, response) ->
    request.league.getAdmins().then (admins) ->
      if admins.length < 2
        response.status(400).json(error: "Cannot remove last admin")
      else
        models.Admin.destroy(where: {
          LeagueId: request.params.id
          id: request.params.adminId
        })
          .then -> response.status(204).json("")
          .catch (error) -> response.status(500).json(error: error)

  router
