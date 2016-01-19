'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'
	'$localStorage'
	require '../../services/gameSettings'
]

class HomeController
	constructor: ( $log, $scope, $state, $localStorage, gameSettings ) ->
		@showTutorial = $localStorage.hasCompletedTutorial isnt true

		@onSelectGame = ( type ) ->
			if @showTutorial
				$state.go('tutorial', {step: 1})
			else
				$state.go('play', {mode: type})

		return

HomeController.$inject = $requires
module.exports = HomeController
