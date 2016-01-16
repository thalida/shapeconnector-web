'use strict'

#===============================================================================
#
#	Game Builder Service
# 		Helper service to generate the core game nodes and goal path
#
#-------------------------------------------------------------------------------
$requires = [
	'$log'
	'LEVELS'
	'SHAPE'
	'BOARD'

	require '../../services/utils'
]

gameBuilderService = ( $log, LEVELS, SHAPE, BOARD, utils) ->
	class GameBuilder
		#	@constructor
		# 		Sets up the options to be used for generating the game
		#-------------------------------------------------------------------
		constructor: ( opts ) ->
			# Level options
			@levels = LEVELS

			# Join shape colors + types to one object
			@shapes =
				colors: SHAPE.COLORS
				types: SHAPE.TYPES

			# Default to an easy 5 x 5 game board
			@defaults =
				difficulty: LEVELS.DEFAULT.name
				dimensions: BOARD.SIZE

			@opts = angular.extend({}, @defaults, opts)

			if @opts.mode is 'tutorial' and @opts.step.random
				@opts.dimensions = @opts.step.boardSize

			@totalColorChain = 0
			@totalShapeChain = 0

			# Get the total # of connections needed to solve the game
			@pathSize = @setPathSize()

			# 2D array of the columns + rows of the game
			@board = []

			# The node path to solve the game
			@path = []

			# The nodes that bookend the path
			@endNodes = []

		#	@generateGame
		# 		Initializes a new game based on the given options
		#-------------------------------------------------------------------
		generateGame: () ->
			# Create an empty board
			@generateGrid()

			if @opts.mode is 'tutorial' and not @opts.step.random
				@generatePredefinedPath()
			else
				# Set the board coordinates for the path
				@generatePath()

				# Fill any empty spaces on the game board
				if @opts.mode is 'tutorial' and @opts.step.makeUnique
					@fillGridAsUnique()
				else
					@fillGrid()

			# Save the start + end nodes for the final path
			@saveEndNodes()

			# $log.debug( 'BOARD', @board )
			# $log.debug( 'PATH', @path )

			return {
				endNodes: @endNodes
				maxMoves: @pathSize
				board: @board
			}

		#	@setPathSize
		# 		Based on the difficulty randomly get the path size
		#-------------------------------------------------------------------
		setPathSize: ->
			if @opts.mode is 'tutorial'
				@pathSize = if @opts.step.random then @opts.step.pathSize else @opts.step.shapes.length - 1
			else
				range = LEVELS[ @opts.difficulty.toUpperCase() ]
				@pathSize = utils.getRandomInt( range.min, range.max )


			return @pathSize

		#	@saveEndNodes
		# 		Get the first and last nodes of the path and save them
		# 		for easy access in the future
		#-------------------------------------------------------------------
		saveEndNodes: ->
			[first, ..., last] = @path

			@endNodes.push( first )
			@endNodes.push( last )

			return @endNodes

		#	@generateGrid
		# 		Setup an empty 2D array for the game board
		#-------------------------------------------------------------------
		generateGrid: ->
			gridSize = if @opts.mode is 'tutorial' and not @opts.step.random then 2 else @opts.dimensions
			@board = new Array( gridSize )

			i = 0
			while i < gridSize
				@board[i] = new Array(gridSize)
				i += 1

			return @board

		generatePredefinedPath: ->
			totalShapes = @opts.step.shapes.length
			i = 0
			while i < totalShapes
				shape = @opts.step.shapes[i]
				node =
					color: shape.color
					type: shape.type
					coords: {x: i, y: 0}

				@path.push( node )
				@board[ node.coords.x ][ node.coords.y ] = node

				i += 1

			return


		#	@generatePath
		# 		Figure out the path for the nodes in the game board
		# 		We need to generate this path to guarantee that a player
		# 		has a way to solve the game
		#-------------------------------------------------------------------
		generatePath: ( parentNode ) ->
			# Return if the path is the correct size
			return @path if @path.length >= @pathSize

			colorOpts = @shapes.colors
			typeOpts = @shapes.types

			# If we don't have a node then this is the start of the path
			# we need to generate the first coords
			if not parentNode?
				# Setup an array of nodes we have already checked
				@visited = []

				x = utils.getRandomInt(0, @opts.dimensions - 1)
				y = utils.getRandomInt(0, @opts.dimensions - 1)
				colorIndex = utils.getRandomInt(0, colorOpts.length - 1)
				typeIndex = utils.getRandomInt(0, colorOpts.length - 1)

				# Create the first node of the path and mark it as visited
				node =
					color: colorOpts[ colorIndex ]
					type: typeOpts[ typeIndex ]
					coords: {x, y}

				@visited.push( node )
				@path.push( node )
				@board[ node.coords.x ][ node.coords.y ] = node

				# Call this function again to start plotting the remaining nodes
				@generatePath( parentNode = node )
				return

			# Get the x and y coords of the parentNode
			[parentNodeX, parentNodeY] = [parentNode.coords.x, parentNode.coords.y]

			# Calculate the potential coords the new (next) node can be plotted on
			potentials = [
				[parentNodeX, parentNodeY - 1],
				[parentNodeX, parentNodeY + 1],
				[parentNodeX - 1, parentNodeY],
				[parentNodeX + 1, parentNodeY],
			]

			# Setup the allowable coords
			allowables = []

			# Loop through the potential coords and check if they're valid
			potentialIdx = 0
			while potentialIdx < potentials.length
				# Get the x and y coors of this potential move
				potNode = potentials[ potentialIdx ]
				[potX, potY] = potNode

				# Check if the x and y coords are valid
				isValidX = 0 <= potX < @opts.dimensions
				isValidY = 0 <= potY < @opts.dimensions

				# Check if we have already visited this node
				isVisited = @checkVisited( potX, potY )

				# If it's a valid x and y and we haven't visited the
				# node yet add it to the allowed moves
				allowables.push( potNode ) if isValidY and isValidX and not isVisited

				potentialIdx += 1

			# If we haven't found any allowed moves
			if allowables.length is 0
				# Remove the last move we made (since it was bad)
				removedNode = @path.pop()

				if removedNode.isKeepColor
					@totalColorChain -= 1
				else
					@totalShapeChain -= 1

				@board[ removedNode.coords.x ][ removedNode.coords.y ] = undefined

				# Go back to the previous node and try again
				@generatePath( @path[@path.length - 1] )
				return

			# Randomly pick an allowed moves
			randomIdx = utils.getRandomInt(0, allowables.length - 1)
			newCoords = allowables[ randomIdx ]

			newNode = angular.copy(parentNode)

			# Add the coords of the allowed move to the node
			newNode.coords =
				x: newCoords[0]
				y: newCoords[1]

			# Decide if to keep the color or the shape type
			isKeepColor = utils.coinFlip()
			hasColorChain = @checkHasColorChain()
			hasShapeChain = @checkHasShapeChain()

			if hasColorChain
				isKeepColor = false
				@totalColorChain = 0
			else if hasShapeChain
				isKeepColor = true
				@totalShapeChain = 0

			@updateChainTally( isKeepColor )

			newNode.isKeepColor = isKeepColor

			missingAttr =
				name: (if isKeepColor then 'type' else 'color')

			# Get the options available for the missing attr
			missingAttr.opts = [].concat(@shapes[missingAttr.name + 's'])

			# Make sure we don't get the same shape attrs
			parentAttrIdx = missingAttr.opts.indexOf(parentNode[missingAttr.name])
			missingAttr.opts.splice(parentAttrIdx, 1)

			# On the last node
			if @path.length + 1 >= @pathSize
				# Make sure we don't get the same shape attrs as the first node
				firstNodeAttrIdx = missingAttr.opts.indexOf(@path[0][missingAttr.name])
				missingAttr.opts.splice(firstNodeAttrIdx, 1)

			# Randomly pick an option from the available list
			missingAttr.index = utils.getRandomInt(0, missingAttr.opts.length - 1)
			newNode[missingAttr.name] = missingAttr.opts[ missingAttr.index ]

			@visited.push( newNode )
			@path.push( newNode )
			@board[ newNode.coords.x ][ newNode.coords.y ] = newNode
			@generatePath( newNode )

			return

		#	@checkVisited
		# 		Check if a node (x, y coodrd) is in the visited list
		#-------------------------------------------------------------------
		checkVisited: ( x, y ) ->
			isVisited = false
			$.each( @visited, (i, node) ->
				if node.coords.x is x and node.coords.y is y
					isVisited = true
					return
			)

			return isVisited

		updateChainTally: ( isKeepColor ) ->
			if isKeepColor
				@totalColorChain += 1
			else
				@totalShapeChain += 1

		checkHasColorChain: ->
			return @totalColorChain > 2

		checkHasShapeChain: ->
			return @totalShapeChain > 2

		#	@fillGrid
		# 		Fill in any empty spots on the grid with a random shape
		#-----------------------------------------------------------------------
		fillGrid: () ->
			$.each(@board, (x, yArr) =>
				$.each(yArr, (y, node) =>
					if not node?
						colorIndex = utils.getRandomInt(0, @shapes.colors.length - 1)
						typeIndex = utils.getRandomInt(0, @shapes.types.length - 1)
						node =
							color: @shapes.colors[ colorIndex ]
							type: @shapes.types[ typeIndex ]
							coords: {x, y}

						@board[x][y] = node
				)
			)

			return @board

		#	@makeUnique
		# 		Loop over the gameboard and make all the nodes unique
		#-----------------------------------------------------------------------
		fillGridAsUnique: () ->
			takenCombos = []
			emptyNodes = []

			generateAttrs = ( takenCombos ) =>
				colorIndex = utils.getRandomInt(0, @shapes.colors.length - 1)
				typeIndex = utils.getRandomInt(0, @shapes.types.length - 1)

				type = @shapes.types[ typeIndex ]
				color = @shapes.colors[ colorIndex ]

				newCombo = type + ':' + color

				if takenCombos.indexOf( newCombo ) == -1
					return [color, type]
				else
					return generateAttrs( takenCombos )

			$.each(@board, (x, yArr) =>
				$.each(yArr, (y, node) =>
					if node?
						combo = node.type + ':' + node.color
						takenCombos.push( combo )
					else
						emptyNodes.push(coords: {x, y})
				)
			)

			$.each(emptyNodes, (i, node) =>
				[color, type] = generateAttrs(takenCombos)
				node.color = color
				node.type = type

				x = node.coords.x
				y = node.coords.y
				@board[x][y] = node

				combo = node.type + ':' + node.color
				takenCombos.push( combo )
			)

			return @board

		#	@findNodeByAttrs
		# 		In a given array find the node that matches the passed attrs
		#-----------------------------------------------------------------------
		findNodeByAttrs: ( nodes, attrs ) ->
			result = found: false, node: null

			$.each(nodes, (node) =>
				if node.color == attrs.color and node.type == attrs.type
					result.found = true
					result.node = node
					return result;
			)

			return result


gameBuilderService.$inject = $requires
module.exports = gameBuilderService
