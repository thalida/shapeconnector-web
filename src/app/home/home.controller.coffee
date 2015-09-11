'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('home',
		url: '/'
		templateUrl: 'app/home/home.html'
		controller: 'HomeCtrl'
	)

app.controller 'HomeCtrl', [
	'$log'
	'$scope'
	'$state'
	'gameSettingsService'
	'assetsService'
	($log, $scope, $state, gameSettings, assetsService) ->

		$scope.onSelectGame = ( type ) ->
			gameSettings.setGameType( type )
			$state.go('play')
]

