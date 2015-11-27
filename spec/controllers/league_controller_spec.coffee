request = require 'supertest'
nock = require 'nock'
expect = require('chai').expect
require '../spec_helper'
models = require '../../models'

describe 'League controller', ->
  describe 'without authentication', ->
    it 'returns 401', (done) ->
      request($app)
        .get('/leagues')
        .expect(401, done)

  describe 'with authentication', ->
    token = '123456'
    userEmail = 'test@example.com'
    beforeEach ->
      nock('https://www.googleapis.com')
        .get('/oauth2/v2/tokeninfo')
        .query({id_token: token})
        .reply 200,
          issued_to: process.env.GOOGLE_CLIENT_ID,
          audience: process.env.GOOGLE_CLIENT_ID,
          user_id: '1234567890',
          expires_in: 3277,
          email: userEmail,
          verified_email: true
      models.League.create(name: 'Biklu').then (league) ->
        models.Admin.create
          UserEmail: userEmail
          LeagueId: league.get('id')

    it "returns the user's leagues", (done) ->
      request($app)
        .get '/leagues'
        .set 'x-auth-google-id-token', token
        .expect (res) ->
          expect(res.body.length).to.eql 1
        .expect(200, done)
