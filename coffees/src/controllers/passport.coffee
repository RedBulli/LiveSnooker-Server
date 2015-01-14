User =
  findOrCreate: (data, callback) ->
    console.log(data)
    callback(null, {username: "sampo"})

module.exports = (app) ->
  passport = require('passport')
  GoogleStrategy = require('passport-google').Strategy

  passport.serializeUser (userObj, done) ->
    done(null, JSON.stringify(userObj))

  passport.deserializeUser (userJSON, done) ->
    done(null, JSON.parse(userJSON))

  passport.use(new GoogleStrategy({
      returnURL: 'http://localhost:5000/auth/google/return',
      realm: 'http://localhost:5000/'
    },
    (identifier, profile, done) ->
      User.findOrCreate { openId: identifier }, (err, user) ->
       done(err, user)
  ))

  app.get('/auth/google', passport.authenticate('google'))

  app.get('/auth/google/return', 
    passport.authenticate(
      'google', 
      { 
        successRedirect: '/',
        failureRedirect: '/login',
        failureFlash: true
      }
    )
  )
