'use strict'

# Module
window.app = angular.module('app', [
	require 'angular-animate'
	require 'angular-cookies'
	require 'angular-touch'
	require 'angular-sanitize'
	require 'angular-resource'
	require 'angular-ui-router'
	'ngStorage'

	'app.about'
	'app.home'
	'app.play'
	'app.settings'
	'app.tutorial'
])
