var express = require("express");
var os = require("os");
var app = express();
var redis = require("redis");
var about = require("./config/version");
var mongoose = require("mongoose");
const packageFile = require("./package.json");
var log = require("kth-node-log");
var fs = require("fs");
var tmp = require("tmp");
const https = require("https");

let logConfiguration = {
  name: packageFile.name,
  app: packageFile.name,
  env: "dev",
  level: "DEBUG",
  console: false,
  stdout: true,
  src: true
};

log.init(logConfiguration);

var redisClientConfig = {
  host: "redis"
};

var start = process.hrtime();

var elapsed_time = function(note) {
  var precision = 3; // 3 decimal places
  var elapsed = process.hrtime(start)[1] / 1000000; // divide by a million to get nano to milli
  var value =
    process.hrtime(start)[0] +
    " s, " +
    elapsed.toFixed(precision) +
    " ms - " +
    note; // print message + time
  start = process.hrtime(); // reset the timer
  return value;
};

var stressTest = function() {
  const rand = process.hrtime()[1] % 3;

  if (rand === 0) {
    console.log("Stress test: Intentionally throw an error");
    throw "Stess test: This time the app crashed.";
  } else if (rand === 1) {
    let makeLarge = "this will be huge and make the app run out of mempry";
    console.log("Stress test: Forcing a RangeError: Invalid string length");
    while (true) {
      makeLarge = makeLarge + "add more bytes";
    }
  } else {
    const largeStr = (s = "#".repeat(100));
    var file = tmp.fileSync();
    var stream = fs.createWriteStream(file.name, {
      flags: "a"
    });
    console.log("Stress test: Writing a huge file: " + file.name);
    while (true) {
      stream.write(largeStr);
    }
  }
};

var allow_performance_test = function() {
  if (process.env.STRESS_TEST == null) {
    return false;
  }

  if (process.env.STRESS_TEST.toLowerCase() == "performance") {
    return true;
  }
};

app.get("/kth-azure-app/stressTestConnections", function(req, res) {
  if (!allow_performance_test()) {
    res.status(403).send("Forbidden");
    return;
  }

  let numberOfFiles = 1000;

  let html = "<!DOCTYPE html><html><title>Hej</title><body>";

  html += "<h1>1000 cats</h1>";

  for (i = 0; i < numberOfFiles; i++) {
    html += "<img src='files/cat-" + i + ".jpg' />";
  }
  html += "</body></html>";

  res.set("Content-Type", "text/html");
  res.status(200).send(html);
});

app.use("/kth-azure-app/files", express.static(__dirname + "/files"));

app.get("/kth-azure-app/logging", function(req, res) {
  log.trace("Logging with level TRACE");
  log.debug("Logging with level DEBUG");
  log.info("Logging with level INFO");
  log.warn("Logging with level WARN");
  log.error("Logging with level ERROR");
  log.error(new Error("This is a logged error"));
  log.fatal("Logging with level FATAL");
  res.status(200).send("Logging done");
});

function fib(n) {
  if (n < 2) {
    return 1;
  } else {
    return fib(n - 2) + fib(n - 1);
  }
}

app.get("/kth-azure-app/stress", function(req, res) {
  if (!allow_performance_test()) {
    res.status(403).send("Forbidden");
    return;
  }

  fib(10000);
  res.status(200).send("Stress test done");
});

app.get("/kth-azure-app/_about", function(req, res) {
  res.set("Content-Type", "text/plain");
  const msg =
    "Docker version: " +
    about.dockerVersion +
    "\n" +
    "Docker name: " +
    about.dockerName +
    "\n" +
    "Docker image: " +
    about.dockerImage +
    "\n" +
    "Jenkins build: " +
    about.jenkinsBuild +
    "\n" +
    "Jenkins build date: " +
    about.jenkinsBuildDate +
    "\n" +
    "Git branch: " +
    about.gitBranch +
    "\n" +
    "Git commit: " +
    about.gitCommit +
    "\n" +
    "hostname: " +
    os.hostname() +
    "\n" +
    "redis-host: " +
    redisClientConfig.host;
  res.status(200).send(msg);
});

function makeExternalRequest() {
  https
    .get("https://www.kth.se/_monitor", response => {
      let data = "";

      // A chunk of data has been recieved.
      response.on("data", chunk => {
        log.info("Got a chunk from external host.");
      });

      // The whole response has been received. Print out the result.
      response.on("end", () => {
        log.info("Got Complete response from external host.");
      });
    })
    .on("error", err => {
      log.warn("Error during request to external host." + err.message);
    });
}

app.get("/kth-azure-app/_monitor", function(req, res) {
  log.info("Got request for /_monitor");

  console.log(req.headers);

  makeExternalRequest();

  res.set("Content-Type", "text/plain");

  let msg = ``;
  if (process.env.ENV_TEST) {
    msg = `APPLICATION_STATUS: OK
          ENV_TEST: ${process.env.ENV_TEST}
              `;
  } else {
    msg = "APPLICATION_STATUS: ERROR Missing secret.env variable ENV_TEST.";
  }
  try {
    res.status(200).send(msg);
  } catch (ex) {
    log.warn("Unablte to send 200 respnse/_monitor" + ex);
  }
});

