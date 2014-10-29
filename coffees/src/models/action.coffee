module.exports = class Action
  @attemptOptions: ["pot", "shot_to_nothing", "safety"]
  @resultOptions: ["pot", "no_pots", "foul"]
  
  constructor: ->
    @actionNo
    @frame
    @player
