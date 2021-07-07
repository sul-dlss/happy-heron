process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const webpackConfig = require('./base')


const devServerConfig = {
  client: {
    logging: webpackConfig.devServer.clientLogLevel,
    overlay: webpackConfig.devServer.overlay,
    needClientEntry: webpackConfig.devServer.injectClient,
    needHotEntry: webpackConfig.devServer.injectHot,
  },
  compress: webpackConfig.devServer.compress,
  devMiddleware: {
    publicPath: webpackConfig.devServer.publicPath,
  },
  firewall: !webpackConfig.devServer.disableHostCheck,
  host: webpackConfig.devServer.host,
  port: webpackConfig.devServer.port,
  https: webpackConfig.devServer.https,
  hot: webpackConfig.devServer.hot,
  historyApiFallback: webpackConfig.devServer.historyApiFallback,
  headers: webpackConfig.devServer.headers,
  static: [
    {
      directory: webpackConfig.devServer.contentBase,
      watch: true,
    }
  ],
};
if (webpackConfig.devServer.quiet) {
  webpackConfig.infrastructureLogging.level = 'none';
}
if (webpackConfig.devServer.useLocalIp) {
  devServerConfig.host = 'local-ip';
}
webpackConfig.stats = webpackConfig.devServer.stats;
webpackConfig.devServer = devServerConfig;

module.exports = webpackConfig
