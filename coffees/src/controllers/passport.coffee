User = require './../models/user'

module.exports = (app) ->
  passport = require('passport')
  GoogleStrategy = require('passport-google-oauth').OAuth2Strategy

  passport.serializeUser (user, done) ->
    done(null, user.toJSON())

  passport.deserializeUser (userJSON, done) ->
    done(null, User.deserialize(userJSON))

  passport.use(new GoogleStrategy({
      clientID: process.env.GOOGLE_OAUTH_APP_KEY,
      clientSecret: process.env.GOOGLE_OAUTH_APP_SECRET,
      callbackURL: process.env.WEB_URL + "/auth/google/callback"
    },
    (token, tokenSecret, profile, done) ->
      User.findOrCreate { profile: profile }, (err, user) ->
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

  # Use only Google authentication for now
  app.get '/authenticate', (req, res) ->
    res.redirect('/auth/google')

  app.get('/auth/google',
    passport.authenticate('google',
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
    )
  )

  app.get('/auth/google/callback',
    passport.authenticate(
      'google', 
      { 
        successRedirect: '/authenticated',
        failureRedirect: '/not-authenticated',
        failureFlash: true
      }
    )
  )
