var express = require('express');
var os = require('os');
var app = express();
var redis = require('redis');

var redisClientConfig = {
  'host': 'redis'
};

var start = process.hrtime();

var elapsed_time = function(note){
  var precision = 3; // 3 decimal places
  var elapsed = process.hrtime(start)[1] / 1000000; // divide by a million to get nano to milli
  var value = process.hrtime(start)[0] + " s, " + elapsed.toFixed(precision) + " ms - " + note; // print message + time
  start = process.hrtime(); // reset the timer
  return value;
};

app.get('/', function (req, res) {
  var result = {
    'redis-host' : redisClientConfig.host,
    'redis-path' : "/redis",
    'hostname' : os.hostname()
  };

  res.json(result);

});

app.get('/redis', function (req, res) {

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
      console.log("Error " + err);
  });

  client.set("a-key", "a-value", function (err) {
    if (err) {
      console.log(err);
      res.status(500).json({"redis-status": "Failed to wite to Redis on " + redisClientConfig.host });
    }
    res.json({"redis-status": "ok" });
  });

});

app.get('/redis-test', function (req, res) {

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
      console.log("Error " + err);
  });

  start = process.hrtime();

  console.log("Writing 1000 keys to redis");

  for (var i = 0; i <= 999; i++) {

    client.set("key-" + i, "value-" + i, function (err) {
      if (err) {
        console.log(err);
      }
    });
  }

  client.set("key-1000", "value-1000", function (err) {
    if (err) {
      console.log(err);
    }
    client.get("key-1000", function(err, value) {
      console.log("Read last key from redis");
      var result = {
        'performance' : elapsed_time("wrote 1000 keys to redis"),
        'last_key_value' : value,
        'os.hostname' : os.hostname()
      };
      if (result) {
        res.json(JSON.stringify(result));
      }
    });

  });

});

app.listen(3000, function () {
  console.log('NodeJS running on port 3000');
});
