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
			gameSettings.setGameType( type )
			$state.go('play')

		return

HomeController.$inject = $requires
module.exports = HomeController
