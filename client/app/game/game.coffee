'use strict'

app.config ($stateProvider) ->
	$stateProvider.state('game',
		url: '/'
		templateUrl: 'app/game/game.html'
		controller: 'GameCtrl'
	)
