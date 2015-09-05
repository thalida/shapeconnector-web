'use strict'

app.config ($stateProvider, $urlRouterProvider, $locationProvider) ->
	$urlRouterProvider.otherwise('/')
	$locationProvider.html5Mode(true)
