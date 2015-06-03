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

.run ($rootScope, $location, Auth) ->
	window.getRandomInt = (min, max) ->
		return Math.floor(Math.random() * (max - min + 1)) + min

	window.coinFlip = () ->
		isEven = getRandomInt(1, 10) % 2 == 0

		return true if isEven
		return false if !isEven

				
	# Redirect to login if route requires auth and you're not logged in
	$rootScope.$on( '$stateChangeStart', (event, next) ->
		Auth.isLoggedInAsync( (loggedIn) ->
			$location.path('/login') if next.authenticate and not loggedIn
		)
	)
