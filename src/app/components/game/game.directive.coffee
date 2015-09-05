'use strict'
#===============================================================================
#
#	Game Directive
# 		Renders the game to the canvas and handles the events
#
#-------------------------------------------------------------------------------
app.directive 'appGame', [
	'$log'
	'$timeout'
	'$interval'
	'BOARD'
	'SHAPE'
	'gameManagerService'
	'WatcherService'
	'gameUtils'
	($log, $timeout, $interval, BOARD, SHAPE, GameManager, Watcher, gameUtils) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		replace: true
		scope:
			sourceGame: '=?'
			difficulty: '@?'
			onNewGame: '&?'
			onResetGame: '&?'
		link: ($scope, el, attrs) ->
			$window = $(window)
			$gameHeader = el.find('.game-header')

			watcher = new Watcher( $scope )
			Game = null

			utils =
				calcGameWidth: () ->
					gameWidth = BOARD.DIMENSIONS.w + 150
					if $window.width() < gameWidth
						gameWidth = $window.width() - 30

					return gameWidth

				calcGameTopMargin: () ->
					windowMidHeight = $window.height() / 2
					boardHalfHeight = BOARD.DIMENSIONS.h / 2
					headerHeight = $gameHeader.outerHeight(true)
					goalHeight = $scope.canvasCollection.goal.$el.outerHeight(true)

					topMargin = windowMidHeight - boardHalfHeight - goalHeight - headerHeight
					topMargin = 60 if topMargin < 0

					return topMargin


			setup = () ->
				$scope.difficulty ?= 'easy'

				$scope.canvasCollection = {}

				$scope.canvasDimensions = {
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
				}

				$scope.gameCanvasEvents =
					start: onDrag.move
					move: onDrag.move
					end: onDrag.end
					cancel: onDrag.cancel


			render = () ->
				Game = new GameManager( $scope.canvasCollection, $scope.difficulty, $scope.sourceGame )

				if not $scope.sourceGame?
					$scope.sourceGame = angular.extend({}, {}, Game.board)

				el.css(
					width: utils.calcGameWidth()
					marginTop: utils.calcGameTopMargin()
				)

				$gameBoardContainer = el.find('.game-board-wrapper')
				$gameBoard = el.find('.game-board')
				$gamePopup = el.find('.game-popup')

				$gameBoardContainer.css(width: BOARD.DIMENSIONS.w)
				$gameBoard.css(height: BOARD.DIMENSIONS.h)
				$gamePopup.css(
					width: BOARD.DIMENSIONS.w
					height: BOARD.DIMENSIONS.h
				)

				$scope.game = Game.start()
				watch()

			watch = () ->
				watcher.start('game.won', Game.onGameWon)
				watcher.start('game.lost', Game.onGameLost)
				watcher.start('game.movesLeft', Game.onMovesLeftChange)
				watcher.start('game.selectedNodes', Game.onSelectedNodesChange)
				watcher.start('game.touchedNodes', Game.onTouchedNodesChange)
				watcher.start('game.addedNodes', Game.onAddedNodesChange)
				watcher.start('game.removedNodes', Game.onRemovedNodesChange)
				watcher.start('game.endGameAnimation', Game.onEndGameAnimationChange)

			$scope.actions =
				newGame: () ->
					$scope.onNewGame?(params: true)
					return

				resetGame: () ->
					$scope.onResetGame?(params: $scope.sourceGame)
					return

				quitGame: () ->
					$scope.onQuitGame?(params: true)
					return

			onDrag =
				move: ( e, params ) ->
					$scope.$apply(() =>
						Game.onMoveEvent(e, params)
					)

				end: () ->
					$scope.$apply(() =>
						Game.onEndEvent()
					)

				cancel: () ->
					$scope.$apply(() =>
						Game.onCancelEvent()
					)

			# $scope.$on('$destroy', () ->
			# )

			setup()

			stopCanvasWatch = watcher.start('canvasCollection', (collection) ->
				if collection?.goal?
					stopCanvasWatch()
					render()
			)
]



app.animation '.game-popup', [
	'$log'
	($log) ->
		return {
			addClass: (element, className, done) ->
				if className is 'ng-hide'
					$el = $(element)
					$el.show()
					$el.css(top: '0%')
					$el.animate({top: '100%'}, 500, () ->
						$el.hide()
						$el.css(top: '100%')
					)

				return

			removeClass: (element, className, done) ->
				if className is 'ng-hide'
					$el = $(element)
					$el.hide().css(top: '100%')
					$el.show().animate({top: '0%'}, 500, () ->
						$el.show()
						$el.css(top: '0%')
					)

				return
		}
]
