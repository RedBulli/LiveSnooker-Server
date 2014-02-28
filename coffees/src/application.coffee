module.exports.listen = (port) ->
  createApp().listen(port)

createApp = () ->
  express = require('express')
  app = express()

  allowCrossDomain = (req, res, next) ->
    res.header('Access-Control-Allow-Origin', '*')
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    res.header(
      'Access-Control-Allow-Headers', 
      'Content-Type, Content-Length, X-Requested-With'
    )
    #res.header('Access-Control-Allow-Credentials', 'true')
    if 'OPTIONS' == req.method
      res.send(200)
    else
      next()

  app.configure ->
    app.use(allowCrossDomain)
    app.use(express.bodyParser())

  app.get '/users/me', (req, res) ->
    res.writeHead(200, {'Content-Type': 'text/html'})
    res.write('')
    res.end()

  return app
