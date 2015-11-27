models = require '../models'
_ = require 'underscore'
nock = require 'nock'

TRUNCATE_SCRIPT = """
CREATE OR REPLACE FUNCTION truncate_tables() RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;
"""

createTruncateScript = ->
  models.sequelize.query(TRUNCATE_SCRIPT)

cleanDatabase = ->
  models.sequelize.query('SELECT truncate_tables();')

cleanRedis = (done) ->
  if process.env.REDIS_NAMESPACE
    redisClient = $app.get('redisClient')
    redisClient.keysAsync(process.env.REDIS_NAMESPACE + '*').then (keys) ->
      if keys.length > 0
        keysWithoutPrefix = _.map(keys, (key) -> key.replace(/^test:/, ''))
        redisClient.delAsync(keysWithoutPrefix).then (res) ->
          done()
      else
        done()
  else
    done()

initApplication = (done) ->
  appInit.then (application) ->
    global.$app = application
    createTruncateScript().then ->
      done()

googleTokenRequest = (token) ->
  nock('https://www.googleapis.com')
    .get('/oauth2/v2/tokeninfo')
    .query(id_token: token)

mockGoogleTokenRequest = (token, email, opts) ->
  opts = opts || {}
  response =
    issued_to: process.env.GOOGLE_CLIENT_ID,
    audience: process.env.GOOGLE_CLIENT_ID,
    user_id: '1234567890',
    expires_in: opts['expires_in'] || 3277,
    email: email,
    verified_email: true
  status = opts['status'] || 200
  googleTokenRequest(token)
    .reply status, response

cleanMockResponses = ->
  nock.cleanAll()

before initApplication
afterEach cleanDatabase
afterEach cleanRedis
afterEach cleanMockResponses

module.exports =
  mockGoogleTokenRequest: mockGoogleTokenRequest
