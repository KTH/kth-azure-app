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

app.get('/_azure/_monitor', function (req, res) {
  res.set("Content-Type", "text/plain");
  res.send("APPLICATION: OK");
});

app.get('/_azure/_monitor/', function (req, res) {
  var result = {
    'redis-host' : redisClientConfig.host,
    'redis-path' : "/redis",
    'hostname' : os.hostname()
  };

  res.json(result);

});

app.get('/_azure/_monitor/redis', function (req, res) {

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
      console.log("Error " + err);
  });

  client.set("a-key", "a-value", function (err) {
    client.quit();
    if (err) {
      console.log(err);
      res.status(500).json({"redis-status": "Failed to wite to Redis on " + redisClientConfig.host });
    }
    res.json({"redis-status": "ok" });
  });

});

app.get('/_azure/_monitor/redis-test', function (req, res) {

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
      client.quit();
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

app.get('/_azure/_monitor/scale-test', function (req, res) {

  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
    console.log("Error " + err);
  });

  var sV0 = "missing";
  var sV1 = "missing";

  client.get("scale-0", function(err, value) {
    if (err) {
      console.log(err);
      res.status(500).json({"redis-status": "Failed to read scale-0 from redis on " + redisClientConfig.host, "error" : err });
    }
    sV0 = value;

    client.get("scale-1", function(err, value) {
      if (err) {
        console.log(err);
        res.status(500).json({"redis-status": "Failed to read scale-1 from redis on " + redisClientConfig.host, "error" : err });
      }
      sV1 = value

      client.quit();
      res.json({ "scale-0" : sV0, "scale-1" : sV1 });
    });

  });

});

// -- Errors --
// If the request ends up here none of the rules above have returned any response
// so then its time for som error handling
app.use(function(req, res){
  res.send(404, "404 - KTH Azure App - No route or static file matched ''" + req.url + "'." )
});

app.listen(3000, function () {
  console.log('NodeJS running on port 3000');
});
