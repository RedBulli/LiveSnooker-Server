authMiddleware = require './../authentication_middleware'
express = require('express')

module.exports = ->
  router = express.Router()

  router.get '/', authMiddleware.requireAuth, (request, response) ->
    response.json({ user: request.user })

  router
