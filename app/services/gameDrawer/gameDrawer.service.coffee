'use strict'

#===============================================================================
#
#	Game Drawer Service
# 		Helper service to draw game comentents + run animations
#
#-------------------------------------------------------------------------------

$requires = [
	'$rootScope'
	'$log'
	'BOARD'
	'SHAPE'
	require '../gameUtils'
]

gameDrawerService = ( $rootScope, $log, BOARD, SHAPE, gameUtils ) ->
	class GameDrawer
		#	@constructor: Saves instance of the game + canvases
		#-------------------------------------------------------------------
		constructor: ( @game, @canvas ) -> return

		#	@run: Clear off the canvases + render the game & goal
		#-------------------------------------------------------------------
		run: ->
			# Make sure the canvases are clear
			@clearLinesBoard()
			@clearGoalBoard()
			@clearGameBoard()

			# Render the game board
			@board()

			# Render the game goal
			@goal()

		#	@getNodeStyle
		# 		Get the style of the node based on it's current state
		#-------------------------------------------------------------------
		getNodeStyle: ( node, lastNode ) ->
			if node.selected is true
				lastNode = @game.getSelectedNodes.last()

				if gameUtils.isSameNode(node, @game.startNode)
					nodeStyle = 'start'
				else if @game.won and gameUtils.isSameNode(node, lastNode)
					nodeStyle = 'start'
				else
					nodeStyle = 'touched'
			else
				nodeStyle = 'untouched'

			return nodeStyle

		#	@movesLeft
		# 		Render the moves left circle + counter
		#---------------------------------------------------------------
		movesLeft: ( isGameWon, color = 'white' ) =>
			numMoves = if isGameWon then @game.maxMoves else @game.movesLeft

			# Set text to green if we've won the game
			if isGameWon
				color = 'teal'

			# Set text to red if we've used up all of our moves
			else if parseInt(numMoves, 10) <= 0
				color = 'red'

			# Get the canvas x pos of the middle column of the board
			middleColumn = Math.floor(BOARD.SIZE / 2)
			gameMiddle = gameUtils.calcCanvasX( middleColumn )

			# Setup the position and dimensions of the moves circle
			movesCircle =
				y: SHAPE.BORDER
				w: (SHAPE.SIZE * 2)
			movesCircle.h = movesCircle.w
			movesCircle.x = gameMiddle - (movesCircle.w / 4)

			# Clear the area under the circle
			@canvas.goal.draw.clear(
				movesCircle.x - SHAPE.BORDER,
				movesCircle.y - SHAPE.BORDER,
				movesCircle.w + (SHAPE.BORDER * 2),
				movesCircle.h + (SHAPE.BORDER * 3)
			)

			# Draw the circle
			@canvas.goal.draw.strokedCircle(movesCircle.x, movesCircle.y, movesCircle.w, movesCircle.h, color)

			# Render the # of moves text on the canvas
			# Center the text in the moves circle
			@canvas.goal.draw.text(
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
		goal: (endNodes, isGameWon) ->
			endNodes ?= @game.endNodes
			isGameWon ?= @game.won

			@canvas.goal.draw.clear(0, 0, BOARD.DIMENSIONS.w, BOARD.MARGIN)

			# Render the moves left
			movesCircle = @movesLeft( isGameWon )

			# Get the middle column of the board
			middleColumn = Math.floor(BOARD.SIZE / 2)

			# For each of the game nodes
			# Render them to the board and draw the dashed connecting line
			$.each(endNodes, (i, node) =>
				# Are we rendering to the left or right of the middle column
				direction = if i == 0 then -1 else 1

				# Calculate the x pos of the node
				x = gameUtils.calcCanvasX(middleColumn + direction)
				# Center the node vertically w/ the circle
				y = ((movesCircle.y + movesCircle.h) - (SHAPE.SIZE / 2)) / 2

				# Set the line to start and end vertically centered with the circle
				line =
					y1: y + (SHAPE.SIZE / 2)
					y2: y + (SHAPE.SIZE / 2)
					# y2: movesCircle.y + ((movesCircle.h + 2) / 2)
					x1: x
					x2: movesCircle.x

				if direction is -1
					line.x1 += SHAPE.SIZE
					line.x2 -= SHAPE.BORDER
				else
					line.x2 += movesCircle.w

				if isGameWon
					line.x2 += SHAPE.BORDER if direction is 1
					nodeStyle = 'start'
					@canvas.goal.draw.solidLine(line.x1, line.y1, line.x2, line.y2)
				else
					line.x2 += (SHAPE.BORDER / 2) if direction is 1
					nodeStyle = 'untouched'
					@canvas.goal.draw.dashedLine(line.x1, line.y1, line.x2, line.y2)

				@canvas.goal.draw.create(
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
		board: ( isGameWon, opts ) ->
			board = @game.board
			isGameWon ?= @game.won

			$.each( board, ( boardX, col ) =>
				$.each( col, ( boardY, node ) =>
					if not isGameWon
						# Get the canvas x and y coords of the node
						x = gameUtils.calcCanvasX(node.coords.x)
						y = gameUtils.calcCanvasY(node.coords.y)

						# Update the node w/ the canvas position
						node.position = {x, y}

						# Mark the node as unselected
						node.selected = false

						# Draw the shape
						@canvas.game.draw.create(
							type: node.type
							color: node.color
							coords: {x, y}
						)
					else
						if not node.selected
							if opts?.animation is true
								@stopAnimation( node, 'glow' )
								@fadeOutAnimation( node )
							else
								drawNode = @canvas.game.draw.createDrawParams( node, 'faded' )
								@canvas.game.draw.create( drawNode )
						else
							if opts?.animation is true
								@stopAnimation( node, 'glow' )
								@shadowAnimation( node )

					return
				)
			)

			return

		#	@allDashedLines
		# 		Render the connecting nodes for all nodes as dashed
		#---------------------------------------------------------------
		allDashedLines: ->
			$.each(@game.selectedNodes, (i, node) =>
				if i > 0
					parentNode = @game.selectedNodes[i - 1]
					@connectingLine(node, parentNode)
			)

		#	@allSolidLines
		# 		Render the connecting lines for all nodes as solid
		#---------------------------------------------------------------
		allSolidLines: ->
			$.each(@game.selectedNodes, (i, node) =>
				if i > 0
					parentNode = @game.selectedNodes[i - 1]
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
				$.each(@game.selectedNodes, (i, thisNode) ->
					if gameUtils.isSameNode( node, thisNode )
						parentNode = @game.selectedNodes[i - 1]
						return
				)

			return false if not parentNode?

			clear =
				x: node.position.x - (SHAPE.MARGIN / 2)
				y: node.position.y - (SHAPE.MARGIN / 2)
				width: SHAPE.OUTERSIZE
				height: SHAPE.OUTERSIZE

			@canvas.lines.draw.clear( clear )

			lineThickness = 2

			x1 = node.position.x + (SHAPE.SIZE / 2)
			y1 = node.position.y + (SHAPE.SIZE / 2) + (lineThickness / 2)

			x2 = parentNode.position.x + (SHAPE.SIZE / 2)
			y2 = parentNode.position.y + (SHAPE.SIZE / 2) + (lineThickness / 2)

			if @game.movesLeft < 0
				if style is 'solid'
					@canvas.lines.draw.solidRedLine(x1, y1, x2, y2)
				else
					@canvas.lines.draw.dashedRedLine(x1, y1, x2, y2)
			else
				if style is 'solid'
					@canvas.lines.draw.solidLine(x1, y1, x2, y2)
				else
					@canvas.lines.draw.dashedLine(x1, y1, x2, y2)


			clearNode = @canvas.lines.draw.createDrawParams(node, 'invisible', 'small').clear
			clearParentNode = @canvas.lines.draw.createDrawParams(parentNode, 'invisible', 'small').clear

			@canvas.lines.draw.clear( clearNode )
			@canvas.lines.draw.clear( clearParentNode )

			return true

		#	@removeConnectingLine
		#		Remove the lines connecting a node
		#---------------------------------------------------------------
		removeConnectingLine: ( node ) ->
			clearX = node.position.x - SHAPE.MARGIN
			clearY = node.position.y - SHAPE.MARGIN
			clearSize = SHAPE.OUTERSIZE + SHAPE.MARGIN

			@canvas.lines.draw.clear(clearX, clearY, clearSize, clearSize)

			return

		#	@clearLinesBoard
		# 		Clear the canvas used to draw the lines
		#---------------------------------------------------------------
		clearLinesBoard: ->
			clearBoard =
				x: 0
				y: 0
				width: @canvas.lines.el.width
				height: @canvas.lines.el.width

			@canvas.lines.draw.clear( clearBoard )

		#	@clearLinesBoard
		# 		Clear the canvas used to draw the lines
		#---------------------------------------------------------------
		clearGoalBoard: ->
			clearBoard =
				x: 0
				y: 0
				width: @canvas.goal.el.width
				height: @canvas.goal.el.width

			@canvas.goal.draw.clear( clearBoard )

		#	@clearLinesBoard
		# 		Clear the canvas used to draw the lines
		#---------------------------------------------------------------
		clearGameBoard: ->
			clearBoard =
				x: 0
				y: 0
				width: @canvas.game.el.width
				height: @canvas.game.el.width

			@canvas.game.draw.clear( clearBoard )

		#	@trackingLine
		# 		Draw the line used to shown when starting to connect to a new node
		#---------------------------------------------------------------
		trackingLine: (startNode, end) ->
			@clearLinesBoard()

			@allDashedLines()

			if startNode?
				startPos =
					x: startNode.position.x + (SHAPE.SIZE / 2)
					y: startNode.position.y + (SHAPE.SIZE / 2)

				@canvas.lines.draw.dashedLine(startPos.x, startPos.y, end.x, end.y)

				clearNode = @canvas.lines.draw.createDrawParams(startNode, 'invisible', 'small').clear
				@canvas.lines.draw.clear( clearNode )

		#	@clearBoardMargins
		# 		Clear the unused margins of the board
		#---------------------------------------------------------------
		clearBoardMargins: ->
			boardLeft =
				x: 0
				y: 0
				width: SHAPE.MARGIN / 4
				height: BOARD.DIMENSIONS.h

			boardRight =
				x: BOARD.DIMENSIONS.w - (SHAPE.MARGIN / 2)
				y: 0
				width: SHAPE.MARGIN
				height: BOARD.DIMENSIONS.h

			boardBottom =
				x: 0
				y: BOARD.DIMENSIONS.h - (SHAPE.MARGIN / 2)
				width: BOARD.DIMENSIONS.w
				height: SHAPE.MARGIN


			@canvas.game.draw.clear( boardLeft )
			@canvas.game.draw.clear( boardRight )
			@canvas.game.draw.clear( boardBottom )

		#	@timer
		# 		Render the countdown timer
		#---------------------------------------------------------------
		timer: (color = 'white') ->
			timeRemaining = @game.timeRemaining
			totalTime = @game.totalTime

			if timeRemaining.total <= 10
				color = 'red'

			spacer = 100 - ((timeRemaining.total / totalTime) * 100)

			clearCanvas =
				x: 0
				y: 0
				width: @canvas.timer.el.width
				height: @canvas.timer.el.height

			circle =
				x: 5
				y: 5
				width: 32
				height: 32

			@canvas.timer.draw.clear(clearCanvas)
			@canvas.timer.draw.strokedCircle(circle.x, circle.y, circle.width, circle.height, color, spacer)
			@canvas.timer.draw.text(
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

		#	@stopAnimation
		# 		Stop the animation currently running on this node
		#---------------------------------------------------------------
		stopAnimation: ( node, type ) ->
			return if not node? or not node.animation?

			if type?
				return if node.animation.type isnt type

				@canvas.game.draw.stopAnimation( node.animation.id )
				@canvas.game.draw.clear( node.animation.clear )
				return

			@canvas.game.draw.stopAnimation( node.animation.id )
			@canvas.game.draw.clear( node.animation.clear )

			return

		#	@glowAnimation
		# 		Create a "glow" selected animation on the node
		#---------------------------------------------------------------
		glowAnimation: ( node ) ->
			# Get the options for the node to be animated
			nodeStyle = @getNodeStyle( node )
			drawNode = @canvas.game.draw.createDrawParams(node, nodeStyle)
			drawNode.animation = {type: 'glow'}

			# Run the animation w/ the prams
			@canvas.game.draw.runAnimation(
				drawNode,
				{
					running: (animation, shape) =>
						@clearBoardMargins()
						node.animation =
							type: 'glow'
							id: animation
							clear: shape

					done: ( shape ) =>
						node.animation = null

						# Add the neighbor nodes to the touched list
						neighborNodes = gameUtils.getNeighborNodes( @game.board, node )
						@game.addTouchedNodes( neighborNodes )

						# Clear the margins of the board
						@clearBoardMargins()
						# Redraw the node
						@canvas.game.draw.create( drawNode )
				}
			)

			return

		#	@fill
		# 		Create a "fill" deselected animation on the node
		#---------------------------------------------------------------
		fillAnimation: ( node ) ->
			drawNode = @canvas.game.draw.createDrawParams(node, 'untouched')
			drawNode.animation = {type: 'fill'}

			@canvas.game.draw.runAnimation(
				drawNode,
				{
					running: ( animation, shape ) =>
						node.animation =
							type: 'fill'
							id: animation
							clear: shape

					done: ( shape ) =>
						node.animation = null
						# Clear any leftover states from animation
						@canvas.game.draw.clear( shape )
						# Draw the node
						@canvas.game.draw.create( drawNode )
				}
			)
			return

		#	@shadow
		# 		Create a "shadow" end game animation on the node
		#---------------------------------------------------------------
		shadowAnimation: ( node ) ->
			# nodeStyle = utils.getNodeStyle( node )
			drawNode = @canvas.game.draw.createDrawParams(node, 'untouched')
			drawNode.animation = {type: 'shadow'}
			drawNode.duration = 200

			@canvas.game.draw.runAnimation(
				drawNode,
				{
					running: ( animation, shape ) =>
						node.animation =
							type: 'shadow'
							id: animation
							clear: shape
					done: ( shape ) =>
						$rootScope.$apply(() =>
							node.animation = null
							@clearBoardMargins()
							@game.endGameAnimation += 1
						)
				}
			)

			return

		#	@fadeOut
		# 		Create a "fadeout" end game animation on the node
		#---------------------------------------------------------------
		fadeOutAnimation: ( node ) ->
			drawNode = @canvas.game.draw.createDrawParams(node, 'untouched')
			drawNode.animation = {type: 'fadeOut'}
			drawNode.duration = 700

			@canvas.game.draw.runAnimation(
				drawNode,
				{
					running: ( animation, shape ) =>
						node.animation =
							type: 'fadeOut'
							id: animation
							clear: shape
					done: ( shape ) =>
						$rootScope.$apply(() =>
							node.animation = null
							@clearBoardMargins()
							@game.endGameAnimation += 1
						)
				}
			)

			return


gameDrawerService.$inject = $requires
module.exports = gameDrawerService
