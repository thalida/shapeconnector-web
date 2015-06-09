'use strict'

#===============================================================================
#
#	Game Dictonary
# 		Returns general global options for the game
#
#-------------------------------------------------------------------------------
app.service 'gameDict', [
	'$log'
	( $log ) ->

		#	Game Levels
		# 		Various difficulty options w/ the range of potential connections
		#-----------------------------------------------------------------------
		levels =
			dev: {
				min: 3,
				max: 3
			}
			easy: {
				min: 5,
				max: 8
			}
			medium: {
				min: 9,
				max: 13
			}
			hard: {
				min: 14,
				max: 18
			}

		#	Colors + Hex Colors
		# 		The options for the node colors in plain text and hex
		#-----------------------------------------------------------------------
		colors =  [
			'red'
			'blue'
			'green'
			'yellow'
		]

		hexColors = {
			white: '#FFFFFF'
			red: '#FF5252'
			blue: '#4B9CFF'
			green: '#8BCA22'
			yellow: '#E5D235'
		}

		#	Types
		# 		The types of shapes to be made in the game
		# 		Each type corresponsds to a draw function
		#-----------------------------------------------------------------------
		types = [
			'square'
			'circle'
			'diamond'
			'triangle'
		]

		return {levels, colors, types, hexColors}
]




