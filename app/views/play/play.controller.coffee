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

		@updateUrlParams = =>
			$state.transitionTo('play', {game: gameStr, mode: @gameType, difficulty: @difficulty}, { notify: false })
			return

		@leaveGame = ( params ) ->
			params.route ?= 'home'
			$state.go( params.route )
			return

		@createNewGame = =>
			@updateUrlParams()
			@attempts = 0
			@gameCopy = null
			@rebuildGame = true
			@pauseGame = false
			return

		@resetGame = =>
			@rebuildGame = true
			@pauseGame = false
			return

		@triggerGamePause = =>
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

