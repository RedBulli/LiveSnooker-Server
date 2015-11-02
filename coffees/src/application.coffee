module.exports.listen = (port, callback) ->
  createApp (app) ->
    server = app.listen port
    app.io = require('socket.io')(server)
    app.io.sockets.on 'connection', (socket) ->
      socket.on 'message', (data) ->
        socket.broadcast.emit('message', data)
    callback(server)

createApp = (callback) ->
  express = require 'express'
  bodyParser = require 'body-parser'
  errors = require './errors'
  authMiddleWare = require './authentication_middleware'
  models = require '../../models'

  allowCrossDomain = (request, response, next) ->
    response.header 'Access-Control-Allow-Origin', '*'
    response.header(
      'Access-Control-Allow-Methods',
      'GET,PUT,POST,DELETE,OPTIONS,PATCH'
    )
    response.header(
      'Access-Control-Allow-Headers',
      'Content-Type, Content-Length, X-Requested-With, X-AUTH-GOOGLE-ID-TOKEN'
    )
    if 'OPTIONS' == request.method
      response.sendStatus 200
    else
      next()

  defaultHeaders = (request, response, next) ->
    response.header 'Content-Type', 'application/json; charset=utf-8'
    next()

  serverErrorHandling = (err, request, response, next) ->
    if err
      if err instanceof errors.HttpError
        response.status(err.statusCode).send(err.message)
      else
        console.error err
        response.sendStatus 500

  jsonParser = (request, response, next) ->
    bodyParser.json() request, response, (err) ->
      if err
        next new errors.BadRequest 'Invalid JSON'
      else
        next()

  app = express()
  app.use allowCrossDomain
  app.use defaultHeaders
  app.use jsonParser
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
  app.use(require('./api')())
  app.use('/leagues', require('./controllers/league_controller')())
  app.use('/leagues/:leagueId/frames', require('./controllers/frame_controller')())
  app.use('/players', require('./controllers/player_controller')())
  app.use('/shots', require('./controllers/shot_controller')())
  app.use serverErrorHandling

  app.set("redisClient", require('./redis_client')())

  models.sequelize.sync().then ->
    callback(app)
