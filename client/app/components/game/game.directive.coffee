'use strict'

app.directive 'appGame', [
	'$log'
	'gameService'
	'drawService'
	($log, gameService, DrawService) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		replace: true
		scope:
			difficulty: '@?'
		link: ($scope, el, attrs) ->
			$canvas = el.find('canvas')
			canvas = $canvas[0]

			draw = undefined
			ctx = undefined
			
			boardMargin = 100
			shapeSize = 16
			shapeMargin = 30
			gameBoardSize = 0
			gameDimensions = {}

			generateGame = () ->
				$scope.difficulty ?= 'easy'
				$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
				gameBoardSize = gameService.opts.dimensions

			setupCanvas = () ->
				maxBoardSize = gameBoardSize * (shapeSize + shapeMargin)
				
				gameDimensions.w = maxBoardSize
				gameDimensions.h = maxBoardSize + (boardMargin * 2)

				canvas.width = (gameDimensions.w * 2)
				canvas.height = (gameDimensions.h * 2)
				canvas.style.width = gameDimensions.w + 'px'
				canvas.style.height = gameDimensions.h + 'px'

				ctx = canvas.getContext('2d')
				ctx.scale(2, 2)
				draw = new DrawService(ctx, {size: shapeSize})


			renderGoal = () ->
				middleColumn = Math.floor( gameBoardSize / 2 )
				gameMiddle = middleColumn * (shapeSize + shapeMargin)

				goalCircle =
					y: 5
					w: 32
					h: 32

				goalCircle.x = gameMiddle - ( goalCircle.w / 4)

				draw.goalCircle(goalCircle.x, goalCircle.y, goalCircle.w, goalCircle.h)

				draw.text(
					$scope.game.maxMoves + '', 
					{
						x1: goalCircle.x,
						y1: goalCircle.y,
						x2: goalCircle.x + goalCircle.w,
						y2: goalCircle.y + goalCircle.h
					}
				)

				$.each($scope.game.endNodes, (i, node) ->
					direction = if i == 0 then -1 else 1

					x = (middleColumn + direction) * (shapeSize + shapeMargin)
					y = ((goalCircle.y + goalCircle.h) - (shapeSize / 2)) / 2

					line = 
						y1: y + (shapeSize / 2)
						y2: goalCircle.y + ((goalCircle.h + 2) / 2)

					line.x1 = x
					line.x2 = goalCircle.x

					if direction == -1
						line.x1 += shapeSize
					else
						line.x2 += goalCircle.w
					
					draw.dashedLine(line.x1, line.y1, line.x2, line.y2)

					draw.create(
						type: node.type
						color: node.color
						coords: {x, y}
					)

					return
				)


			renderBoard = () ->
				board = $scope.game.board
				$.each( board, ( boardX, row ) ->
					$.each( row, ( boardY, node ) ->
						x = node.coords.x * (shapeSize + shapeMargin)
						y = node.coords.y * (shapeSize + shapeMargin)

						y += boardMargin

						draw.create(
							type: node.type
							color: node.color
							coords: {x, y}
						)

						return
					)
				)

				return


			initGame = (() ->
				generateGame()
				setupCanvas()
				renderGoal()
				renderBoard()
			)()
]
