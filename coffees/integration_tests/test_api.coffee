request = require 'supertest'
apiTesthelpers = require './api_test_helpers'

applyTestHelpers = (response) ->
  response.expectBadRequest = (message, done) ->
    response.expect 400
    response.expect {error: message}, done

describe 'rest api', ->
  server = null
  post = (url, content) ->
    response = request server
      .post url
      .set 'Accept', 'application/json'

    if content
      response.send content
      response.set 'Content-Type', 'application/json'
    applyTestHelpers(response)
    response

  helpers = apiTesthelpers(post)

  before (done) ->
    rootRequire('application').listen 4000, (serverApp) ->
      server = serverApp
      done()

  after ->
    server.close()

  describe 'POST /action', ->
    url = '/action'

    describe 'parameter points', ->
      validFormData = fixtures.actionFormData()
      delete validFormData.points
      helpers.assertIntegerParameter
        otherParams: validFormData
        parameter: 'points'
        url: url
        min: 0
        max: 16
        required: true

  describe 'POST /player', ->
    url = '/players'

    it 'should work', (done) ->
      response = post('/players/', {name: "Sampo"})
      response.expect 201, done
