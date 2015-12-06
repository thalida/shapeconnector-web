'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'
	'$localStorage'
	require '../../services/gameSettings'
]

class PlayController
	constructor: ( $log, $scope, $state, $localStorage, gameSettings ) ->
		mode = $state.params.mode
		@gameType = gameSettings.setGameType( mode )
		@difficulty = gameSettings.getDifficulty()

		if $localStorage.hasCompletedTutorial != true
			$state.go('tutorial', {step: 1, mode: @gameType})

		@rebuildGame = true
		@pauseGame = false
		@attempts = 0

		@goHome = ->
			$state.go('home')

		@createNewGame = =>
			@attempts = 0
			@gameCopy = null
			@rebuildGame = true
			return

		@resetGame = =>
			@rebuildGame = true
			return

		@onHeaderClick = =>
			@pauseGame = true
			return

		return

PlayController.$inject = $requires
module.exports = PlayController

