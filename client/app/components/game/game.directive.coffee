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
			$window = $(window)
			$canvas = el.find('canvas')
			canvas = $canvas[0]

			draw = undefined
			ctx = undefined

			gameStatus = 
				movesLeft: 0

			_ = 
				BOARD_SIZE: 0
				BOARD_DIMENSIONS: {}
				BOARD_MARGIN: {
					top: 100
				}
				SHAPE_SIZE: 16
				SHAPE_MARGIN: 30

			_.BOARD_MARGIN.left = _.SHAPE_MARGIN
			_.SHAPE_OUTERSIZE = _.SHAPE_SIZE + _.SHAPE_MARGIN


			$scope.selectedNodes = []

			isDragging = false

			utils = 
				calcBoardX: ( canvasX ) ->
					return Math.round((canvasX - _.BOARD_MARGIN.left) / _.SHAPE_OUTERSIZE)

				calcBoardY: ( canvasY ) ->
					return Math.round((canvasY - _.BOARD_MARGIN.top) / _.SHAPE_OUTERSIZE)

				calcCanvasX: ( boardX ) ->
					return (boardX * _.SHAPE_OUTERSIZE) + _.BOARD_MARGIN.left

				calcCanvasY: ( boardY ) ->
					return (boardY * _.SHAPE_OUTERSIZE) + _.BOARD_MARGIN.top

				calcShapeMinTrigger: ( canvasPoint ) ->
					return canvasPoint - (_.SHAPE_MARGIN / 2)
				
				calcShapeMaxTrigger: ( canvasPoint ) ->
					return canvasPoint + _.SHAPE_SIZE + (_.SHAPE_MARGIN / 2)

				isValidBoardAxis: ( boardAxis ) ->
					return 0 <= boardAxis < _.BOARD_SIZE


			setup = new class GameSetup
				constructor: () ->

				run: () ->
					@game()
					@canvas()

				game: () ->
					$scope.difficulty ?= 'easy'
					$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
					
					_.BOARD_SIZE = gameService.opts.dimensions
					gameStatus.movesLeft = $scope.game.maxMoves

				canvas: () ->
					maxBoardSize = _.BOARD_SIZE * _.SHAPE_OUTERSIZE
				
					_.BOARD_DIMENSIONS.w = maxBoardSize + _.BOARD_MARGIN.left
					_.BOARD_DIMENSIONS.h = maxBoardSize + _.BOARD_MARGIN.top

					el.css(
						width: _.BOARD_DIMENSIONS.w
						height: _.BOARD_DIMENSIONS.h
					)

					canvas.width = _.BOARD_DIMENSIONS.w * 2
					canvas.height = _.BOARD_DIMENSIONS.h * 2
					canvas.style.width = _.BOARD_DIMENSIONS.w + 'px'
					canvas.style.height = _.BOARD_DIMENSIONS.h + 'px'

					ctx = canvas.getContext('2d')
					ctx.scale(2, 2)
					draw = new DrawService(ctx, {size: _.SHAPE_SIZE})


			render = new class GameRender
				run: () ->
					@board()
					@goal()

				movesLeft: ( numMoves ) ->
					numMoves ?= $scope.game.maxMoves

					middleColumn = Math.floor(_.BOARD_SIZE / 2)
					gameMiddle = utils.calcCanvasX( middleColumn )

					movesCircle =
						y: 5
						w: 32
						h: 32

					movesCircle.x = gameMiddle - ( movesCircle.w / 4)

					draw.clear(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h)
					draw.movesCircle(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h)

					color = 'white'
					if parseInt(numMoves, 10) < 0
						color = 'red'

					draw.text(
						numMoves + '', 
						{
							x1: movesCircle.x,
							y1: movesCircle.y,
							x2: movesCircle.x + movesCircle.w,
							y2: movesCircle.y + movesCircle.h,
							color: color
						}
					)

					return movesCircle

				goal: () ->
					movesCirlce = @movesLeft()				
					middleColumn = Math.floor(_.BOARD_SIZE / 2)

					$.each($scope.game.endNodes, (i, node) ->
						direction = if i == 0 then -1 else 1

						x = utils.calcCanvasX(middleColumn + direction)
						y = ((movesCirlce.y + movesCirlce.h) - (_.SHAPE_SIZE / 2)) / 2

						line = 
							y1: y + (_.SHAPE_SIZE / 2)
							y2: movesCirlce.y + ((movesCirlce.h + 2) / 2)

						line.x1 = x
						line.x2 = movesCirlce.x

						if direction == -1
							line.x1 += _.SHAPE_SIZE
						else
							line.x2 += movesCirlce.w
						
						draw.dashedLine(line.x1, line.y1, line.x2, line.y2)

						draw.create(
							type: node.type
							color: node.color
							coords: {x, y}
						)

						return
					)

				board: () ->
					board = $scope.game.board
					$.each( board, ( boardX, col ) ->
						$.each( col, ( boardY, node ) ->
							x = utils.calcCanvasX(node.coords.x)
							y = utils.calcCanvasY(node.coords.y)

							node.position = {x, y}
							node.selected = false

							draw.create(
								type: node.type
								color: node.color
								coords: {x, y}
							)

							return
						)
					)

					$log.debug( $scope.game.board )

					return


			findNode = ( pos ) ->
				boardX = utils.calcBoardX(pos.x)
				boardY = utils.calcBoardY(pos.y)

				isValidBoardX = utils.isValidBoardAxis(boardX)
				isValidBoardY = utils.isValidBoardAxis(boardY)
				
				return if not isValidBoardX || not isValidBoardY
					
				return $scope.game.board[boardX][boardY]


			validateAxis = ( params ) ->
				calcCanvasName = 'calcCanvas' + params.type.toUpperCase()
				canvasPos = utils[calcCanvasName]( params.nodeCoord )
				minTouch = utils.calcShapeMinTrigger(canvasPos)
				maxTouch = utils.calcShapeMaxTrigger(canvasPos)

				return minTouch <= params.touchPos <= maxTouch


			checkMove = ( pos, opts ) ->
				node = findNode( pos )
				return false if !node? || node is false

				if $scope.selectedNodes.length == 0 
					saveNode( node ) if opts?.save
					return true

				return false if node.selected == true and not isGrandPaNode( node )

				isValidCanvasX = validateAxis({type: 'x', nodeCoord: node.coords.x, touchPos: pos.x})
				isValidCanvasY = validateAxis({type: 'y', nodeCoord: node.coords.y, touchPos: pos.y})
				return false if not isValidCanvasX || not isValidCanvasY

				parentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 1 ]
				dx = Math.abs(parentNode.coords.x - node.coords.x)
				dy = Math.abs(parentNode.coords.y - node.coords.y)
				isValidDirection = (dx + dy) == 1
				return false if not isValidDirection

				sameColor = parentNode.color == node.color
				sameType = parentNode.type == node.type
				isValidMove = isValidDirection and (sameColor or sameType)
				return false if not isValidMove

				saveNode( node )
				
				return isValidMove


			isGrandPaNode = ( node ) ->
				grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]

				return false if not grandparentNode?
				
				isSameX = node.coords.x == grandparentNode.coords.x
				isSameY = node.coords.y == grandparentNode.coords.y

				return isSameX and isSameY


			saveNode = ( node ) ->
				return if !node?

				if isGrandPaNode( node )
					grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]
					$scope.game.board[grandparentNode.coords.x][grandparentNode.coords.y].selected = false
					$scope.selectedNodes.pop()
					return

				nodeCoords = node.coords
				$scope.game.board[nodeCoords.x][nodeCoords.y].selected = true
				$scope.selectedNodes.push( node )
				return



			processMove = ( touch, opts ) ->
				canvasOffset = $canvas.offset()
				nodePosition = 
					x: touch.pageX - canvasOffset.left
					y: touch.pageY - canvasOffset.top

				$scope.$apply(() ->
					checkMove(nodePosition, {save: true})
				)
				

			processMoveDone = ( touch, opts ) ->
				$scope.$apply(() ->
					if $scope.selectedNodes.length == 1
						node = $scope.selectedNodes[0]
						$scope.game.board[node.coords.x][node.coords.y].selected = false
						$scope.selectedNodes = []
				)

				$log.debug('END: ', $scope.selectedNodes, $scope.game.board )
				$log.debug('=================================')

			processMoveCancel = ( touch, opts ) ->
				$scope.selectedNodes = []



			onTouch =
				start: ( e ) ->
					$log.debug('=================================')
					$log.debug('STARTED TOUCH')
					
					processMove( e.changedTouches[0] )
					
				move: ( e ) ->
					e.preventDefault()
					processMove( e.changedTouches[0] )

				end: ( e ) ->
					processMoveDone()

				cancel: ( e ) ->
					processMoveCancel()

			onMouse = 
				start: ( e ) ->
					$log.debug('=================================')
					$log.debug('STARTED MOUSE')
					
					isDragging = true
					processMove( e )
					
				move: ( e ) ->
					if isDragging
						e.preventDefault()
						processMove( e )

				end: ( e ) ->
					isDragging = false
					processMoveDone()


			initEvents = () ->
				$canvas
					.on('mousedown', onMouse.start)
					.on('mousemove', onMouse.move)
					.on('mouseup', onMouse.end)

				canvasEl = $canvas[0]
				canvasEl.addEventListener('touchstart', onTouch.start, false)
				canvasEl.addEventListener('touchmove', onTouch.move, false)
				canvasEl.addEventListener('touchend', onTouch.end, false)
				canvasEl.addEventListener('touchleave', onTouch.end, false)
				canvasEl.addEventListener('touchcancel', onTouch.cancel, false)


			startWatch = () ->
				$scope.$watchCollection('selectedNodes', (nodes) ->
					$log.debug('selected', nodes)
				)


			initGame = (() ->
				setup.run()
				render.run()

				startWatch()
				initEvents()
			)()
]
