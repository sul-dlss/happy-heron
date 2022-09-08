const { defineConfig } = require('cypress')

module.exports = defineConfig({
  screenshotsFolder: "tmp/cypress_screenshots",
  videosFolder: "tmp/cypress_videos",
  trashAssetsBeforeRuns: false,  
  e2e: {
    defaultCommandTimeout: 10000,
    supportFile: "cypress/support/index.js",
    specPattern: "cypress/spec/**/*.cy.{js,jsx,ts,tsx}"
  }
})
