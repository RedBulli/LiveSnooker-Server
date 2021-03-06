express = require 'express'
models  = require '../../models'
authMiddleware = require '../middleware/authentication'
isEmail = require('./../utils').isEmail
streamHandler = require './stream_handler'
_ = require 'underscore'

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

  router.get '/', (request, response) ->
    queries = [
      models.League.findAll(
        where: {public: true},
        include: leagueIncludes
      )
    ]
    if request.user
      queries.push request.user.getLeagues(include: leagueIncludes)

    Promise.all(queries)
      .then (results) ->
        leagues = _.uniq(_.union(results[0] || [], results[1] || []), false, (league) ->
          league.id
        )
        response.json(leagues)
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

  setLeagueToRequest = (req, resp, next) ->
    require('../middleware/authentication').setLeagueToRequest(req.params.leagueId, req, resp, next)

  router.all ['/:leagueId*'], setLeagueToRequest

  requireRead = (req, resp, next) ->
    require('../middleware/authentication').validateLeagueReadAuth(req, resp, next)

  requireWrite = (req, resp, next) ->
    require('../middleware/authentication').validateLeagueModifyAuth(req, resp, next)

  router.get ['/:leagueId*'], requireRead
  router.post ['/:leagueId*'], requireWrite
  router.put ['/:leagueId*'], requireWrite
  router.delete ['/:leagueId*'], requireWrite
  router.patch ['/:leagueId*'], requireWrite

  router.get '/:leagueId', (request, response) ->
    findLeague(request.league.id)
      .then (league) ->
        response.json(league)
      .catch (error) -> response.status(500).json(error: error)

  router.patch '/:leagueId', (request, response) ->
    request.league.set('public', request.body['public'])
    request.league.save()
      .then ->
        response.json(request.league)
      .catch (error) -> response.status(500).json(error: error)

  router.get '/:leagueId/admins', (request, response) ->
    request.league.getAdmins()
      .then (admins) ->
        response.json(admins)
      .catch (error) -> response.status(500).json(error: error)

  router.post '/:leagueId/admins', (request, response) ->
    if isEmail(request.body.UserEmail)
      models.Admin.create(
        LeagueId: request.league.id
        UserEmail: request.body["UserEmail"]
      )
        .then (admin) -> response.status(201).json(admin)
        .catch (error) -> response.status(500).json(error: error)
    else
      response.status(400).json(error: "Invalid email")

  router.delete '/:leagueId/admins/:adminId', (request, response) ->
    request.league.getAdmins(where: {write: true}).then (admins) ->
      if admins.length < 2 && admins[0].id == request.params.adminId
        response.status(400).json(error: "Cannot remove last write-access admin")
      else
        models.Admin.destroy(where: {
          LeagueId: request.league.id
          id: request.params.adminId
        })
          .then -> response.status(204).json("")
          .catch (error) -> response.status(500).json(error: error)

  router.patch '/:leagueId/admins/:adminId', (request, response) ->
    models.Admin.findOne(where: {LeagueId: request.league.id, id: request.params.adminId})
      .then (admin) ->
        updateAdminWriteAccess = ->
          admin.set('write', request.body['write'])
          admin.save()
            .then ->
              response.status(200).json(admin)
            .catch (error) ->
              response.status(500).json(error: error)

        if admin
          unless request.body['write']
            request.league.getAdmins(where: {write: true}).then (admins) ->
              if admins.length < 2
                response.status(400).json(error: "At least 1 admin has to have write access")
              else
                updateAdminWriteAccess()
          else
            updateAdminWriteAccess()
        else
          response.status(404).json(error: 'Not found')
      .catch (error) -> response.status(500).json(error: error)

  router.get '/:leagueId/stream', (request, response) ->
    streamHandler(request.league.id, request, response)

  router
