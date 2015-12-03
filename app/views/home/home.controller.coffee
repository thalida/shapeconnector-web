'use strict'

$requires = [
	'$log'
	'$scope'
	'$state'

	require '../../services/gameSettings'
	require '../../services/assets'
]

class HomeController
	constructor: ( $log, $scope, $state, gameSettings, assets ) ->
		@onSelectGame = ( type ) ->
			gameSettings.setGameType( type )
			$state.go('play')

		return

HomeController.$inject = $requires
module.exports = HomeController
