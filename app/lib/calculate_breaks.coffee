models  = require '../../models'
_ = require 'underscore'

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

saveBreakModels = (breakStats) ->
  models.sequelize.transaction (transaction) ->
    Promise.all(
      _.map(breakStats, (singleBreakStats) ->
        models.Break.create(singleBreakStats, {transaction: transaction})
      )
    )

findAllShots = (frame) ->
  models.Shot.findAll({
    where: {FrameId: frame.id}
    order: [['shotNumber', 'ASC']]
  })

module.exports = (frame) ->
  findAllShots(frame)
    .then calculateBreaks
    .then saveBreakModels
