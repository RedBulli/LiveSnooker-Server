User = require './../models/user'

module.exports = (app) ->
  passport = require('passport')
  GoogleStrategy = require('passport-google').Strategy

  passport.serializeUser (user, done) ->
    done(null, user.toJSON())

  passport.deserializeUser (userJSON, done) ->
    done(null, User.deserialize(userJSON))

  passport.use(new GoogleStrategy({
      returnURL: 'http://localhost:5000/auth/google/return',
      realm: 'http://localhost:5000/'
    },
    (identifier, profile, done) ->
      User.findOrCreate { openId: identifier, profile: profile }, (err, user) ->
       done(err, user)
  ))

  app.get '/authenticated', (req, res) ->
    if req.user
      res.send('You have successfully authenticated to LiveSnooker! You can now safely close this window.')
    else
      res.redirect('/authenticate')

  app.get '/not-authenticated', (req, res) ->
    res.set('Content-Type', 'text/html')
    res.send(
      'Failed to authenticate: ' + JSON.stringify(req.flash()) +
      '<br><a href="/authenticate">Try again</a>'
    )

  # Use only Google auth for now
  app.get '/authenticate', (req, res) ->
    res.redirect('/auth/google')

  app.get('/auth/google', passport.authenticate('google'))

  app.get('/auth/google/return', 
    passport.authenticate(
      'google', 
      { 
        successRedirect: '/authenticated',
        failureRedirect: '/not-authenticated',
        failureFlash: true
      }
    )
  )
