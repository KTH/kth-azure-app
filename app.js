var express = require('express');
var os = require('os');
var app = express();
var redis = require('redis');

var redisClientConfig = {
  'host': 'redis',
  'port': process.env.REDIS_PORT_6379_TCP_PORT
};

app.get('/', function (req, res) {

  //console.log("Got request")

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
      res.send("Error " + err);
  });

  client.set("my-host", os.hostname(), function (err, reply) {
    if (err) {
      console.log(err);
    }
    client.get("my-host", function(err, value) {
      console.log('Wrote and got key: ' + value)
      res.send(
          "<p><strong>OS:</strong>" + os.hostname() + "</p>" +
          "<p><strong>Redis value:</strong>" + value + "</p>" +
          "<p>" + redisClientConfig.host + "</p>");
    });

  });

});

app.listen(3000, function () {
  console.log('NodeJS running on port 3000');
});
