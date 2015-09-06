'use strict'

#===============================================================================
#
#	Game Manager Service
# 		The core game logic - builds the board and controlls the game events
#
#-------------------------------------------------------------------------------

app.service 'GameManagerService', [
	'$rootScope'
	'$log'
	'LEVELS'
	'BOARD'
	'SHAPE'
	'TimerService'
	'GameBuilderService'
	'GameDrawerService'
	'WatcherService'
	'assetsService'
	'gameUtils'
	( $rootScope, $log, LEVELS, BOARD, SHAPE, Timer, GameBuilderService, GameDrawer, Watcher, assetsService, gameUtils ) ->
		return class Manager
			#	@constructor: Sets up all of the variables to be used
			#-------------------------------------------------------------------
			constructor: ( @canvas, @difficulty, board ) ->
				# If no difficulty was passed default to easy
				@difficulty ?= LEVELS.DEFAULT.name

				@selectedNodes = []
				@addedNodes = []
				@removedNodes = []
				@touchedNodes = []
				@startNode = null

				@animationsDone = false
				@disableNewConnections = null

				@dragStart = {}
				@isDragging = false
				@isValidStart = false

				@hasTimer = true
				@timer = null
				@totalTime = 10
				@timeRemaining = 0

				@selectedNodesHelper()

				@setBoard( board )

				$rootScope.game = this

				return this

			#	@selectedNodesHelper: Namespaced quick actions for selectedNodes
			#-------------------------------------------------------------------
			selectedNodesHelper: ->
				@getSelectedNodes =
					first: () =>
						return @selectedNodes[0]
					last: () =>
						return @selectedNodes[@selectedNodes.length - 1]
					total: () =>
						return @selectedNodes.length

			#	@setBoard: Generate a new game OR used passed game AND save
			#-------------------------------------------------------------------
			setBoard: ( game ) ->
				# Generate the game board arrays
				gameBuilder = new GameBuilderService(difficulty: @difficulty)

				if game?
					gameBoard = angular.copy( game )
				else
					gameBoard = gameBuilder.generateGame()

				@board = gameBoard.board
				@endNodes = gameBoard.endNodes
				@maxMoves = gameBoard.maxMoves
				@movesLeft = @maxMoves

			#	@start: Namespaced quick actions for selectedNodes
			#-------------------------------------------------------------------
			start: ( ) ->
				# Setup the game canvases
				@render = new GameDrawer( this, @canvas )

				@won = false
				@lost = false

				# Start the game watchers
				@watch()

				# Finish rendering the board & optionally start the timer after
				# all of the assets have finished downloading
				assetsService.onComplete(() =>
					@render.run()

					if @hasTimer == true
						@timer = new Timer( @totalTime )
						@timer.onTick = @onTimerChange
						@timer.start()
				)

				# Start downloading the assets
				assetsService.downloadAll()

				return this

			#	@watch: Assign watchers to various aspects of the ggame
			#-------------------------------------------------------------------
			watch: () ->
				watcher = new Watcher( $rootScope )
				watcher.start('game.won', @onGameWon)
				watcher.start('game.lost', @onGameLost)
				watcher.start('game.movesLeft', @onMovesLeftChange)
				watcher.start('game.selectedNodes', @onSelectedNodesChange)
				watcher.start('game.touchedNodes', @onTouchedNodesChange)
				watcher.start('game.addedNodes', @onAddedNodesChange)
				watcher.start('game.removedNodes', @onRemovedNodesChange)
				watcher.start('game.endGameAnimation', @onEndGameAnimationChange)

			#	@isGrandPaNode
			# 		Check if the given node is the SAME as the node two moves back
			#-------------------------------------------------------------------
			isGrandPaNode: ( node ) ->
				grandparentNode = @selectedNodes[ @selectedNodes.length - 2 ]
				return gameUtils.isSameNode( node, grandparentNode )

			#	@checkIsTouched
			# 		Check if a node is already in the touched array
			#-------------------------------------------------------------------
			checkIsTouched: ( node ) =>
				touched = false

				$.each(@touchedNodes, (i, thisNode) ->
					if gameUtils.isSameNode( node, thisNode )
						touched = true
						return
				)

				return touched

			#	@validateTouchAxis
			# 		Check if the user has touched in a valid section
			#-------------------------------------------------------------------
			validateTouchAxis: ( params ) ->
				calcCanvasName = 'calcCanvas' + params.type.toUpperCase()
				canvasPos = gameUtils[calcCanvasName]( params.nodeCoord )
				minTouch = gameUtils.calcShapeMinTrigger(canvasPos)
				maxTouch = gameUtils.calcShapeMaxTrigger(canvasPos)

				return minTouch <= params.touchPos <= maxTouch

			#	@checkMove
			# 		Validate that node moved to via touch/mouse is a valid one
			#-------------------------------------------------------------------
			checkMove: ( node, pos, opts ) ->
				# Return if no node has been found
				return false if !node? || node is false

				# If we have NO other selected nodes this move is automatically valid
				if @getSelectedNodes.total() == 0
					@saveNode( node ) if opts?.save
					return true

				# Return false if this node is selected and it is not a grandpa node
				return false if node.selected == true and not @isGrandPaNode( node )

				# Validate that move is in the accepted distance to trigger the closest node
				isValidCanvasX = @validateTouchAxis({type: 'x', nodeCoord: node.coords.x, touchPos: pos.x})
				isValidCanvasY = @validateTouchAxis({type: 'y', nodeCoord: node.coords.y, touchPos: pos.y})
				return false if not isValidCanvasX or not isValidCanvasY

				# Check that the node this move is closest to is one that we're
				# allowed to move to (up, down, left, or right only)
				parentNode = @getSelectedNodes.last()
				dx = Math.abs(parentNode.coords.x - node.coords.x)
				dy = Math.abs(parentNode.coords.y - node.coords.y)
				isValidDirection = (dx + dy) is 1
				return false if not isValidDirection

				# Check that the node we're closest to is either the same color
				# or the same type as the parent node
				sameColor = parentNode.color == node.color
				sameType = parentNode.type == node.type
				isValidMove = isValidDirection and (sameColor or sameType)
				return false if not isValidMove

				# Woot! We've made a valid move
				@saveNode( node )

				return isValidMove

			#	@isGameOver
			# 		Check if the game is completed
			#-------------------------------------------------------------------
			isGameOver: () ->
				return false if @movesLeft > 0

				[firstNode, ..., lastNode] = @selectedNodes
				[endNodeA, ..., endNodeB] = @endNodes

				isFirstEndNodeA = gameUtils.isSameShape(firstNode, endNodeA)
				isLastEndNodeA = gameUtils.isSameShape(lastNode, endNodeA)
				return false if not isFirstEndNodeA and not isLastEndNodeA

				isFirstEndNodeB = gameUtils.isSameShape(firstNode, endNodeB)
				isLastEndNodeB = gameUtils.isSameShape(lastNode, endNodeB)
				return false if not isFirstEndNodeB and not isLastEndNodeB

				return true

			#	saveNode
			# 		Save the given node if it is a new move
			# 		Pop the past node if the user is trying to undo a move
			#-------------------------------------------------------------------
			saveNode: ( node ) ->
				return if not node?

				# If the current node is the same as the node two moves back
				# then the player is dragging back to "undo" the connection they
				# made. We need to pop this node off.
				if @isGrandPaNode( node )
					grandparentNode = @selectedNodes[@selectedNodes.length - 2 ]
					parentNode = @getSelectedNodes.last()

					@board[parentNode.coords.x][parentNode.coords.y].selected = false

					# parentNode.parent = grandparentNode
					@removedNodes.push(parentNode)
					@selectedNodes.pop()
					return

				return if @disableNewConnections

				nodeCoords = node.coords
				@board[nodeCoords.x][nodeCoords.y].selected = true
				@selectedNodes.push( node )
				@addedNodes.push( node )
				return

			#	addTouchedNodes
			#-------------------------------------------------------------------
			addTouchedNodes: ( nodes ) ->
				newTouchedNodes = []

				if not Array.isArray( nodes )
					thisNode = nodes
					nodes = [].push( thisNode )

				$.each(nodes, (i, node) =>
					isTouched = @checkIsTouched( node )
					if not isTouched
						newTouchedNodes.push( node )
				)

				@touchedNodes = @touchedNodes.concat( newTouchedNodes )

			#	onTimerChange: Watcher callback
			#-------------------------------------------------------------------
			onTimerChange: ( time ) =>
				@timeRemaining = time
				@render.timer()

				if @timeRemaining.total is 0
					@lost = true

			#	@gameWon: Watcher callback
			# 		Check to see if the user has won the game
			#-------------------------------------------------------------------
			onGameWon: ( hasWon ) =>
				if hasWon is true
					@endGameAnimation = 0
					@movesLeft = 0

					@timer?.stop?()

					@render.clearLinesBoard()
					@render.allSolidLines( @selectedNodes )
					@render.goal( @endNodes, hasWon )

					assetsService.sounds.removedNode.pause()
					assetsService.sounds.addedNode.pause()

					assetsService.sounds.gameOver.currentTime = 0
					assetsService.sounds.gameOver.play()

					@render.board(hasWon, {animation: true})

			#	@gameLost: Watcher Callback
			# 		Check to see if the user has lost the game
			#-------------------------------------------------------------------
			onGameLost: ( hasLost ) =>
				if hasLost is true
					@animationsDone = true

			#	@movesLeft: Watcher Callback
			# 		Are there any available moves left?
			#-------------------------------------------------------------------
			onMovesLeftChange: ( numMoves ) =>
				if numMoves <= 0 and not @won and not @lost
					@disableNewConnections = true
					@render.movesLeft(@won, 'red')

			#	@endGameAnimation
			#		Wait for the end game animations to finish
			#-------------------------------------------------------------------
			onEndGameAnimationChange: (endGameAnimation) =>
				totalNodes = BOARD.SIZE * BOARD.SIZE
				# Have all the nodes animated
				if endGameAnimation is totalNodes
					@render.board(@won, {animation: false})
					@animationsDone = true

			#	@selectedNodes
			# 		Watch if we have changed the nodes that are selected
			#-------------------------------------------------------------------
			onSelectedNodesChange: (nodes) =>
				nodes ?= []

				totalNodes = nodes.length

				@startNode = nodes[0]

				@dragStart = nodes[nodes.length - 1]

				# Only update the counter when we have two or more selections
				if totalNodes == 0
					@movesLeft = @maxMoves - 1
				else
					@movesLeft = @maxMoves - totalNodes

				@render.movesLeft( @won )

				if @movesLeft <= 0
					@won = @isGameOver()
					@disableNewConnections = true
				else
					@disableNewConnections = false

			#	@touchedNodes
			# 		If a node has been "touched" by an animation re-render it
			#-------------------------------------------------------------------
			onTouchedNodesChange: (nodes) =>
				nodes ?= []

				$.each(nodes, (i, node) =>
					nodeStyle = @render.getNodeStyle( node )
					params = @canvas.game.draw.createDrawParams(node, nodeStyle)
					@canvas.game.draw.create( params )
				)

				@touchedNodes = []

			#	@addedNodes
			# 		If a new nodes has been selected run the "glow"
			# 		enter animation
			#-------------------------------------------------------------------
			onAddedNodesChange: (nodes) =>
				nodes ?= []

				@won = @isGameOver()
				if not @won and nodes.length > 0
					# $log.debug('ADDED', nodes)
					$.each(nodes, (i, node) =>
						assetsService.sounds.addedNode.currentTime = 0
						assetsService.sounds.addedNode.play()
						@render.glowAnimation( node )
					)

				@addedNodes = []

			#	removedNodes
			# 		If a node has been deselected run the "leave" animation
			#-------------------------------------------------------------------
			onRemovedNodesChange: (nodes) =>
				nodes ?= []

				if nodes.length > 0
					# $log.debug('REMOVED', nodes)
					$.each(nodes, (i, node) =>
						@render.stopAnimation(node, 'glow')
						@render.removeConnectingLine( node )

						assetsService.sounds.removedNode.currentTime = 0
						assetsService.sounds.removedNode.play()
						@render.fillAnimation(node)
					)

				@removedNodes = []

			#	onMoveEvent
			# 		Callback if the user has triggered a mouse/touch move events
			#-------------------------------------------------------------------
			onMoveEvent: ( e, params ) =>
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
				canvasOffset = @canvas.game.$el.offset()
				nodePosition =
					x: touch.pageX - canvasOffset.left
					y: touch.pageY - canvasOffset.top

				# Get the node at this position
				currNode = gameUtils.findNode( @board, nodePosition )

				# If a START event was triggered
				if currNode and params.start
					@isDragging = true

					# Make sure the player starts dragging from a valid endNode
					if @getSelectedNodes.total() is 0
						@isValidStart = false
						$.each(@endNodes, (i, endNode) =>
							sameColor = currNode.color is endNode.color
							sameType = currNode.type is endNode.type
							return @isValidStart = true if sameColor and sameType
						)

					# Make sure the player starts dragging from the last selected node
					else
						lastTouchedNode = @getSelectedNodes.last()
						@isValidStart = gameUtils.isSameNode( currNode, lastTouchedNode )
						@addedNodes.push( lastTouchedNode ) if @isValidStart


				isValidMouse = params.type is 'mouse' and @isDragging
				isValidTouch = params.type is 'touch'

				# Check if we should process the mouse/touch event
				if @isValidStart && (isValidTouch or isValidMouse)
					e.preventDefault()
					@dragStart = currNode if params.start

					@checkMove(currNode, nodePosition, {save: true})
					@render.trackingLine(@dragStart, nodePosition)

			#	onEndEvent
			# 		Callback if the user has triggered a mouse/touch end events
			#-------------------------------------------------------------------
			onEndEvent: () =>
				@isDragging = false

				# If the user has tried to leave only one node selected
				# REMOVE it! A node only "counts" when it has a pair
				if @getSelectedNodes.total() is 1
					node = @selectedNodes[0]
					@board[node.coords.x][node.coords.y].selected = false
					@removedNodes.push( node )
					@selectedNodes = []

				@render.clearLinesBoard()
				@render.allDashedLines()

			#	onCancelEvent
			# 		Callback if the user has triggered a touch cancel event
			#-------------------------------------------------------------------
			onCancelEvent: () =>
				@removedNodes = []
				@removedNodes = [].concat( @selectedNodes )
				@selectedNodes = []
]
