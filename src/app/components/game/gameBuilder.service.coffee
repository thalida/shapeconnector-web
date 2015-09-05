'use strict'

#===============================================================================
#
#	Game Builder Service
# 		Helper service to generate the core game pieces
#
#-------------------------------------------------------------------------------
app.service 'GameBuilderService', [
	'$log'
	'LEVELS'
	'SHAPES'
	'BOARD'
	( $log, LEVELS, SHAPES, BOARD) ->
		return class Builder

			#	@constructor
			# 		Sets up the options to be used for generating the game
			#-------------------------------------------------------------------
			constructor: ( opts ) ->
				# Level options
				@levels = LEVELS

				# Join shape colors + types to one object
				@shapes =
					colors: SHAPES.COLORS
					types: SHAPES.TYPES

				# Default to an easy 5 x 5 game board
				@defaults =
					difficulty: 'easy'
					dimensions: BOARD.SIZE

				@opts = angular.extend({}, @defaults, opts)

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

				# Set the board coordinates for the path
				@generatePath()

				# Save the start + end nodes for the final path
				@saveEndNodes()

				# Fill any empty spaces on the game board
				@fillGrid()

				$log.debug( 'BOARD', @board )
				$log.debug( 'PATH', @path )

				return {
					endNodes: @endNodes
					maxMoves: @pathSize
					board: @board
				}

			#	@setPathSize
			# 		Based on the difficulty randomly get the path size
			#-------------------------------------------------------------------
			setPathSize: () ->
				range = LEVELS[ @opts.difficulty.toUpperCase() ]
				@pathSize = getRandomInt( range.min, range.max )

			#	@saveEndNodes
			# 		Get the first and last nodes of the path and save them
			# 		for easy access in the future
			#-------------------------------------------------------------------
			saveEndNodes: () ->
				[first, ..., last] = @path

				@endNodes.push( first )
				@endNodes.push( last )

				return @endNodes

			#	@generateGrid
			# 		Setup an empty 2D array for the game board
			#-------------------------------------------------------------------
			generateGrid: () ->
				@board = new Array( @opts.dimensions )

				i = 0
				while i < @opts.dimensions
					@board[i] = new Array(@opts.dimensions)
					i += 1

				return @board

			#	@generatePath
			# 		Figure out the path for the nodes in the game board
			# 		We need to generate this path to guarantee that a player
			# 		has a way to solve the game
			#-------------------------------------------------------------------
			generatePath: ( parentNode ) ->
				# Return if the path is the correct size
				if @path.length >= @pathSize
					return @path

				colorOpts = @shapes.colors
				typeOpts = @shapes.types


				# If we don't have a node then this is the start of the path
				# we need to generate the first coords
				if not parentNode?
					# Setup an array of nodes we have already checked
					@visited = []

					x = getRandomInt(0, @opts.dimensions - 1)
					y = getRandomInt(0, @opts.dimensions - 1)
					colorIndex = getRandomInt(0, colorOpts.length - 1)
					typeIndex = getRandomInt(0, colorOpts.length - 1)

					# Create the first node of the path and mark it as visited
					parentNode =
						color: colorOpts[ colorIndex ]
						type: typeOpts[ typeIndex ]
						coords: {x, y}

					@visited.push( parentNode )
					@path.push( parentNode )
					@board[ parentNode.coords.x ][ parentNode.coords.y ] = parentNode

					# Call this function again to start plotting the remaining nodes
					@generatePath( parentNode )
					return


				# Get the x and y coords of the parentNode
				parentNodeX = parentNode.coords.x
				parentNodeY = parentNode.coords.y

				# Calculate the potential coords the new (next) node
				# can be plotted on
				potentials = [
					[parentNodeX, parentNodeY - 1],
					[parentNodeX, parentNodeY + 1],
					[parentNodeX - 1, parentNodeY],
					[parentNodeX + 1, parentNodeY],
				]

				# Setup an empty list of the allowable coords
				allowables = []

				# Loop through the potential coords and check if they
				# would count as a valid move
				potentialIdx = 0
				while potentialIdx < potentials.length
					# Get the x and y coors of this potential move
					potNode = potentials[ potentialIdx ]
					potX = potNode[0]
					potY = potNode[1]

					# Check if the x and y coords are valid
					isValidX = 0 <= potX < @opts.dimensions
					isValidY = 0 <= potY < @opts.dimensions

					# Check if we have already visited this node
					isVisited = @checkVisited( potX, potY )

					# If it's a valid x and y and we haven't visited the
					# node yet add it to the allowed moves
					if isValidY && isValidX && !isVisited
						allowables.push( potNode )

					potentialIdx += 1

				# If we haven't found any allowed moves
				if allowables.length == 0
					# Remove the last move we made (since it was bad)
					@path.pop()

					# Go back to the move before that and try again
					@generatePath( @path[@path.length - 1] )
					return


				# Randomly pick an allowed moves
				randomIdx = getRandomInt(0, allowables.length - 1)
				newCoords = allowables[ randomIdx ]

				newNode = angular.extend({}, {}, parentNode)

				# Add the coords of the allowed move to the node
				newNode.coords = {
					x: newCoords[0]
					y: newCoords[1]
				}

				# Decide if to keep the color or the shape type
				isKeepColor = coinFlip()
				missingAttr =
					name: (if isKeepColor then 'type' else 'color')

				# Get the options available for the missing attr
				missingAttr.opts = [].concat(@shapes[missingAttr.name + 's'])

				# Make sure we don't get the same shape attrs
				parentAttrIdx = missingAttr.opts.indexOf(parentNode[missingAttr.name])
				missingAttr.opts.splice(parentAttrIdx, 1)

				# Randomly pick an option from the available list
				missingAttr.index = getRandomInt(0, missingAttr.opts.length - 1)
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
					if node.coords.x == x and node.coords.y == y
						isVisited = true
						return
				)

				return isVisited

			#	@fillGrid
			# 		Fill in any empty spots on the grid with a random shape
			#-------------------------------------------------------------------
			fillGrid: () ->
				$.each(@board, (x, yArr) =>
					$.each(yArr, (y, node) =>
						if not node?
							colorIndex = getRandomInt(0, @shapes.colors.length - 1)
							typeIndex = getRandomInt(0, @shapes.types.length - 1)
							node =
								color: @shapes.colors[ colorIndex ]
								type: @shapes.types[ typeIndex ]
								coords: {x, y}
							@board[x][y] = node
					)
				)

				return @board
]
