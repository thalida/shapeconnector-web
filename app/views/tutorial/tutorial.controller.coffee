'use strict'

$requires = [ '$scope', '$log', '$state', 'TUTORIAL_STEPS']

class TutorialController
	constructor: ( $scope, $log, $state, TUTORIAL_STEPS ) ->
		step = parseInt($state.params.step, 10)

		if not (1 <= step <= 5)
			$state.go('tutorial', {step: 1})

		this.showSuccess = step == 5

		this.mode = 'tutorial'
		this.stepNum = step
		this.step = TUTORIAL_STEPS[this.stepNum]
		this.endNodes = []

		replaceNodeText = ( str, find, node ) ->
			return str if !str?
			replace = node.color + ' ' + node.type
			str = str.replace(find, replace)
			return str

		$scope.$watch(
			() =>
				return this.endNodes
			( nodes ) =>
				return if !nodes? || nodes.length == 0

				[startNode, endNode] = nodes
				this.step.header1 = replaceNodeText(this.step.header1, '#{startNode}', startNode)
				this.step.header1 = replaceNodeText(this.step.header1, '#{endNode}', endNode)

				this.step.header2 = replaceNodeText(this.step.header2, '#{startNode}', startNode)
				this.step.header2 = replaceNodeText(this.step.header2, '#{endNode}', endNode)
		)

		return

TutorialController.$inject = $requires
module.exports = TutorialController
