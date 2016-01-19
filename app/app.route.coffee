'use strict'

$requires = [
	'$stateProvider'
	'$urlRouterProvider'
	'$locationProvider'
]

route = ($stateProvider, $urlRouterProvider, $locationProvider) ->
	$urlRouterProvider.otherwise('/')
	$locationProvider.html5Mode( false )

	$urlRouterProvider.rule(($injector, $location) ->
		path = $location.path()
		hasTrailingSlash = path[path.length - 1] == '/';

		return path += '/' if !hasTrailingSlash
	)

	return

route.$inject = $requires
module.exports = route
