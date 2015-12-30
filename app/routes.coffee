express = require 'express'
authMiddleWare = require './middleware/authentication'

module.exports = (app) ->
  router = express.Router()
  router.post '*', authMiddleWare.requireAuth
  router.put '*', authMiddleWare.requireAuth
  router.patch '*', authMiddleWare.requireAuth
  router.delete '*', authMiddleWare.requireAuth

  app.use(router)
  app.use('/account', require('./controllers/account_controller')())
  app.use('/leagues', require('./controllers/league_controller')())
  app.use('/leagues/:leagueId/frames', require('./controllers/frame_controller')())
  app.use('/leagues/:leagueId/players', require('./controllers/player_controller')())
  app.use('/leagues/:leagueId/players/:playerId/stats', require('./controllers/stats_controller')())
