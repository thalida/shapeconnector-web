var jade = require('jade');

var createJadePreprocessor = function(logger, basePath) {
  var log = logger.create('preprocessor.jade');

  return function(content, file, done) {
    var processed = null;

    log.debug('Processing "%s".', file.originalPath);
    file.path = file.originalPath.replace(/\.jade$/, '.html');

    var templateName = file.originalPath.replace(/^.*\/([^\/]+)\.jade$/, '$1');

    try {
        var jadeOptions = {
            filename: file.originalPath,
            client: true,
            pretty: true
        };
        processed = jade.compile(content, jadeOptions)
    } catch (e) {
      log.error('%s\n  at %s', e.message, file.originalPath);
    }
   done(processed);
   // done("define(['jadeRuntime'], function(jade) { return " + jade.compile(content, jadeOptions) +"; });");
  };

};

createJadePreprocessor.$inject = ['logger', 'config.basePath'];

// PUBLISH DI MODULE
module.exports = {
  'preprocessor:jade': ['factory', createJadePreprocessor]
};
