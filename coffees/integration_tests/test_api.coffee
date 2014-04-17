should = require('chai').should()
request = require 'supertest'

describe 'rest api', ->
  server = null

  before ->
    server = require('./../src/application').listen 4000

  post = (url, content) ->
    request server
      .post url
      .send content
      .set 'Content-Type', 'application/json'
      .set 'Accept', 'application/json'

  describe 'POST /pot', ->
    url = '/pot'

    it 'should return 204 with ball_value 1 to 7', (done) ->
      response = post url, {ball_value: 1}
      response.expect 204
      response = post url, {ball_value: 7}
      response.expect 204, done

    it 'should enforce ball_value to be an int', (done) ->
      response = post url, {ball_value: "one"}
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

  after ->
    server.close()
