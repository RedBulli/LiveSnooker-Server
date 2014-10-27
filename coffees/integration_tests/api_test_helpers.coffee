_ = require('underscore')

module.exports = (requestHandler) ->
  assertIntegerParameter: (options) ->
    describe 'parameter ' + options.parameter, () ->
      it 'returns 204 with ' + options.parameter  + ' ' + options.min + '
      ' + ' to ' + options.max, (done) ->
        postData = _.extend({}, options.otherParams)
        postData[options.parameter] = options.min
        response = requestHandler options.url, postData
        response.expect 204
        postData[options.parameter] = options.max
        response = requestHandler options.url, postData
        response.expect 204, done

      it 'returns 400 with ' + options.parameter + ' less than
      ' + ' ' + options.min + ' or higher than ' + options.max, (done) ->
        expectedErrorMessage = {}
        expectedErrorMessage[options.parameter] = '
          Should be an integer between ' + options.min + '-' + options.max

        postData = _.extend({}, options.otherParams)
        postData[options.parameter] = options.min - 1
        response = requestHandler options.url, postData
        response.expectBadRequest expectedErrorMessage

        postData[options.parameter] = options.max + 1
        response = requestHandler options.url, postData
        response.expectBadRequest expectedErrorMessage, done

      it 'returns 400 if ' + options.parameter + ' is not an int', (done) ->
        expectedErrorMessage = {}
        expectedErrorMessage[options.parameter] = 'Should be an integer'
        postData = _.extend({}, options.otherParams)
        postData[options.parameter] = 'one'
        response = requestHandler options.url, postData
        response.expectBadRequest expectedErrorMessage, done

      if options.required
        it 'returns 400 with no content', (done) ->
          expectedErrorMessage = {}
          expectedErrorMessage[options.parameter] = 'Required parameter'
          response = requestHandler options.url
          response.expectBadRequest expectedErrorMessage
          response = requestHandler options.url, {}
          response.expectBadRequest expectedErrorMessage, done

      it 'returns 400 if invalid json content', (done) ->
        response = requestHandler options.url, '
          {unquoted_key_is_not_allowed_in_json: 1}'
        response.expectBadRequest 'Invalid JSON', done
