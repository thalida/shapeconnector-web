'use strict'

$requires = [
	'$scope'
	'$log'
	'$state'
	'$interval'
	'$localStorage'
	'TUTORIAL_STEPS'
]

class TutorialController
	constructor: ( $scope, $log, $state, $interval, $localStorage, TUTORIAL_STEPS ) ->
		step = parseInt($state.params.step, 10)
		totTutorialViews = TUTORIAL_STEPS.total + 1

		if not (1 <= step <= totTutorialViews)
			$state.go('tutorial', {step: 1})

		@showSuccess = step == totTutorialViews
		@mode = 'tutorial'
		@stepNum = step
		@step = angular.copy(TUTORIAL_STEPS[@stepNum])
		@endNodes = []

		if @showSuccess
			@canvasSize =
				width: window.innerWidth
				height: window.innerHeight

			@success = angular.copy(TUTORIAL_STEPS.success)
			$localStorage.hasCompletedTutorial = true

		@skip = =>
			$localStorage.hasCompletedTutorial = true
			$state.go('play', {mode: 'timed'})
			return

		replaceNodeText = ( str, find, node ) ->
			return str if !str?
			replace = node.color + ' ' + node.type
			str = str.replace(find, replace)
			return str

		$scope.$watch(
			() =>
				return @endNodes
			( nodes ) =>
				return if !nodes? || nodes.length == 0

				[startNode, endNode] = nodes

				@step.header1 = replaceNodeText(@step.header1, '#{startNode}', startNode)
				@step.header1 = replaceNodeText(@step.header1, '#{endNode}', endNode)

				@step.header2 = replaceNodeText(@step.header2, '#{startNode}', startNode)
				@step.header2 = replaceNodeText(@step.header2, '#{endNode}', endNode)
		)

		renderConfetti = () =>
			$interval.cancel(@stopAnimation) if @stopAnimation?

			return if !@canvas?

			@stopAnimation = @canvas.draw.confettiAnimation(
				canvas: @canvas.$el
				totalParticles: 'auto'
				radius: 6
				tilt: 3
			)

			return @stopAnimation


		if @showSuccess
			canvasWatch = $scope.$watch('tutorial.canvas', (canvas) ->
				if canvas?.draw?
					canvasWatch()
					@canvas = canvas

					renderConfetti()
					resizeWatch()
					return
			)


		resizeWatch = () =>
			stopResizeWatch = $scope.$watchCollection(
				() ->
					return [window.innerWidth, window.innerHeight]
				( dimension ) =>
					@canvasSize =
						width: dimension[0]
						height: dimension[1]

					renderConfetti()

					return
				true
			)

		return

TutorialController.$inject = $requires
module.exports = TutorialController
