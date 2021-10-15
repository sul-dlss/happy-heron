const esbuild = require("esbuild");
const { stimulusPlugin } = require("esbuild-plugin-stimulus");

const watch = process.argv.includes("--watch") && {
  onRebuild(error) {
    if (error) console.error("[watch] build failed", error);
    else console.log("[watch] build finished");
  },
};

esbuild
  .build({
    entryPoints: ["app/javascript/application.js"],
    bundle: true,
    outdir: "app/assets/builds",
    watch: watch,
    plugins: [stimulusPlugin()],
  })
  .catch(() => process.exit(1));
