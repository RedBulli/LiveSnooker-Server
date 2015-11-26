request = require 'supertest'
nock = require 'nock'
expect = require('chai').expect

describe 'Account controller', ->
  app = null
  before (done) ->
    appInit.then (application) ->
      app = application
      done()

  describe 'without authentication', ->
    it 'returns 401', (done) ->
      request(app)
        .get('/account')
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
      request(app)
        .get '/account'
        .set 'x-auth-google-id-token', token
        .expect (res) ->
          expect(res.body)
            .to.have.deep.property('user.email', 'sampo.verkasalo@gmail.com')
        .expect(200, done)
