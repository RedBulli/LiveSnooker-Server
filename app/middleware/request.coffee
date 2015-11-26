bodyParser = require 'body-parser'

defaultHeaders = (request, response, next) ->
  response.header 'Content-Type', 'application/json; charset=utf-8'
  next()

serverErrorHandling = (err, request, response, next) ->
  if err
    console.error err
  response.sendStatus 500

jsonParser = (request, response, next) ->
  bodyParser.json() request, response, (err) ->
    if err
      response.status(400).json(error: "Invalid JSON")
    else
      next()

module.exports =
  defaultHeaders: defaultHeaders
  serverErrorHandling: serverErrorHandling
  jsonParser: jsonParser
