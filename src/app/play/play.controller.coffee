'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('play',
		url: '/'
		templateUrl: 'app/play/play.html'
		controller: 'PlayCtrl'
	)


app.controller 'PlayCtrl', [
	'$log'
	'$scope'
	($log, $scope) ->
		$scope.difficulty = (if window.location.hostname is 'localhost' then 'dev' else 'medium')

		$scope.rebuildGame = false

		$scope.createNewGame = () ->
			$scope.gameCopy = null
			$scope.rebuildGame = true
			return

		$scope.resetGame = () ->
			$scope.rebuildGame = true
			return
]

