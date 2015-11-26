module.exports.listen = (port) ->
  new Promise (resolve, reject) ->
    startApplication()
      .then (app) ->
        server = app.listen port
        initSocketIo(app, server)
        resolve()
      .catch reject

initSocketIo = (app, server) ->
  app.io = require('socket.io')(server)
  app.io.sockets.on 'connection', (socket) ->
    socket.on 'message', (data) ->
      socket.broadcast.emit('message', data)

startApplication = ->
  express = require 'express'
  authMiddleWare = require './authentication_middleware'
  models = require '../../models'
  requestMiddleware = require './request_middleware'

  app = express()
  app.use requestMiddleware.allowCrossDomain
  app.use requestMiddleware.defaultHeaders
  app.use requestMiddleware.jsonParser
  app.use authMiddleWare.jwtAuthentication
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
  app.use requestMiddleware.serverErrorHandling

  app.set("redisClient", require('./redis_client')())

  new Promise (resolve, reject) ->
    models.sequelize.sync()
      .then ->
        resolve(app)
      .catch reject
