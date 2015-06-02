# karma-ng-jade2js-preprocessor

> Preprocessor for converting jade files to [AngularJS](http://angularjs.org/) templates.

Forked from [karma-ng-html2js-preprocessor](https://github.com/karma-runner/karma-ng-html2js-preprocessor)

[![Build Status](https://travis-ci.org/chmanie/karma-ng-jade2js-preprocessor.svg)](https://travis-ci.org/chmanie/karma-ng-jade2js-preprocessor)

## Installation

The easiest way is to keep `karma-ng-jade2js-preprocessor` as a devDependency in your `package.json`.
```json
{
  "devDependencies": {
    "karma": "~0.10",
    "karma-ng-jade2js-preprocessor": "~0.1"
  }
}
```

You can simple do it by:
```bash
npm install karma-ng-jade2js-preprocessor --save-dev
```

## Configuration
```js
// karma.conf.js
module.exports = function(config) {
  config.set({
    preprocessors: {
      '**/*.jade': ['ng-jade2js']
    },

    files: [
      '*.js',
      '*.jade',
      // if you wanna load template files in nested directories, you must use this
      '**/*.jade'
    ],

    ngJade2JsPreprocessor: {
      // strip this from the file path
      stripPrefix: 'public/',
      // prepend this to the
      prependPrefix: 'served/',

      // or define a custom transform function
      cacheIdFromPath: function(filepath) {
        return cacheId;
      },

      // Support for jade locals to render at compile time
      locals: {
        foo: 'bar'
      },

      // By default, Jade files are added to template cache with '.html' extension.
      // Set this option to change it.
      templateExtension: 'html',

      // setting this option will create only a single module that contains templates
      // from all the files, so you can load them all with module('foo')
      moduleName: 'foo',

      // Jade compiler options. For a list of possible options, consult Jade documentation.
      jadeOptions: {
        doctype: 'xml'
      }
    }
  });
};
```

----

For more information on Karma see the [homepage].


[homepage]: http://karma-runner.github.com
