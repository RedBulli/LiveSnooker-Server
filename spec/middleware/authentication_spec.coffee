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

  it 'caches the user data from Google', (done) ->
    specHelper.mockGoogleTokenRequest(token, userEmail)
    accountRequest().end ->
      secondRequestMock = specHelper.mockGoogleTokenRequest(token, userEmail, {status: 400})
      accountRequest()
        .expect ->
          expect(secondRequestMock.isDone()).to.eql false
        .expect(200, done)
