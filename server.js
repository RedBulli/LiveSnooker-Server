var listen_port = Number(process.env.PORT || 5000);
var express = require('express'),
    redis = require("redis");
var publisherClient = createClient();
var currentFrame = '{"p1": "Sampo", "p2": "Mikko", "points1": 0, "points2": 0, "frames1": 0, "frames2": 0, "bestOf": 7}';

function createClient() {
  if (process.env.REDISTOGO_URL) {
    var rtg   = require("url").parse(process.env.REDISTOGO_URL);
    client = redis.createClient(rtg.port, rtg.hostname);
    client.auth(rtg.auth.split(":")[1]);
  } else {
    client = redis.createClient();
  }
  return client;
}


var allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');

    // intercept OPTIONS method
    if ('OPTIONS' == req.method) {
      res.send(200);
    }
    else {
      next();
    }
};

var app = express();
app.configure(function () {
  app.use(allowCrossDomain);
});
app.use(express.bodyParser());

app.get('/framestream', function(req, res) {
  req.socket.setTimeout(Infinity);

  var messageCount = 0;
  var subscriber = createClient();

  subscriber.subscribe('updates');

  subscriber.on('error', function(err) {
    console.log('Redis Error: ' + err);
  });

  subscriber.on('subscribe', function(err) {
    publisherClient.publish('updates', currentFrame);
  });

  subscriber.on('message', function(channel, message) {
    messageCount++;
    res.write('id: ' + messageCount + '\n');
    res.write("data: " + message + '\n\n');
  });

  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  });
  res.write('\n');

  req.on('close', function() {
    subscriber.unsubscribe();
    subscriber.quit();
  });
});

app.post('/update_frame', function(req, res) {
  var currentFrame = JSON.stringify(req.body);
  publisherClient.publish('updates', currentFrame);
  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write('Published: ' + currentFrame);
  res.end();
});

app.listen(listen_port);
console.log('Express server listening on port %d', listen_port);

