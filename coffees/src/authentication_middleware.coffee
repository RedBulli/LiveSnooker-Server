JWT = require 'jsonwebtoken'
request = require 'request'

parseGoogleToken = (token, callback) ->
  request 'https://www.googleapis.com/oauth2/v2/tokeninfo?id_token=' + token, (error, response, body) ->
    if (!error && response.statusCode == 200)
      callback(null, JSON.parse(body))
    else
      callback("ERROR!")

jwtAuthentication = (request, response, next) ->
  token = request.headers['x-auth-google-id-token']
  if token
    parseGoogleToken token, (err, googleUser) ->
      if !err
        userData = {auth_id: googleUser.user_id, email: googleUser.email, vendor: 'google'}
        request.app.get('models').User.findOrCreate userData, (err, user) ->
          throw err if err
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
