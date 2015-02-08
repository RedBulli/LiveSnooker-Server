express = require('express')

module.exports = ->
  router = express.Router()
  router.get '/framestream', (req, res) ->
    req.socket.setTimeout Infinity

    messageCount = 1
    subscriberCount = 0

    subscriber = require('./redis_client')()

    subscriber.subscribe 'updates'

    subscriber.on 'error', (err) ->
      console.error('Redis Error: ' + err)

    subscriber.on 'subscribe', (err) ->
      subscriberCount++

    subscriber.on "message", (channel, message) ->
      messageCount++
      res.write 'id: ' + messageCount + '\n'
      res.write 'data: ' + message + '\n\n'

    res.writeHead 200,
      'Content-Type': 'text/event-stream'
      'Cache-Control': 'no-cache'
      'Connection': 'keep-alive'

    res.write '\n'

    req.on 'close', ->
      subscriberCount--
      subscriber.unsubscribe()
      subscriber.quit()
  router
