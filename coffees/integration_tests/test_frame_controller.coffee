expect = require('chai').expect
FrameController = rootRequire 'controllers/frame_controller'

xdescribe 'FrameController', ->
  frameController = new FrameController()

  describe '#act', ->
    createdAction = fixtures.Action()
    before (done) ->
      frameController.act(createdAction, done)
    
    xit 'stores the action', (done) ->
      done()
      # Should grow by 1
