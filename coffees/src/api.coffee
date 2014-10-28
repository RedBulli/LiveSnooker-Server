forms = require './forms'
errors = require './errors'
validators = require './forms/validators'

getValidatedFormValues = (form, request) ->
  try
    form.getValidatedValues(request.body)
  catch err
    if err instanceof validators.ValidationError
      throw new errors.BadRequest err.message
    else
      throw err

frameState =
  id: 'frameID'
  potted: 0

module.exports = (app) ->
  publisherClient = require('./redis_client')()

  app.post '/pot', (request, response) ->
    form = new forms.PotForm()
    values = getValidatedFormValues(form, request)
    frameState.potted += values.ball_value
    publisherClient.publish 'updates', JSON.stringify(frameState)
    response.sendStatus 204

  app.post '/missed_pot', (request, response) ->
    response.sendStatus 204

  app.post '/safety', (request, response) ->
    form = new forms.SafetyForm()
    values = getValidatedFormValues(form, request)
    response.sendStatus 204
