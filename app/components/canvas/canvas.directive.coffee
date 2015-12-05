'use strict'

require './'

#===============================================================================
#
#	ShapeConnector (SC) Canvas Directive
# 		Creates a canvas with the specified name + dimensions
# 		"Returns" an object w/ the canvas data and a new Canvas Draw Service
#
#-------------------------------------------------------------------------------

angular.module('app').directive 'scCanvas', [
	'$log',
	'SHAPE'
	require '../../services/canvasDraw/'
	($log, SHAPE, CanvasDrawService) ->
		templateUrl: 'components/canvas/canvas.html'
		restrict: 'E'
		scope:
			name: '@'
			size: '@'
			classes: '@?'
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
				events.bind()


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
				bind: () ->
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

				unbind: () ->
					canvas.$el
						.off('mousedown')
						.off('mousemove')
						.off('mouseup')

					canvas.el.removeEventListener('touchstart', @start, false)
					canvas.el.removeEventListener('touchmove', @move, false)
					canvas.el.removeEventListener('touchend', @end, false)
					canvas.el.removeEventListener('touchleave', @end, false)
					canvas.el.removeEventListener('touchcancel', @cancel, false)

				process: (evtType, e, isMouse) =>
					trigger = (if isMouse then 'mouse' else 'touch')
					$scope.events[evtType]?(e, {start: evtType == 'start', type: trigger })

				start: ( e, isMouse ) -> events.process('start', e, isMouse)
				move: ( e, isMouse ) -> events.process('move', e, isMouse)
				end: ( e, isMouse ) -> events.process('end', e, isMouse)
				cancel: ( e, isMouse ) -> events.process('cancel', e, isMouse)


			# sizeWatch: Watch for the canvas size to be set before rendering
			#-------------------------------------------------------------------
			stopSizeWatch = $scope.$watch('size', (size) ->
				return if !size?
				stopSizeWatch()

				# Kick things off!
				render()
			)


			# destory: unbind the events on destory
			#-------------------------------------------------------------------
			$scope.$on('$destroy', () ->
				events.unbind()
			)
]
