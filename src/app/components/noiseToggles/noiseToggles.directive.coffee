'use strict'

app.directive 'scNoiseToggles', [
	'$log'
	'gameSettingsService'
	( $log, gameSettings) ->
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
				return

]
