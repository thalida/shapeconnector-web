'use strict'

#===============================================================================
#
#	Canvas Directive
# 		Creates a canvas with the specified name + dimensions
# 		"Returns" an object w/ the canvas data and a new Canvas Draw Service
#
#-------------------------------------------------------------------------------

app.directive 'appCanvas', [
	'$log',
	'SHAPE'
	'CanvasDrawService'
	($log, SHAPE, CanvasDrawService) ->
		templateUrl: 'app/components/canvas/canvas.html'
		restrict: 'E'
		scope:
			name: '@'
			classes: '@?'
			size: '@?'
			canvas: '=?'
			events: '=?'
		link: ($scope, el, attrs) ->
			# globals
			$scope.canvasName = 'canvas-' + $scope.name
			$canvas = el.find('canvas')
			canvasEl = $canvas[0]
			ctx = null
			canvas = null


			# render: Sets the canvans dimenions, sets up the events, and creates
			# the new Draw classes
			#-------------------------------------------------------------------
			render = ->
				$scope.size = JSON.parse( $scope.size )

				setDimension('width')
				setDimension('height')

				ctx = canvasEl.getContext('2d')
				ctx.scale(2, 2)

				save()
				events.setup()


			# setDimensions: Set the width/height of the canvas
			#-------------------------------------------------------------------
			setDimension = ( type ) ->
				canvasEl[type] = $scope.size[type] * 2
				canvasEl.style[type] = $scope.size[type] + 'px'


			# save: Set the canvas data to a two-way bound variable, such that
			# the parent controller now has a copy
			#-------------------------------------------------------------------
			save = ->
				canvas =
					$el: $canvas
					el: canvasEl
					ctx: ctx
					draw: new CanvasDrawService( ctx )

				$scope.canvas = canvas


			# events: sets up the optional events bindings
			#-------------------------------------------------------------------
			events =
				setup: () ->
					return if !$scope.events?

					if $scope.events.start?
						canvas.el.addEventListener('touchstart', @start, false)
						canvas.$el.on('mousedown', ( e ) => @start(e, true))

					if $scope.events.move?
						canvas.el.addEventListener('touchmove', @move, false)
						canvas.$el.on('mousemove', ( e ) => @move(e, true))

					if $scope.events.end?
						canvas.el.addEventListener('touchend', @end, false)
						canvas.el.addEventListener('touchleave', @end, false)
						canvas.$el.on('mouseup', ( e ) => @end(e, true))

					if $scope.events.cancel?
						canvas.el.addEventListener('touchcancel', @cancel, false)

				process: (evtType, e, isMouse) =>
					trigger = (if isMouse then 'mouse' else 'touch')
					$scope.events[evtType]?(e, {start: evtType == 'start', type: trigger })

				start: ( e, isMouse ) -> @process('start', e, isMouse)
				move: ( e, isMouse ) -> @process('move', e, isMouse)
				end: ( e, isMouse ) -> @process('end', e, isMouse)
				cancel: ( e, isMouse ) -> @process('cancel', e, isMouse)


			# Kick things off!
			render()
]