/*
 * Default values used if not enviroment variable is set before.
 */

const defaultEnvs = require("@kth/default-envs");

module.exports = {
  APPLICATION_NAME: "KTH Azure App",
  LOG_LEVEL: "info",
  PORT: 3000,
  APPINSIGHTS_INSTRUMENTATIONKEY: "",
  EXTERNAL_API_CALL: "https://api.kth.se/api/pipeline/v1/active/kth-azure-app/",
  FLOTTSBRO_API_KEY: defaultEnvs.REQUIRED_NO_DEFAULT,
};
