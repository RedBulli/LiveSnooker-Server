var models = require('../models');
var calculateFrameStats = require('../build/lib/calculate_frame_stats');
var _ = require('underscore');

console.log("Truncating stats");
var truncation = Promise.all([models.Break.truncate(), models.FrameStats.truncate()]);
truncation.then(function() {
  return models.Frame.findAll().then(recalculate);
}).then(function() {
  console.log("DONE");
  process.exit();
});

function recalculate(frames) {
  console.log("Calculating frames: " + frames.length);
  return Promise.all(
    _.map(frames, function(frame) {
      console.log(".");
      return calculateFrameStats(frame);
    })
  );
}
