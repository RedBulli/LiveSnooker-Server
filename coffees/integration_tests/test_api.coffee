should = require('chai').should()
request = require 'supertest'

applyTestHelpers = (response) ->
  response.expectBadRequest = (message) ->
    response.expect 400
    response.expect {error: message}

describe 'rest api', ->
  server = null

  before ->
    server = require('./../src/application').listen 4000

  post = (url, content) ->
    response = request server
      .post url
      .set 'Accept', 'application/json'

    if content
      response.send content
      response.set 'Content-Type', 'application/json'
    applyTestHelpers(response)
    return response

  describe 'POST /pot', ->
    url = '/pot'

    it 'should return 204 with ball_value 1 to 7', () ->
      response = post url, { ball_value: 1 }
      response.expect 204
      response = post url, { ball_value: 7 }
      response.expect 204

    it 'should return 400 with ball_value less than 1 or higher than 7', () ->
      response = post url, { ball_value: 0 }
      response.expectBadRequest {
        ball_value: 'Should be an integer between 1-7'
      }

    it 'should return 400 with ball_value higher than 7', () ->
      response = post url, { ball_value: 9 }
      response.expectBadRequest {
        ball_value: 'Should be an integer between 1-7'
      }

    it 'should enforce ball_value to be an int', () ->
      response = post url, { ball_value: 'one' }
      response.expectBadRequest { ball_value: 'Should be an integer' }

    it 'should return 400 with no content', () ->
      response = post url
      response.expectBadRequest { ball_value: 'Required parameter' }
      response = post url, {}
      response.expectBadRequest { ball_value: 'Required parameter' }

    it 'should return 400 if invalid json content', () ->
      response = post url, '{unquoted_key_is_not_allowed_in_json: 1}'
      response.expectBadRequest 'Invalid JSON'

  describe 'POST /missed_pot', ->
    url = '/missed_pot'

    it 'should return 204', () ->
      response = post url
      response.expect 204

  describe 'POST /safety', ->
    url = '/safety'

    it 'should return 204 with pot parameter from 1 to 7', () ->
      response = post url, { pot: 1 }
      response.expect 204
      response = post url, { pot: 7 }
      response.expect 204

  after ->
    server.close()
