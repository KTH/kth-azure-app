/*jshint esversion: 8 */

const logger = require("./logger");
const fetch = require("node-fetch");

/**
 * Gets this applications name from an external api to test
 * that network.
 */
const getStatus = async () => {
  let result = "ERROR - Could not read api.kth.se";
  const startTime = Date.now();
  try {
    let json = await getJson();
    if (json) {
      result = json.applicationName;
    }
  } catch (error) {
    logger.log.error("Error to get data from public api.", error);
  }
  const durationMs = Date.now() - startTime;
  logger.log.info(
    `Round trip time for ${process.env.EXTERNAL_API_CALL} took ${durationMs}ms.`
  );
  return result;
};

async function getJson() {
  let result;
  if (!process.env.FLOTTSBRO_API_KEY) {
    logger.log.error("env FLOTTSBRO_API_KEY has no value.");
  }
  try {
    let response = await fetch(process.env.EXTERNAL_API_CALL, {
      headers: {
        api_key: process.env.FLOTTSBRO_API_KEY,
      },
    });
    result = await response.json();
  } catch (error) {
    logger.log.warn(
      `Could not make an external call to the Flottsbro-api '${process.env.EXTERNAL_API_CALL}' with env FLOTTSBRO_API_KEY set as api_key.`
    );
  }
  return result;
}

/**
 * Module exports
 */
module.exports = {
  getStatus: getStatus,
};
