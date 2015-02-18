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
  models.User.create(email: googleUserData.email).then (user) ->
    auth = models.Authentication.build(authData)
    auth.setUser(user)
    auth.save(cb(user))

getOrCreateUser = (authData, email, cb) ->
  models.Authentication.find({ where: authData }).then (authentication) ->
    if !authentication
      createUserWithAuthentication(authData, googleUser.email, cb)
    else
      cb(authentication.getUser())

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
