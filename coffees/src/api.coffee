forms = require './forms'

module.exports = (app) ->
  app.post '/pot', (request, response) ->
    form = new forms.PotForm(request)
    form.validate()
    response.send 204

  app.post '/missed_pot', (request, response) ->
    response.send 204

  app.post '/safety', (request, response) ->
    form = new forms.SafetyForm(request)
    form.validate()
    response.send 204
