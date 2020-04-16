/* eslint-env mocha */
"use strict";

// Testing libraries
const expect = require("chai").expect;
const monitor = require("../../modules/monitor");

describe("Template handling", function () {
  it("Path '/_monitor' should contain ENV_TEST value specified in env 'ENV_TEST' if set.", async function () {
    process.env.ENV_TEST = "a value";
    const result = await monitor.tests();
    expect(result).to.contain("a value");
    delete process.env.ENV_TEST;
  });

  it("Path '/_monitor' should contain 'No env value for ENV_TEST is set.' when env 'ENV_TEST' is not set.", async function () {
    const result = await monitor.tests();
    expect(result).to.contain("No env value for ENV_TEST is set.");
    expect(result).to.contain("Could not read api.kth.se");
  });
});
