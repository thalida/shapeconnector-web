'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('tutorial',
		url: '/tutorial'
		templateUrl: 'app/tutorial/tutorial.html'
		controller: 'TutorialCtrl'
	)


app.controller 'TutorialCtrl', [
	'$log'
	'$scope'
	($log, $scope) ->
]

