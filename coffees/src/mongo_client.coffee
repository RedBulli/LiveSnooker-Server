assert = require 'assert'

class MongoClient
  connect: (callback) ->
    require('mongodb').MongoClient.connect process.env.MONGOHQ_URL, (err, db) =>
      assert.equal null, err
      @connection = db
      callback()

  getCollection: (collectionName) ->
    @connection.collection collectionName

  insert: (collection, data, callback) ->
    @getCollection(collection).insert [data], (err, result) ->
      assert.equal err, null
      callback result

  find: (collection, query, callback) ->
    @getCollection(collection).find query, (err, result) ->
      assert.equal err, null
      callback result

module.exports = MongoClient
