models  = require '../../models'
_ = require 'underscore'

module.exports = (frame) ->
  findAllShots(frame).then (shots) ->
    models.sequelize.transaction (transaction) ->
      breaks = calculateBreaks(shots)
      Promise.all([
        saveBreakModels(breaks, transaction),
        saveFrameStats(frame, calculateFrameStats(frame, shots, breaks), transaction)
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

calculateFrameStats = (frame, shots, breaks) ->
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
  biggestBreaks = calculateBiggestBreaks(frame, breaks)
  frameStats[frame.Player1Id].biggestBreak = biggestBreaks[frame.Player1Id]
  frameStats[frame.Player2Id].biggestBreak = biggestBreaks[frame.Player2Id]
  frameStats

calculateBiggestBreaks = (frame, breaks) ->
  init = {}
  init[frame.Player1Id] = 0
  init[frame.Player2Id] = 0
  _.reduce(breaks, (memo, breakObj) ->
    memo[breakObj.PlayerId] = breakObj.points if memo[breakObj.PlayerId] < breakObj.points
    memo
  , init);

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
