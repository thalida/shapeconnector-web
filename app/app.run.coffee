'use strict'

$requires = [
	'$rootScope'
	'$location'
	'$timeout'
	'$state'

	require './services/windowEvents'
	require './services/assets'
]

run = ($rootScope, $location, $timeout, $state, WindowEvents, assets) ->
	$rootScope.windowEvents = new WindowEvents()

	assets.downloadAll().then(() =>
		assets.playSound('background')
	)

	$rootScope.windowEvents.onFocus( -> assets.playSound('background') )
	$rootScope.windowEvents.onBlur( -> assets.pauseSound('background') )

	window.requestAnimationFrame = window.requestAnimationFrame ||
								   window.webkitRequestAnimationFrame ||
								   window.mozRequestAnimationFrame ||
								   window.msRequestAnimationFrame ||
								   window.oRequestAnimationFrame ||
								   (callback) ->
										return $timeout(callback, 1)

	window.cancelRequestAnimFrame = window.cancelAnimationFrame ||
									window.webkitCancelRequestAnimationFrame ||
									window.mozCancelRequestAnimationFrame ||
									window.oCancelRequestAnimationFrame ||
									window.msCancelRequestAnimationFrame ||
									clearTimeout

	$rootScope.$on('$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
		blacklist = [
			# 'play'
			'tutorial'
		]

		if blacklist.indexOf(toState.name) >= 0 and fromState.name.length is 0
			e.preventDefault()
			$state.go('home')
	)

	return

run.$inject = $requires
module.exports = run
