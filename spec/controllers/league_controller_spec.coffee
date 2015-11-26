request = require 'supertest'
nock = require 'nock'
expect = require('chai').expect
require '../spec_helper'

describe 'League controller', ->
  describe 'without authentication', ->
    it 'returns 401', (done) ->
      request($app)
        .get('/leagues')
        .expect(401, done)

  describe 'with authentication', ->
    token = '123456'
    beforeEach ->
      nock('https://www.googleapis.com')
        .get('/oauth2/v2/tokeninfo')
        .query({id_token: token})
        .reply 200,
          issued_to: '3.apps.googleusercontent.com',
          audience: '3.apps.googleusercontent.com',
          user_id: '1234567890',
          expires_in: 3277,
          email: 'sampo.verkasalo@gmail.com',
          verified_email: true

    it 'returns the user', (done) ->
      request($app)
        .get '/leagues'
        .set 'x-auth-google-id-token', token
        .expect []
        .expect(200, done)
