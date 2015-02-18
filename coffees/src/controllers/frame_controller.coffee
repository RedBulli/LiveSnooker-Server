express = require 'express'
REDIS_CHANNEL = "updates"

publish = (request, event, json) ->
  data =
    event: event
    data: json
  request.app.get("redisClient").publish(REDIS_CHANNEL, JSON.stringify(data))

newFrame = (request) ->
  Frame = request.app.get('models').Frame
  Frame.create (data)


module.exports = ->
  router = express.Router()

  router.post '/frame', (request, response) ->
    publish(request, {event: "newFrame", data: action})

  router
