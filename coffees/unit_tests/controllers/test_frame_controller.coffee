expect = require('chai').expect
FrameController = rootRequire 'controllers/frame_controller'

describe 'FrameController', ->
  frameController = new FrameController()

  describe '#act', ->
    it 'stores the action to redis'
