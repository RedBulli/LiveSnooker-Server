validators = require './validators'
Form = require './form'
Action = require './../models/action'
#Frame = require './../models/frame'
#Player = require './../models/player'

module.exports = class ActionForm extends Form
  fields:
    FrameId: [
      new validators.RequiredValidator,
      new validators.IntegerValidator
    ]
    PlayerId: [
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
    action.frame = {id: validatedValues.FrameId}
    # Player.find(validatedValues.player_id)
    action.player = {id: validatedValues.PlayerId}
    action.attempt = validatedValues.attempt
    action.foul = validatedValues.foul || false
    action.points = validatedValues.points
    action
