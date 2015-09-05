'use strict'

app.directive 'appCanvas', [
	'$log',
	'SHAPE'
	'DrawService'
	($log, SHAPE, DrawService) ->
		templateUrl: 'app/components/canvas/canvas.html'
		restrict: 'E'
		scope:
			name: '@'
			classes: '@?'
			size: '@?'
			canvas: '=?'
			events: '=?'
		link: ($scope, el, attrs) ->
			$scope.className = 'canvas-' + $scope.name

			$selector = el.find('canvas')
			canvasEl = $selector[0]

			$scope.size = JSON.parse( $scope.size )

			canvasEl.width = $scope.size.width * 2
			canvasEl.style.width = $scope.size.width + 'px'

			canvasEl.height = $scope.size.height * 2
			canvasEl.style.height = $scope.size.height + 'px'

			ctx = canvasEl.getContext('2d')
			ctx.scale(2, 2)

			canvas =
				$el: $selector
				el: canvasEl
				ctx: ctx

			canvas.draw = new DrawService(canvas.ctx, {size: SHAPE.SIZE})

			events =
				setup: () ->
					return if !$scope.events?

					if $scope.events.start?
						canvas.el.addEventListener('touchstart', @start, false)
						canvas.$el.on('mousedown', ( e ) =>
							@start(e, true)
						)

					if $scope.events.move?
						canvas.el.addEventListener('touchmove', @move, false)
						canvas.$el.on('mousemove', ( e ) =>
							@move(e, true)
						)

					if $scope.events.end?
						canvas.el.addEventListener('touchend', @end, false)
						canvas.el.addEventListener('touchleave', @end, false)
						canvas.$el.on('mouseup', ( e ) =>
							@end(e, true)
						)

					if $scope.events.cancel?
						canvas.el.addEventListener('touchcancel', @cancel, false)

				start: ( e, isMouse ) =>
					type = (if isMouse then 'mouse' else 'touch')
					$scope.events.start(e, {start: true, type })
					return

				move: ( e, isMouse ) =>
					type = (if isMouse then 'mouse' else 'touch')
					$scope.events.move(e, {start: false, type })
					return

				end: ( e, isMouse ) =>
					type = (if isMouse then 'mouse' else 'touch')
					$scope.events.end(e, {start: false, type })
					return

				cancel: ( e, isMouse ) =>
					type = (if isMouse then 'mouse' else 'touch')
					$scope.events.cancel(e, {start: false, type })
					return

			events.setup()
			$scope.canvas = canvas
]
