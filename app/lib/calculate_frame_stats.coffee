models  = require '../../models'
_ = require 'underscore'

module.exports = (frame) ->
  findAllShots(frame).then (shots) ->
    models.sequelize.transaction (transaction) ->
      Promise.all([
        saveBreakModels(calculateBreaks(shots), transaction),
        saveFrameStats(frame, calculateFrameStats(frame, shots), transaction)
      ])

findAllShots = (frame) ->
  models.Shot.findAll({
    where: {FrameId: frame.id}
    order: [['shotNumber', 'ASC']]
  })

saveBreakModels = (breakStats, transaction) ->
  Promise.all(
    _.map(breakStats, (singleBreakStats) ->
      models.Break.create(singleBreakStats, {transaction: transaction})
    )
  )

saveFrameStats = (frame, frameStats, transaction) ->
  stats = _.map([frame.Player1Id, frame.Player2Id], (playerId) ->
    _.extend(frameStats[playerId], {
      PlayerId: playerId,
      FrameId: frame.id
    })
  )
  console.log("stats", stats)
  Promise.all([
    models.FrameStats.create(stats[0], {transaction: transaction}),
    models.FrameStats.create(stats[1], {transaction: transaction})
  ])

calculateBreaks = (shots) ->
  _.reduce(shots, (memo, shot) ->
    if shot.result == 'pot'
      lastBreak = _.last(memo)
      if lastBreak?.shotNumberStart == (shot.shotNumber - lastBreak?.shots)
        lastBreak.shots++
        lastBreak.points += shot.points
      else
        memo.push
          FrameId: shot.FrameId
          PlayerId: shot.PlayerId
          shotNumberStart: shot.shotNumber
          shots: 1
          points: shot.points
    memo
  , [])

calculateFrameStats = (frame, shots) ->
  frameStats = _.reduce(shots, (memo, shot) ->
    playerStats = memo[shot.PlayerId]

    if memo.previousShotSafetyBy && memo.previousShotSafetyBy != shot.PlayerId && shot.result == 'pot'
      memo[memo.previousShotSafetyBy].safetyFailCount++
    memo.previousShotSafetyBy = undefined

    if shot.attempt == 'pot'
      playerStats.potAttempts++
      playerStats.potsFromPotAttempts++ if shot.result == 'pot'
    else if shot.attempt == 'safety'
      playerStats.safetyAttempts++
      if shot.result == 'pot'
        playerStats.potsFromSafeties++
      else
        memo.previousShotSafetyBy = shot.PlayerId

    if shot.result == 'pot'
      playerStats.totalPoints += shot.points
    else if shot.result == 'foul'
      playerStats.failCount++
      playerStats.failPoints += shot.points
    memo
  , initialStats(frame))
  delete frameStats.previousShotSafetyBy
  frameStats

initialStats = (frame) ->
  stats = {
    safetyAttempt: undefined
  }
  stats[frame.Player1Id] = initialPlayerStats()
  stats[frame.Player2Id] = initialPlayerStats()
  stats

initialPlayerStats = ->
  potAttempts: 0
  safetyAttempts: 0
  potsFromPotAttempts: 0
  potsFromSafeties: 0
  safetyFailCount: 0
  totalPoints: 0
  failCount: 0
  failPoints: 0
