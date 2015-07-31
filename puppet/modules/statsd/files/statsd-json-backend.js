// THIS FILE IS MANAGED BY PUPPET

// Simple statsd backend to show last flush in a file in proper
// JSON format so it can be processed by tools like jq

var fs = require('fs');

exports.init = function(startup_time, config, events) {
  events.on('flush', function(timestamp, metrics) {
    fs.writeFile('/vagrant/logs/statsd.json', JSON.stringify(metrics));
  });

  return true;
};
