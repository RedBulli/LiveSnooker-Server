forms = require './forms'

module.exports = (app) ->
  app.post '/pot', (request, response) ->
    form = new forms.PotForm(request)
    form.validate()
    console.log form.values
    response.send 204

  app.post '/missed_pot', (request, response) ->
    response.send 204

  app.post '/safety', (request, response) ->
    response.send 204
