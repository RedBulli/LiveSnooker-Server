listen = (port) ->
  new Promise (resolve, reject) ->
    initApplication()
      .then (app) ->
        server = app.listen port
        require('./video_socket_io')(app, server)
        resolve()
      .catch reject

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
