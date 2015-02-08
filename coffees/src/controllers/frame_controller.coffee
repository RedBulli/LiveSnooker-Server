module.exports = class FrameController
  redisChannel: "updates"
  redisKeyPrefix: process.env.REDIS_APP_KEY + ':frames'
  constructor: ->
    @redisClient = require('./../redis_client')()

  publish: (dataJSON) ->
    @redisClient.publish "updates", dataJSON

  getRedisKey: (frameId) ->
    @redisKeyPrefix + frameId + ":actions"

  storeAction: (action, callback) ->
    callback()
    #@mongoClient.insert "actions", action.toObject(), callback

  act: (action, callback) ->
    @storeAction action, =>
      @publish action.toJSON()
      callback()
