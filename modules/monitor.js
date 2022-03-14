"use strict";

const api = require("./api");
const logger = require("./logger");
const { statusCodes } = require("@kth/http-responses");

/**
 * Extra tests for the monitor page
 */
async function tests() {
  const text = `
  - ENV_TEST: ${getEnvTest()} - Should return the cluster name.
  - API Call: ${await api.getStatus()} - Should always return this applications name.
  `;

  logger.log.info(text);
  return text;
}

/**
 * Gets the env ENV_TEST or a error message.
 * This tests that ENV handling works in clusters.
 * @returns The env ENV_TEST or a error message.
 */
function getEnvTest() {
  return process.env.ENV_TEST
    ? process.env.ENV_TEST
    : "No env value for ENV_TEST is set.";
}

/**
 * Module exports
 */
module.exports = {
  tests: tests,
};
