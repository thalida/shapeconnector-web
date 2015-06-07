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
#	Draw Service
# 		Helper service to draw the various items on the cavans
# 
#-------------------------------------------------------------------------------
app.service 'drawService', [
	'$log'
	'gameDict'
	( $log, gameDict ) ->
		return class Draw
		
			#	@constructor
			# 		Inits the drawService when new is called
			#-------------------------------------------------------------------
			constructor: ( ctx, opts ) ->
				@_defaults =
					# Radius for the rounded cornders
					radius: 3
					# Size of the shape
					size: 16

				@opts = angular.extend({}, @_defaults, opts)

				# Shortcuts to the options
				@radius = @opts.radius
				@defaultSize = @opts.size

				# Canvas context
				@ctx = ctx

				return

			#	@clear
			# 		Clear only a part of the canvas
			#-------------------------------------------------------------------
			clear: (x, y, width, height) =>
				# If an object has been passed split it into the individual vars
				if angular.isObject( x )
					opts = angular.extend({}, {}, x)
					x = opts.x
					y = opts.y
					width = opts.width
					height = opts.height

				@ctx.clearRect(x, y, width, height)

			#	@create
			# 		Helper service to draw a shape
			# 		Calls the correct draw function based on the params, and
			# 		styles and colors the shape
			#-------------------------------------------------------------------
			create: ( params ) ->
				_defaults = 
					type: 'square'
					color: 'white'
					coords: {x: 0, y: 0}
					size: {w: @defaultSize, h: @defaultSize}
					style: 'untouched'

				params = angular.extend({}, _defaults, params)
				
				# Convert the text color to the hex version
				if params.color.indexOf('#') < 0
					params.color = gameDict.hexColors[params.color]

				# Do we need to clear a space?
				if params.clear?
					@clear( params.clear )

				# Get the shape function based on the type of shape we want
				makeShape = @[params.type]

				# Draw the shape on the canvas
				makeShape?(params.coords.x, params.coords.y, params.size.w, params.size.h)

				# Set the style of the shape
				@setShapeStyle( params )
				
				return

			#	@runAnimation
			# 		Helper service to animate a shape
			# 		Calls the correct animation function based on the params, and
			# 		styles and colors the shape
			#-------------------------------------------------------------------
			runAnimation: ( params, callbacks ) =>
				_defaults = 
					type: 'square'
					color: 'white'
					coords: {x: 0, y: 0}
					size: {w: @defaultSize, h: @defaultSize}
					style: 'untouched'
					duration: 300

				params = angular.extend({}, _defaults, params)
				
				# Convert the text color to the hex version
				params.color = gameDict.hexColors[params.color]
				
				# Calculate/get the start and end times of the animation
				enterStart = new Date().getTime()
				enterEnd = enterStart + params.duration
				leaveEnd = enterStart + (params.duration * 2)

				# Create the animation loop
				enterAnimation = () =>
					# Get our current progres
					timestamp = new Date().getTime()
					progress = Math.min((params.duration - (enterEnd - timestamp)) / params.duration, 1)

					# Set the enter + leave animations
					if params.style is 'start' or params.style is 'touched'
						shape = @glowEnterAnimation( params, progress, callbacks?.during)
					else 
						shape = @fillAnimation( params, progress, callbacks?.during)

					# If the animation hasn't finished, repeat the animation loop
					if (progress < 1)
						callbacks.before?( animation, shape )
						animation = requestAnimationFrame(enterAnimation)
						callbacks.running?( animation, shape )
						callbacks.after?( animation, shape )
					else
						if params.style is 'start' or params.style is 'touched'
							# @clear(shape)
							leaveAnimation()
						else	
							callbacks.done?(shape)

				leaveAnimation = () =>
					# Get our current progres
					timestamp = new Date().getTime()
					progress = Math.min((params.duration - (leaveEnd - timestamp)) / params.duration, 1)

					# Set the enter + leave animations
					if params.style is 'start' or params.style is 'touched'
						shape = @glowLeaveAnimation( params, progress, callbacks?.during )

					# If the animation hasn't finished, repeat the animation loop
					if (progress < 1)
						callbacks.before?( animation, shape )
						animation = requestAnimationFrame(leaveAnimation)
						callbacks.running?( animation, shape )
						callbacks.after?( animation, shape )
					else
						callbacks.done?(shape)


				# Start the animation
				return enterAnimation()

			#	@stopAnimation
			# 		Cancel the passed animation
			#-------------------------------------------------------------------
			stopAnimation: ( animation ) ->
       			window.cancelAnimationFrame(animation)
       			animation = undefined

			#	@setShapeStyle
			# 		Styles the shape based on it's status
			#-------------------------------------------------------------------
			setShapeStyle: ( params ) ->
				@ctx.save()
				@ctx.lineWidth = 2

				rgb = hexToRgb(params.color)

				# Untouched: solid filled shape
				if params.style is 'untouched'
					@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 1)"
					@ctx.strokeStyle = params.color

				# Start: White outline filled shape
				else if params.style is 'start'
					@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.5)"
					@ctx.strokeStyle = 'white'

				# Touched: Colored outlined shape (no fill)
				else if params.style is 'touched'
					@ctx.fillStyle = "rgba(0,0,0,0.0)"
					@ctx.strokeStyle = params.color
				
				@ctx.fill()
				@ctx.stroke()
				@ctx.restore()

			#	@glowEnterAnimation
			# 		Creates a glow around the shape
			#-------------------------------------------------------------------
			glowEnterAnimation: (params, progress, cb) ->
				# $log.debug('in enter animation')
				# Shape width/height grows outward
				shape = 
					width: (params.size.w * progress) * 3.2
					height: (params.size.h * progress) * 3.2

					# width: params.size.w + ((params.size.w * progress) * 2.5)
					# height: params.size.h + ((params.size.h * progress) * 2.5)

				# Keep the glow vertically alinged w/ the main shape
				shiftBy = (shape.width - params.size.w) / 2
				shape.x = params.coords.x - shiftBy
				shape.y = params.coords.y - shiftBy
				
				# Clear the canvas beneath the shape
				@clear(shape)

				# Draw the shape on the canvas
				makeShape = @[params.type]
				makeShape(
					shape.x,
					shape.y,
					shape.width,
					shape.height
				)

				# Get the rgba version of color and make opaque
				rgb = hexToRgb(params.color)

				# Fill the glow
				@ctx.save()
				@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.2)"
				@ctx.fill()
				@ctx.restore()

				# Don't try to clear the canvas again
				params.clear = null


				cb?( shape )

				# Draw the main shape
				@create( params )

				return shape

			#	@glowLeaveAnimation
			# 		Creates a glow around the shape
			#-------------------------------------------------------------------
			glowLeaveAnimation: (params, progress) ->
				# $log.debug('in leave animation')

				# Shape width/height grows outward
				shape = 
					width: (params.size.w * (1 - progress)) * 3.2
					height: (params.size.h * (1 - progress)) * 3.2

				# Keep the glow vertically alinged w/ the main shape
				shiftBy = (shape.width - params.size.w) / 2
				shape.x = params.coords.x - shiftBy
				shape.y = params.coords.y - shiftBy


				fullSizeShape = 
					width: (params.size.w * 1) * 3.4
					height: (params.size.h * 1) * 3.4
				
				fullSizeShift = (fullSizeShape.width - params.size.w) / 2
				fullSizeShape.x = params.coords.x - fullSizeShift
				fullSizeShape.y = params.coords.y - fullSizeShift

				# Clear the canvas beneath the shape
				@clear(fullSizeShape)

				# Draw the shape on the canvas
				makeShape = @[params.type]
				makeShape(
					shape.x,
					shape.y,
					shape.width,
					shape.height
				)

				# Get the rgba version of color and make opaque
				rgb = hexToRgb(params.color)

				# Fill the glow
				@ctx.save()
				@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.2)"
				@ctx.fill()
				@ctx.restore()

				# Don't try to clear the canvas again
				params.clear = null

				# Draw the main shape
				@create( params )

				return fullSizeShape

			#	@fillAnimation
			# 		Fills in the shape from the outside in
			#-------------------------------------------------------------------
			fillAnimation: (params, progress) ->
				shape = 
					width: params.size.w - (params.size.w * progress)
					height: params.size.h - (params.size.h * progress)

				shiftBy = (params.size.w - shape.width) / 2

				shape.x = params.coords.x + shiftBy
				shape.y = params.coords.y + shiftBy
				
				if progress == 0
					@clear( params.clear )

				makeShape = @[params.type]
				makeShape(
					shape.x,
					shape.y,
					shape.width,
					shape.height
				)

				@ctx.save()
				@ctx.strokeStyle = params.color
				@ctx.lineWidth = 1
				@ctx.stroke()
				@ctx.restore()

				return shape

			#	@genericCircle
			# 		Creates a basic circle
			#-------------------------------------------------------------------
			genericCircle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@ctx.beginPath()

				radius = Math.floor(width / 2)
				centerX = Math.floor( x + ( width / 2 ))
				centerY = Math.floor(y + ( height / 2 ))

				@ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
				
				@ctx.closePath()

				return

			#	@genericCircle
			# 		Creates a basic line with rounded caps
			#-------------------------------------------------------------------
			genericLine: (x1, y1, x2, y2) =>
				@ctx.lineCap = 'round'
				@ctx.beginPath()
				@ctx.moveTo(x1, y1)
				@ctx.lineTo(x2, y2)
				@ctx.stroke()

				return

			#	@text
			# 		Writes out a str at a given x or y coord, it can also 
			# 		optionally vertically center text in a square
			# 
			# 		Params: 
			# 			x, y OR x1, y1, x2, y2
			#-------------------------------------------------------------------
			text: ( str, params ) =>
				@ctx.save()

				fontSize = 16
				@ctx.font = fontSize + 'px sans-serif'
				@ctx.textAlign = 'center'
				@ctx.textBaseline = 'top'
				@ctx.fillStyle = '#FFFFFF'

				# If a color has been passed set the fillStyles
				if params.color?
					@ctx.fillStyle = gameDict.hexColors[params.color]

				# If both x and y coords have been passed draw the text
				if params.x? and params.y?
					@ctx.fillText('' + str, param.x, params.y)
				else
					# Vertically center the text in the square provided
					x = (params.x1 + params.x2) / 2
					y = (params.y2 + params.y1) / 2
					y -= fontSize / 2

					@ctx.fillText('' + str, x, y)

				@ctx.restore()

				return

			#	@dashedLine
			# 		Extends @genericLine to create a dashed line
			#-------------------------------------------------------------------
			dashedLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.setLineDash([2, 5])
				@ctx.lineWidth = 2
				@ctx.strokeStyle = 'white'
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			#	@dashedRedLine
			# 		Extends @genericLine to create a dashed line
			#-------------------------------------------------------------------
			dashedRedLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.setLineDash([2, 5])
				@ctx.lineWidth = 2
				@ctx.strokeStyle = gameDict.hexColors['red']
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			#	@solidLine
			# 		Extends @genericLine to create a solid line
			#-------------------------------------------------------------------
			solidLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.setLineDash([0,0])
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			#	@connectingLine
			# 		Extends @dashedLine to create a line between to nodes
			#-------------------------------------------------------------------
			connectingLine: (x1, y1, x2, y2) =>
				@ctx.dashedLine(x1, y1, x2, y2)

				return

			#	@movesCircle
			# 		Extends @genericCircle to create the circle counting down
			# 		the moves left in the game
			#-------------------------------------------------------------------
			movesCircle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@genericCircle(x, y, width, height)
				
				@ctx.strokeStyle = '#fff'
				@ctx.lineWidth = 2
				@ctx.stroke()

				return

			#	@circle
			# 		Extends @genericCircle to create the circle used on the
			# 		game board
			#-------------------------------------------------------------------
			circle: (x, y, width, height) =>
				# $log.debug('making circle:', x, y, width, height)
				@genericCircle(x, y, width, height)

				return

			#	@square
			# 		Creates the rounded corner square used on the game board
			#-------------------------------------------------------------------
			square: (x, y, width, height) =>
				# $log.debug('making square:', x, y, width, height, @radius)
				@ctx.beginPath()

				# Start at the top left of the shape
				@ctx.moveTo(x, y + @radius)
				
				# Draw the left side
				@ctx.lineTo(x, y + height - @radius)

				# Draw the bottom left curve
				@ctx.quadraticCurveTo(x, y + height, x + @radius, y + height)
				
				# Draw the bottom side
				@ctx.lineTo(x + width - @radius, y + height)

				# Draw the bottom right curve
				@ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - @radius)
				
				# Draw the right side
				@ctx.lineTo(x + width, y + @radius)

				# Draw the top right curve
				@ctx.quadraticCurveTo(x + width, y, x + width - @radius, y)
				
				# Draw the top
				@ctx.lineTo(x + @radius, y)

				# Draw the top left curve
				@ctx.quadraticCurveTo(x, y, x, y + @radius)

				@ctx.closePath()

				return

			#	@diamond
			# 		Creates the diamond shape used on the game board
			#-------------------------------------------------------------------
			diamond: (x, y, width, height) =>
				# $log.debug('making diamond:', x, y, width, height)
				@ctx.beginPath()

				# Increase the height + width of the diamond
				# to give it the illusion that it's the same size of other shapes
				width += 2
				height += 2

				# Start at the top center
				@ctx.moveTo(x + (width / 2), y)
				
				# Draw top left side
				@ctx.lineTo(x, y + (height / 2))
				
				# Draw bottom left side
				@ctx.lineTo(x + (width / 2), y + height)
				
				# Draw bottom right side
				@ctx.lineTo(x + width, y + (height / 2))
				
				# Draw top right side
				@ctx.lineTo(x + (width / 2), y)
				
				@ctx.closePath()

				return

			#	@triangle
			# 		Creates the rounded edge triangle shape used on the game board
			#-------------------------------------------------------------------
			triangle: (x, y, width, height) =>
				# $log.debug('making triangle', x, y, width, height)
				@ctx.beginPath()

				# Start at the top center
				@ctx.moveTo(x + (width / 2) - @radius, y + @radius)
				
				# Draw left side
				@ctx.lineTo(x, y + height - @radius)

				# Draw bottom left curve
				@ctx.quadraticCurveTo(x, y + height, x + @radius, y + height)
				
				# Draw bottom side
				@ctx.lineTo(x + width - @radius, y + height)
				
				# Draw bottom right curve
				@ctx.quadraticCurveTo(x + width, y + height, x + width, y + height - @radius)
				
				# Draw right side
				@ctx.lineTo(x + (width / 2) + @radius, y + @radius)
				
				# Draw top curve
				@ctx.quadraticCurveTo(x + (width / 2), y - @radius, x + (width / 2) - @radius, y + @radius)
				
				@ctx.closePath()

				return
]



#===============================================================================
# 
#	Game Service
# 		Helper service to generate the core game pieces
# 
#-------------------------------------------------------------------------------
app.service 'gameService', [
	'$log'
	'gameDict'
	( $log, gameDict) ->
		return new class Game

			#	@constructor
			# 		Sets up the options to be used for generating the game
			#-------------------------------------------------------------------
			constructor: () ->
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

				@opts = {}
				
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
			generateGame: ( opts ) ->
				@opts = angular.extend({}, @defaults, opts)

				# Get the total # of connections needed to solve the game
				@pathSize = @setPathSize()

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

				$log.debug( 'BOARD', @board ) 
				$log.debug( 'PATH', @path )

				return {
					endNodes: @endNodes
					maxMoves: @pathSize - 1
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
