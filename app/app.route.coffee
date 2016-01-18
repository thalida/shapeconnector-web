'use strict'

$requires = [
	'$stateProvider'
	'$urlRouterProvider'
	'$locationProvider'
]

route = ($stateProvider, $urlRouterProvider, $locationProvider) ->
	$urlRouterProvider.otherwise('/')
	$locationProvider.html5Mode( MODE.production == true )

	return

route.$inject = $requires
module.exports = route
