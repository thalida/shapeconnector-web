'use strict'

#===============================================================================
# 
#	Game Directive
# 		Renders the game to the canvas and handles the events
# 
#-------------------------------------------------------------------------------
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
			
			#	Game elements
			#-------------------------------------------------------------------
			$window = $(window)
			$canvas = $('#canvas-' + $scope.$id)
			canvas = $canvas[0]

			$canvaslines = $('#canvas-lines-' + $scope.$id)
			canvaslines = $canvaslines[0]

			#	Setup the variables for the draw service and canvas context
			#-------------------------------------------------------------------
			draw = undefined
			ctx = undefined

			drawlines = undefined
			linesctx = undefined

			#	Setup the store of general game information
			#-------------------------------------------------------------------
			$scope.selectedNodes = []
			$scope.addedNodes = []
			$scope.removedNodes = []
			$scope.touchedNodes = []

			$scope.startNode = null
			$scope.gameOver = 
				won: false
				lost: false
			gameStatus = 
				movesLeft: 0

			#	Setup events globals
			#-------------------------------------------------------------------
			dragStart = {}
			isDragging = false
			isValidStart = false
			disableNewConnections = false

			#	Setup the consts dictonary for the game
			#-------------------------------------------------------------------
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

				isSameNode: (nodeA, nodeB) ->
					return false if not nodeA? or not nodeB?

					isSameX = nodeA.coords.x == nodeB.coords.x
					isSameY = nodeA.coords.y == nodeB.coords.y

					return isSameX and isSameY

				isSameShape: (nodeA, nodeB) ->
					return false if not nodeA? or not nodeB?

					isSameColor = nodeA.color == nodeB.color
					isSameType = nodeA.type == nodeB.type

					return isSameColor and isSameType

				createDrawParams: ( node, nodeStyle, clearStyle ) ->
					if clearStyle? and clearStyle == 'small'
						clear =
							x: node.position.x
							y: node.position.y
							width: _.SHAPE_SIZE
							height: _.SHAPE_SIZE
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

				getNodeStyle: ( node ) ->
					$scope.gameOver.won = isGameOver()
					if node.selected == true
						lastNode = utils.selectedNodes.last()
						
						if utils.isSameNode(node, $scope.startNode)
							nodeStyle = 'start'
						else if $scope.gameOver.won and utils.isSameNode(node, lastNode)
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
				getNeighborNodes: ( node ) ->
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
							node = $scope.game.board[potX][potY]
							neighbors.push( node )

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
					$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
					
					# Set the board size const
					_.BOARD_SIZE = gameService.opts.dimensions
					
					# Set the num moves left to the total moves possible
					gameStatus.movesLeft = $scope.game.maxMoves

				#	@canvas
				# 		Sets the canvas width + height based on the
				# 		size of the board
				#---------------------------------------------------------------
				canvas: () ->
					$canvas = el.find('.canvas')
					canvas = $canvas[0]

					$canvaslines = el.find('.canvas-lines')
					canvaslines = $canvaslines[0]

					maxBoardSize = _.BOARD_SIZE * _.SHAPE_OUTERSIZE
					
					# Save the outer width and height dimenions of the baord
					_.BOARD_DIMENSIONS.w = maxBoardSize + _.BOARD_MARGIN.left
					_.BOARD_DIMENSIONS.h = maxBoardSize + _.BOARD_MARGIN.top

					# Set the width + height of the game wrapper
					el.css(
						width: _.BOARD_DIMENSIONS.w
						height: _.BOARD_DIMENSIONS.h
					)

					# Set the width + height of the canvas
					# NOTE: We do a trick below w/ doubling the canvas.width
					# and canvas.height to combat against a "blurring" issue
					# when drawing on the canvas
					canvas.width = _.BOARD_DIMENSIONS.w * 2
					canvas.height = _.BOARD_DIMENSIONS.h * 2
					canvas.style.width = _.BOARD_DIMENSIONS.w + 'px'
					canvas.style.height = _.BOARD_DIMENSIONS.h + 'px'

					canvaslines.width = _.BOARD_DIMENSIONS.w * 2
					canvaslines.height = _.BOARD_DIMENSIONS.h * 2
					canvaslines.style.width = _.BOARD_DIMENSIONS.w + 'px'
					canvaslines.style.height = _.BOARD_DIMENSIONS.h + 'px'

					# Get the canvas context
					ctx = canvas.getContext('2d')
					ctx.scale(2, 2)

					# Get the canvas context
					linesctx = canvaslines.getContext('2d')
					linesctx.scale(2, 2)

					# Setup the drawing service
					draw = new DrawService(ctx, {size: _.SHAPE_SIZE})
					drawlines = new DrawService(linesctx, {size: _.SHAPE_SIZE})










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
					@board()
					@goal()


				#	@movesLeft
				# 		Render the moves left circle + counter
				#---------------------------------------------------------------
				movesLeft: ( color = 'white' ) ->
					numMoves = gameStatus.movesLeft

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
					draw.clear(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h)
					
					# Draw the circle
					draw.movesCircle(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h, color)

					# Default to white text
					color = 'white'

					# Set text to red if we've used up all of our moves
					if parseInt(numMoves, 10) < 0
						color = 'red'

					# Render the # of moves text on the canvas
					# Center the text in the moves circle
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

				#	@goal
				# 		Render the nodes that must start and end the connections
				#---------------------------------------------------------------
				goal: () ->
					draw.clear(0, 0, _.BOARD_DIMENSIONS.w, _.BOARD_MARGIN)

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
						
						if $scope.gameOver.won
							nodeStyle = 'start'
							draw.solidLine(line.x1, line.y1, line.x2, line.y2)
						else
							nodeStyle = 'untouched'
							draw.dashedLine(line.x1, line.y1, line.x2, line.y2)

						draw.create(
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
				board: () ->
					board = $scope.game.board
					$.each( board, ( boardX, col ) ->
						$.each( col, ( boardY, node ) ->
							# Get the canvas x and y coords of the node
							x = utils.calcCanvasX(node.coords.x)
							y = utils.calcCanvasY(node.coords.y)

							# Update the node w/ the canvas position
							node.position = {x, y}

							# Mark the node as unselected
							node.selected = false

							# Draw the shape
							draw.create(
								type: node.type
								color: node.color
								coords: {x, y}
							)

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

					drawlines.clear( clear )


					x1 = node.position.x + (_.SHAPE_SIZE / 2)
					y1 = node.position.y + (_.SHAPE_SIZE / 2)
					
					x2 = parentNode.position.x + (_.SHAPE_SIZE / 2)
					y2 = parentNode.position.y + (_.SHAPE_SIZE / 2)
					
					if gameStatus.movesLeft < 0
						if style is 'solid'
							drawlines.solidRedLine(x1, y1, x2, y2)
						else
							drawlines.dashedRedLine(x1, y1, x2, y2)
					else
						if style is 'solid'
							drawlines.solidLine(x1, y1, x2, y2)
						else
							drawlines.dashedLine(x1, y1, x2, y2)


					clearNode = utils.createDrawParams(node, 'invisible', 'small').clear
					clearParentNode = utils.createDrawParams(parentNode, 'invisible', 'small').clear

					drawlines.clear( clearNode )
					drawlines.clear( clearParentNode )

					return true
				
				#	@removeConnectingLine
				#		Remove the lines connecting a node
				#---------------------------------------------------------------
				removeConnectingLine: ( node ) ->
					clearX = node.position.x - _.SHAPE_MARGIN
					clearY = node.position.y - _.SHAPE_MARGIN
					clearSize = _.SHAPE_OUTERSIZE + _.SHAPE_MARGIN

					drawlines.clear(clearX, clearY, clearSize, clearSize)

					return

				#	@clearLinesBoard
				# 		Clear the canvas used to draw the lines
				#---------------------------------------------------------------
				clearLinesBoard: () ->
					clearBoard = 
						x: 0
						y: 0
						width: _.BOARD_DIMENSIONS.w
						height: _.BOARD_DIMENSIONS.h

					drawlines.clear( clearBoard )

				#	@trackingLine
				# 		Draw the line used to shown when starting to connect to a new node
				#---------------------------------------------------------------
				trackingLine: (startNode, end) ->
					startPos = 
						x: startNode.position.x + (_.SHAPE_SIZE / 2)
						y: startNode.position.y + (_.SHAPE_SIZE / 2)

					@clearLinesBoard()
					
					@allDashedLines()

					drawlines.dashedLine(startPos.x, startPos.y, end.x, end.y)
					
					clearNode = utils.createDrawParams(startNode, 'invisible', 'small').clear
					drawlines.clear( clearNode )

				#	@clearBoardMargins
				# 		Clear the unused margins of the board
				#---------------------------------------------------------------
				clearBoardMargins: () ->
					boardLeft = 
						x: 0
						y: _.BOARD_MARGIN.top
						width: _.SHAPE_MARGIN / 4
						height: _.BOARD_DIMENSIONS.h
					
					boardRight = 
						x: _.BOARD_DIMENSIONS.w - (_.SHAPE_MARGIN / 2)
						y: _.BOARD_MARGIN.top
						width: _.SHAPE_MARGIN
						height: _.BOARD_DIMENSIONS.h

					boardTop = 
						x: 0
						y: _.BOARD_MARGIN.top - _.SHAPE_MARGIN - (_.SHAPE_MARGIN / 2)
						width: _.BOARD_DIMENSIONS.w
						height: _.SHAPE_MARGIN

					boardBottom = 
						x: 0
						y: _.BOARD_DIMENSIONS.h - (_.SHAPE_MARGIN / 2)
						width: _.BOARD_DIMENSIONS.w
						height: _.SHAPE_MARGIN


					draw.clear( boardLeft )
					draw.clear( boardRight )
					draw.clear( boardTop )
					draw.clear( boardBottom )









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

				stop: ( node, type ) ->
					if node.animation?.type is type
						draw.stopAnimation( node.animation.id )
						draw.clear( node.animation.clear )

				glow: ( node ) ->
					# Get the options for the node to be animated
					nodeStyle = utils.getNodeStyle( node )
					drawNode = utils.createDrawParams(node, nodeStyle)

					# Run the animation w/ the prams
					draw.runAnimation(
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
								draw.create( drawNode )
						}
					)

				fill: ( node ) ->
					drawNode = utils.createDrawParams(node, 'untouched')
					draw.runAnimation(
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
								draw.clear( shape )
								# Draw the node
								draw.create( drawNode )
							}
						
					)











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
					$canvas
						.on('mousedown', @onMouse.start)
						.on('mousemove', @onMouse.move)
						.on('mouseup', @onMouse.end)

					canvasEl = $canvas[0]
					canvasEl.addEventListener('touchstart', @onTouch.start, false)
					canvasEl.addEventListener('touchmove', @onTouch.move, false)
					canvasEl.addEventListener('touchend', @onTouch.end, false)
					canvasEl.addEventListener('touchleave', @onTouch.end, false)
					canvasEl.addEventListener('touchcancel', @onTouch.cancel, false)

					return

				#	@unbind
				# 		Enable canvas events + callbacks
				#---------------------------------------------------------------
				unbind: () =>
					$canvas
						.off('mousedown', @onMouse.start)
						.off('mousemove', @onMouse.move)
						.off('mouseup', @onMouse.end)

					canvasEl = $canvas[0]
					canvasEl.removeEventListener('touchstart', @onTouch.start, false)
					canvasEl.removeEventListener('touchmove', @onTouch.move, false)
					canvasEl.removeEventListener('touchend', @onTouch.end, false)
					canvasEl.removeEventListener('touchleave', @onTouch.end, false)
					canvasEl.removeEventListener('touchcancel', @onTouch.cancel, false)

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
						canvasOffset = $canvas.offset()
						nodePosition = 
							x: touch.pageX - canvasOffset.left
							y: touch.pageY - canvasOffset.top
							
						currNode = utils.findNode( nodePosition )

						# If a START event was triggered
						if params.start
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

								isValidMove = checkMove(currNode, nodePosition, {save: true})

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
						new ScopeWatch('gameOver', @gameOver),
						new ScopeWatch('selectedNodes', @selectedNodes),
						new ScopeWatch('touchedNodes', @touchedNodes),
						new ScopeWatch('addedNodes', @addedNodes),
						new ScopeWatch('removedNodes', @removedNodes)
					]

				#	@end
				# 		Stop watching the scope vars
				#---------------------------------------------------------------
				end: () ->
					$.each(@watching, (i, watchFunc) ->
						watchFunc?()
					)
					@watching = []

				#	@gameOver
				# 		Watch the game over status
				#---------------------------------------------------------------
				gameOver: (gameOver) ->
					if gameOver.won
						events.unbind()
						render.clearLinesBoard()
						render.allSolidLines()
						render.goal()
					else
						if gameStatus.movesLeft <= 0
							disableNewConnections = true
							render.movesLeft('red')

				#	@selectedNodes
				# 		Watch if we have changed the nodes that are selected
				#---------------------------------------------------------------
				selectedNodes: (nodes) ->
					totalNodes = nodes.length

					$scope.startNode = nodes[0]

					dragStart = nodes[nodes.length - 1]
					
					# Only update the counter when we have two or more selections
					if totalNodes <= 1
						gameStatus.movesLeft = $scope.game.maxMoves
					else
						gameStatus.movesLeft = $scope.game.maxMoves - totalNodes + 1
					
					render.movesLeft()

					if gameStatus.movesLeft <= 0
						$scope.gameOver.won = isGameOver()
					else
						disableNewConnections = false
					
					# $log.debug('SELECTED', nodes)

				#	@touchedNodes
				# 		If a node has been "touched" by an animation re-render it
				#---------------------------------------------------------------
				touchedNodes: (nodes) ->
					$.each(nodes, (i, node) ->
						nodeStyle = utils.getNodeStyle( node )
						draw.create( utils.createDrawParams(node, nodeStyle) )
					)
					$scope.touchedNodes = []

				#	@addedNodes
				# 		If a new nodes has been selected run the "glow"
				# 		enter animation
				#---------------------------------------------------------------
				addedNodes: (nodes) ->
					# $log.debug('ADDED', nodes)
					
					$.each(nodes, (i, node) ->
						$scope.gameOver.won = isGameOver()
						lastSelectedNode = utils.selectedNodes.last()
						animation.glow( node )
					)

					$scope.addedNodes = []

				#	removedNodes
				# 		If a node has been deselected run the "leave" animation
				#---------------------------------------------------------------
				removedNodes: (nodes) ->
					# $log.debug('REMOVED', nodes)
					
					$.each(nodes, (i, node) ->
						animation.stop(node, 'glow')
						render.removeConnectingLine( node )
						animation.fill(node)
					)

					$scope.removedNodes = []










			#===================================================================
			#	checkMove
			# 		Validate that node moved to via touch/mouse is a valid one
			#-------------------------------------------------------------------
			checkMove = ( node, pos, opts ) ->
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



			#===================================================================
			#	isGameOver
			# 		Check if the game is completed
			#-------------------------------------------------------------------
			isGameOver = () ->
				return false if gameStatus.movesLeft > 0

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









			initGame = (() ->
				setup.run()
				render.run()
				watchers.start()
				events.bind()
			)()
]
