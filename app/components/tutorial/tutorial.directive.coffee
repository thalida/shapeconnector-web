'use strict'

#===============================================================================
#
#	ShapeConnector (SC) Game Directive
# 		Renders the game to the canvas and handles the events
#
#-------------------------------------------------------------------------------
angular.module('app').directive 'scTutorial', [
	'$rootScope'
	'$log'
	'$state'
	'$timeout'
	'TUTORIAL_STEPS'
	'LEVELS'
	'BOARD'
	'SHAPE'
	require '../../services/gameManager'
	require '../../services/watcher'

	($rootScope, $log, $state, $timeout, TUTORIAL_STEPS, LEVELS, BOARD, SHAPE, GameManager, Watcher) ->
		templateUrl: 'components/tutorial/tutorial.html'
		restrict: 'E'
		scope:
			onStepSuccess: '&?'
			stepNum: '@?step'
			endNodes: '=?'
		link: ($scope, el, attrs) ->
			# globals
			game = null
			$window = $(window)
			watcher = new Watcher( $scope )
			step = TUTORIAL_STEPS[$scope.stepNum]
			$scope.step = step

			boardSizeX = if step.random then step.boardSize else step.shapes.length
			boardSizeY = if step.random then step.boardSize else 1

			# Calculate the total width + height of the game board
			boardDimensions =
				w: (boardSizeX * SHAPE.OUTERSIZE) + BOARD.MARGIN.left
				h: (boardSizeY * SHAPE.OUTERSIZE) + BOARD.MARGIN.top


			# setup: creates variables to be used when we render + start the game
			#-------------------------------------------------------------------
			setup = ->
				# Collection of canvases to be drawn on
				$scope.canvasCollection = {}

				# The dimenisions (sizes) of the canvases we need
				$scope.canvasDimensions =
					goal: {
						width: boardDimensions.w
						height: SHAPE.OUTERSIZE
					}
					board: {
						width: boardDimensions.w
						height: boardDimensions.h
					}

				# Callback events for the game canvas
				$scope.gameCanvasEvents =
					start: events.onStart
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
						mode: 'tutorial'
						step: $scope.step
					render:
						canvas: $scope.canvasCollection
				)

				positionBoard()

				$scope.endNodes = angular.copy(game.endNodes)

				# Create a scoped copy of the Game class
				game.start()

				$window.on('resize', events.onResize)

				return

			# positionBoard: Update the position of the board on the screen
			#-------------------------------------------------------------------
			positionBoard = ->
				$game = el.find('.game')
				$gameBoard = $game.find('.game-board')

				headerHeight = if window.innerHeight > 650 and step.showGoal then SHAPE.OUTERSIZE + 10 else 0

				windowMidHeight = window.innerHeight / 2
				windowMidWidth = window.innerWidth / 2

				boardHalfHeight = boardDimensions.h / 2
				boardHalfWidth = boardDimensions.w / 2

				topMargin = windowMidHeight - headerHeight - boardHalfHeight
				topMargin = 180 if topMargin < 200

				leftMargin = windowMidWidth - boardHalfWidth
				leftMargin = 0 if leftMargin < 0

				$game.css(
					position: 'absolute'
					width: boardDimensions.w
					top: topMargin
					left: leftMargin
				)

				$gameBoard.css(
					height: boardDimensions.h
					width: boardDimensions.w
				)

				return

			# events
			# 	Bind gameboard the touch/mouse events to the corresponding
			# 	method in the Game manager
			#	Note: Keep $scope.$apply since events are bound outåside of angular
			#-------------------------------------------------------------------
			events =
				onStart: ( e, params ) -> $scope.$apply( => game.onStartEvent(e, params) )
				onMove: ( e, params ) -> $scope.$apply( => game.onMoveEvent(e, params) )
				onEnd: -> $scope.$apply( => game.onEndEvent() )
				onCancel: -> $scope.$apply( => game.onCancelEvent() )
				onResize: -> positionBoard()


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
						if hasWon is true
							$timeout(()->
								nextStep = parseInt($scope.stepNum) + 1
								$state.go('tutorial', {step: nextStep})
								return
							,400)
				)

			# Destroy the Game class on directive $destroy
			$scope.$on('$destroy', () ->
				game.destroy()
			)
]
