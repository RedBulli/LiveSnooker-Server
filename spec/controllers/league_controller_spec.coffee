request = require 'supertest'
expect = require('chai').expect
specHelper = require '../spec_helper'
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
      specHelper.mockGoogleTokenRequest(token, userEmail)
      models.League.create(name: 'Biklu').then (league) ->
        models.Admin.create
          UserEmail: userEmail
          LeagueId: league.id

    it "returns the user's leagues", (done) ->
      request($app)
        .get '/leagues'
        .set 'x-auth-google-id-token', token
        .expect (res) ->
          expect(res.body.length).to.eql 1
        .expect(200, done)
