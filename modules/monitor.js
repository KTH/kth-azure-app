"use strict";

const api = require("./api");
const logger = require("./logger");
const { statusCodes } = require("@kth/http-responses");

/**
 * Extra tests for the monitor page
 */
async function tests() {
  const text = `
  - ENV_TEST: ${
    process.env.ENV_TEST
      ? process.env.ENV_TEST
      : "No env value for ENV_TEST is set."
  } - Should return the cluster name.
  - API Call: ${await api.getStatus()} - Should return application name.
  `;

  logger.log.info(text);
  return text;
}

/**
 * Module exports
 */
module.exports = {
  tests: tests,
};
