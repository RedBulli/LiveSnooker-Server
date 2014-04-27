should = require('chai').should()
request = require 'supertest'

applyTestHelpers = (response) ->
  response.expectBadRequest = (message, done) ->
    response.expect 400
    response.expect {error: message}, done

copyObject = (object) ->
  copiedObj = {}
  for key in Object.keys object
    copiedObj[key] = object[key]
  return copiedObj

assertIntegerParameter = (options) ->
  describe 'parameter ' + options.parameter, () ->
    it 'should return 204 with ' + options.parameter  + ' ' + options.min + ' 
    ' + ' to ' + options.max, (done) ->
      postData = copyObject(options.otherPostData)
      postData[options.parameter] = options.min
      response = options.post options.url, postData
      response.expect 204
      postData[options.parameter] = options.max
      response = options.post options.url, postData
      response.expect 204, done

    it 'should return 400 with ' + options.parameter + ' less than 
    ' + ' ' + options.min + ' or higher than ' + options.max, (done) ->
      expectedErrorMessage = {}
      expectedErrorMessage[options.parameter] = '
        Should be an integer between ' + options.min + '-' + options.max

      postData = copyObject(options.otherPostData)
      postData[options.parameter] = options.min - 1
      response = options.post options.url, postData
      response.expectBadRequest expectedErrorMessage

      postData[options.parameter] = options.max + 1
      response = options.post options.url, postData
      response.expectBadRequest expectedErrorMessage, done

    it 'should return 400 if ' + options.parameter + ' is not an int', (done) ->
      expectedErrorMessage = {}
      expectedErrorMessage[options.parameter] = 'Should be an integer'
      postData = copyObject(options.otherPostData)
      postData[options.parameter] = 'one'
      response = options.post options.url, postData
      response.expectBadRequest expectedErrorMessage, done

    if options.required
      it 'should return 400 with no content', (done) ->
        expectedErrorMessage = {}
        expectedErrorMessage[options.parameter] = 'Required parameter'
        response = options.post options.url
        response.expectBadRequest expectedErrorMessage
        response = options.post options.url, {}
        response.expectBadRequest expectedErrorMessage, done

    it 'should return 400 if invalid json content', (done) ->
      response = options.post options.url, '
        {unquoted_key_is_not_allowed_in_json: 1}'
      response.expectBadRequest 'Invalid JSON', done

describe 'rest api', ->
  server = null

  before ->
    server = require('./../src/application').listen 4000

  post = (url, content) ->
    response = request server
      .post url
      .set 'Accept', 'application/json'

    if content
      response.send content
      response.set 'Content-Type', 'application/json'
    applyTestHelpers(response)
    return response

  describe 'POST /pot', ->
    url = '/pot'

    assertIntegerParameter({
      otherPostData: {}, 
      parameter: 'ball_value',
      url: url, 
      min: 1,
      max: 7,
      post: post,
      required: true,
    })

  describe 'POST /missed_pot', ->
    url = '/missed_pot'

    it 'should return 204', (done) ->
      response = post url
      response.expect 204, done

  describe 'POST /safety', ->
    url = '/safety'

    it 'should not require any parameters', (done) ->
      response = post url
      response.expect 204, done

    assertIntegerParameter({
      otherPostData: {}, 
      parameter: 'pot',
      url: url, 
      min: 1,
      max: 7,
      post: post,
      required: false,
    })

  after ->
    server.close()
