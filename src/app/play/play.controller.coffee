'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('play',
		url: '/play'
		templateUrl: 'app/play/play.html'
		controller: 'PlayCtrl'
	)


app.controller 'PlayCtrl', [
	'$log'
	'$scope'
	'$state'
	'gameSettingsService'
	($log, $scope, $state, gameSettings) ->
		$scope.gameType = gameSettings.getGameType()
		$scope.difficulty = gameSettings.getDifficulty()

		$scope.rebuildGame = true
		$scope.pauseGame = false
		$scope.attempts = 0

		$scope.createNewGame = () ->
			$scope.attempts = 0
			$scope.gameCopy = null
			$scope.rebuildGame = true
			return

		$scope.resetGame = () ->
			$scope.rebuildGame = true
			return

		$scope.onHeaderClick = () ->
			$scope.pauseGame = true
			return

		$scope.goHome = ->
			$state.go('home')
			return
]

