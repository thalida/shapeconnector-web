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

	# https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/findIndex
	if !Array::findIndex
		Array::findIndex = (predicate) ->
			if this == null
				throw new TypeError('Array.prototype.findIndex called on null or undefined')

			if typeof predicate != 'function'
				throw new TypeError('predicate must be a function')

			list = Object(this)
			length = list.length >>> 0
			thisArg = arguments[1]
			value = undefined
			i = 0

			while i < length
				value = list[i]
				if predicate.call(thisArg, value, i, list)
					return i
				i++

			return -1


	return

run.$inject = $requires
module.exports = run
