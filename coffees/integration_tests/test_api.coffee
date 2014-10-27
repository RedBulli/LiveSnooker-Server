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

  before ->
    server = rootRequire('application').listen 4000

  after ->
    server.close()

  describe 'POST /pot', ->
    url = '/pot'

    helpers.assertIntegerParameter
      parameter: 'ball_value'
      url: url
      min: 1
      max: 7
      required: true

  describe 'POST /missed_pot', ->
    url = '/missed_pot'

    it 'returns 204', (done) ->
      response = post url
      response.expect 204, done

  describe 'POST /safety', ->
    url = '/safety'

    it 'does not require any parameters', (done) ->
      response = post url
      response.expect 204, done

    helpers.assertIntegerParameter
      parameter: 'pot'
      url: url
      min: 1
      max: 7
      required: false
