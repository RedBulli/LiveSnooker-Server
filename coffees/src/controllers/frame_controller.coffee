module.exports = class FrameController
  redisChannel: "updates"
  redisKeyPrefix: process.env.REDIS_APP_KEY + ':frames'

  connectDbClients: (callback) ->
    @redisClient = require('./../redis_client')()
    MongoClient = require('./../mongo_client')
    @mongoClient = new MongoClient()
    @mongoClient.connect(callback)

  publish: (dataJSON) ->
    @redisClient.publish "updates", dataJSON

  getRedisKey: (frameId) ->
    @redisKeyPrefix + frameId + ":actions"

  storeAction: (action, callback) ->
    @mongoClient.insert "actions", action.toObject(), callback

  act: (action, callback) ->
    @storeAction action, =>
      @publish action.toJSON()
      callback()
