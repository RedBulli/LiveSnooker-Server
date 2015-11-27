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

cleanDatabase = (done) ->
  models.sequelize.query('SELECT truncate_tables();').then -> done()

initApplication = (done) ->
  appInit.then (application) ->
    global.$app = application
    createTruncateScript().then ->
      done()

googleTokenRequest = (token) ->
  nock('https://www.googleapis.com')
    .get('/oauth2/v2/tokeninfo')
    .query(id_token: token)

mockGoogleTokenRequest = (token, email, status) ->
  response =
    issued_to: process.env.GOOGLE_CLIENT_ID,
    audience: process.env.GOOGLE_CLIENT_ID,
    user_id: '1234567890',
    expires_in: 3277,
    email: email,
    verified_email: true
  status = status || 200
  googleTokenRequest(token)
    .reply status, response

before initApplication
afterEach cleanDatabase

module.exports =
  mockGoogleTokenRequest: mockGoogleTokenRequest
