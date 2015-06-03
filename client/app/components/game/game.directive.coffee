'use strict'

app.directive 'appGame', [
	'$log'
	'gameService'
	($log, gameService) ->
		templateUrl: 'app/components/game/game.html'
		restrict: 'E'
		replace: true
		scope:
			difficulty: '@?'
		link: ($scope, el, attrs) ->
			$scope.difficulty ?= 'easy';

			$scope.game = gameService.generateGame( difficulty: $scope.difficulty )
]
