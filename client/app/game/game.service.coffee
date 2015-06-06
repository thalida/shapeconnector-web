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

		hexColors = {
			white: '#FFFFFF'
			red: '#FF5252'
			blue: '#4B9CFF'
			green: '#8BCA22'
			yellow: '#E5D235'
		}
		
		types = [
			'square'
			'circle'
			'diamond'
			'triangle'
		]

		return {levels, colors, types, hexColors}
]


app.service 'drawService', [
	'$log'
	'gameDict'
	( $log, gameDict ) ->
		return class Draw
			constructor: ( ctx, opts ) ->
				@_defaults = 
					radius: 3
					size: 16

				@opts = angular.extend({}, @_defaults, opts)

				@radius = @opts.radius
				@defaultSize = @opts.size

				@ctx = ctx

				return

			create: ( params ) ->
				_defaults = 
					type: 'square'
					color: 'white'
					coords: {x: 0, y: 0}
					size: {w: @defaultSize, h: @defaultSize}

				params = angular.extend({}, _defaults, params)
				
				params.color = gameDict.hexColors[params.color]

				makeShape = @[params.type]
				makeShape( params.coords.x, params.coords.y, params.size.w, params.size.h)

				@ctx.lineWidth = 1
				@ctx.fillStyle = params.color
				@ctx.fill()

				return

			clear: (x, y, width, height) =>
				@ctx.clearRect(x, y, width, height)

			genericCircle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@ctx.beginPath()

				radius = Math.floor(width / 2)
				centerX = Math.floor( x + ( width / 2 ))
				centerY = Math.floor(y + ( height / 2 ))

				@ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
				
				@ctx.closePath()

				return

			genericLine: (x1, y1, x2, y2) =>
				@ctx.lineCap = 'round'
				@ctx.beginPath()
				@ctx.moveTo(x1, y1)
				@ctx.lineTo(x2, y2)
				@ctx.stroke()

				return

			text: ( str, params ) =>
				fontSize = 16
				@ctx.font = fontSize + 'px sans-serif'
				@ctx.textAlign = 'center'
				@ctx.textBaseline = 'top'
				@ctx.fillStyle = '#FFFFFF'

				# $log.debug( params.color )

				if params.color?
					@ctx.fillStyle = gameDict.hexColors[params.color]

				if params.x? or params.y?
					@ctx.fillText('' + str, param.x, params.y)
				else
					x = (params.x1 + params.x2) / 2
					y = (params.y2 + params.y1) / 2

					# x -= fontSize / 2
					y -= fontSize / 2

					@ctx.fillText('' + str, x, y)

				return

			dashedLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.setLineDash([2, 5])
				@ctx.lineWidth = 2
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			solidLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.setLineDash([0,0])
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			connectingLine: (x1, y1, x2, y2) =>
				@ctx.dashedLine(x1, y1, x2, y2)

				return

			movesCircle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@genericCircle(x, y, width, height)
				
				@ctx.strokeStyle = '#fff'
				@ctx.lineWidth = 2
				@ctx.stroke()

				return


			circle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@genericCircle(x, y, width, height)
				
				@ctx.fill()

				return


			square: (x, y, width, height) =>
				# $log.debug('making square:', x, y, width, height, @radius)
				@ctx.beginPath()

				@ctx.moveTo(x, y + @radius)
				
				@ctx.lineTo(x, y + height - @radius)
				@ctx.quadraticCurveTo(x, y + height, x + @radius, y + height)
				
				@ctx.lineTo(x + width - @radius, y + height)
				@ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - @radius)
				
				@ctx.lineTo(x + width, y + @radius)
				@ctx.quadraticCurveTo(x + width, y, x + width - @radius, y)
				
				@ctx.lineTo(x + @radius, y)
				@ctx.quadraticCurveTo(x, y, x, y + @radius)

				@ctx.closePath()
				
				@ctx.fill()

				return

			diamond: (x, y, width, height) =>
				# $log.debug('making diamond:', x, y, width, height)
				@ctx.beginPath()

				width += 2
				height += 2

				@ctx.moveTo(x + (width / 2), y)
				
				@ctx.lineTo(x, y + (height / 2))
				
				@ctx.lineTo(x + (width / 2), y + height)
				
				@ctx.lineTo(x + width, y + (height / 2))
				
				@ctx.lineTo(x + (width / 2), y)
				
				@ctx.closePath()

				@ctx.fill()

				return

			diamondRounded: (x, y, width, height) =>
				# $log.debug('making diamond:', x, y, width, height)
				@ctx.beginPath()

				width += @radius
				height += @radius
				
				x -= (@radius / 2)
				y -= (@radius / 2)

				@ctx.moveTo(x + (width / 2) - @radius, y + @radius)
				
				@ctx.lineTo(x + @radius, y + (height / 2) - @radius)
				@ctx.quadraticCurveTo(x, y + (height / 2), x + @radius, y + (height / 2) + @radius)
				
				@ctx.lineTo(x + (width / 2) - @radius, y + height - @radius)
				@ctx.quadraticCurveTo(x + (width / 2), y + height, x + (width / 2) + @radius, y + height - @radius)
				
				@ctx.lineTo(x + width - @radius, y + (height / 2) + @radius)
				@ctx.quadraticCurveTo(x + width, y + (height / 2), x + width - @radius, y + (height / 2) - @radius)
				
				@ctx.lineTo(x + (width / 2) + @radius, y + @radius)
				@ctx.quadraticCurveTo(x + (width / 2), y, x + (width / 2) - @radius, y + @radius)
				
				@ctx.closePath()

				@ctx.fill()

				return

			triangle: (x, y, width, height) =>
				# $log.debug('making triangle', x, y, width, height)
				@ctx.beginPath()

				@ctx.moveTo(x + (width / 2) - @radius, y + @radius)
				
				@ctx.lineTo(x, y + height - @radius)
				@ctx.quadraticCurveTo(x, y + height, x + @radius, y + height)
				
				@ctx.lineTo(x + width - @radius, y + height)
				@ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - @radius)
				
				@ctx.lineTo(x + (width / 2) + @radius, y + @radius)
				@ctx.quadraticCurveTo(x + (width / 2), y - @radius, x + (width / 2) - @radius, y + @radius)
				
				@ctx.closePath()

				@ctx.fill()

				return
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

			generateGame: ( opts ) ->
				@opts = angular.extend({}, @defaults, opts)

				@pathSize = @setPathSize()

				@setFirstNode()
				@generatePathNodes(@pathNodes)

				@generateGrid()
				@generatePathCoords()
				@saveEndNodes()
				@fillGrid()

				$log.debug( 'BOARD', @board ) 
				$log.debug( 'PATH', @path )
				$log.debug( 'PATH NODES', @pathNodes )

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
				[first, ..., last] = @path
				
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
