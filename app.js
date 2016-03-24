var express = require('express');
var os = require('os');
var app = express();
var redis = require('redis');

var redisClientConfig = {
  'host': 'redis-v3.local'
  // 'host': '192.168.99.100'
};

app.get('/', function (req, res) {

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
      res.send("Error " + err);
  });

  client.set("my-key", "1337", function (err, reply) {
    if (err) {
      console.log(err);
    }
    client.get("my-key", function(err, value) {
      res.send(
          "<p><strong>host:</strong> " + os.hostname() + "</p>" +
          "<p><strong>redis value:</strong>" + value + "</p>");
    });

  });

});

app.listen(3000, function () {
  console.log('NodeJS running on port 3000');
});
