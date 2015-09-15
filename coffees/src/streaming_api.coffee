express = require('express')

module.exports = ->
  router = express.Router()
  router.get '/framestream/:id', (request, response) ->
    request.socket.setTimeout 1000*1000

    messageCount = 1
    subscriberCount = 0

    subscriber = require('./redis_client')()

    subscriber.subscribe request.params.id

    subscriber.on 'error', (err) ->
      console.error('Redis Error: ' + err)

    subscriber.on 'subscribe', (err) ->
      subscriberCount++

    subscriber.on "message", (channel, message) ->
      messageCount++
      response.write 'id: ' + messageCount + '\n'
      response.write 'data: ' + message + '\n\n'

    response.writeHead 200,
      'Content-Type': 'text/event-stream'
      'Cache-Control': 'no-cache'
      'Connection': 'keep-alive'

    response.write '\n'

    request.on 'close', ->
      subscriberCount--
      subscriber.unsubscribe()
      subscriber.quit()
  router
