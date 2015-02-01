ActionForm = require('./forms/action_form')
FrameController = require('./controllers/frame_controller')
JWT = require('jsonwebtoken')
request = require('request')

parseGoogleToken = (token, callback) ->
  request('https://www.googleapis.com/oauth2/v1/tokeninfo?id_token=' + token, (error, response, body) ->
    if (!error && response.statusCode == 200)
      callback(null, JSON.parse(body))
    else
      callback("ERROR!")
  )
  # TODO: cache the certs and do decode the JWT more efficiently
  # JSON.parse(JWT.verify(token, cert))

module.exports = (app, callback) ->
  actionForm = new ActionForm()
  frameController = new FrameController()

  frameController.connectDbClients ->
    app.post '/action', (request, response) ->
      action = actionForm.getPopulatedModel request.body
      frameController.act action, ->
        # TODO get errors from the callback
        response.sendStatus 204

    app.get '/account', (request, response) ->
      parseGoogleToken(request.headers['x-auth-google-id-token'], (err, user) ->
        if !err
          response.json({ message: 'Logged in as: ' + user["email"] });
        else
          throw "Error"
      )

    callback()

  require('./controllers/passport')(app)
