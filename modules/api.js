/*jshint esversion: 8 */

const logger = require("./logger");
const fetch = require("node-fetch");

/**
 * Gets this applications name from an external api to test
 * that network.
 */
const getStatus = async () => {
  try {
    let json = await getJson();
    return json.applicationName;
  } catch (error) {
    logger.log.error("Error to get data from public api.", error);
  }
  return "ERROR - Could not read api.kth.se";
};

async function getJson() {
  let response = await fetch(
    `https://api.kth.se/api/pipeline/v1/active/kth-azure-app/ `
  );
  return await response.json();
}

/**
 * Module exports
 */
module.exports = {
  getStatus: getStatus,
};
