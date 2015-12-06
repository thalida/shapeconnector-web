'use strict'

route = ($stateProvider) ->
	$stateProvider.state('play',
		url: '/play'
		params: {
			mode: {}
		}
		templateUrl: 'views/play/play.html'
		controller: 'PlayController'
		controllerAs: 'play'
	)

route.$inject = ['$stateProvider']

module.exports = route
