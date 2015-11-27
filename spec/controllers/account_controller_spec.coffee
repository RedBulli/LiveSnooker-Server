request = require 'supertest'
expect = require('chai').expect
models = require '../../models'
specHelper = require '../spec_helper'

describe 'Account controller', ->
  describe 'without authentication', ->
    it 'returns 401', (done) ->
      request($app)
        .get('/account')
        .expect(401, done)

  describe 'with authentication', ->
    token = '123456'
    userEmail = 'test@example.com'
    beforeEach ->
      specHelper.mockGoogleTokenRequest(token, userEmail)

    accountRequest = ->
      request($app)
        .get '/account'
        .set 'x-auth-google-id-token', token

    it 'creates the user', (done) ->
      accountRequest()
        .expect ->
          models.User.count(where: {email: 'test@example.com'})
            .then (count) ->
              expect(count).to.eql 1
        .expect(200, done)

    it 'returns the user', (done) ->
      accountRequest()
        .expect (res) ->
          expect(res.body)
            .to.have.deep.property('user.email', 'test@example.com')
        .expect(200, done)

    describe 'authentication middleware', ->
      it 'caches the user data from Google', (done) ->
        accountRequest().end ->
          secondRequestMock = specHelper.mockGoogleTokenRequest(token, userEmail, 400)
          accountRequest()
            .expect ->
              expect(secondRequestMock.isDone()).to.eql false
            .expect(200, done)

