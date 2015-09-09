'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('play',
		url: '/play'
		templateUrl: 'app/play/play.html'
		controller: 'PlayCtrl'
	)


app.controller 'PlayCtrl', [
	'$log'
	'$rootScope'
	'$scope'
	'$state'
	'gameSettingsService'
	($log, $rootScope, $scope, $state, gameSettings) ->
		$scope.gameType = gameSettings.getGameType()
		$scope.difficulty = (if not $rootScope.isProdSite then 'dev' else gameSettings.getDifficulty())

		$scope.rebuildGame = false

		$scope.createNewGame = () ->
			$scope.gameCopy = null
			$scope.rebuildGame = true
			return

		$scope.resetGame = () ->
			$scope.rebuildGame = true
			return

		$scope.goHome = ->
			$state.go('home')
			return
]

