express = require 'express'
authMiddleWare = require './authentication_middleware'

module.exports = (app) ->
  router = express.Router()
  router.post '*', authMiddleWare.requireAuth
  router.put '*', authMiddleWare.requireAuth
  router.patch '*', authMiddleWare.requireAuth
  router.delete '*', authMiddleWare.requireAuth

  router.all ['/leagues/:leagueId*'], (req, resp, next) ->
    authMiddleWare.validateLeagueAuth(req.params.leagueId, req, resp, next)

  app.use(router)
  app.use(require('./streaming_api')())
  app.use('/account', require('./account')())
  app.use('/leagues', require('./controllers/league_controller')())
  app.use('/leagues/:leagueId/frames', require('./controllers/frame_controller')())
  app.use('/leagues/:leagueId/players', require('./controllers/player_controller')())
