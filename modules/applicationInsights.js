const appInsights = require("applicationinsights");
const logger = require("./logger");

/**
 * app insights env specified by Azure is APPINSIGHTS_INSTRUMENTATIONKEY
 */

const useApplicationInsight = () => {
  return process.env.APPINSIGHTS_INSTRUMENTATIONKEY ? true : false;
};

/**
 * Init a Azure Application Insights if a key is passed as env APPINSIGHTS_INSTRUMENTATIONKEY
 */

const init = () => {
  if (useApplicationInsight()) {
    startAppInsights();
    logger.log.info(
      `Using Application Ingsights: '${process.env.APPINSIGHTS_INSTRUMENTATIONKEY}'.`
    );
  } else {
    logger.log.info(`Application Ingsights not used.`);
  }
};

/**
 * Start and configure app insights specified in env APPINSIGHTS_INSTRUMENTATIONKEY.
 */

const startAppInsights = () => {
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
};

/**
 * Module exports
 */
module.exports = {
  useApplicationInsight: useApplicationInsight,
  init: init,
};
