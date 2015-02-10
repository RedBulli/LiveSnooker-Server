userSchema =
  auth_id: { type: String, required: true }
  vendor: { type: String, required: true }
  email: { type: String, required: true }
  created_at: { type: Date, required: true }
  last_login: { type: Date, required: true }

module.exports = (mongoose) ->
  User = mongoose.model('User', new mongoose.Schema(userSchema))

  User.findOrCreate = (userData, callback) ->
    userData["last_login"] = new Date()
    User.findOneAndUpdate {auth_id: userData.auth_id, vendor: 'google'}, userData, (err, user) ->
      if user
        callback(err, user)
      else
        userData["created_at"] = userData["last_login"]
        User.create(userData, callback)

  User
