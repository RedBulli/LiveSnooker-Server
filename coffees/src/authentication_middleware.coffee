JWT = require 'jsonwebtoken'
request = require 'request'
models  = require '../../models'

pendingUserQueryPromises = {}

requestTokenInfo = (token) ->
  new Promise (resolve, reject) ->
    request 'https://www.googleapis.com/oauth2/v2/tokeninfo?id_token=' + token, (error, response, body) ->
      if !error && response.statusCode == 200
        resolve(JSON.parse(body))
      else
        reject()

getUserData = (token) ->
  new Promise (resolve, reject) ->
    requestTokenInfo(token).then (userData) ->
      if userData.audience == process.env.GOOGLE_CLIENT_ID
        resolve(userData)
      else
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
    response.status(404).json(error: 'not found')
    response.end()

  query = models.League.findOne where: {id: leagueId}
  query.then (league) ->
    unless league
      return response.sendStatus 404
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
    getUserData(token)
      .then (googleUser) ->
        authData = {vendorUserId: googleUser.user_id, vendor: 'google', email: googleUser.email}
        getOrCreateUser(authData).then((user) ->
          request.user = user
          next()
        ).catch (err) ->
          console.error err
          response.sendStatus 500
      .catch ->
        response.sendStatus 401
  else
    next()

requireAuth = (request, response, next) ->
  if request.user
    next()
  else
    response.sendStatus 401

module.exports =
  jwtAuthentication: jwtAuthentication
  requireAuth: requireAuth
  validateLeagueAuth: validateLeagueAuth
