'use strict'

route = ($stateProvider) ->
	$stateProvider.state('settings',
		url: '/settings'
		templateUrl: 'views/settings/settings.html'
		controller: 'SettingsController'
		controllerAs: 'settings'
	)

route.$inject = ['$stateProvider']

module.exports = route
