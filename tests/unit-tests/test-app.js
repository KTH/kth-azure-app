/* eslint-env mocha */
"use strict";

// Testing libraries
const expect = require("chai").expect;
const templates = require("../../modules/templates");

describe("Template handling", function() {
  it("Path '/' should contain a title.", function() {
    const result = templates.index();
    expect(result).to.contain("Continuous Delivery Reference Application");
  });

  it("Path '/error404' should contain a message.", function() {
    const result = templates.error404();
    expect(result).to.contain("404 - Page not found");
  });

  it("The header should contain env Application Insights key 'APPINSIGHTS_INSTRUMENTATIONKEY' if set.", function() {
    process.env.APPINSIGHTS_INSTRUMENTATIONKEY = "abcd-1234-efghi";
    const result0 = templates.index();
    expect(result0).to.contain("abcd-1234-efghi");
    const result1 = templates.error404();
    expect(result1).to.contain("abcd-1234-efghi");
    delete process.env.APPINSIGHTS_INSTRUMENTATIONKEY;
  });

  it("Path '/_monitor' should contain 'APPLICATION_STATUS: OK'.", function() {
    const result = templates._monitor();
    expect(result).to.contain("APPLICATION_STATUS: OK");
  });

  it("Path '/_monitor' should contain ENV_TEST value specified in env 'ENV_TEST' if set.", function() {
    process.env.ENV_TEST = "a value";
    const result = templates._monitor();
    expect(result).to.contain("a value");
    delete process.env.ENV_TEST;
  });

  it("Path '/_monitor' should contain 'No env value for ENV_TEST is set.' when env 'ENV_TEST' is not set.", function() {
    const result = templates._monitor();
    expect(result).to.contain("No env value for ENV_TEST is set.");
  });
});
