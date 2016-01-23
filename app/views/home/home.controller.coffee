'use strict'

$requires = [
	'$log'
	'$rootScope'
	'$scope'
	'$state'
	'$localStorage'
	'LEVELS'
	require '../../services/gameSettings'
]

class HomeController
	constructor: ( $log, $rootScope, $scope, $state, $localStorage, LEVELS, gameSettings ) ->
		@isProd = MODE.production is true
		@showTutorial = $localStorage.hasCompletedTutorial isnt true

		@levels = angular.copy( LEVELS )
		delete @levels.DEFAULT

		if MODE.production is true
			delete @levels.DEV

		@selectedLevel = gameSettings.getDifficulty().toUpperCase()

		@setDifficulity = ( params ) ->
			level = params.value
			if @levels[ level ]?
				gameSettings.setDifficulty( level )

		@clearLocalStorage = ->
			$localStorage.$reset()
			$state.go('home')
			return

		@onSelectGame = ( type ) ->
			if @showTutorial
				$state.go('tutorial', {step: 1})
			else
				$state.go('play', {mode: type})

		return

HomeController.$inject = $requires
module.exports = HomeController
