JWT = require 'jsonwebtoken'
request = require 'request'
models  = require '../../models'
_ = require 'underscore'

parseGoogleToken = (token, callback) ->
  request 'https://www.googleapis.com/oauth2/v2/tokeninfo?id_token=' + token, (error, response, body) ->
    if (!error && response.statusCode == 200)
      callback(null, JSON.parse(body))
    else
      callback("ERROR!")

createUserWithAuthentication = (authData, email, cb) ->
  models.User.create(email: email).then (user) ->
    auth = models.Authentication.build(authData)
    auth.setUser(user, save: false)
    auth.save(cb(user))

getOrCreateUser = (authData, email, cb) ->
  models.Authentication.find({ where: authData }).then (authentication) ->
    if !authentication
      createUserWithAuthentication(authData, email, cb)
    else
      authentication.getUser().then(cb)

validateLeagueAuth = (leagueId, request, response, next) ->
  responseNotFound = ->
    response.status(404).json(error: 'not found')
    response.end()

  query = models.League.findOne where: {id: leagueId}
  query.then (league) ->
    request.league = league
    if league.public
      next()
    else
      unless request.user
        responseNotFound()
      else
        models.Admin.count(
          where: {UserId: request.user.id, LeagueId: request.params.id}
        ).then (count) ->
          if count == 0
            responseNotFound()
          else
            next()
  query.catch responseNotFound

jwtAuthentication = (request, response, next) ->
  token = request.headers['x-auth-google-id-token']
  if token
    parseGoogleToken token, (err, googleUser) ->
      if !err
        authData = {vendorUserId: googleUser.user_id, vendor: 'google'}
        getOrCreateUser authData, googleUser.email, (user) ->
          request.user = user
          next()
      else
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
