errors = require './errors'
bodyParser = require 'body-parser'

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

module.exports =
  allowCrossDomain: allowCrossDomain
  defaultHeaders: defaultHeaders
  serverErrorHandling: serverErrorHandling
  jsonParser: jsonParser
