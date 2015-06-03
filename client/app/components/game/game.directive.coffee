'use strict'

app.directive 'appGame', [
	'$log'
	'gameService'
	($log, gameService) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		replace: true
		scope:
			difficulty: '@?'
		link: ($scope, el, attrs) ->
			$scope.difficulty ?= 'easy';

			$scope.game = gameService.generateGame( difficulty: $scope.difficulty )

			$canvas = el.find('canvas')

			ctx = $canvas[0].getContext('2d')

			# variable that decides if something should be drawn on mousemove
			drawing = no

			# the last coordinates before the current move
			centerX = undefined
			centerY = undefined

			$canvas.on('mousedown', (e) ->
				centerX = e.offsetX
				centerY = e.offsetY

				# begins new line
				ctx.beginPath()
				drawing = yes
			)

			$canvas.on('mousemove', (e) ->
				if drawing 
					# get current mouse position
					currentX = e.offsetX
					currentY = e.offsetY
					
					draw(centerX, centerY, currentX, currentY)

				return
			)

			$canvas.on('mouseup', (e) ->
				# stop drawing
				drawing = no
			)
			
			# canvas reset
			reset = () ->
				$canvas[0].width = $canvas[0].width
			
			draw = (startX, startY, currentX, currentY) ->
				reset()
				sizeX = currentX - startX
				sizeY = currentY - startY
				
				ctx.rect(startX, startY, sizeX, sizeY)
				ctx.lineWidth = 3
				# color
				ctx.strokeStyle = '#fff'
				# draw it
				ctx.stroke()
]
