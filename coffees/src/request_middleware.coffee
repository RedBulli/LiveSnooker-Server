errors = require './errors'
bodyParser = require 'body-parser'

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
  defaultHeaders: defaultHeaders
  serverErrorHandling: serverErrorHandling
  jsonParser: jsonParser
