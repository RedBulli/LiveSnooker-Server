module.exports = class Frame
  constructor: (@framePlayers) ->
    @winner = null
    @inTurn = @framePlayers?[0]
