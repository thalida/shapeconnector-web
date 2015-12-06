'use strict'

angular.module('app').directive 'scNoiseToggles', [
	'$log'
	'assets'
	require '../../services/gameSettings'
	( $log, assets, gameSettings) ->
		templateUrl: 'components/noiseToggles/noiseToggles.html'
		restrict: 'E'
		scope: true
		link: ($scope, el, attrs) ->
			$scope.noises =
				sounds: {
					label: 'Sound'
					allowed: gameSettings.getAllowSounds()
				}
				music: {
					label: 'Music'
					allowed: gameSettings.getAllowMusic()
				}

			$scope.toggleNoise = ( type ) ->
				$scope.noises[type].allowed = gameSettings.toggle( type )
				if type is 'music'
					if $scope.noises[type].allowed is yes
						assets.playSound('background')
					else
						assets.pauseSound('background')
				return

]
