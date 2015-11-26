request = require('supertest')

describe 'Account controller', ->
  app = null
  before (done) ->
    appInit.then (application) ->
      app = application
      done()

  it 'without a token returns 401', (done) ->
    request(app)
      .get('/account')
      .expect(401, done)
