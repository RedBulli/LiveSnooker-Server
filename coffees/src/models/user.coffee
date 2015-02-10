userSchema =
  auth_id: { type: String, required: true }
  vendor: { type: String, required: true }
  email: { type: String, required: true }

module.exports = (mongoose) ->
  User = mongoose.model('User', new mongoose.Schema(userSchema))

  User.findOrCreate = (userData, callback) ->
    User.findOne {auth_id: userData.auth_id, vendor: 'google'}, (err, user) ->
      if user
        callback(err, user)
      else
        User.create(userData, callback)

  User
