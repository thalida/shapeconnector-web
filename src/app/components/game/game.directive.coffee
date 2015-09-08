'use strict'

#===============================================================================
#
#	ShapeConnector (SC) Game Directive
# 		Renders the game to the canvas and handles the events
#
#-------------------------------------------------------------------------------

app.directive 'scGame', [
	'$rootScope'
	'$log'
	'LEVELS'
	'BOARD'
	'SHAPE'
	'GameManagerService'
	'WatcherService'
	($rootScope, $log, LEVELS, BOARD, SHAPE, GameManager, Watcher) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		scope:
			sourceGame: '=?'
			difficulty: '@?'
			onNewGame: '&?'
			onResetGame: '&?'
		link: ($scope, el, attrs) ->
			# globals
			Game = null
			$window = $(window)
			$gameHeader = el.find('.game-header')
			watcher = new Watcher( $scope )
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
					windowMidHeight = $window.height() / 2
					boardHalfHeight = BOARD.DIMENSIONS.h / 2
					headerHeight = $gameHeader.outerHeight(true)

					topMargin = windowMidHeight - headerHeight - boardHalfHeight
					topMargin = 60 if topMargin < 0

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
				Game = new GameManager( $scope.canvasCollection, $scope.difficulty, $scope.sourceGame )

				# Save the current game board to the parent (controller) scope
				saveGameBoard()

				# Position the board correctly on the window
				positionBoard()

				# Create a scoped copy of the Game class
				$scope.game = Game.start()

				# $rootScope.windowEvents.onFocus( events.onFocus )
				$rootScope.windowEvents.onBlur( events.onBlur )
				$window.on('resize', events.onResize)

				return


			# saveGameBoard: Save the current game board to the controller
			#-------------------------------------------------------------------
			saveGameBoard = ->
				if not $scope.sourceGame?
					$scope.sourceGame = angular.copy(Game.cacheGameBoard)


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
				onMove: ( e, params ) ->
					$scope.$apply( => Game.onMoveEvent(e, params) )
				onEnd: -> $scope.$apply( => Game.onEndEvent() )
				onCancel: -> $scope.$apply( => Game.onCancelEvent() )
				onResize: -> positionBoard()
				onBlur: ->
					$scope.$apply( =>
						Game.pauseGame()
						$scope.showPauseModal = true
					)


			# actions: Additonal user triggered actions on game win/lose
			#-------------------------------------------------------------------
			$scope.actions =
				debug: ( e ) -> console.log('Made it to game.directive', e )
				newGame: -> $scope.onNewGame?(params: true)
				resetGame: -> $scope.onResetGame?(params: Game.cacheGameBoard)
				quitGame: -> $scope.onQuitGame?(params: true)
				resumeGame: ->
					$scope.$apply( =>
						Game.resumeGame()
						$scope.showPauseModal = false
					)



			# We're ready to set the scope variables
			setup()

			# Watch the canvasCollection for updates - start the game when
			# we have the game canvas data
			stopCanvasWatch = watcher.start('canvasCollection', (collection) ->
				if collection?.game?
					stopCanvasWatch()
					start()
			)

			watcher.start('game.won', ( hasWon ) ->
				$scope.showWinModal = (hasWon is true)
			)
			watcher.start('game.lost', ( hasLost ) ->
				$scope.showLoseModal = (hasLost is true)
			)

			# Destroy the Game class on directive $destroy
			$scope.$on('$destroy', () ->
				Game.destroy()
			)
]
