messageCount = 1
subscriberCount = 0

module.exports = (id, request, response) ->
  request.socket.setTimeout 1000*1000

  subscriber = require('../redis_client')()
  subscriber.subscribe id

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
