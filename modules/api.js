/*jshint esversion: 8 */

const logger = require("./logger");
const fetch = require("node-fetch");

/**
 * Gets this applications name from an external api to test
 * that network.
 */
const getStatus = async () => {
  const timerLabel = `Request time to get external api ${process.env.EXTERNAL_API_CALL}`;
  try {
    console.time(timerLabel);
    let json = await getJson();
    console.timeEnd(timerLabel);

    return json.applicationName;
  } catch (error) {
    logger.log.error("Error to get data from public api.", error);
  }
  return "ERROR - Could not read api.kth.se";
};

async function getJson() {
  let result;
  try {
    let response = await fetch(process.env.EXTERNAL_API_CALL, {
      headers: {
        api_key: process.env.FLOTTSBRO_API_KEY,
      },
    });
    result = await response.json();
  } catch (error) {
    logger.log.warn(
      `Could not make an external call to the Flottsbro-api '${process.env.EXTERNAL_API_CALL}' with env FLOTTSBRO_API_KEY set as api_key.`,
      error
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
