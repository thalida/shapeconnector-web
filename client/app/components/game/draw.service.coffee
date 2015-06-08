
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

				# $log.debug( params )

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

					animationType = params.animation.type 
					animationFunc = null

					if animationType is 'shadow'
						animationFunc = @shadowAnimation

					else if animationType is 'glow'
						animationFunc = @glowEnterAnimation

					else if animationType is 'fill'
						animationFunc = @fillAnimation

					else if animationType is 'fadeOut'
						animationFunc = @fadeOutAnimation

					shape = animationFunc?( params, progress, callbacks?.during)

					# If the animation hasn't finished, repeat the animation loop
					if (progress < 1)
						callbacks.before?( animation, shape )
						
						animation = requestAnimationFrame(enterAnimation)
						
						callbacks.running?( animation, shape )

						callbacks.after?( animation, shape )
					else
						if animationType is 'glow'
							leaveAnimation()
						else	
							callbacks.done?(shape)

				leaveAnimation = () =>
					# Get our current progres
					timestamp = new Date().getTime()
					progress = Math.min((params.duration - (leaveEnd - timestamp)) / params.duration, 1)
					animationType = params.animation.type 

					if animationType is 'glow'
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
					@ctx.shadowColor = "rgba(0,0,0,0.0)"
					@ctx.shadowBlur = 0
					@ctx.shadowOffsetX = 0
					@ctx.shadowOffsetY = 0

				# Start: White outline filled shape
				else if params.style is 'start'
					@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.5)"
					@ctx.strokeStyle = 'white'

				# Touched: Colored outlined shape (no fill)
				else if params.style is 'touched'
					@ctx.fillStyle = "rgba(0,0,0,0.0)"
					@ctx.strokeStyle = params.color

				# Touched: black outline filled shape
				else if params.style is 'disallowed'
					@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.9)"
					@ctx.strokeStyle = 'black'

				# Touched: faded filled shape
				else if params.style is 'faded'
					@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 0.2)"
					@ctx.strokeStyle = "rgba(0,0,0,0.0)"
					@ctx.shadowColor = "rgba(0,0,0,0.0)"
					@ctx.shadowBlur = 0
					@ctx.shadowOffsetX = 0
					@ctx.shadowOffsetY = 0

				@ctx.fill()
				@ctx.stroke()
				@ctx.restore()

			#	@glowEnterAnimation
			# 		Creates a glow around the shape
			#-------------------------------------------------------------------
			glowEnterAnimation: (params, progress, cb) =>
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
			glowLeaveAnimation: (params, progress) =>
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
			fillAnimation: (params, progress) =>
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

			#	@shadowAnimation
			# 		Adds a shadow beneath the shape
			#-------------------------------------------------------------------
			shadowAnimation: (params, progress) =>
				@clear( params.clear )
				
				rgb = hexToRgb(params.color)

				@ctx.save()
				@ctx.lineWidth = 2
				@ctx.shadowBlur = 10
				@ctx.shadowOffsetX = 0
				@ctx.shadowOffsetY = (params.size.h * progress) * 1
				@ctx.strokeStyle = 'white'
				@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, 1)"
				@ctx.shadowColor = 'rgba(0,0,0,0.5)'

				makeShape = @[params.type]
				makeShape(params.coords.x, params.coords.y, params.size.w, params.size.h)
				
				@ctx.fill()
				@ctx.stroke()
				@ctx.restore()

				return {
					x: params.coords.x, 
					y: params.coords.y,
					width: params.size.w, 
					height: params.size.h
				}

				return 


			#	@fadeOutAnimation
			# 		Adds a shadow beneath the shape
			#-------------------------------------------------------------------
			fadeOutAnimation: (params, progress) =>
				@clear( params.clear )

				rgb = hexToRgb(params.color)
				fade = (1 - progress) + 0.2

				makeShape = @[params.type]
				makeShape(params.coords.x, params.coords.y, params.size.w, params.size.h)

				@ctx.save()
				@ctx.fillStyle = "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, #{fade})"
				@ctx.strokeStyle = "rgba(0,0,0,0.0)"
				@ctx.shadowColor = "rgba(0,0,0,0.0)"
				@ctx.shadowBlur = 0
				@ctx.shadowOffsetX = 0
				@ctx.shadowOffsetY = 0
				@ctx.fill()
				@ctx.restore()

				return {
					x: params.coords.x, 
					y: params.coords.y,
					width: params.size.w, 
					height: params.size.h
				}


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
				@ctx.lineWidth = 2
				@ctx.strokeStyle = 'white'
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			#	@solidRedLine
			# 		Extends @genericLine to create a solid line
			#-------------------------------------------------------------------
			solidRedLine: (x1, y1, x2, y2) =>
				@ctx.save()
				@ctx.lineWidth = 2
				@ctx.strokeStyle = gameDict.hexColors['red']
				@genericLine(x1, y1, x2, y2)
				@ctx.restore()

				return

			#	@movesCircle
			# 		Extends @genericCircle to create the circle counting down
			# 		the moves left in the game
			#-------------------------------------------------------------------
			movesCircle: (x, y, width, height, color) =>
				# $log.debug('making circle:', x, y, width, height)
				@genericCircle(x, y, width, height)
				
				@ctx.strokeStyle = gameDict.hexColors[color]
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
