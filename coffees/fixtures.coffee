_ = require 'underscore'
sequences = {}
Action = rootRequire 'models/action'
Player = rootRequire 'models/player'
Frame = rootRequire 'models/frame'

global.fixtures =
  sequence: (name) ->
    current = sequences[name] || 0
    sequences[name] = current + 1

  Frame: (data = {}) ->
    defaults =
      id: fixtures.sequence 'frame-id'
    data = _.extend defaults, data
    new Frame data

  Player: (data = {}) ->
    defaults =
      id: fixtures.sequence 'player-id'
    data = _.extend defaults, data
    new Player data

  Action: (data = {}) ->
    defaults =
      frame: data["frame"] || fixtures.Frame()
      player: data["player"] || fixtures.Player()
      attempt: "pot"
      foul: false
      points: 7
    data = _.extend defaults, data
    new Action data

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
