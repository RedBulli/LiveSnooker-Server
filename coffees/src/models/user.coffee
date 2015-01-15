Backbone = require 'backbone'

module.exports = class User extends Backbone.Model
  @findOrCreate: (data, callback) ->
    callback(null, new User(data))

  @deserialize: (userJSON) ->
    attributes = JSON.parse(userJSON)
    new User(attributes)
  
  toJSON: ->
    JSON.stringify(@attributes)
