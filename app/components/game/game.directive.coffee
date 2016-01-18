'use strict'

#===============================================================================
#
#	ShapeConnector (SC) Game Directive
# 		Renders the game to the canvas and handles the events
#
#-------------------------------------------------------------------------------
angular.module('app').directive 'scGame', [
	'$rootScope'
	'$log'
	'LEVELS'
	'BOARD'
	'SHAPE'
	require '../../services/gameManager'
	require '../../services/watcher'

	($rootScope, $log, LEVELS, BOARD, SHAPE, GameManager, Watcher) ->
		templateUrl: 'components/game/game.html'
		restrict: 'E'
		scope:
			sourceGame: '=?'
			gameType: '@?type'
			difficulty: '@?'
			attempts: '=?'
			modalShown: '=?'
			triggerGamePause: '=?pauseGame'
			onNewGame: '&?'
			onResetGame: '&?'
			onQuitGame: '&?'
		link: ($scope, el, attrs) ->
			# globals
			game = null
			$window = $(window)
			$gameHeader = el.find('.game-header')
			watcher = new Watcher( $scope )

			$scope.showWinModal = false
			$scope.showLoseModal = false
			$scope.showPauseModal = false


			# utils: simple functions used to render the board
			#-------------------------------------------------------------------
			utils =
				calcGameWidth: ->
					gameWidth = BOARD.DIMENSIONS.w + 150
					if $window.width() < gameWidth
						gameWidth = $window.width() - 30

					return gameWidth

				calcGameTopMargin: ->
					windowMidHeight = window.innerHeight / 2
					boardHalfHeight = BOARD.DIMENSIONS.h / 2
					headerHeight = if window.innerHeight > 650 then SHAPE.OUTERSIZE + 10 else 0

					topMargin = windowMidHeight - headerHeight - boardHalfHeight
					topMargin = 60 if topMargin < 100

					return topMargin


			# setup: creates variables to be used when we render + start the game
			#-------------------------------------------------------------------
			setup = ->
				# Default the game difficulty to easy
				$scope.difficulty ?= LEVELS.DEFAULT.name

				# Collection of canvases to be drawn on
				$scope.canvasCollection = {}

				# The dimenisions (sizes) of the canvases we need
				$scope.canvasDimensions =
					goal: {
						width: BOARD.DIMENSIONS.w
						height: SHAPE.OUTERSIZE
					}
					timer: {
						width: SHAPE.OUTERSIZE
						height: SHAPE.OUTERSIZE
					}
					board: {
						width: BOARD.DIMENSIONS.w
						height: BOARD.DIMENSIONS.h
					}

				# Callback events for the game canvas
				$scope.gameCanvasEvents =
					start: events.onMove
					move: events.onMove
					end: events.onEnd
					cancel: events.onCancel


			# start: create and render a new game
			#-------------------------------------------------------------------
			start = ->
				# ALL of the game logic: Creates a game that uses the specified
				# canvases, difficulty, and optional source game board
				game = GameManager.init(
					scope:
						$scope: $scope
						namespace: 'game'
					settings:
						mode: $scope.gameType
						difficulty: $scope.difficulty
					render:
						canvas: $scope.canvasCollection
						board: $scope.sourceGame
				)

				# Save the current game board to the parent (controller) scope
				saveGameBoard()

				# Position the board correctly on the window
				positionBoard()

				# Create a scoped copy of the Game class
				game.start()
				$scope.attempts += 1

				$rootScope.windowEvents.onBlur( events.onBlur )
				$window.on('resize', events.onResize)

				return


			# saveGameBoard: Save the current game board to the controller
			#-------------------------------------------------------------------
			saveGameBoard = ->
				if not $scope.sourceGame?
					$scope.sourceGame = angular.copy(game.cacheGameBoard)


			# positionBoard: Update the position of the board on the screen
			#-------------------------------------------------------------------
			positionBoard = ->
				$game = el.find('.game')
				$gameBoard = $game.find('.game-board')

				$game.css(
					width: utils.calcGameWidth()
					marginTop: utils.calcGameTopMargin()
				)

				$gameBoard.css(
					height: BOARD.DIMENSIONS.h
					width: BOARD.DIMENSIONS.w
				)


			# events
			# 	Bind gameboard the touch/mouse events to the corresponding
			# 	method in the Game manager
			#	Note: Keep $scope.$apply since events are bound outåside of angular
			#-------------------------------------------------------------------
			events =
				onMove: ( e, params ) -> $scope.$apply( => game.onMoveEvent(e, params) )
				onEnd: -> $scope.$apply( => game.onEndEvent() )
				onCancel: -> $scope.$apply( => game.onCancelEvent() )
				onResize: -> positionBoard()
				onBlur: ->$scope.$apply( => $scope.actions.pauseGame() )


			# actions: Additonal user triggered actions on game win/lose
			#-------------------------------------------------------------------
			$scope.actions =
				newGame: -> $scope.onNewGame?(params: true)
				resetGame: -> $scope.onResetGame?(params: game.cacheGameBoard)
				quitGame: -> $scope.onQuitGame?(params: true)
				pauseGame: () ->
					if game.gameOver is false
						game.pauseGame()
						if $scope.modalShown isnt 'share'
							$scope.showPauseModal = true
							$scope.modalShown = 'pause'
				resumeGame: (useApply = true) ->
					game.resumeGame()
					$scope.triggerGamePause = false
					$scope.showPauseModal = false
					$scope.modalShown = ''

					$scope.$apply() if useApply



			# We're ready to set the scope variables
			setup()

			# Watch the canvasCollection for updates - start the game when
			# we have the game canvas data
			stopCanvasWatch = watcher.start('canvasCollection', (collection) ->
				if collection?.game?
					stopCanvasWatch()
					start()
					startWatching()
			)

			startWatching = ->
					watcher.start(
						() -> return game.won
						( hasWon ) ->
							$scope.showWinModal = (hasWon is true)
							$scope.modalShown = 'win'
					)

					watcher.start(
						() -> return game.lost
						( hasLost ) ->
							$scope.showLoseModal = (hasLost is true)
							$scope.modalShown = 'lose'
					)

			stopPauseWatcher = watcher.start('triggerGamePause', ( pauseGame, lastState ) ->
				if $scope.triggerGamePause is true
					if game?.gameOver is true
						$scope.actions.quitGame()
					else
						$scope.actions.pauseGame()

				if lastState is true and pauseGame is false and $scope.modalShown is 'share'
					$scope.modalShown = ''
					$scope.actions.resumeGame( false )

			)

			# Destroy the Game class on directive $destroy
			$scope.$on('$destroy', () ->
				game.destroy()
			)
]
