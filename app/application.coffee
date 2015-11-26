listen = (port) ->
  new Promise (resolve, reject) ->
    initApplication()
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

initApplication = ->
  express = require 'express'
  models = require '../models'
  requestMiddleware = require './middleware/request'

  app = express()
  app.use require('cors')()
  app.use requestMiddleware.defaultHeaders
  app.use requestMiddleware.jsonParser
  app.use require('./middleware/authentication').jwtAuthentication
  require('./routes')(app)
  app.use requestMiddleware.serverErrorHandling

  app.set('redisClient', require('./redis_client')())

  new Promise (resolve, reject) ->
    models.sequelize.sync()
      .then ->
        resolve(app)
      .catch reject

module.exports =
  listen: listen
  initApplication: initApplication
