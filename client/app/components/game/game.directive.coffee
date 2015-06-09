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
	'gameService'
	'drawService'
	'timerService'
	'assetsService'
	($log, $timeout, $interval, GameService, DrawService, Timer, assetsService) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		replace: true
		scope:
			difficulty: '@?'
		link: ($scope, el, attrs) ->
			$window = $(window)
			$gameHeader = el.find('.game-header')

			_ = null
			canvas = null
			dragStart = null
			isDragging = null
			isValidStart = null
			disableNewConnections = null
			timer = null
			timeRemaining = null
			totalTime = null

			#===================================================================
			# 
			# 
			# 
			#	INIT
			# 
			# 
			# 
			#-------------------------------------------------------------------
			init = () ->
				_ = 
					BOARD_SIZE: 0
					BOARD_DIMENSIONS: {}
					BOARD_MARGIN: {}
					SHAPE_SIZE: 16
					SHAPE_MARGIN: 30

				_.BOARD_MARGIN.top = _.SHAPE_MARGIN
				_.BOARD_MARGIN.left = _.SHAPE_MARGIN
				_.SHAPE_OUTERSIZE = _.SHAPE_SIZE + _.SHAPE_MARGIN

				#	Setup the store of general game information
				#---------------------------------------------------------------
				$scope.selectedNodes = []
				$scope.addedNodes = []
				$scope.removedNodes = []
				$scope.touchedNodes = []
				$scope.startNode = null
				$scope.animationsDone = false

				canvas = {}

				#	Setup events globals
				#---------------------------------------------------------------
				dragStart = {}
				isDragging = false
				isValidStart = false
				disableNewConnections = false
				
				totalTime = 60
				timeRemaining = 0


				assetsService.onComplete(() ->
					timer?.stop()
					watchers?.stop()

					setup.run()
					render.run()
					watchers.start()
					events.bind()

					$scope.hasTimer = true
					timer = new Timer( totalTime )
					timer.onTick = onTimerChange
					timer.start()
				)
				assetsService.downloadAll()

				return
			
			$scope.newGame = init




			#===================================================================
			# 
			# 
			# 
			#	RESET
			# 
			# 
			# 
			#-------------------------------------------------------------------
			reset = () ->
				timer?.stop()
				watchers?.stop()
				$scope.game = $scope.origGame

				#	Setup the store of general game information
				#---------------------------------------------------------------
				$scope.selectedNodes = []
				$scope.addedNodes = []
				$scope.removedNodes = []
				$scope.touchedNodes = []
				$scope.startNode = null
				$scope.animationsDone = false

				#	Setup events globals
				#---------------------------------------------------------------
				dragStart = {}
				isDragging = false
				isValidStart = false
				disableNewConnections = false

				timeRemaining = 0

				render.run()
				watchers.start()
				events.bind()

				$scope.hasTimer = true
				timer = new Timer( totalTime )
				timer.onTick = onTimerChange
				timer.start()

				return
			
			$scope.resetGame = reset
			









			#===================================================================
			# 
			# 
			# 
			#	UTILS
			# 		General functions and calculations used to figure out where
			# 		various aspects of the canvas or board
			# 
			# 
			# 
			#-------------------------------------------------------------------

			utils = 
				calcGameWidth: () ->
					gameWidth = _.BOARD_DIMENSIONS.w + 150
					if $window.width() < gameWidth
						gameWidth = $window.width() - 30

					return gameWidth

				calcGameTopMargin: () ->
					windowMidHeight = $window.height() / 2
					boardHalfHeight = _.BOARD_DIMENSIONS.h / 2
					headerHeight = $gameHeader.outerHeight(true)
					goalHeight = canvas.goal.$el.outerHeight(true)

					topMargin = windowMidHeight - boardHalfHeight - goalHeight - headerHeight
					topMargin = 60 if topMargin < 0

					return topMargin

				#	@calcBoardX
				# 		With a given canvas X coord get the X column of the board
				#---------------------------------------------------------------
				calcBoardX: ( canvasX ) ->
					return Math.round((canvasX - _.BOARD_MARGIN.left) / _.SHAPE_OUTERSIZE)

				#	@calcBoardY
				# 		With a given canvas Y coord get the Y row of the board
				#---------------------------------------------------------------
				calcBoardY: ( canvasY ) ->
					return Math.round((canvasY - _.BOARD_MARGIN.top) / _.SHAPE_OUTERSIZE)

				#	@calcCanvasX
				# 		With a given X column of the board get the canvas X coord
				#---------------------------------------------------------------
				calcCanvasX: ( boardX ) ->
					return (boardX * _.SHAPE_OUTERSIZE) + _.BOARD_MARGIN.left

				#	@calcCanvasY
				# 		With a given Y row of the board get the canvas Y coord
				#---------------------------------------------------------------
				calcCanvasY: ( boardY ) ->
					return (boardY * _.SHAPE_OUTERSIZE) + _.BOARD_MARGIN.top

				#	@calcShapeMinTrigger
				# 		Figure out the min coord to trigger a shape selection
				#---------------------------------------------------------------
				calcShapeMinTrigger: ( canvasPoint ) ->
					return canvasPoint - (_.SHAPE_MARGIN / 2)
				
				#	@calcShapeMaxTrigger
				# 		Figure out the max coord to trigger a shape selection
				#---------------------------------------------------------------
				calcShapeMaxTrigger: ( canvasPoint ) ->
					return canvasPoint + _.SHAPE_SIZE + (_.SHAPE_MARGIN / 2)

				#	@isValidBoardAxis
				# 		Check if a given X or Y coord is a valid board option
				#---------------------------------------------------------------
				isValidBoardAxis: ( boardAxis ) ->
					return 0 <= boardAxis < _.BOARD_SIZE

				#	@isSameNode
				# 		Check if two nodes share the same coords
				#---------------------------------------------------------------
				isSameNode: (nodeA, nodeB) ->
					return false if not nodeA? or not nodeB?

					isSameX = nodeA.coords.x == nodeB.coords.x
					isSameY = nodeA.coords.y == nodeB.coords.y

					return isSameX and isSameY

				#	@isSameShape
				# 		Check if two nodes are the same type + color shape
				#---------------------------------------------------------------
				isSameShape: (nodeA, nodeB) ->
					return false if not nodeA? or not nodeB?

					isSameColor = nodeA.color == nodeB.color
					isSameType = nodeA.type == nodeB.type

					return isSameColor and isSameType

				#	@createDrawParams
				# 		Global utility for converting a node to the drawService params
				#---------------------------------------------------------------
				createDrawParams: ( node, nodeStyle, clearStyle ) ->
					if clearStyle? and clearStyle == 'small'
						clear =
							x: node.position.x
							y: node.position.y
							width: _.SHAPE_SIZE
							height: _.SHAPE_SIZE
					else if clearStyle? and clearStyle == 'large'
						clear =
							x: node.position.x - _.SHAPE_MARGIN
							y: node.position.y - _.SHAPE_MARGIN
							width: _.SHAPE_OUTERSIZE + _.SHAPE_MARGIN
							height: _.SHAPE_OUTERSIZE + _.SHAPE_MARGIN
					else
						clear =
							x: node.position.x - (_.SHAPE_MARGIN / 2)
							y: node.position.y - (_.SHAPE_MARGIN / 2)
							width: _.SHAPE_OUTERSIZE
							height: _.SHAPE_OUTERSIZE

					return {
						type: node.type
						color: node.color
						style: nodeStyle
						coords: {x: node.position.x, y: node.position.y}
						clear: clear
					}

				#	@getNodeStyle
				# 		Get the style of the node based on it's current state
				#---------------------------------------------------------------
				getNodeStyle: ( node ) ->
					$scope.game.won = utils.isGameOver()
					if node.selected == true
						lastNode = utils.selectedNodes.last()
						
						if utils.isSameNode(node, $scope.startNode)
							nodeStyle = 'start'
						else if $scope.game.won and utils.isSameNode(node, lastNode)
							nodeStyle = 'start'
						else
							nodeStyle = 'touched'
					else
						nodeStyle = 'untouched'

					return nodeStyle

				#	@findNode
				# 		Based on a canvas x and y position find the node that is
				# 		at this point
				#---------------------------------------------------------------
				findNode: ( pos ) ->
					# Get the x and y coords of the board at this canvas position
					boardX = utils.calcBoardX(pos.x)
					boardY = utils.calcBoardY(pos.y)

					# Validate that these are allowable board coords
					isValidBoardX = utils.isValidBoardAxis(boardX)
					isValidBoardY = utils.isValidBoardAxis(boardY)
					
					return if not isValidBoardX || not isValidBoardY
						
					return $scope.game.board[boardX][boardY]

				#	@validateTouchAxis
				# 		Check if the given touch coords are in a valid
				# 		location to trigger the nearest node
				#---------------------------------------------------------------
				validateTouchAxis: ( params ) ->
					calcCanvasName = 'calcCanvas' + params.type.toUpperCase()
					canvasPos = utils[calcCanvasName]( params.nodeCoord )
					minTouch = utils.calcShapeMinTrigger(canvasPos)
					maxTouch = utils.calcShapeMaxTrigger(canvasPos)

					return minTouch <= params.touchPos <= maxTouch

				#	@isGrandPaNode
				# 		Check if the given node is the SAME as the node two moves back
				#-------------------------------------------------------------------
				isGrandPaNode: ( node ) ->
					grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]
					return utils.isSameNode( node, grandparentNode )

				#	@getNeighborNodes
				# 		Get all the nodes surrounding this one
				#---------------------------------------------------------------
				getNeighborNodes: ( node, checks ) ->
					nodeX = node.coords.x
					nodeY = node.coords.y

					neighbors = []
					potentials = [
						[nodeX + 1, nodeY]
						[nodeX + 1, nodeY + 1]
						[nodeX + 1, nodeY - 1]
						[nodeX, nodeY + 1]
						[nodeX, nodeY - 1]
						[nodeX - 1, nodeY]
						[nodeX - 1, nodeY + 1]
						[nodeX - 1, nodeY - 1]
					]

					potentialIdx = 0
					while potentialIdx < potentials.length
						# Get the x and y coors of this potential move
						potNode = potentials[ potentialIdx ]
						potX = potNode[0]
						potY = potNode[1]

						# Check if the x and y coords are valid 
						isValidX = utils.isValidBoardAxis( potX )
						isValidY = utils.isValidBoardAxis( potY )

						if isValidX and isValidY
							neighborNode = $scope.game.board[potX][potY]

							if checks?
								if checks.selected? && neighborNode.selected == checks.selected
									neighbors.push( neighborNode )
							else
								neighbors.push( neighborNode )

						potentialIdx += 1

					return neighbors

				#	@checkIsTouched
				# 		Check if a node is already in the touched array
				#---------------------------------------------------------------
				checkIsTouched: ( node ) ->
					touched = false
					$.each($scope.touchedNodes, (i, thisNode) ->
						if utils.isSameNode( node, thisNode )
							touched = true
							return
					)

					return touched

				#	@selectedNodes
				# 		Get the first, last, and total elements for the 
				# 		$scope.selectedNodes
				#---------------------------------------------------------------
				selectedNodes:
					first: () ->
						return $scope.selectedNodes[0]
					last: () ->
						return $scope.selectedNodes[$scope.selectedNodes.length - 1]
					total: () ->
						return $scope.selectedNodes.length

				#	@checkMove
				# 		Validate that node moved to via touch/mouse is a valid one
				#---------------------------------------------------------------
				checkMove: ( node, pos, opts ) ->
					# Return if no node has been found
					return false if !node? || node is false

					# If we have NO other selected nodes this move is automatically valid
					if utils.selectedNodes.total() == 0 
						saveNode( node ) if opts?.save
						return true

					# Return false if this node is selected and it is not a grandpa node
					return false if node.selected == true and not utils.isGrandPaNode( node )

					# Validate that move is in the accepted distance to trigger the closest node
					isValidCanvasX = utils.validateTouchAxis({type: 'x', nodeCoord: node.coords.x, touchPos: pos.x})
					isValidCanvasY = utils.validateTouchAxis({type: 'y', nodeCoord: node.coords.y, touchPos: pos.y})
					return false if not isValidCanvasX || not isValidCanvasY

					# Check that the node this move is closest to is one that we're
					# allowed to move to (up, down, left, or right only)
					parentNode = utils.selectedNodes.last()
					dx = Math.abs(parentNode.coords.x - node.coords.x)
					dy = Math.abs(parentNode.coords.y - node.coords.y)
					isValidDirection = (dx + dy) == 1
					return false if not isValidDirection

					# Check that the node we're closest to is either the smae color
					# or the same type as the parent node
					sameColor = parentNode.color == node.color
					sameType = parentNode.type == node.type
					isValidMove = isValidDirection and (sameColor or sameType)
					return false if not isValidMove

					# Woot! We've made a valid move
					saveNode( node )
					
					return isValidMove

				#	@isGameOver
				# 		Check if the game is completed
				#---------------------------------------------------------------
				isGameOver: () ->
					return false if $scope.game.movesLeft > 0

					[firstNode, ..., lastNode] = $scope.selectedNodes
					[endNodeA, ..., endNodeB] = $scope.game.endNodes

					isFirstEndNodeA = utils.isSameShape(firstNode, endNodeA)
					isLastEndNodeA = utils.isSameShape(lastNode, endNodeA)
					return false if not isFirstEndNodeA and not isLastEndNodeA

					isFirstEndNodeB = utils.isSameShape(firstNode, endNodeB)
					isLastEndNodeB = utils.isSameShape(lastNode, endNodeB)
					return false if not isFirstEndNodeB and not isLastEndNodeB

					return true










			#===================================================================
			# 
			# 
			# 
			#	SETUP: General setup of the game and canvas
			# 
			# 
			# 
			#-------------------------------------------------------------------
			setup = new class GameSetup
				constructor: () ->

				run: () ->
					@game()
					@canvas()

				#	@game
				# 		Setups the game arrays and consts
				#---------------------------------------------------------------
				game: () ->
					# If no difficulty was passed default to easy
					$scope.difficulty ?= 'easy'

					# Generate the game board arrays
					gameService = new GameService()
					$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
					$scope.game.movesLeft = $scope.game.maxMoves
					$scope.game.won = false
					$scope.game.lost = false

					$scope.origGame = angular.extend({}, {}, $scope.game)
					
					# Set the board size const
					_.BOARD_SIZE = gameService.opts.dimensions

				#	@createCanvas
				# 		Create a new canvas and draw servic
				#---------------------------------------------------------------
				createCanvas: ( canvasName, className ) ->
					$selector = el.find(className)
					canvasEl = $selector[0]

					if canvasName is 'goal'
						canvasEl.width = _.BOARD_DIMENSIONS.w * 2
						canvasEl.style.width = _.BOARD_DIMENSIONS.w + 'px'
						canvasEl.height = _.SHAPE_OUTERSIZE * 2
						canvasEl.style.height = _.SHAPE_OUTERSIZE + 'px'
					else if canvasName is 'timer'
						canvasEl.width = _.SHAPE_OUTERSIZE * 2
						canvasEl.style.width = _.SHAPE_OUTERSIZE + 'px'
						canvasEl.height = _.SHAPE_OUTERSIZE * 2
						canvasEl.style.height = _.SHAPE_OUTERSIZE + 'px'
					else
						canvasEl.width = _.BOARD_DIMENSIONS.w * 2
						canvasEl.style.width = _.BOARD_DIMENSIONS.w + 'px'
						canvasEl.height = _.BOARD_DIMENSIONS.h * 2
						canvasEl.style.height = _.BOARD_DIMENSIONS.h + 'px'

					ctx = canvasEl.getContext('2d')
					ctx.scale(2, 2)

					canvas[canvasName] =
						$el: $selector
						el: canvasEl
						ctx: ctx

					canvas[canvasName].render = new DrawService(canvas[canvasName].ctx, {size: _.SHAPE_SIZE})

					return canvas[canvasName]


				#	@canvas
				# 		Sets the canvas width + height based on the
				# 		size of the board
				#---------------------------------------------------------------
				canvas: () ->
					maxBoardSize = _.BOARD_SIZE * _.SHAPE_OUTERSIZE
					
					# Save the outer width and height dimenions of the baord
					_.BOARD_DIMENSIONS.w = maxBoardSize + _.BOARD_MARGIN.left
					_.BOARD_DIMENSIONS.h = maxBoardSize + _.BOARD_MARGIN.top


					@createCanvas('game', '.canvas-game')
					@createCanvas('lines', '.canvas-lines')
					@createCanvas('goal', '.canvas-goal')
					@createCanvas('timer', '.canvas-timer')


					$gameBoardContainer = el.find('.game-board-wrapper')
					$gameBoard = el.find('.game-board')
					$gamePopup = el.find('.game-popup')

					el.css(
						width: utils.calcGameWidth()
						marginTop: utils.calcGameTopMargin()
					)
					$gameBoardContainer.css(width: _.BOARD_DIMENSIONS.w)
					$gameBoard.css(height: _.BOARD_DIMENSIONS.h)
					$gamePopup.css(
						width: _.BOARD_DIMENSIONS.w
						height: _.BOARD_DIMENSIONS.h
					)










			#===================================================================
			# 
			# 
			# 
			#	RENDER: Render the game elements to the canvas
			# 
			# 
			# 
			#-------------------------------------------------------------------
			render = new class GameRender
				run: () ->
					@clearLinesBoard()
					@clearGoalBoard()
					@clearGameBoard()

					@board()
					@goal()


				#	@movesLeft
				# 		Render the moves left circle + counter
				#---------------------------------------------------------------
				movesLeft: ( color = 'white' ) ->
					numMoves = $scope.game.movesLeft

					# Set text to red if we've used up all of our moves
					if not $scope.game.won and parseInt(numMoves, 10) <= 0
						color = 'red'

					# Get the canvas x pos of the middle column of the board
					middleColumn = Math.floor(_.BOARD_SIZE / 2)
					gameMiddle = utils.calcCanvasX( middleColumn )

					# Setup the position and dimensions of the moves circle
					movesCircle =
						y: 5
						w: 32
						h: 32
					movesCircle.x = gameMiddle - ( movesCircle.w / 4)

					# Clear the area under the circle
					canvas.goal.render.clear(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h)
					
					# Draw the circle
					canvas.goal.render.strokedCircle(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h, color)

					# Render the # of moves text on the canvas
					# Center the text in the moves circle
					canvas.goal.render.text(
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

				#	@goal
				# 		Render the nodes that must start and end the connections
				#---------------------------------------------------------------
				goal: () ->
					canvas.goal.render.clear(0, 0, _.BOARD_DIMENSIONS.w, _.BOARD_MARGIN)

					# Render the moves left
					movesCircle = @movesLeft()				
					
					# Get the middle column of the board
					middleColumn = Math.floor(_.BOARD_SIZE / 2)

					# For each of the game nodes 
					# Render them to the board and draw the dashed connecting line
					$.each($scope.game.endNodes, (i, node) ->
						# Get if we are rendering to the left or right of the
						# middle column
						direction = if i == 0 then -1 else 1

						# Calculate the x pos of the node
						x = utils.calcCanvasX(middleColumn + direction)
						# Center the node vertically w/ the circle
						y = ((movesCircle.y + movesCircle.h) - (_.SHAPE_SIZE / 2)) / 2

						# Set the line to start and end vertically centered
						# with the circle
						line = 
							y1: y + (_.SHAPE_SIZE / 2)
							y2: movesCircle.y + ((movesCircle.h + 2) / 2)

						# Set the start and end positions of the line
						line.x1 = x
						line.x2 = movesCircle.x

						if direction == -1
							line.x1 += _.SHAPE_SIZE
						else
							line.x2 += movesCircle.w
						
						if $scope.game.won
							nodeStyle = 'start'
							canvas.goal.render.solidLine(line.x1, line.y1, line.x2, line.y2)
						else
							nodeStyle = 'untouched'
							canvas.goal.render.dashedLine(line.x1, line.y1, line.x2, line.y2)

						canvas.goal.render.create(
							type: node.type
							color: node.color
							coords: {x, y}
							style: nodeStyle
						)

						return
					)

				#	@board
				# 		Render the nodes of the game board
				#---------------------------------------------------------------
				board: ( params ) ->
					board = $scope.game.board
					$.each( board, ( boardX, col ) ->
						$.each( col, ( boardY, node ) ->
							if not $scope.game.won
								# Get the canvas x and y coords of the node
								x = utils.calcCanvasX(node.coords.x)
								y = utils.calcCanvasY(node.coords.y)

								# Update the node w/ the canvas position
								node.position = {x, y}

								# Mark the node as unselected
								node.selected = false

								# Draw the shape
								canvas.game.render.create(
									type: node.type
									color: node.color
									coords: {x, y}
								)
							else
								if not node.selected
									if params? and params.animation == true
										animation.stop(node, 'glow')
										animation.fadeOut( node )
									else
										drawNode = utils.createDrawParams(node, 'faded')
										canvas.game.render.create( drawNode )
								else
									if params? and params.animation == true
										animation.stop(node, 'glow')
										animation.shadow( node )

							return
						)
					)

					# $log.debug( $scope.game.board )
					return

				#	@allDashedLines
				# 		Render the connecting nodes for all nodes as dashed
				#---------------------------------------------------------------
				allDashedLines: () ->
					$.each($scope.selectedNodes, (i, node) =>
						if i > 0
							parentNode = $scope.selectedNodes[i - 1]
							@connectingLine(node, parentNode)
					)

				#	@allSolidLines
				# 		Render the connecting lines for all nodes as solid
				#---------------------------------------------------------------
				allSolidLines: () ->
					$.each($scope.selectedNodes, (i, node) =>
						if i > 0
							parentNode = $scope.selectedNodes[i - 1]
							@connectingLine(node, parentNode, 'solid')
					)

				# 	@connectingLine
				#		Render the lines that connect two nodes
				#---------------------------------------------------------------
				connectingLine: ( node, parentNode, style = 'dashed') ->
					return false if not node.selected

					if angular.isString( parentNode )
						style = parentNode + ''
						parentNode = null

					if not parentNode?
						$.each($scope.selectedNodes, (i, thisNode) ->
							if utils.isSameNode( node, thisNode )
								parentNode = $scope.selectedNodes[i - 1]
								return
						)

					return false if not parentNode?

					clear =
						x: node.position.x - (_.SHAPE_MARGIN / 2)
						y: node.position.y - (_.SHAPE_MARGIN / 2)
						width: _.SHAPE_OUTERSIZE
						height: _.SHAPE_OUTERSIZE

					canvas.lines.render.clear( clear )

					lineThickness = 2

					x1 = node.position.x + (_.SHAPE_SIZE / 2)
					y1 = node.position.y + (_.SHAPE_SIZE / 2) + (lineThickness / 2)
					
					x2 = parentNode.position.x + (_.SHAPE_SIZE / 2)
					y2 = parentNode.position.y + (_.SHAPE_SIZE / 2) + (lineThickness / 2)
					
					if $scope.game.movesLeft < 0
						if style is 'solid'
							canvas.lines.render.solidRedLine(x1, y1, x2, y2)
						else
							canvas.lines.render.dashedRedLine(x1, y1, x2, y2)
					else
						if style is 'solid'
							canvas.lines.render.solidLine(x1, y1, x2, y2)
						else
							canvas.lines.render.dashedLine(x1, y1, x2, y2)


					clearNode = utils.createDrawParams(node, 'invisible', 'small').clear
					clearParentNode = utils.createDrawParams(parentNode, 'invisible', 'small').clear

					canvas.lines.render.clear( clearNode )
					canvas.lines.render.clear( clearParentNode )

					return true
				
				#	@removeConnectingLine
				#		Remove the lines connecting a node
				#---------------------------------------------------------------
				removeConnectingLine: ( node ) ->
					clearX = node.position.x - _.SHAPE_MARGIN
					clearY = node.position.y - _.SHAPE_MARGIN
					clearSize = _.SHAPE_OUTERSIZE + _.SHAPE_MARGIN

					canvas.lines.render.clear(clearX, clearY, clearSize, clearSize)

					return

				#	@clearLinesBoard
				# 		Clear the canvas used to draw the lines
				#---------------------------------------------------------------
				clearLinesBoard: () ->
					clearBoard = 
						x: 0
						y: 0
						width: canvas.lines.el.width
						height: canvas.lines.el.width

					canvas.lines.render.clear( clearBoard )

				#	@clearLinesBoard
				# 		Clear the canvas used to draw the lines
				#---------------------------------------------------------------
				clearGoalBoard: () ->
					clearBoard = 
						x: 0
						y: 0
						width: canvas.goal.el.width
						height: canvas.goal.el.width

					canvas.goal.render.clear( clearBoard )

				#	@clearLinesBoard
				# 		Clear the canvas used to draw the lines
				#---------------------------------------------------------------
				clearGameBoard: () ->
					clearBoard = 
						x: 0
						y: 0
						width: canvas.game.el.width
						height: canvas.game.el.width

					canvas.game.render.clear( clearBoard )

				#	@trackingLine
				# 		Draw the line used to shown when starting to connect to a new node
				#---------------------------------------------------------------
				trackingLine: (startNode, end) ->
					@clearLinesBoard()
						
					@allDashedLines()

					if startNode?
						startPos = 
							x: startNode.position.x + (_.SHAPE_SIZE / 2)
							y: startNode.position.y + (_.SHAPE_SIZE / 2)

						canvas.lines.render.dashedLine(startPos.x, startPos.y, end.x, end.y)
						
						clearNode = utils.createDrawParams(startNode, 'invisible', 'small').clear
						canvas.lines.render.clear( clearNode )

				#	@clearBoardMargins
				# 		Clear the unused margins of the board
				#---------------------------------------------------------------
				clearBoardMargins: () ->
					boardLeft = 
						x: 0
						y: 0
						width: _.SHAPE_MARGIN / 4
						height: _.BOARD_DIMENSIONS.h
					
					boardRight = 
						x: _.BOARD_DIMENSIONS.w - (_.SHAPE_MARGIN / 2)
						y: 0
						width: _.SHAPE_MARGIN
						height: _.BOARD_DIMENSIONS.h

					boardBottom = 
						x: 0
						y: _.BOARD_DIMENSIONS.h - (_.SHAPE_MARGIN / 2)
						width: _.BOARD_DIMENSIONS.w
						height: _.SHAPE_MARGIN


					canvas.game.render.clear( boardLeft )
					canvas.game.render.clear( boardRight )
					canvas.game.render.clear( boardBottom )

				#	@timer
				# 		Render the countdown timer
				#---------------------------------------------------------------
				timer: (color = 'white') ->
					if timeRemaining.total <= 10
						color = 'red'
					
					spacer = 100 - ((timeRemaining.total / totalTime) * 100)

					clearCanvas = 
						x: 0
						y: 0
						width: canvas.timer.el.width
						height: canvas.timer.el.height

					circle =
						x: 5
						y: 5
						width: 32
						height: 32

					# $log.debug( spacer )

					canvas.timer.render.clear(clearCanvas)
					canvas.timer.render.strokedCircle(circle.x, circle.y, circle.width, circle.height, color, spacer)
					canvas.timer.render.text(
						timeRemaining.total + '', 
						{
							x1: circle.x,
							y1: circle.y,
							x2: circle.x + circle.width,
							y2: circle.y + circle.height,
							color: color
						}
					)

					return circle








			#===================================================================
			# 
			# 
			# 
			#	ANIMATION: Controls the canvas animations
			# 	
			# 
			# 
			#-------------------------------------------------------------------
			animation = new class Animation
				constructor: () ->
					return

				#	@stop
				# 		Stop the animation currently running on this node
				#---------------------------------------------------------------
				stop: ( node, type ) ->
					return if not node? or not node.animation?

					if type?
						return if node.animation.type isnt type

						canvas.game.render.stopAnimation( node.animation.id )
						canvas.game.render.clear( node.animation.clear )
						return
					
					canvas.game.render.stopAnimation( node.animation.id )
					canvas.game.render.clear( node.animation.clear )
					
					return

				#	@glow
				# 		Create a "glow" selected animation on the node
				#---------------------------------------------------------------
				glow: ( node ) ->
					# Get the options for the node to be animated
					nodeStyle = utils.getNodeStyle( node )
					drawNode = utils.createDrawParams(node, nodeStyle)
					drawNode.animation = {type: 'glow'}

					# Run the animation w/ the prams
					canvas.game.render.runAnimation(
						drawNode,
						{
							running: (animation, shape) ->
								render.clearBoardMargins()
								node.animation = 
									type: 'glow'
									id: animation
									clear: shape
							
							done: ( shape ) ->
								node.animation = null

								# Add the neighbor nodes to the touched list
								neighborNodes = utils.getNeighborNodes( node )
								addTouchedNodes( neighborNodes )

								# Clear the margins of the board
								render.clearBoardMargins()
								# Redraw the node
								canvas.game.render.create( drawNode )
						}
					)

					return

				#	@fill
				# 		Create a "fill" deselected animation on the node
				#---------------------------------------------------------------
				fill: ( node ) ->
					drawNode = utils.createDrawParams(node, 'untouched')
					drawNode.animation = {type: 'fill'}
					canvas.game.render.runAnimation(
						drawNode,
						{
							running: ( animation, shape ) ->
								node.animation = 
									type: 'fill'
									id: animation
									clear: shape
							
							done: ( shape ) ->
								node.animation = null
								# Clear any leftover states from animation
								canvas.game.render.clear( shape )
								# Draw the node
								canvas.game.render.create( drawNode )
						}
					)
					return

				#	@shadlow
				# 		Create a "shadow" end game animation on the node
				#---------------------------------------------------------------
				shadow: ( node ) ->
					# nodeStyle = utils.getNodeStyle( node )
					drawNode = utils.createDrawParams(node, 'untouched')
					drawNode.animation = {type: 'shadow'}
					drawNode.duration = 200

					canvas.game.render.runAnimation(
						drawNode,
						{
							running: ( animation, shape ) ->
								node.animation = 
									type: 'shadow'
									id: animation
									clear: shape
							done: ( shape ) ->
								$scope.$apply(() ->
									node.animation = null
									render.clearBoardMargins()
									$scope.endGameAnimation += 1
								)
						}
					)

					return

				#	@fadeOut
				# 		Create a "fadeout" end game animation on the node
				#---------------------------------------------------------------
				fadeOut: ( node ) ->
					drawNode = utils.createDrawParams(node, 'untouched')
					drawNode.animation = {type: 'fadeOut'}
					drawNode.duration = 700

					canvas.game.render.runAnimation(
						drawNode,
						{
							running: ( animation, shape ) ->
								node.animation = 
									type: 'fadeOut'
									id: animation
									clear: shape
							done: ( shape ) ->
								$scope.$apply(() ->
									node.animation = null
									render.clearBoardMargins()
									$scope.endGameAnimation += 1
								)
								
						}
					)

					return










			#===================================================================
			# 
			# 
			# 
			#	CANVAS EVENTS: Manages the canvas events
			# 
			# 
			# 
			#-------------------------------------------------------------------
			events = new class Events 
				constructor: () ->
					@onDrag = @eventsProcessor()
					@onTouch = @touchEvents()
					@onMouse = @mouseEvents()

					return 

				#	@bind
				# 		Enable canvas events + callbacks
				#---------------------------------------------------------------
				bind: () =>
					$window.on('resize', @onResize)

					canvas.game.$el
						.on('mousedown', @onMouse.start)
						.on('mousemove', @onMouse.move)
						.on('mouseup', @onMouse.end)

					canvas.game.el.addEventListener('touchstart', @onTouch.start, false)
					canvas.game.el.addEventListener('touchmove', @onTouch.move, false)
					canvas.game.el.addEventListener('touchend', @onTouch.end, false)
					canvas.game.el.addEventListener('touchleave', @onTouch.end, false)
					canvas.game.el.addEventListener('touchcancel', @onTouch.cancel, false)

					return

				#	@unbind
				# 		Enable canvas events + callbacks
				#---------------------------------------------------------------
				unbind: () =>
					# $window.off('resize', @onResize)

					canvas.game.$el
						.off('mousedown', @onMouse.start)
						.off('mousemove', @onMouse.move)
						.off('mouseup', @onMouse.end)

					canvas.game.el.removeEventListener('touchstart', @onTouch.start, false)
					canvas.game.el.removeEventListener('touchmove', @onTouch.move, false)
					canvas.game.el.removeEventListener('touchend', @onTouch.end, false)
					canvas.game.el.removeEventListener('touchleave', @onTouch.end, false)
					canvas.game.el.removeEventListener('touchcancel', @onTouch.cancel, false)

					return

				#	@eventsProcessor
				# 		Process the onTouch/onMouse events
				#---------------------------------------------------------------
				eventsProcessor: () ->
					move: ( e, params ) =>
						_defaults = 
							start: false
							type: 'touch'
						params = angular.extend({}, _defaults, params)
						
						# Get the touch coords object
						if params.type is 'touch'
							touch = e.changedTouches[0]
						else
							touch = e

						# Calculate the position of the touch on the canvas
						canvasOffset = canvas.game.$el.offset()
						nodePosition = 
							x: touch.pageX - canvasOffset.left
							y: touch.pageY - canvasOffset.top
							
						currNode = utils.findNode( nodePosition )

						# If a START event was triggered
						if currNode and params.start
							isDragging = true

							# Make sure the player starts dragging from a valid endNode
							if utils.selectedNodes.total() == 0
								isValidStart = false
								$.each($scope.game.endNodes, (i, endNode) ->
									sameColor = currNode.color == endNode.color
									sameType = currNode.type == endNode.type

									if sameColor and sameType
										isValidStart = true
										return
								)

							# Make sure the player starts dragging from the last selected node
							else
								lastTouchedNode = utils.selectedNodes.last()
								isValidStart = utils.isSameNode( currNode, lastTouchedNode )

								if isValidStart
									$scope.addedNodes.push( lastTouchedNode )
						
						isValidMouse = params.type is 'mouse' and isDragging

						# Check if we should process the mouse/touch event
						if isValidStart && (params.type is 'touch' or isValidMouse)
							e.preventDefault()
							$scope.$apply(() ->
								if params.start
									dragStart = currNode

								isValidMove = utils.checkMove(currNode, nodePosition, {save: true})

								render.trackingLine(dragStart, nodePosition)
							)

					end: () =>
						isDragging = false

						$scope.$apply(() ->
							if utils.selectedNodes.total() == 1
								node = $scope.selectedNodes[0]
								$scope.game.board[node.coords.x][node.coords.y].selected = false
								$scope.removedNodes.push( node )
								$scope.selectedNodes = []

							render.clearLinesBoard()
							render.allDashedLines()
						)

						# $log.debug('=================================')

					cancel: () =>
						$scope.$apply(() ->
							$scope.removedNodes = []
							$scope.removedNodes = [].concat( $scope.selectedNodes )
							$scope.selectedNodes = []
						)

				#	Touch Events
				# 		Send the touch specific event data
				#---------------------------------------------------------------
				touchEvents: () ->
					start: ( e ) =>
						@onDrag.move(e, {start: true, type: 'touch'})
						
					move: ( e ) =>
						@onDrag.move(e, {type: 'touch'})

					end: ( e ) =>
						@onDrag.end()

					cancel: ( e ) =>
						@onDrag.cancel()

				#	Mouse Events
				# 		Send the mouse specific event data
				#---------------------------------------------------------------
				mouseEvents: () ->
					start: ( e ) =>
						@onDrag.move(e, {start: true, type: 'mouse'})
						
					move: ( e ) =>
						@onDrag.move(e, {type: 'mouse'})

					end: ( e ) =>
						@onDrag.end()

				onResize: ( e ) ->
					el.css(
						width: utils.calcGameWidth()
						marginTop: utils.calcGameTopMargin()
					)

					return









			#===================================================================
			# 
			# 
			# 
			#	SCOPE WATCHING:
			# 		Setup and manage the watches on the scope
			# 
			# 
			# 
			#-------------------------------------------------------------------
			class ScopeWatch
				constructor: ( @name, @callback ) ->
					@watch = $scope.$watchCollection(@name, @callback)
					return @watch


			watchers = new class Watchers
				constructor: () ->
					@watching = []

				#	@start
				# 		Start watching the scope vars we want
				#---------------------------------------------------------------
				start: () ->
					# Create an array of the scope attrs we are watching
					@watching = [
						new ScopeWatch('game.won', @gameWon),
						new ScopeWatch('game.lost', @gameLost),
						new ScopeWatch('game.movesLeft', @movesLeft),
						new ScopeWatch('selectedNodes', @selectedNodes),
						new ScopeWatch('touchedNodes', @touchedNodes),
						new ScopeWatch('addedNodes', @addedNodes),
						new ScopeWatch('removedNodes', @removedNodes),
						new ScopeWatch('endGameAnimation', @endGameAnimation)
					]

				#	@stop
				# 		Stop watching the scope vars
				#---------------------------------------------------------------
				stop: () ->
					$.each(@watching, (i, watchFunc) ->
						watchFunc?()
					)
					@watching = []

				#	@gameWon
				# 		Watch the game over status
				#---------------------------------------------------------------
				gameWon: ( hasWon ) =>
					if hasWon == true
						$scope.endGameAnimation = 0

						$scope.game.movesLeft = 0

						timer.stop()
						events.unbind()
						render.clearLinesBoard()
						render.allSolidLines()
						render.goal()

						assetsService.sounds.removedNode.pause()
						assetsService.sounds.addedNode.pause()

						assetsService.sounds.gameOver.currentTime = 0
						assetsService.sounds.gameOver.play()

						render.board({animation: true})
					return

				#	@gameLost
				# 		Watch the game over status
				#---------------------------------------------------------------
				gameLost: ( hasLost ) =>
					if hasLost == true
						events.unbind()
						$scope.animationsDone = true
						@stop()
					return

				#	@movesLeft
				# 		Watch the game over status
				#---------------------------------------------------------------
				movesLeft: ( numMoves ) ->
					if numMoves <= 0 and not $scope.game.won and not $scope.game.lost
						disableNewConnections = true
						render.movesLeft('red')
					return
				
				#	@endGameAnimation
				# 		Watch the game over status
				#---------------------------------------------------------------
				endGameAnimation: (endGameAnimation) =>
					totalNodes = _.BOARD_SIZE * _.BOARD_SIZE
					if endGameAnimation == totalNodes
						render.board({animation: false})
						$scope.animationsDone = true
						@stop()

				#	@selectedNodes
				# 		Watch if we have changed the nodes that are selected
				#---------------------------------------------------------------
				selectedNodes: (nodes) ->
					totalNodes = nodes.length

					$scope.startNode = nodes[0]

					dragStart = nodes[nodes.length - 1]
					
					# Only update the counter when we have two or more selections
					if totalNodes == 0
						$scope.game.movesLeft = $scope.game.maxMoves - 1
					else
						$scope.game.movesLeft = $scope.game.maxMoves - totalNodes
					
					render.movesLeft()

					if $scope.game.movesLeft <= 0
						$scope.game.won = utils.isGameOver()
						disableNewConnections = true
					else
						disableNewConnections = false
					
					# $log.debug('SELECTED', nodes)

				#	@touchedNodes
				# 		If a node has been "touched" by an animation re-render it
				#---------------------------------------------------------------
				touchedNodes: (nodes) ->
					$.each(nodes, (i, node) ->
						nodeStyle = utils.getNodeStyle( node )
						canvas.game.render.create( utils.createDrawParams(node, nodeStyle) )
					)
					$scope.touchedNodes = []

				#	@addedNodes
				# 		If a new nodes has been selected run the "glow"
				# 		enter animation
				#---------------------------------------------------------------
				addedNodes: (nodes) ->
					$scope.game.won = utils.isGameOver()
					
					if not $scope.game.won and nodes.length > 0
						# $log.debug('ADDED', nodes)
						$.each(nodes, (i, node) ->
							assetsService.sounds.addedNode.currentTime = 0
							assetsService.sounds.addedNode.play()
							animation.glow( node )
						)

					$scope.addedNodes = []

				#	removedNodes
				# 		If a node has been deselected run the "leave" animation
				#---------------------------------------------------------------
				removedNodes: (nodes) ->
					if nodes.length > 0
						# $log.debug('REMOVED', nodes)
						$.each(nodes, (i, node) ->
							animation.stop(node, 'glow')
							render.removeConnectingLine( node )

							assetsService.sounds.removedNode.currentTime = 0
							assetsService.sounds.removedNode.play()
							animation.fill(node)
						)

					$scope.removedNodes = []






			
				


			#===================================================================
			#	saveNode
			# 		Save the given node if it is a new move
			# 		Pop the past node if the user is trying to undo a move
			#-------------------------------------------------------------------
			saveNode = ( node ) ->
				return if !node?
								
				# If the current node is the same as the node two moves back
				# then the player is dragging back to "undo" the connection they 
				# made. We need to pop this node off.
				if utils.isGrandPaNode( node )
					grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]
					parentNode = utils.selectedNodes.last()

					$scope.game.board[parentNode.coords.x][parentNode.coords.y].selected = false

					# parentNode.parent = grandparentNode
					$scope.removedNodes.push(parentNode)
					$scope.selectedNodes.pop()
					return

				return if disableNewConnections

				nodeCoords = node.coords
				$scope.game.board[nodeCoords.x][nodeCoords.y].selected = true
				$scope.selectedNodes.push( node )
				$scope.addedNodes.push( node )
				return



			#===================================================================
			#	addTouchedNodes
			# 		Add new nodes to the touched array
			#-------------------------------------------------------------------
			addTouchedNodes = ( nodes ) ->
				newTouchedNodes = []

				if not angular.isArray( nodes )
					thisNode = nodes
					nodes = [].push( thisNode )

				$.each(nodes, (i, node) ->
					isTouched = utils.checkIsTouched( node )
					if not isTouched
						newTouchedNodes.push( node )
				)
				$scope.touchedNodes = $scope.touchedNodes.concat( newTouchedNodes )



			#===================================================================
			#	onTimerChange
			# 		Add new nodes to the touched array
			#-------------------------------------------------------------------
			onTimerChange = ( time ) ->
				timeRemaining = time
				render.timer()

				if timeRemaining.total == 0
					$scope.game.lost = true










			init()
]

app.animation '.game-popup', [
	'$log'
	($log) ->
		return {
			addClass: (element, className, done) ->
				if className is 'ng-hide'
					$(element).slideUp(500, done)
				
				return

			removeClass: (element, className, done) ->
				if className is 'ng-hide'
					$(element).hide().slideDown(500, done)

				return
		}
]
