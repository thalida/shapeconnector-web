'use strict'

$requires = [
	'$scope'
	'$log'
	'$state'
	'$localStorage'
	'TUTORIAL_STEPS'
]

class TutorialController
	constructor: ( $scope, $log, $state, $localStorage, TUTORIAL_STEPS ) ->
		step = parseInt($state.params.step, 10)
		@playMode = $state.params.mode

		if not (1 <= step <= 5)
			$state.go('tutorial', {step: 1})

		@showSuccess = step == 5

		if @showSuccess
			$localStorage.hasCompletedTutorial = true

		@mode = 'tutorial'
		@stepNum = step
		@step = angular.copy(TUTORIAL_STEPS[@stepNum])
		@endNodes = []

		@skip = =>
			$localStorage.hasCompletedTutorial = true
			$state.go('play', {mode: @playMode})
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

		return

TutorialController.$inject = $requires
module.exports = TutorialController
