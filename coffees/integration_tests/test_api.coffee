request = require 'supertest'
apiTesthelpers = require './api_test_helpers'
models  = require '../../models'

applyTestHelpers = (response) ->
  response.expectBadRequest = (message, done) ->
    response.expect 400
    response.expect {error: message}, done

describe 'rest api', ->
  server = null
  post = (url, content) ->
    response = request server
      .post url
      .set 'Accept', 'application/json'

    if content
      response.send content
      response.set 'Content-Type', 'application/json'
    applyTestHelpers(response)
    response

  helpers = apiTesthelpers(post)

  before (done) ->
    rootRequire('application').listen 4000, (serverApp) ->
      server = serverApp
      done()

  after ->
    server.close()

  describe 'POST /action', ->
    url = '/action'

    describe 'parameter points', ->
      validFormData = fixtures.actionFormData()
      delete validFormData.points
      helpers.assertIntegerParameter
        otherParams: validFormData
        parameter: 'points'
        url: url
        min: 0
        max: 16
        required: true

  describe 'POST /player', ->
    url = '/players'
    league = null

    before (done) ->
      models.League.findOne({}).then (foundLeague) ->
        if foundLeague
          league = foundLeague
          done()
        else
          models.League.create({name: "Test"}).then (newLeague) ->
            league = newLeague
            done()

    it 'should work', (done) ->
      response = post('/players/', {name: "Sampo", LeagueId: league.id})
      response.expect 201
      models.Player.destroy({truncate: true, cascade: true}).then(-> done())
