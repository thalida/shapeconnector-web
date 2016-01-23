'use strict'

angular.module('app').directive 'appHeader', [
	'$log'
	'$state'

	require '../../services/gameSettings'
	($log, $state, gameSettings) ->
		templateUrl: 'components/header/header.html'
		restrict: 'E'
		scope:
			onClick: '&?'
			onShareEvent: '&?'
			shareOpts: '=?'
			showLogo: '@?'
			showShare: '@?'
			showMenu: '@?'
			showSounds: '@?'
		transclude: true
		link: ($scope, el, attrs) ->
			$scope.showLogo ?= 'true'

			$scope.showAppLogo = $scope.showLogo == 'true'
			$scope.showShareLink = $scope.showShare == 'true'
			$scope.showMenuIcon = $scope.showMenu == 'true'
			$scope.showSoundsIcon = $scope.showSounds == 'true'
			$scope.showSoundsModal = false
			$scope.isMusicOn = gameSettings.allowMusic || gameSettings.allowSounds

			$scope.onLogoClick = ( e ) ->
				if $scope.onClick?
					$scope.onClick({params: e})
				else
					$state.go('home')
				return

			$scope.shareEvent = ( params ) ->
				$scope.onShareEvent({ params })

			$scope.openSoundsModal = () ->
				$scope.showSoundsModal = true

			$scope.onSoundsModalEvent = () ->
				$scope.isMusicOn = gameSettings.allowMusic || gameSettings.allowSounds


]
