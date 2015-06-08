'use strict'

window.app = angular.module 'app', [
	'ngCookies'
	'ngResource'
	'ngSanitize'
	'btford.socket-io'
	'ui.router'
]

app
.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
	$urlRouterProvider.otherwise('/')

	$locationProvider.html5Mode(true)
	$httpProvider.interceptors.push('authInterceptor')

.factory 'authInterceptor', ($rootScope, $q, $cookieStore, $location) ->
	# Add authorization token to headers
	request: (config) ->
		config.headers ?= {}
		
		if $cookieStore.get('token')
			config.headers.Authorization = 'Bearer ' + $cookieStore.get('token')
		
		return config

	# Intercept 401s and redirect you to login
	responseError: (response) ->
		if response.status is 401
			$location.path('/login')
			
			# remove any stale tokens
			$cookieStore.remove('token')

		$q.reject(response)

.run ($rootScope, $location, $timeout, Auth) ->
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

		result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
		
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

				
	# Redirect to login if route requires auth and you're not logged in
	$rootScope.$on( '$stateChangeStart', (event, next) ->
		Auth.isLoggedInAsync( (loggedIn) ->
			$location.path('/login') if next.authenticate and not loggedIn
		)
	)
