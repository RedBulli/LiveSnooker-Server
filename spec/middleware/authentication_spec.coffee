request = require 'supertest'
expect = require('chai').expect
models = require '../../models'
specHelper = require '../spec_helper'

describe 'authentication middleware', ->
  token = '123456'
  userEmail = 'test@example.com'
  accountRequest = ->
    request($app)
      .get '/account'
      .set 'x-auth-google-id-token', token

  leagueGetRequest = (id, token) ->
    req = request($app).get '/leagues/' + id
    req.set 'x-auth-google-id-token', token if token
    req

  leagueCreateAdminRequest = (id, token) ->
    req = request($app)
      .post "/leagues/#{id}/admins"
      .send UserEmail: 'something@eee.com'
    req.set 'x-auth-google-id-token', token if token
    req

  it 'caches the user data from Google', (done) ->
    specHelper.mockGoogleTokenRequest(token, userEmail)
    accountRequest().end ->
      secondRequestMock = specHelper.mockGoogleTokenRequest(token, userEmail, {status: 400})
      accountRequest()
        .expect ->
          expect(secondRequestMock.isDone()).to.eql false
        .expect(200, done)

  describe 'league privileges', ->
    userToken = '12345'
    writeAdminEmail = 'write-admin@example.com'
    readAdminEmail = 'read-admin@example.com'
    nonAdminEmail = 'not-admin@example.com'

    beforeEach ->
      models.League.create(name: 'Biklu').then (league) =>
        @league = league
        Promise.all([
          models.Admin.create
            UserEmail: writeAdminEmail
            LeagueId: league.id
            write: true
          models.Admin.create
            UserEmail: readAdminEmail
            LeagueId: league.id
            write: false
        ])

    describe 'when user is not authenticated', ->
      it "doesn't allow GET", (done) ->
        leagueGetRequest(@league.id).expect(401, done)

      it "doesn't allow admin creation", (done) ->
        leagueCreateAdminRequest(@league.id).expect(401, done)

      it 'allows GET if league is public', (done) ->
        @league.set('public', true)
        @league.save().then =>
          leagueGetRequest(@league.id).expect(200, done)

    describe 'when the user is not an admin', ->
      beforeEach ->
        specHelper.mockGoogleTokenRequest(userToken, nonAdminEmail)

      it "doesn't allow GET", (done) ->
        leagueGetRequest(@league.id, userToken).expect(403, done)

      it "doesn't allow admin creation", (done) ->
        leagueCreateAdminRequest(@league.id, userToken).expect(403, done)

      it 'allows GET if league is public', (done) ->
        @league.set('public', true)
        @league.save().then =>
          leagueGetRequest(@league.id, userToken).expect(200, done)

    describe 'when user has admin without write', ->
      beforeEach ->
        specHelper.mockGoogleTokenRequest(userToken, readAdminEmail)

      it "allows GET", (done) ->
        leagueGetRequest(@league.id, userToken).expect(200, done)

      it "doesn't allow admin creation", (done) ->
        leagueCreateAdminRequest(@league.id, userToken).expect(403, done)

    describe 'when user has write admin', ->
      beforeEach ->
        specHelper.mockGoogleTokenRequest(userToken, writeAdminEmail)

      it "allows GET", (done) ->
        leagueGetRequest(@league.id, userToken).expect(200, done)

      it "allows admin creation", (done) ->
        leagueCreateAdminRequest(@league.id, userToken).expect(201, done)
