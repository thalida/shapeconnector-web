'use strict'

$requires = [
	'$rootScope'
	'$location'
	'$timeout'
	'$state'
	'$localStorage'

	require './services/windowEvents'
	require './services/assets'
]

run = ($rootScope, $location, $timeout, $state, $localStorage, WindowEvents, assets) ->
	console.log( new Date() )

	$rootScope.windowEvents = new WindowEvents()

	assets.downloadAll().then(() =>
		assets.playSound('background')
	)

	if !$localStorage.firstVisited?
		$localStorage.firstVisited = new Date()
		$localStorage.hasCompletedTutorial = false

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

	return

run.$inject = $requires
module.exports = run
