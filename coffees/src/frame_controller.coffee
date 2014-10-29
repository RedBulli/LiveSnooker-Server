module.exports = class FrameController
  redisChannel: "updates"
  constructor: ->
    @publisher = require('./redis_client')()

  publish: (data) ->
    @publisher.publish @redisChannel, JSON.stringify(data)

  storeAction: (action) ->

  act: (action) ->
