expect = require('chai').expect
FrameController = rootRequire 'controllers/frame_controller'

describe 'FrameController', ->
  frameController = new FrameController()

  describe '#act', ->
    createdAction = fixtures.Action()
    before (done) ->
      frameController.act(createdAction, done)
    
    xit 'stores the action to mongo', (done) ->
      frameController.mongoClient.find "actions",
        {
          frame_id: createdAction.frame.id
          player_id: createdAction.player.id
        },
        (result) ->
          # Should grow by 1
          done()
