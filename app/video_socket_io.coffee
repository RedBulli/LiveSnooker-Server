module.exports = (app, server) ->
  authMiddleware = require('./middleware/authentication')
  models  = require '../models'
  app.io = require('socket.io')(server)
  redisClient = require('./redis_client')()

  respondSocketError = (next, err) ->
    console.error "Socket failed to connect", err
    next(new Error('not found'))

  validateLeagueAuth = (socket, next) ->
    unless socket.handshake.query.league_id
      respondSocketError(next)
    else
      models.League.findOne(where: {id: socket.handshake.query.league_id})
        .then (league) ->
          if league
            if league.public
              next()
            else
              authMiddleware.getOrCreateUserFromToken(socket.handshake.query.id_token, redisClient)
                .then (user) ->
                  next()
                .catch respondSocketError.bind(null, next)
          else
            respondSocketError(next)
        .catch respondSocketError.bind(null, next)

  app.io.use validateLeagueAuth

  app.io.sockets.on 'connection', (socket) ->
    socket.join(socket.handshake.query.league_id);
    socket.on 'message', (data) ->
      socket.broadcast.to(socket.handshake.query.league_id).emit('message', data)
