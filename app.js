var express = require('express');
var os = require('os');
var app = express();
var redis = require('redis');
var about = require('./config/version');
var mongoose = require('mongoose');
const packageFile = require('./package.json')
var log = require('kth-node-log')

let logConfiguration = {
  name: packageFile.name,
  app: packageFile.name,
  env: 'dev',
  level: 'DEBUG',
  console: false,
  stdout: true,
  src: true
}

log.init(logConfiguration)

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

app.get('/_azure/_monitor/logging', function(req, res) {
  log.trace('Logging with level TRACE')
  log.debug('Logging with level DEBUG')
  log.info('Logging with level INFO')
  log.warn('Logging with level WARN')
  log.error('Logging with level ERROR')
  log.error(new Error('This is a logged error'))
  log.fatal('Logging with level FATAL')
  res.status(200).send('Logging done')
})

function fib(n) {
  if (n < 2) {
    return 1;
  } else {
    return fib(n - 2) + fib(n - 1);
  }
}

app.get('/_azure/_monitor/stress', function(req, res) {
  fib(10000)
  res.status(200).send('Stress test done') 
})

app.get('/_azure/_about', function (req, res) {
  res.set("Content-Type", "text/plain");
  const msg = "Docker version: " + about.dockerVersion + "\n" +
    "Docker name: " + about.dockerName + "\n" +
    "Jenkins build: " + about.jenkinsBuild + "\n" +
    "Jenkins build date: " + about.jenkinsBuildDate + "\n" +
    "Git branch: " + about.gitBranch + "\n" +
    "Git commit: " + about.gitCommit + ""
  res.status(200).send(msg);
});


app.get('/_azure/_monitor', function (req, res) {
  res.set("Content-Type", "text/plain");
  res.status(200).send("APPLICATION: OK");
});

app.get('/_azure/_monitor/', function (req, res) {
  var result = {
    'redis-host' : redisClientConfig.host,
    'redis-path' : "/redis",
    'hostname' : os.hostname()
  };
  res.status(200).send(result);
});



// Connect to mongodb
var connect = function () {
  options = {
    dbUsername: process.env.AZURE_DOCUMENTDB_USERNAME,
    dbPassword: process.env.AZURE_DOCUMENTDB_PASSWORD,
    dbUri: process.env.AZURE_DOCUMENTDB_URI,
    logger: console.log,
    server: { socketOptions: { keepAlive: 1 } }
  }
  try {
    mongoose.connect(process.env.AZURE_DOCUMENTDB_URI, options);
  } catch (ex) {
    res.status(500).send({"Error" : "" + ex })
  }
};

app.get('/_azure/_monitor/documentdb', function (req, res) {

  try {

    connect();

    mongoose.connection.on('error', console.log);

    res.status(200).send({"Connection": true})

  } catch (ex) {
    res.status(500).send({"Error" : "" + ex })
  }

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
        res.json(result)
      }
    });

  });

});

app.post('/_azure/_monitor/persistance', function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
    console.log("Error " + err);
  });

  client.set("persistance", "works", redis.print)
})

app.get('/_azure/_monitor/persistance', function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function (err) {
    console.log("Error " + err);
  });

  client.get("persistance", function(err, value) {
    if (err) {
      console.log(err);
      res.status(500).json({"redis-status": "Failed to read persistance from redis on " + redisClientConfig.host, "error" : err });
    }

    client.quit();
    res.json({ "persistance" : value }); 
  })

})

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
      res.status(200).send(JSON.stringify({ "scale-0" : sV0, "scale-1" : sV1 }))
    });

  });

});

// -- Errors --
// If the request ends up here none of the rules above have returned any response
// so then its time for som error handling
app.use(function(req, res){
  res.status(404).send({ "message" : "KTH Azure App - No route or static file matched ''" + req.url + "'.", "status": 404 })
});

app.listen(3000, function () {
  console.log('NodeJS running on port 3000');
});
