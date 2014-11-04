_ = require 'underscore'

module.exports = class Action
  @attemptOptions: ["pot", "shot_to_nothing", "safety"]
  @resultOptions: ["pot", "no_pots", "foul"]

  constructor: (options) ->
    _.extend @, options

  toObject: ->
    frame_id: @frame.id
    player_id: @player.id
    attempt: @attempt
    result: @result
    points: @points

  toJSON: ->
    JSON.stringify(@toObject())
