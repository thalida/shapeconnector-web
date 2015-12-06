'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'
	require '../../services/gameSettings'
]

class HomeController
	constructor: ( $log, $scope, $state, gameSettings ) ->
		@onSelectGame = ( type ) ->
			$state.go('play', {mode: type})

		return

HomeController.$inject = $requires
module.exports = HomeController
