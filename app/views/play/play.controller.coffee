'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'
	'$localStorage'
	require '../../services/gameUtils'
	require '../../services/gameSettings'
]

class PlayController
	constructor: ( $log, $scope, $state, $localStorage, gameUtils, gameSettings ) ->
		mode = $state.params.mode
		difficulty = $state.params.difficulty
		gameStr = $state.params.game

		if gameStr?.length > 0
			game = gameUtils.convertStrToGame( gameStr )

			if game.maxMoves? > 0 and game.endNodes.length == 2 and game.board.length > 0
				@gameCopy = angular.copy(game)

		@gameType = gameSettings.setGameType( mode )
		@difficulty = gameSettings.setDifficulty( difficulty )

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

		@onShareEvent = ( params ) =>
			if params.type == 'show'
				@modal = 'share'
				@pauseGame = true
			else if params.type == 'close'
				@modal = 'share'
				@pauseGame = false

		return

PlayController.$inject = $requires
module.exports = PlayController

