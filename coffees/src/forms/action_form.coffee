validators = require './validators'
Form = require './form'
Action = require './../models/action'
Frame = require './../models/frame'
Player = require './../models/player'

module.exports = class ActionForm extends Form
  fields:
    frame_id: [
      new validators.RequiredValidator,
      new validators.IntegerValidator
    ]
    player_id: [
      new validators.RequiredValidator,
      new validators.IntegerValidator
    ]
    attempt: [
      new validators.RequiredValidator,
      new validators.OptionValidator(Action.attemptOptions)
    ]
    result: [
      new validators.RequiredValidator,
      new validators.OptionValidator(Action.resultOptions)
    ]
    points: [
      new validators.RequiredValidator,
      new validators.IntegerValidator(min: 0, max: 16)
    ]

  getPopulatedModel: (requestBody) ->
    validatedValues = @getValidatedValues(requestBody)
    action = new Action()
    #Frame.find(validatedValues.frame_id)
    action.frame = new Frame({id: validatedValues.frame_id})
    # Player.find(validatedValues.player_id)
    action.player = new Player({id: validatedValues.player_id})
    action.attempt = validatedValues.attempt
    action.result = validatedValues.result
    action.points = validatedValues.points
    action
