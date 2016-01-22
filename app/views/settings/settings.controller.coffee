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

class SettingsController
	constructor: ($log, $rootScope, $scope, $state, $localStorage, LEVELS, gameSettings) ->
		@isProd = MODE.production is true
		@levels = angular.copy( LEVELS )
		@levels.DEFAULT = null

		@selectedLevel = gameSettings.getDifficulty()

		if MODE.production is true
			@levels.DEV = null

		@setDifficulity = ( level ) ->
			if @levels[ level ]?
				gameSettings.setDifficulty( level )
				@selectedLevel = level

		@clearLocalStorage = ->
			$localStorage.$reset()
			$state.go('home')
			return


SettingsController.$inject = $requires
module.exports = SettingsController
