const appInsights = require("applicationinsights");
const express = require("express");
const app = express();
const templates = require("./modules/templates");
const logger = require("./modules/logger");
const httpResponse = require("@kth/http-responses");
const os = require("os");
const packageFile = require("./package.json");

/**
 * Init a Azure Application Insights if a key is passed as env APPINSIGHTS_INSTRUMENTATIONKEY
 */
app.initApplicationInsights = function () {
  if (process.env.APPINSIGHTS_INSTRUMENTATIONKEY) {
    appInsights
      .setup()
      .setAutoDependencyCorrelation(true)
      .setAutoCollectRequests(true)
      .setAutoCollectPerformance(true)
      .setAutoCollectExceptions(true)
      .setAutoCollectDependencies(true)
      .setAutoCollectConsole(true)
      .setUseDiskRetryCaching(true)
      .start();
    logger.log.info(
      `Using Application Ingsights: '${process.env.APPINSIGHTS_INSTRUMENTATIONKEY}'.`
    );
  } else {
    logger.log.info(`Application Ingsights not used.`);
  }
};

/**
 * Start server on port 3000, or use port specifed in env PORT.
 */
app.getListenPort = function () {
  return process.env.PORT ? process.env.PORT : 3000;
};

/**
 * Start the server on configured port.
 */
app.listen(app.getListenPort(), function () {
  logger.log.info(
    `Started ${packageFile.name} on ${os.hostname()}:${app.getListenPort()}`
  );
  app.initApplicationInsights();
});

/********************* routes **************************/

/**
 * Index page.
 */
app.get("/kth-azure-app/", function (request, response) {
  httpResponse.ok(request, response, templates.index());
});

/**
 * 502 error page.
 */
app.get("/kth-azure-app/502", function (request, response) {
  httpResponse.badGateway(request, response, templates.badGateway());
});

/**
 * About page. Versions and such.
 */
app.get("/kth-azure-app/_about", function (request, response) {
  httpResponse.ok(request, response, templates._about());
});

/**
 * Health check route.
 */
app.get("/kth-azure-app/_monitor", async function (request, response) {
  httpResponse.ok(
    request,
    response,
    await templates._monitor(),
    httpResponse.contentTypes.PLAIN_TEXT
  );
});

/**
 * Ignore favicons.
 */
app.get("/kth-azure-app/favicon.ico", function (request, response) {
  httpResponse.noContent(request, response);
});

/**
 * Crawler access definitions.
 */
app.get("/kth-azure-app/robots.txt", function (request, response) {
  httpResponse.ok(
    request,
    response,
    templates.robotstxt(),
    httpResponse.contentTypes.PLAIN_TEXT
  );
});

/**
 * Default route, if no other route is matched (404 Not Found).
 */
app.use(function (request, response) {
  httpResponse.notFound(request, response, templates.error404());
});

// This will trigger a warning from https://github.com/auth0/repo-supervisor/ on CI.
var fake_secret_for_testing = "zJd-55qmsY6LD53CRTqnCr_g-";
