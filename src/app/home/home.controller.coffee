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
	($log, $scope, $state, gameSettings) ->

		$scope.onSelectGame = ( type ) ->
			gameSettings.setGameType( type )
			$state.go('play')

]

