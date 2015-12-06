'use strict'

$requires = [
	'$rootScope'
	'$location'
	'$timeout'
	'$state'

	require './services/windowEvents'
	require './services/assets'
]

onAppRun = ($rootScope, $location, $timeout, $state, WindowEvents, assets) ->
	$rootScope.isProdSite = MODE.production is true

	$rootScope.windowEvents = new WindowEvents()

	assets.downloadAll().then(() =>
		assets.playSound('background')
	)

	$rootScope.windowEvents.onFocus( -> assets.playSound('background') )
	$rootScope.windowEvents.onBlur( -> assets.pauseSound('background') )

	$rootScope.$on('$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
		if (toState.name is 'play' || toState.name is 'tutorial') and fromState.name.length is 0
			e.preventDefault()
			$state.go('home')
	)

	window.getRandomInt = (min, max) ->
		return Math.floor(Math.random() * (max - min + 1)) + min

	window.coinFlip = () ->
		isEven = getRandomInt(1, 10) % 2 == 0

		return true if isEven
		return false if !isEven

	# http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
	window.hexToRgb = (hex) ->
		# Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
		shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i
		hex = hex.replace(shorthandRegex, (m, r, g, b) ->
			return r + r + g + g + b + b
		)

		result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)

		if result
			return {
				r: parseInt(result[1], 16)
				g: parseInt(result[2], 16)
				b: parseInt(result[3], 16)
			}
		else
			return null

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


onAppRun.$inject = $requires
angular.module('app').run( onAppRun )
