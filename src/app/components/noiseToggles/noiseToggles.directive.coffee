'use strict'

app.directive 'scNoiseToggles', [
	'$log'
	'gameSettingsService'
	'assetsService'
	( $log, gameSettings, assetsService) ->
		templateUrl: 'app/components/noiseToggles/noiseToggles.html'
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
				if type is 'music' and $scope.noises[type].allowed is false
					assetsService.pauseSound('background')
				if type is 'music' and $scope.noises[type].allowed is true
					assetsService.playSound('background')
				return

]
