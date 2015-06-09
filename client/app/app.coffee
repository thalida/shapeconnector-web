'use strict'

angular.module 'appApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ui.router'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $urlRouterProvider
  .otherwise '/'

  $locationProvider.html5Mode true
