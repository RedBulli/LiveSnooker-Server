bluebird = require 'bluebird'

module.exports = ->
  redis = require('redis')
  bluebird.promisifyAll(redis.RedisClient.prototype)
  bluebird.promisifyAll(redis.Multi.prototype)

  if (process.env.REDISTOGO_URL)
    rtg  = require('url').parse(process.env.REDISTOGO_URL)
    client = redis.createClient(rtg.port, rtg.hostname, {prefix: process.env.REDIS_NAMESPACE})
    client.auth(rtg.auth.split(':')[1])
  else
    client = redis.createClient(prefix: process.env.REDIS_NAMESPACE)
  client
