express = require 'express'
models  = require '../../models'
_ = require 'underscore'

frameStatKeys = [
  'totalPoints',
  'potAttempts',
  'safetyAttempts',
  'potsFromPotAttempts',
  'potsFromSafeties',
  'totalPoints',
  'failCount',
  'failPoints'
]

module.exports = ->
  router = express.Router()

  router.get '/', (request, response) ->
    getOverallStats(request.player)
      .then (stats) ->
        response.json stats
      .catch (error) ->
        console.error error
        response.status(500).json(error: error)

  router.get '/full', (request, response) ->
    Promise.all([
      getAllBreaksForPlayer(request.player),
      getFrameStats(request.player)
    ])
      .then (result) ->
        response.json
          breaks: result[0]
          frameStats: result[1]
      .catch (error) ->
        console.error error
        response.status(500).json(error: error)

getAllBreaksForPlayer = (player) ->
  models.Break.findAll
    where: {PlayerId: player.id}
    include: [{ model: models.Frame }]
    order: [['id', 'ASC']]

getFrameStats = (player) ->
  models.FrameStats.findAll
    where: {PlayerId: player.id}
    include: [{ model: models.Frame }]
    order: [['id', 'ASC']]

getOverallStats = (player) ->
  models.FrameStats.find(
    where: { PlayerId: player.id }
    attributes: _.map(frameStatKeys, (key) ->
      [models.sequelize.fn('SUM', models.sequelize.col(key)), key]
    )
  ).then (result) -> _.mapObject(result.dataValues, parseInt)
