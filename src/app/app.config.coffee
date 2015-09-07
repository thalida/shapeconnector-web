'use strict'

app.config [
	'$stateProvider'
	'$urlRouterProvider'
	'$locationProvider'
	($stateProvider, $urlRouterProvider, $locationProvider) ->
		$urlRouterProvider.otherwise('/')
		$locationProvider.html5Mode(true)
]
