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
      'GET,PUT,POST,DELETE,OPTIONS'
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
  app.use(require('./streaming_api')())
  app.use(require('./api')())
  app.use(require('./controllers/frame_controller')())
  app.use(require('./controllers/player_controller')())
  app.use(require('./controllers/league_controller')())
  app.use(require('./controllers/shot_controller')())
  app.use serverErrorHandling

  mongoose = require('mongoose')
  mongoose.connect(process.env.MONGOHQ_URL)

  app.set("redisClient", require('./redis_client')())

  models.sequelize.sync().then ->
    callback(app)