app.get("/kth-azure-app/_monitor_core", function(req, res) {
  res.set("Content-Type", "text/plain");

  let msg = ``;
  if (process.env.ENV_TEST) {
    msg = `APPLICATION_STATUS: OK
          ENV_TEST: ${process.env.ENV_TEST}
              `;
  } else {
    msg = "APPLICATION_STATUS: ERROR Missing secret.env variable ENV_TEST.";
  }
  res.status(200).send(msg);
});

// Connect to mongodb
var connect = function() {
  options = {
    dbUsername: process.env.AZURE_DOCUMENTDB_USERNAME,
    dbPassword: process.env.AZURE_DOCUMENTDB_PASSWORD,
    dbUri: process.env.AZURE_DOCUMENTDB_URI,
    logger: console.log,
    server: {
      socketOptions: {
        keepAlive: 1
      }
    }
  };
  try {
    mongoose.connect(process.env.AZURE_DOCUMENTDB_URI, options);
  } catch (ex) {
    res.status(500).send({
      Error: "" + ex
    });
  }
};

app.get("/kth-azure-app/documentdb", function(req, res) {
  try {
    connect();

    mongoose.connection.on("error", console.log);

    res.status(200).send({
      Connection: true
    });
  } catch (ex) {
    res.status(500).send({
      Error: "" + ex
    });
  }
});

app.get("/kth-azure-app/redis", function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  client.set("a-key", "a-value", function(err) {
    client.quit();
    if (err) {
      console.log(err);
      res.status(500).json({
        "redis-status": "Failed to wite to Redis on " + redisClientConfig.host
      });
    }
    res.json({
      "redis-status": "ok"
    });
  });
});

app.get("/kth-azure-app/redis-test", function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  start = process.hrtime();

  console.log("Writing 1000 keys to redis");

  for (var i = 0; i <= 999; i++) {
    client.set("key-" + i, "value-" + i, function(err) {
      if (err) {
        console.log(err);
      }
    });
  }

  client.set("key-1000", "value-1000", function(err) {
    if (err) {
      console.log(err);
    }
    client.get("key-1000", function(err, value) {
      client.quit();
      console.log("Read last key from redis");
      var result = {
        performance: elapsed_time("wrote 1000 keys to redis"),
        last_key_value: value,
        "os.hostname": os.hostname()
      };
      if (result) {
        res.json(result);
      }
    });
  });
});

app.post("/kth-azure-app/persistance", function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  client.set("persistance", "works", redis.print);
});

app.get("/kth-azure-app/persistance", function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  client.get("persistance", function(err, value) {
    if (err) {
      console.log(err);
      res.status(500).json({
        "redis-status":
          "Failed to read persistance from redis on " + redisClientConfig.host,
        error: err
      });
    }

    client.quit();
    res.json({
      persistance: value
    });
  });
});

/**
 * Log incomming request.
 * E.g:  http://localhost:3000/_about - Response Code: 200, Client IP: 127.0.0.1
 */
app.sendError = function(res, statusCode = 200) {
  console.log(`Send ${statusCode} error.`);
  res.status(statusCode).send(`KTH Azure App: Status code ${statusCode}`);
};

app.get("/kth-azure-app/401", function(req, res) {
  app.sendError(res, 401);
});

app.get("/kth-azure-app/403", function(req, res) {
  app.sendError(res, 403);
});

app.get("/kth-azure-app/501", function(req, res) {
  app.sendError(res, 501);
});

app.get("/kth-azure-app/502", function(req, res) {
  app.sendError(res, 502);
});

app.get("/kth-azure-app/scale-test", function(req, res) {
  var client = redis.createClient(redisClientConfig);

  client.on("error", function(err) {
    console.log("Error " + err);
  });

  var sV0 = "missing";
  var sV1 = "missing";

  client.get("scale-0", function(err, value) {
    if (err) {
      console.log(err);
      res.status(500).json({
        "redis-status":
          "Failed to read scale-0 from redis on " + redisClientConfig.host,
        error: err
      });
    }
    sV0 = value;

    client.get("scale-1", function(err, value) {
      if (err) {
        console.log(err);
        res.status(500).json({
          "redis-status":
            "Failed to read scale-1 from redis on " + redisClientConfig.host,
          error: err
        });
      }
      sV1 = value;

      client.quit();
      res.status(200).send(
        JSON.stringify({
          "scale-0": sV0,
          "scale-1": sV1
        })
      );
    });
  });
});

app.get("/kth-azure-app/", function(req, res) {
  res
    .status(200)
    .send(
      "<!DOCTYPE html><h1>Continuous Delivery Reference Application</h1><h2>KTH Azure App</h2>"
    );
});

// -- Errors --
// If the request ends up here none of the rules above have returned any response
// so then its time for som error handling
app.use(function(req, res) {
  res.status(404).send({
    message:
      "KTH Azure App - No route or static file matched '" + req.url + "'.",
    status: 404
  });
});

app.listen(3000, function() {
  if (
    process.env.STRESS_TEST != null &&
    process.env.STRESS_TEST.toLowerCase() == "true"
  ) {
    stressTest();
  }
  console.log("NodeJS running on port 3000");
});

// This will trigger a warning from https://github.com/auth0/repo-supervisor/ on CI.
var fake_secret_for_testing = "zJd-55qmsY6LD53CRTqnCr_g-";
