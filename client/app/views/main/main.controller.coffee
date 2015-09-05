'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('main',
		url: '/main'
		templateUrl: 'app/views/main/main.html'
		controller: 'MainCtrl'
	)


app.controller 'MainCtrl', [($scope, $http) ->
	$scope.awesomeThings = []
	$http.get('/api/things').success((awesomeThings) ->
		$scope.awesomeThings = awesomeThings
	)
]
