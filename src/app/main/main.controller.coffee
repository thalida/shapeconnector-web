app.config ($stateProvider) ->
	$stateProvider.state('main',
		url: '/main'
		templateUrl: 'app/main/main.html'
		controller: 'MainCtrl'
	)


app.controller 'MainCtrl', [
	'$log'
	'$scope'
	($log, $scope) ->
		$scope.date = moment().format('llll')
]

