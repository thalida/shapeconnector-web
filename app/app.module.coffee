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

require './views/about'
require './views/home'
require './views/play'
require './views/settings'
require './views/tutorial'

require './app.constants.coffee'
require './app.filters.coffee'
require './app.routes.coffee'
require './app.run.coffee'
