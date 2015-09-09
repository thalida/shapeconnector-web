'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('about',
		url: '/about'
		templateUrl: 'app/about/about.html'
		controller: 'AboutCtrl'
	)


app.controller 'AboutCtrl', [
	'$log'
	'$rootScope'
	'$scope'
	($log, $rootScope, $scope) ->
]

