models = require '../models'

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

before initApplication
afterEach cleanDatabase
