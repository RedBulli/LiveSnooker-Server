request = require 'supertest'
expect = require('chai').expect
specHelper = require '../spec_helper'
models = require '../../models'

describe 'League controller', ->
  adminEmail = 'test@example.com'

  beforeEach ->
    leagues = [
      models.League.create(name: 'Biklu').then (league) ->
        models.Admin.create
          UserEmail: adminEmail
          LeagueId: league.id
      models.League.create(name: 'Public', public: true)
      models.League.create(name: 'PublicAdmined', public: true).then (league) ->
        models.Admin.create
          UserEmail: adminEmail
          LeagueId: league.id
    ]
    Promise.all(leagues)

  describe 'without authentication', ->
    it 'returns public leagues', (done) ->
      request($app)
        .get('/leagues')
        .expect (res) ->
          expect(res.body.length).to.eql 2
        .expect(200, done)

  describe 'with authentication', ->
    token = '123456'

    beforeEach ->
      specHelper.mockGoogleTokenRequest(token, adminEmail)

    it "returns the user's leagues", (done) ->
      request($app)
        .get '/leagues'
        .set 'x-auth-google-id-token', token
        .expect (res) ->
          expect(res.body.length).to.eql 3
        .expect(200, done)
