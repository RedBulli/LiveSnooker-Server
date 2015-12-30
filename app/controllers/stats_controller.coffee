express = require 'express'
models  = require '../../models'
_ = require 'underscore'

getAllBreaksForPlayer = (player) ->
  models.Break.findAll
    where: {PlayerId: player.id}
    include: [{ model: models.Frame }]
    order: [['id', 'ASC']]

getOverallStats = (player) ->
  intKeys = ['sum_points', 'pots', 'misses']
  new Promise (resolve, reject) ->
    query = """
      SELECT
        SUM(CASE WHEN "result" = 'pot' THEN "points" ELSE 0 END) AS "sum_points",
        COUNT(CASE WHEN "result" = 'pot' THEN 1 ELSE null END) AS "pots",
        COUNT(CASE WHEN "result" != 'pot' AND "attempt" = 'pot' THEN 1 ELSE null END) AS "misses"
      FROM (
        SELECT "attempt", "result", "points" FROM "Shots" WHERE "PlayerId" = '55b11711-71f8-4fc1-a1da-a5aeeead145e'
      ) AS allShots;
    """
    models.sequelize.query(query).then (res) ->
      result = res[0][0]
      for key in intKeys
        result[key] = parseInt(result[key])
      resolve(result)

module.exports = ->
  router = express.Router()

  router.get '/', (request, response) ->
    getOverallStats(request.player).then (stats) ->
      response.json stats

  router.get '/full', (request, response) ->
    getAllBreaksForPlayer(request.player).then (shots) ->
      response.json shots
