should = require('chai').should()

describe 'server', ->
  it 'should allow cors', (done) ->
    server = require('./../src/application').listen(4000)
    corsLib = require('cors-tester')
    corsLib.simpleTest 'http://localhost:4000/users/me', (returnValue)->
      returnValue.should.equal 'Success!'
      done()
