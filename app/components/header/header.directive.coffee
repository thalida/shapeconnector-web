'use strict'

angular.module('app').directive 'appHeader', [
	'$log'
	'$state'
	($log, $state) ->
		templateUrl: 'components/header/header.html'
		restrict: 'E'
		scope:
			onClick: '&?'
		link: ($scope, el, attrs) ->
			$scope.onLogoClick = ( e ) ->
				if $scope.onClick?
					$scope.onClick({params: e})
				else
					$state.go('home')
				return
]
