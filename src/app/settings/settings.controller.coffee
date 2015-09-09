'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('settings',
		url: '/settings'
		templateUrl: 'app/settings/settings.html'
		controller: 'SettingsCtrl'
	)


app.controller 'SettingsCtrl', [
	'$log'
	'$rootScope'
	'$scope'
	'$state'
	'gameSettingsService'
	'LEVELS'
	($log, $rootScope, $scope, $state, gameSettings, LEVELS) ->
		$scope.isProd = $rootScope.isProdSite
		$scope.levels = angular.copy(LEVELS)
		$scope.levels.DEFAULT = null

		$scope.selectedLevel = gameSettings.getDifficulty()

		if $rootScope.isProdSite
			$scope.levels.DEV = null

		$scope.setDifficulity = ( level ) ->
			if $scope.levels[ level ]?
				gameSettings.setDifficulty( level )
				$scope.selectedLevel = level
]

