'use strict'

angular.module('app').config(
	($stateProvider, $urlRouterProvider, $locationProvider) ->
		$urlRouterProvider.otherwise('/')
		$locationProvider.html5Mode(false)
)
