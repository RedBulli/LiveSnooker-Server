_ = require 'underscore'

module.exports = class Action
  @attemptOptions: ["pot", "shot_to_nothing", "safety"]
  @resultOptions: ["pot", "nothing", "foul"]

  constructor: (options) ->
    _.extend @, options

  toObject: ->
    frame_id: @frame.id
    player_id: @player.id
    attempt: @attempt
    foul: @foul
    points: @points

  toJSON: ->
    JSON.stringify(@toObject())
