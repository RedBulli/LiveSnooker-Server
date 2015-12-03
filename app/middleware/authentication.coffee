JWT = require 'jsonwebtoken'
request = require 'request'
models  = require '../../models'

pendingUserQueryPromises = {}

requestTokenInfo = (token) ->
  new Promise (resolve, reject) ->
    request 'https://www.googleapis.com/oauth2/v2/tokeninfo?id_token=' + token, (error, response, body) ->
      if !error && response.statusCode == 200
        jsonBody = JSON.parse(body)
        if jsonBody.audience == process.env.GOOGLE_CLIENT_ID
          resolve(jsonBody)
        else
          reject()
      else
        reject()

tokenRedisKey = (token) ->
  'tokens:' + token

getCachedTokenInfo = (token, redis) ->
  key = tokenRedisKey(token)
  redis.getAsync(key)

cacheTokenInfo = (token, body, redis) ->
  key = tokenRedisKey(token)
  redis.setAsync(key, JSON.stringify(body)).then ->
    console.log "expires",  body.expires_in
    redis.expireAsync(key, body.expires_in)

getTokenInfo = (token, redis) ->
  new Promise (resolve, reject) ->
    getCachedTokenInfo(token, redis)
      .then (response) ->
        if response
          console.log "cache hit!"
          resolve(JSON.parse(response))
        else
          requestTokenInfo(token)
            .then (response) ->
              cacheTokenInfo(token, response, redis).then ->
                resolve(response)
            .catch (err) ->
              reject()

createUser = (email) ->
  models.User.create(email: email)

getOrCreateUser = (authData) ->
  email = authData.email
  unless pendingUserQueryPromises[email]
    pendingUserQueryPromises[email] = models.User.find({where: {email: email}}).then (user) ->
      if user
        user
      else
        models.User.create(email: email)
    .then (user) ->
      delete pendingUserQueryPromises[email]
      user
  pendingUserQueryPromises[email]

validateLeagueAuth = (leagueId, request, response, next) ->
  responseNotFound = ->
    response.status(404).json(error: 'Not found')
    response.end()

  query = models.League.findOne where: {id: leagueId}
  query.then (league) ->
    unless league
      return responseNotFound()
    request.league = league
    if league.get('public')
      next()
    else
      unless request.user
        responseNotFound()
      else
        models.Admin.count(
          where: {UserEmail: request.user.email, LeagueId: leagueId}
        ).then (count) ->
          if count == 0
            responseNotFound()
          else
            next()
  query.catch responseNotFound

jwtAuthentication = (request, response, next) ->
  token = request.headers['x-auth-google-id-token']
  if token
    getTokenInfo(token, request.app.get('redisClient'))
      .then (googleUser) ->
        authData = {vendorUserId: googleUser.user_id, vendor: 'google', email: googleUser.email}
        getOrCreateUser(authData).then((user) ->
          request.user = user
          next()
        ).catch (err) ->
          console.error err
          response.status(500).json(error: "Internal server error")
      .catch ->
        response.status(401).json(error: "Unauthorized")
  else
    next()

requireAuth = (request, response, next) ->
  if request.user
    next()
  else
    response.status(401).json(error: "Unauthorized")

module.exports =
  jwtAuthentication: jwtAuthentication
  requireAuth: requireAuth
  validateLeagueAuth: validateLeagueAuth
