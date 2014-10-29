ActionForm = require('./forms/action_form')
FrameController = require('./frame_controller')

module.exports = (app) ->
  actionForm = new ActionForm()
  frameController = new FrameController()
  app.post '/action', (request, response) ->
    action = actionForm.getPopulatedModel(request.body)
    frameController.act(action)
    response.sendStatus 204
