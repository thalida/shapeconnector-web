'use strict'

app.directive 'appHeader', [
	'$rootScope'
	'$log'
	'$state'
	($rootScope, $log, $state) ->
		templateUrl: 'app/components/header/header.html'
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
