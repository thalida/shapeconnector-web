'use strict'

route = ($stateProvider) ->
	$stateProvider.state('home',
		url: '/'
		templateUrl: 'views/home/home.html'
		controller: 'HomeController'
		controllerAs: 'home'
	)

route.$inject = ['$stateProvider']

module.exports = route
