'use strict'

app.service 'gameDict', [
	'$log'
	( $log ) ->
		levels = 
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

		colors =  [
			'red'
			'blue'
			'green'
			'yellow'
		]
		
		types = [
			'square'
			'circle'
			'diamond'
			'triangle'
		]

		return {levels, colors, types}
]

app.service 'gameService', [
	'$log'
	'gameDict'
	( $log, gameDict) ->
		return new class Game
			constructor: () ->
				@levels = gameDict.levels
				@shapes = 
					colors: gameDict.colors
					types: gameDict.types
				@defaults = 
					difficulty: 'easy'
					dimensions: 5
				@opts = {}
				
				@board = []
				@path = []
				@pathNodes = []
				@endNodes = []

				$log.debug( 'BOARD', @board ) 
				$log.debug( 'PATH', @path )
				$log.debug( 'PATH NODES', @pathNodes )

			generateGame: ( opts ) ->
				@opts = angular.extend({}, @defaults, opts)

				@pathSize = @setPathSize()

				@setFirstNode()
				@generatePathNodes(@pathNodes)
				@saveEndNodes()

				@generateGrid()
				@generatePathCoords()
				@fillGrid()

				return {
					endNodes: @endNodes
					maxMoves: @pathSize - 1
					board: @board
				}

			setPathSize: () ->
				range = @levels[ @opts.difficulty ]
				@pathSize = getRandomInt( range.min, range.max )

			setFirstNode: () ->
				colorOpts = @shapes.colors
				typeOpts = @shapes.types

				colorIndex = getRandomInt(0, colorOpts.length - 1)	
				typeIndex = getRandomInt(0, colorOpts.length - 1)	

				newShape = 
					color: colorOpts[ colorIndex ]
					type: typeOpts[ typeIndex ]

				@pathNodes.push( newShape )

			saveEndNodes: () ->
				[first, ..., last] = @pathNodes
				
				@endNodes.push( first ) 
				@endNodes.push( last )

				return @endNodes

			generatePathNodes: ( pathNodes, parentShape ) ->
				parentShape ?= @pathNodes[0]
				newShape = angular.extend({}, {}, parentShape)
				
				isKeepColor = coinFlip()
				
				missingAttr = {}
				missingAttr.name = if isKeepColor then 'type' else 'color'
				missingAttr.opts = @shapes[missingAttr.name + 's']
				missingAttr.index = getRandomInt(0, missingAttr.opts.length - 1)
				
				newShape[missingAttr.name] = missingAttr.opts[ missingAttr.index ]
				
				pathNodes.push( newShape )

				if pathNodes.length < @pathSize
					@generatePathNodes(pathNodes, newShape)
				else
					return pathNodes

			generateGrid: () ->
				@board = new Array( @opts.dimensions )

				i = 0
				while i < @opts.dimensions
					@board[i] = new Array(@opts.dimensions)
					i += 1

				return @board

			getFirstPathCoord: () ->
				x = getRandomInt(0, @opts.dimensions - 1)
				y = getRandomInt(0, @opts.dimensions - 1)

				@path[0] = angular.extend({}, {}, @pathNodes[0]);
				@path[0].coords = {x, y}
				@board[x][y] = @path[0]

				return @path[0]

			generatePathCoords: ( node ) ->
				if @path.length >= @pathSize
					return @path

				if not node?
					@visited = []
					node = @getFirstPathCoord()
					@visited.push( node )
					@generatePathCoords( node )
				else
					nodeX = node.coords.x
					nodeY = node.coords.y
					potentials = [
						[nodeX, nodeY - 1],
						[nodeX, nodeY + 1],
						[nodeX - 1, nodeY],
						[nodeX + 1, nodeY],
					]
					allowables = []

					potentialIdx = 0
					while potentialIdx < potentials.length
						potNode = potentials[ potentialIdx ]
						potX = potNode[0]
						potY = potNode[1]

						isValidX = 0 <= potX < @opts.dimensions
						isValidY = 0 <= potY < @opts.dimensions
						isVisited = @checkVisited( potX, potY )

						if isValidY && isValidX && !isVisited
							allowables.push( potNode )

						potentialIdx += 1

					if allowables.length == 0
						@path.pop()
						@generatePathCoords( @path[@path.length - 1] )
					else
						randomIdx = getRandomInt(0, allowables.length - 1)
						newCoords = allowables[ randomIdx ]
						pathNodeIdx = @path.length
						newNode = angular.extend({}, {}, @pathNodes[pathNodeIdx])
						newNode.coords = {
							x: newCoords[0]
							y: newCoords[1]
						}
						@visited.push( newNode )
						@path.push( newNode )
						@board[ newNode.coords.x ][ newNode.coords.y ] = newNode
						@generatePathCoords( newNode )


			checkVisited: ( x, y ) ->
				isVisited = false
				$.each( @visited, (i, node) ->
					if node.coords.x == x and node.coords.y == y
						isVisited = true
						return;
				)

				return isVisited

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
