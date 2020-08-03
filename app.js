const os = require("os");
const express = require("express");
const httpResponse = require("@kth/http-responses");
const { templates } = require("@kth/basic-html-templates");
const logger = require("./modules/logger");
const about = require("./config/version");
const defaultEnvs = require("./modules/defaultEnvs");
const monitor = require("./modules/monitor");
const applicationInsights = require("./modules/applicationInsights");

const started = new Date();
const app = express();

defaultEnvs.set(true);

/**
 * Start the server on configured port.
 */
app.listen(process.env.PORT, function () {
  logger.log.info(
    `Started ${about.dockerName}:${about.dockerVersion} on ${os.hostname()}:${
      process.env.PORT
    }`
  );
  applicationInsights.init();
});

/********************* routes **************************/

/**
 * Index page.
 */
app.get("/kth-azure-app/", function (request, response) {
  httpResponse.ok(
    request,
    response,
    templates.index("Continuous Delivery Reference Application")
  );
});

/**
 * 502 error page.
 */
app.get("/kth-azure-app/502", function (request, response) {
  httpResponse.badGateway(request, response);
});

/**
 * About page. Versions and such.
 */
app.get("/kth-azure-app/_about", function (request, response) {
  httpResponse.ok(request, response, templates._about(about, started));
});

/**
 * Health check route.
 */
app.get("/kth-azure-app/_monitor", async function (request, response) {
  httpResponse.ok(
    request,
    response,
    templates._monitor((status = "OK"), (extras = await monitor.tests())),
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
var fake_secret_for_testing = "zJd-55qmsY6LD53CRdTqnCr_g-";
