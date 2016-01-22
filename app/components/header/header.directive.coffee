'use strict'

angular.module('app').directive 'appHeader', [
	'$log'
	'$state'
	($log, $state) ->
		templateUrl: 'components/header/header.html'
		restrict: 'E'
		scope:
			onClick: '&?'
			onShareEvent: '&?'
			shareOpts: '=?'
			showShare: '@?'
			showMenu: '@?'
		link: ($scope, el, attrs) ->
			$scope.showShareLink = $scope.showShare == 'true'
			$scope.showMenuIcon = $scope.showMenu == 'true'

			$scope.onLogoClick = ( e ) ->
				if $scope.onClick?
					$scope.onClick({params: e})
				else
					$state.go('home')
				return

			$scope.shareEvent = ( params ) ->
				$scope.onShareEvent({ params })
]
