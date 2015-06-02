// Karma configuration
// http://karma-runner.github.io/0.10/config/configuration-file.html

module.exports = function(config) {
  config.set({
    // base path, that will be used to resolve files and exclude
    basePath: '',

    // testing framework to use (jasmine/mocha/qunit/...)
    frameworks: ['jasmine'],

    // list of files / patterns to load in the browser
    files: [
      'public/bower_components/jquery/dist/jquery.js',
      'public/bower_components/angular/angular.js',
      'public/bower_components/angular-mocks/angular-mocks.js',
      'public/bower_components/angular-resource/angular-resource.js',
      'public/bower_components/angular-cookies/angular-cookies.js',
      'public/bower_components/angular-sanitize/angular-sanitize.js',
      'public/bower_components/angular-route/angular-route.js',
      'public/bower_components/lodash/dist/lodash.compat.js',
      'public/bower_components/angular-ui-router/release/angular-ui-router.js',
      'public/app/app.js',
      'public/app/app.coffee',
      'public/app/**/*.js',
      'public/app/**/*.coffee',
      'public/components/**/*.js',
      'public/components/**/*.coffee',
      'public/app/**/*.jade',
      'public/components/**/*.jade',
      'public/app/**/*.html',
      'public/components/**/*.html'
    ],

    preprocessors: {
      '**/*.jade': 'ng-jade2js',
      '**/*.html': 'html2js',
      '**/*.coffee': 'coffee',
    },

    ngHtml2JsPreprocessor: {
      stripPrefix: 'public/'
    },

    ngJade2JsPreprocessor: {
      stripPrefix: 'public/'
    },

    // list of files / patterns to exclude
    exclude: [],

    // web server port
    port: 8080,

    // level of logging
    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS'],


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