#===============================================================================
#
#	Game Builder Service
# 		Helper service to generate the core game pieces
#
#-------------------------------------------------------------------------------
app.service 'gameBuilderService', [
	'$log'
	'gameDict'
	( $log, gameDict) ->
		return class Game

			#	@constructor
			# 		Sets up the options to be used for generating the game
			#-------------------------------------------------------------------
			constructor: ( opts ) ->
				# Level options
				@levels = gameDict.levels

				# Join shape colors + types to one object
				@shapes =
					colors: gameDict.colors
					types: gameDict.types

				# Defautl to an easy 5 x 5 game board
				@defaults =
					difficulty: 'easy'
					dimensions: 5

				@opts = angular.extend({}, @defaults, opts)

				# Get the total # of connections needed to solve the game
				@pathSize = @setPathSize()

				# 2D array of the columns + rows of the game
				@board = []

				# The node path to solve the game
				@path = []

				# The individual nodes that will make up the final path
				@pathNodes = []

				# The nodes that bookend the path
				@endNodes = []

			#	@generateGame
			# 		Initializes a new game based on the given options
			#-------------------------------------------------------------------
			generateGame: () ->
				# Get the nodes that will make up the final path
				@generatePathNodes( @pathNodes )

				# Create an empty board
				@generateGrid()

				# Set the board coordinates for the path
				@generatePathCoords()

				# Save the start + end nodes for the final path
				@saveEndNodes()

				# Fill any empty spaces on the game board
				@fillGrid()

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
			setPathSize: () ->
				range = @levels[ @opts.difficulty ]
				@pathSize = getRandomInt( range.min, range.max )

			#	@setFirstNode
			# 		Randomly pick a color and type to start the game with
			#-------------------------------------------------------------------
			setFirstNode: () ->
				colorOpts = @shapes.colors
				typeOpts = @shapes.types

				colorIndex = getRandomInt(0, colorOpts.length - 1)
				typeIndex = getRandomInt(0, colorOpts.length - 1)

				newShape =
					color: colorOpts[ colorIndex ]
					type: typeOpts[ typeIndex ]

				# Add the new shape to the nodes that will end up making
				# the final path
				return newShape

			#	@saveEndNodes
			# 		Get the first and last nodes of the path and save them
			# 		for easy access in the future
			#-------------------------------------------------------------------
			saveEndNodes: () ->
				[first, ..., last] = @path

				@endNodes.push( first )
				@endNodes.push( last )

				return @endNodes

			#	@generatePathNodes
			# 		Based on the parent shape randomly pick a new shape that
			# 		has either the same color and/or the same shape type
			#-------------------------------------------------------------------
			generatePathNodes: ( pathNodes, parentShape ) ->
				# Generate the start of the nodes
				if not parentShape?
					parentShape = @setFirstNode()
					@pathNodes.push( parentShape )

				# Init the new shape as a duplicate of the parent
				newShape = angular.extend({}, {}, parentShape)

				# Decide if to keep the color or the shape type
				isKeepColor = coinFlip()

				missingAttr = {}

				# Figure out which attr we need to get
				missingAttr.name = if isKeepColor then 'type' else 'color'

				# Get the options available for the missing attr
				missingAttr.opts = []
				missingAttr.opts = [].concat(@shapes[missingAttr.name + 's'])

				# Make sure we don't get the same shape attrs
				parentShapeAttrIdx = missingAttr.opts.indexOf(parentShape[missingAttr.name])
				missingAttr.opts.splice(parentShapeAttrIdx, 1)

				# Randomly pick an option from the available list
				missingAttr.index = getRandomInt(0, missingAttr.opts.length - 1)

				# Update the color or type of the new shape
				newShape[missingAttr.name] = missingAttr.opts[ missingAttr.index ]

				# Add the new shape
				pathNodes.push( newShape )

				# If we haven't reached the end of the path
				# Continue getting more nodes
				if pathNodes.length < @pathSize
					@generatePathNodes(pathNodes, newShape)
				else
					return pathNodes

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

			#	@getFirstPathCoord
			# 		Randomly pick and x and y coord of the board to start the
			# 		goal path at
			#-------------------------------------------------------------------
			getFirstPathCoord: () ->
				x = getRandomInt(0, @opts.dimensions - 1)
				y = getRandomInt(0, @opts.dimensions - 1)

				# Get the first node of the path
				@path[0] = angular.extend({}, {}, @pathNodes[0]);

				# Save the coords to the node
				@path[0].coords = {x, y}

				# Add this node to the board
				@board[x][y] = @path[0]

				return @path[0]

			#	@generatePathCoords
			# 		Figure out the path for the nodes in the game board
			# 		We need to generate this path to guarantee that a player
			# 		has a way to solve the game
			#-------------------------------------------------------------------
			generatePathCoords: ( parentNode ) ->
				# Return if the path is the correct size
				if @path.length >= @pathSize
					return @path

				# If we don't have a node then this is the start of the path
				# we need to generate the first coords
				if not parentNode?
					# Setup an array of nodes we have already checked
					@visited = []

					# Get the first node of the path and mark it as visited
					parentNode = @getFirstPathCoord()
					@visited.push( parentNode )

					# Call this function again to start recursivley plotting
					# the other pathNodes on the coordinate system
					@generatePathCoords( parentNode )
				else
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

						# Go back to he move before that and try again
						@generatePathCoords( @path[@path.length - 1] )
					else
						# Randomly pick an allowed moves
						randomIdx = getRandomInt(0, allowables.length - 1)
						newCoords = allowables[ randomIdx ]

						# Get the next move in the path
						pathNodeIdx = @path.length
						newNode = angular.extend({}, {}, @pathNodes[pathNodeIdx])

						# Add the coords of the allowed move to the node
						newNode.coords = {
							x: newCoords[0]
							y: newCoords[1]
						}

						# Add this node to the visited list (so that we don't)
						# try to move here again
						@visited.push( newNode )

						# Add the node to the game path
						@path.push( newNode )

						# Add the node to the board
						@board[ newNode.coords.x ][ newNode.coords.y ] = newNode

						# Generate the next set of coords based on this node
						@generatePathCoords( newNode )

			#	@checkVisited
			# 		Check if a node (x, y coodrd) is in the visited list
			#-------------------------------------------------------------------
			checkVisited: ( x, y ) ->
				isVisited = false
				$.each( @visited, (i, node) ->
					if node.coords.x == x and node.coords.y == y
						isVisited = true
						return;
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
