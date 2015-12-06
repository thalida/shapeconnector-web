'use strict'

route = ($stateProvider) ->
	$stateProvider.state('about',
		url: '/about'
		templateUrl: 'views/about/about.html'
		controller: 'AboutController'
		controllerAs: 'about'
	)

route.$inject = ['$stateProvider']

module.exports = route
