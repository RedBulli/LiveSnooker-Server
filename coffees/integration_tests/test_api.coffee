should = require('chai').should()
request = require 'supertest'

describe 'rest api', ->
  server = null

  before ->
    server = require('./../src/application').listen 4000

  post = (url, content) ->
    request_var = request server
      .post url
      .set 'Accept', 'application/json'

    if content
      request_var.send content
      request_var.set 'Content-Type', 'application/json'

    return request_var

  describe 'POST /pot', ->
    url = '/pot'

    it 'should return 204 with ball_value 1 to 7', (done) ->
      response = post url, {ball_value: 1}
      response.expect 204
      response = post url, {ball_value: 7}
      response.expect 204, done

    it 'should enforce ball_value to be an int', (done) ->
      response = post url, {ball_value: 'one'}
      response.expect {error: {
          ball_value: 'Should be an integer'
        }
      }
      response.expect 400, done

    it 'should return 400 with no content', (done) ->
      response = post url, {}
      response.expect {error: {
          ball_value: 'Required parameter'
        }
      }
      response.expect 400, done

    it 'should return 400 if invalid json content', (done) ->
      response = post url, '{unquoted_key_is_not_allowed_in_json: 1}'
      response.expect {error: 'Invalid JSON'}
      response.expect 400, done

  describe 'POST /missed_pot', ->
    url = '/missed_pot'

    it 'should exist', (done) ->
      response = post url
      response.expect 204, done

  after ->
    server.close()
