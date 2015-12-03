'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'
	require '../../services/gameSettings'
]

class PlayController
	constructor: ( $log, $scope, $state, gameSettings ) ->
		@gameType = gameSettings.getGameType()
		@difficulty = gameSettings.getDifficulty()

		@rebuildGame = true
		@pauseGame = false
		@attempts = 0

		@goHome = ->
			$state.go('home')

		return

	createNewGame: =>
		@attempts = 0
		@gameCopy = null
		@rebuildGame = true
		return

	resetGame: =>
		@rebuildGame = true
		return

	onHeaderClick: =>
		@pauseGame = true
		return

PlayController.$inject = $requires
module.exports = PlayController

