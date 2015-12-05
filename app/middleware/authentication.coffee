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
    redis.expireAsync(key, body.expires_in)

getTokenInfo = (token, redis) ->
  new Promise (resolve, reject) ->
    getCachedTokenInfo(token, redis)
      .then (response) ->
        if response
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

respondNotFound = (response) ->
  response.status(404).json(error: 'Not found')

respondUnauthorized = (response) ->
  response.status(401).json(error: 'Unauthorized')

respondForbidden = (response) ->
  response.status(403).json(error: 'Forbidden')

setLeagueToRequest = (leagueId, request, response, next) ->
  query = models.League.findOne where: {id: leagueId}
  query.then (league) ->
    if league
      request.league = league
      next()
    else
      respondNotFound(response)
  query.catch -> respondNotFound(response)

validateLeagueReadAuth = (request, response, next) ->
  if request.league.get('public')
    next()
  else
    unless request.user
      respondUnauthorized(response)
    else
      models.Admin.count(
        where: {UserEmail: request.user.email, LeagueId: request.league.id}
      ).then (count) ->
        if count == 0
          respondForbidden(response)
        else
          next()

validateLeagueModifyAuth = (request, response, next) ->
  unless request.user
    return respondUnauthorized(response)
  else
    models.Admin.count(
      where:
        UserEmail: request.user.email
        LeagueId: request.league.id
        write: true
    ).then (count) ->
      if count == 0
        respondForbidden(response)
      else
        next()

jwtAuthentication = (request, response, next) ->
  token = request.headers['x-auth-google-id-token'] || request.query.id_token
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
        respondUnauthorized(response)
  else
    next()

requireAuth = (request, response, next) ->
  if request.user
    next()
  else
    respondUnauthorized(response)

module.exports =
  jwtAuthentication: jwtAuthentication
  requireAuth: requireAuth
  validateLeagueReadAuth: validateLeagueReadAuth
  validateLeagueModifyAuth: validateLeagueModifyAuth
  setLeagueToRequest: setLeagueToRequest
