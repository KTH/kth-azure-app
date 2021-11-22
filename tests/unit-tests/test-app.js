/* eslint-env mocha */
"use strict";

// Testing libraries
const expect = require("chai").expect;
const monitor = require("../../modules/monitor");
const defaultEnvs = require("../../modules/defaultEnvs");

describe("Template handling", function () {
  it("Path '/_monitor' should contain ENV_TEST value specified in env 'ENV_TEST' if set.", async function () {
    process.env.ENV_TEST = "a value";
    process.env.EXTERNAL_API_CALL = defaultEnvs.DEFAULTS.EXTERNAL_API_CALL;
    const result = await monitor.tests();
    expect(result).to.contain("fail a value");
    delete process.env.ENV_TEST;
    delete process.env.EXTERNAL_API_CALL;
  });

  it("Path '/_monitor' should contain 'No env value for ENV_TEST is set.' when env 'ENV_TEST' is not set.", async function () {
    process.env.EXTERNAL_API_CALL = defaultEnvs.DEFAULTS.EXTERNAL_API_CALL;
    const result = await monitor.tests();
    expect(result).to.contain("No env value for ENV_TEST is set.");
    delete process.env.EXTERNAL_API_CALL;
  });
});

describe("Env handling", function () {
  it("If env APPLICATION_NAME is set, that should be used as name not default env.", async function () {
    defaultEnvs.set();
    expect(process.env.APPLICATION_NAME).to.equal("application-test-name");
  });
  it("Validate that no character is escaped in Github Actions.", async function () {
    expect(process.env.MONGODB_CONNECTION_STRING).to.equal(
      "mongodb://example-com:aaaaaA%3D%3D@example.com:10255/docs?ssl=true"
    );
  });
  it("Validate that = characters is Github Actions Bash schell.", async function () {
    expect(process.env.A_KEY).to.equal("?name=key&apiKey=asdfasdf&scope=read");
  });
});
