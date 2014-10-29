_ = require 'underscore'
sequences = {}

global.fixtures =
  sequence: (name) ->
    current = sequences[name] || 0
    sequences[name] = current + 1

  actionFormData: (data = {}) ->
    frameId = fixtures.sequence 'frame-id'
    playerId = fixtures.sequence 'player-id'
    defaults =
      frame_id: frameId
      player_id: playerId
      attempt: "pot"
      result: "pot"
      points: 7

    data = _.extend defaults, data
