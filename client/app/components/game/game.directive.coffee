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
			$canvas = el.find('canvas')
			canvas = $canvas[0]

			#	Setup the variables for the draw service and canvas context
			#-------------------------------------------------------------------
			draw = undefined
			ctx = undefined

			#	Setup the store of general game inforamtion
			#-------------------------------------------------------------------
			$scope.selectedNodes = []
			$scope.addedNodes = []
			$scope.removedNodes = []
			$scope.touchedNodes = []

			$scope.enterAnimations = []
			$scope.leaveAnimations = []

			dragStart = {}
			isDragging = false
			isValidStart = false
			gameStatus = 
				movesLeft: 0

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
			#	utils
			# 		General functions and calculations used to figure out where
			# 		various aspects of the canvas or board
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

				createDrawParams: ( node, nodeStyle ) ->
					return {
						type: node.type
						color: node.color
						style: nodeStyle
						coords: {x: node.position.x, y: node.position.y}
						clear: {
							x: node.position.x - (_.SHAPE_MARGIN / 2)
							y: node.position.y - (_.SHAPE_MARGIN / 2)
							width: _.SHAPE_OUTERSIZE
							height: _.SHAPE_OUTERSIZE
						}
					}




			#===================================================================
			#	setup
			# 		General setup of the game and canvas
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

					# Get the canvas context
					ctx = canvas.getContext('2d')
					ctx.scale(2, 2)

					# Setup the drawing service
					draw = new DrawService(ctx, {size: _.SHAPE_SIZE})



			#===================================================================
			#	render
			# 		Render the game elements to the canvas
			#-------------------------------------------------------------------
			render = new class GameRender
				run: () ->
					@board()
					@goal()

				#	@movesLeft
				# 		Render the moves left circle + counter
				#---------------------------------------------------------------
				movesLeft: () ->
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
					draw.movesCircle(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h)

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
					# Render the moves left
					movesCirlce = @movesLeft()				
					
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
						y = ((movesCirlce.y + movesCirlce.h) - (_.SHAPE_SIZE / 2)) / 2

						# Set the line to start and end vertically centered
						# with the circle
						line = 
							y1: y + (_.SHAPE_SIZE / 2)
							y2: movesCirlce.y + ((movesCirlce.h + 2) / 2)

						# Set the start and end positions of the line
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



			#===================================================================
			#	clearBoardMargins
			# 		Clear the unused margins of the board
			#-------------------------------------------------------------------
			clearBoardMargins = () ->
				boardLeft = 
					x: 0
					y: _.BOARD_MARGIN.top
					width: _.SHAPE_MARGIN / 4
					height: _.BOARD_DIMENSIONS.h
				
				boardRight = 
					x: _.BOARD_DIMENSIONS.w - (_.SHAPE_MARGIN / 3)
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
					y: _.BOARD_DIMENSIONS.h - (_.SHAPE_MARGIN / 3)
					width: _.BOARD_DIMENSIONS.w
					height: _.SHAPE_MARGIN


				draw.clear( boardLeft )
				draw.clear( boardRight )
				draw.clear( boardTop )
				draw.clear( boardBottom )


			#===================================================================
			#	findNode
			# 		Based on a canvas x and y position find the node that is
			# 		at this point
			#-------------------------------------------------------------------
			findNode = ( pos ) ->
				# Get the x and y coords of the board at this canvas position
				boardX = utils.calcBoardX(pos.x)
				boardY = utils.calcBoardY(pos.y)

				# Validate that these are allowable board coords
				isValidBoardX = utils.isValidBoardAxis(boardX)
				isValidBoardY = utils.isValidBoardAxis(boardY)
				
				return if not isValidBoardX || not isValidBoardY
					
				return $scope.game.board[boardX][boardY]


			#===================================================================
			#	validateTouchAxis
			# 		Check if the given touch coords are in a valid
			# 		location to trigger the nearest node
			#-------------------------------------------------------------------
			validateTouchAxis = ( params ) ->
				calcCanvasName = 'calcCanvas' + params.type.toUpperCase()
				canvasPos = utils[calcCanvasName]( params.nodeCoord )
				minTouch = utils.calcShapeMinTrigger(canvasPos)
				maxTouch = utils.calcShapeMaxTrigger(canvasPos)

				return minTouch <= params.touchPos <= maxTouch


			#===================================================================
			#	checkMove
			# 		Validate that node moved to via touch/mouse is a valid one
			#-------------------------------------------------------------------
			checkMove = ( node, pos, opts ) ->
				# Get the node nearest to this position
				# node = findNode( pos )

				# Return if no node has been found
				return false if !node? || node is false

				# If we have NO other selected nodes this move is automatically valid
				if $scope.selectedNodes.length == 0 
					saveNode( node ) if opts?.save
					return true

				# Return false if this node is selected and it is not a grandpa node
				return false if node.selected == true and not isGrandPaNode( node )

				# Validate that move is in the accepted distance to trigger the closest node
				isValidCanvasX = validateTouchAxis({type: 'x', nodeCoord: node.coords.x, touchPos: pos.x})
				isValidCanvasY = validateTouchAxis({type: 'y', nodeCoord: node.coords.y, touchPos: pos.y})
				return false if not isValidCanvasX || not isValidCanvasY

				# Check that the node this move is closest to is one that we're
				# allowed to move to (up, down, left, or right only)
				parentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 1 ]
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
			#	isGrandPaNode
			# 		Check if the given node is the SAME as the node two moves back
			#-------------------------------------------------------------------
			isGrandPaNode = ( node ) ->
				grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]
				return utils.isSameNode( node, grandparentNode )



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
				if isGrandPaNode( node )
					grandparentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 2 ]
					parentNode = $scope.selectedNodes[ $scope.selectedNodes.length - 1 ]

					$scope.game.board[parentNode.coords.x][parentNode.coords.y].selected = false
					
					$scope.removedNodes.push(parentNode)
					$scope.selectedNodes.pop()
					return

				nodeCoords = node.coords
				$scope.game.board[nodeCoords.x][nodeCoords.y].selected = true
				$scope.selectedNodes.push( node )
				$scope.addedNodes.push( node )
				return



			#===================================================================
			#	getNeighborNodes
			# 		Get all the nodes surrounding this one
			#-------------------------------------------------------------------
			getNeighborNodes = ( node ) ->
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



			#===================================================================
			#	checkIsTouched
			# 		Check if a node is already in the touched array
			#-------------------------------------------------------------------
			checkIsTouched = ( node ) ->
				touched = false
				$.each($scope.touchedNodes, (i, thisNode) ->
					if utils.isSameNode( node, thisNode )
						touched = true
						return
				)

				return touched



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
					isTouched = checkIsTouched( node )
					if not isTouched
						newTouchedNodes.push( node )
				)

				$scope.touchedNodes = $scope.touchedNodes.concat( newTouchedNodes )



			#===================================================================
			#	onDrag
			# 		Process the touch and mouse events
			#-------------------------------------------------------------------
			onDrag = 
				move: ( e, params ) ->
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
						
					currNode = findNode( nodePosition )

					# If a START event was triggered
					if params.start
						# $log.debug('=================================')
						# $log.debug('STARTED' + params.type.toUpperCase())
						isDragging = true

						# Make sure the player starts dragging from a valid endNode
						if $scope.selectedNodes.length == 0
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
							lastTouchedNode = $scope.selectedNodes[$scope.selectedNodes.length - 1]
							isValidStart = utils.isSameNode( currNode, lastTouchedNode )

					# Check if we should process the mouse/touch event
					if isValidStart && (params.type is 'touch' or (params.type is 'mouse' and isDragging))
						e.preventDefault()
						$scope.$apply(() ->
							checkMove(currNode, nodePosition, {save: true})
						)

				end: () ->
					isDragging = false

					$scope.$apply(() ->
						if $scope.selectedNodes.length == 1
							node = $scope.selectedNodes[0]
							$scope.game.board[node.coords.x][node.coords.y].selected = false
							$scope.removedNodes.push( node )
							$scope.selectedNodes = []
					)

					# $log.debug('=================================')

				cancel: () ->
					$scope.$apply(() ->
						$scope.removedNodes = []
						$scope.removedNodes = [].concat( $scope.selectedNodes )
						$scope.selectedNodes = []
					)



			#===================================================================
			#	onTouch Events
			# 		Send the touch specific event data
			#-------------------------------------------------------------------
			onTouch =
				start: ( e ) ->
					onDrag.move(e, {start: true, type: 'touch'})
					
				move: ( e ) ->
					onDrag.move(e, {type: 'touch'})

				end: ( e ) ->
					onDrag.end()

				cancel: ( e ) ->
					OnDrag.cancel()

			#===================================================================
			#	onMouse Events
			# 		Send the mouse specific event data
			#-------------------------------------------------------------------
			onMouse = 
				start: ( e ) ->
					onDrag.move(e, {start: true, type: 'mouse'})
					
				move: ( e ) ->
					onDrag.move(e, {type: 'mouse'})

				end: ( e ) ->
					onDrag.end()

			#===================================================================
			#	initEvents
			# 		Enable canvas events + callbacks
			#-------------------------------------------------------------------
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



			#===================================================================
			#	startWatch
			# 		Start watching the various scope events
			#-------------------------------------------------------------------
			startWatch = () ->

				#	selectedNodes
				# 		Update the move counter when we selecte a new node
				#---------------------------------------------------------------
				$scope.$watchCollection('selectedNodes', (nodes) ->
					totalNodes = nodes.length
					
					# Only update the counter when we have two or more selections
					if totalNodes <= 1
						gameStatus.movesLeft = $scope.game.maxMoves
					else
						gameStatus.movesLeft = $scope.game.maxMoves - totalNodes + 1
					
					render.movesLeft()
					
					$log.debug('SELECTED', nodes)
				)



				#	touchedNodes
				# 		Redraw nodes that have been "touched" by another nodes
				# 		animation or by the connecting line
				#---------------------------------------------------------------
				$scope.$watchCollection('touchedNodes', (nodes) ->
					# $log.debug('TOUCHED', nodes)

					# Get the first node selected
					startNode = $scope.selectedNodes[0]
					
					$.each(nodes, (i, node) ->
						# Figure out what style the node is
						if node.selected == true
							if utils.isSameNode(node, startNode)
								nodeStyle = 'start'
							else
								nodeStyle = 'touched'
						else
							nodeStyle = 'untouched'

						# Redraw the node
						draw.create( utils.createDrawParams(node, nodeStyle) )
					)

					$scope.touchedNodes = []
				)



				#	addedNodes
				# 		If a new nodes has been selected run the "glow"
				# 		enter animation
				#---------------------------------------------------------------
				$scope.$watchCollection('addedNodes', (nodes) ->
					# $log.debug('ADDED', nodes)
					
					$.each(nodes, (i, node) ->
						# If this is the first node added it has the "start" style
						if $scope.selectedNodes.length == 1
							nodeStyle = 'start'
						else
							nodeStyle = 'touched'

						# Get the options for the node to be animated
						drawNode = utils.createDrawParams(node, nodeStyle)

						# Run the animation w/ the prams
						draw.runAnimation(
							drawNode,

							# On animation start
							( animation, shape ) ->
								clearBoardMargins()

								node.animation = 
									type: 'glow'
									id: animation
									clear: shape

							# On animation finished
							( shape ) ->
								# Get the nodes surrounding this one
								neighborNodes = getNeighborNodes( node )
								# Add the neighbor nodes to the touched list
								addTouchedNodes( neighborNodes )

								# Clear the margins of the board
								clearBoardMargins()

								# Clear the space around this shape
								draw.clear( shape )

								# Redraw the shape
								draw.create( drawNode )
						)
					)

					$scope.addedNodes = []
				)



				#	removedNodes
				# 		If a node has been deselected run the "leave" 
				# 		node animation
				#---------------------------------------------------------------
				$scope.$watchCollection('removedNodes', (nodes) ->
					# $log.debug('REMOVED', nodes)
					
					$.each(nodes, (i, node) ->
						if node.animation?.type == 'glow'
							draw.stopAnimation( node.animation.id )
							draw.clear( node.animation.clear )

						drawNode = utils.createDrawParams(node, 'untouched')

						draw.runAnimation(
							drawNode,
							( animation ) ->
								node.animation = animation
							( shape ) ->
								draw.clear( shape )
								draw.create( drawNode )
						)
					)

					$scope.removedNodes = []
				)


			initGame = (() ->
				setup.run()
				render.run()

				startWatch()
				initEvents()
			)()
]
