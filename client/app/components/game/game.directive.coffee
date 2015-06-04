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
			$targets = el.find('.targets')

			$canvas = el.find('canvas')
			canvas = $canvas[0]

			draw = undefined
			ctx = undefined
			
			shapeSize = 16
			shapeMargin = 30
			gameBoardSize = 0
			gameDimensions = {}
			gamePosition = {}
			boardMargin = {
				top: 100
				left: shapeMargin
			}

			generateGame = () ->
				$scope.difficulty ?= 'easy'
				$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
				gameBoardSize = gameService.opts.dimensions

			setupCanvas = () ->
				maxBoardSize = gameBoardSize * (shapeSize + shapeMargin)
				
				gameDimensions.w = maxBoardSize + boardMargin.left
				gameDimensions.h = maxBoardSize + (boardMargin.top * 2)

				el.css(
					width: gameDimensions.w
					height: gameDimensions.h
				)

				# $targets.css(
				# 	width: gameDimensions.w
				# 	height: maxBoardSize + shapeMargin
				# )

				canvas.width = (gameDimensions.w * 2)
				canvas.height = (gameDimensions.h * 2)
				canvas.style.width = gameDimensions.w + 'px'
				canvas.style.height = gameDimensions.h + 'px'

				gamePosition = $canvas.offset()

				ctx = canvas.getContext('2d')
				ctx.scale(2, 2)
				draw = new DrawService(ctx, {size: shapeSize})


			renderGoal = () ->
				middleColumn = Math.floor( gameBoardSize / 2 )
				gameMiddle = (middleColumn * (shapeSize + shapeMargin)) + boardMargin.left

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

					x = ((middleColumn + direction) * (shapeSize + shapeMargin)) + boardMargin.left
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


			renderTarget = (node, x, y) ->
				classNames = "target target_#{node.coords.x}-#{node.coords.y}"
				$newTarget = $('<div class="'+classNames+'"></div>')

				$newTarget.data(
					x: node.coords.x
					y: node.coords.y
					left: x
					right: y
					color: node.color
					type: node.type
				)

				$newTarget.css(
					top: y - (shapeMargin / 4)
					left: x - (shapeMargin / 4)
					width: shapeSize + (shapeMargin / 2)
					height: shapeSize + (shapeMargin / 2)
				)


				$targets.append( $newTarget )



			renderBoard = () ->
				board = $scope.game.board
				$.each( board, ( boardX, row ) ->
					$.each( row, ( boardY, node ) ->
						x = node.coords.x * (shapeSize + shapeMargin) + boardMargin.left
						y = (node.coords.y * (shapeSize + shapeMargin)) + boardMargin.top

						renderTarget(node, x, y)

						draw.create(
							type: node.type
							color: node.color
							coords: {x, y}
						)

						return
					)
				)

				return

			initEvents = () ->
				$targets = $('.targets')

				$targets.on('mousedown', (e) ->
					$node = $(e.target)

					$log.debug( $node.data() )
				)


			initGame = (() ->
				generateGame()
				setupCanvas()
				renderGoal()
				renderBoard()

				initEvents()
			)()
]
