ActionForm = require('./forms/action_form')
FrameController = require('./controllers/frame_controller')

module.exports = (app, callback) ->
  actionForm = new ActionForm()
  frameController = new FrameController()

  frameController.connectDbClients ->
    app.post '/action', (request, response) ->
      action = actionForm.getPopulatedModel request.body
      frameController.act action, ->
        # TODO get errors from the callback
        response.sendStatus 204

    callback()
