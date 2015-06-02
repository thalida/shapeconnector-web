var util = require('util');
var jade = require('jade');

var TEMPLATE = 'angular.module(\'%s\', []).run(function($templateCache) {\n' +
    '  $templateCache.put(\'%s\',\n    \'%s\');\n' +
    '});\n';

var SINGLE_MODULE_TPL = '(function(module) {\n' +
    'try {\n' +
    '  module = angular.module(\'%s\');\n' +
    '} catch (e) {\n' +
    '  module = angular.module(\'%s\', []);\n' +
    '}\n' +
    'module.run(function($templateCache) {\n' +
    '  $templateCache.put(\'%s\',\n    \'%s\');\n' +
    '});\n' +
    '})();\n';

var escapeContent = function(content) {
  return content.replace(/\\/g, '\\\\').replace(/'/g, '\\\'').replace(/\r?\n/g, '\\n\' +\n    \'');
};

var createJade2JsPreprocessor = function(logger, basePath, config) {
  config = typeof config === 'object' ? config : {};

  var log = logger.create('preprocessor.jade2js');
  var moduleName = config.moduleName;
  var locals = config.locals;
  var templateExtension = config.templateExtension || 'html';
  var stripPrefix = new RegExp('^' + (config.stripPrefix || ''));
  var prependPrefix = config.prependPrefix || '';
  var jadeOptions = config.jadeOptions || {};
  var cacheIdFromPath = config && config.cacheIdFromPath || function(filepath) {
    return prependPrefix + filepath.replace(stripPrefix, '');
  };

  return function(content, file, done) {
    var processed;

    log.debug('Processing "%s".', file.originalPath);

    jadeOptions.filename = file.originalPath;

    try {
       processed = jade.compile(content, jadeOptions);
    } catch (e) {
     log.error('%s\n  at %s', e.message, file.originalPath);
    }

    content = processed(locals);

    var htmlPath = cacheIdFromPath(file.originalPath.replace(basePath + '/', ''))
                                                    .replace(/\.jade$/, '.' + templateExtension);

    file.path = file.path.replace(/\.jade$/, '.html') + '.js';

    if (moduleName) {
      done(util.format(SINGLE_MODULE_TPL, moduleName, moduleName, htmlPath, escapeContent(content)));
    } else {
      done(util.format(TEMPLATE, htmlPath, htmlPath, escapeContent(content)));
    }
  };
};

createJade2JsPreprocessor.$inject = ['logger', 'config.basePath', 'config.ngJade2JsPreprocessor'];

module.exports = createJade2JsPreprocessor;
