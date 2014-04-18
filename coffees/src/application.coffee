module.exports.listen = (port) ->
  createApp().listen port

createApp = () ->
  express = require 'express'
  bodyParser = require 'body-parser'

  allowCrossDomain = (request, response, next) ->
    response.header 'Access-Control-Allow-Origin', '*'
    response.header(
      'Access-Control-Allow-Methods',
      'GET,PUT,POST,DELETE,OPTIONS'
    )
    response.header(
      'Access-Control-Allow-Headers', 
      'Content-Type, Content-Length, X-Requested-With'
    )
    #response.header('Access-Control-Allow-Credentials', 'true')
    if 'OPTIONS' == request.method
      response.send 200
    else
      next()

  defaultHeaders = (request, response, next) ->
    response.header 'Content-Type', 'application/json; charset=utf-8'
    next()

  serverErrorHandling = (err, request, response, next) ->
    response.send 500

  jsonParser = (request, response, next) ->
    bodyParser.json() request, response, (err) ->
      if err
        response.send 400, {error: 'Invalid JSON'}
      next(err)

  app = express()
  app.use allowCrossDomain
  app.use defaultHeaders
  app.use jsonParser
  app.use require './request_handler'
  app.use serverErrorHandling

  require('./api')(app)

  return app
