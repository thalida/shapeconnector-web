'use strict'

ngstorage = require 'ngstorage'
config = require './app.constants.coffee'

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
.constant( 'ALPHABET', config.ALPHABET )
.constant( 'LEVELS', config.LEVELS )
.constant( 'TUTORIAL_STEPS', config.TUTORIAL_STEPS )
.constant( 'GAME_TYPES', config.GAME_TYPES )
.constant( 'HEXCOLORS', config.HEXCOLORS )
.constant( 'BOARD', config.BOARD )
.constant( 'SHAPE', config.SHAPE )
.config( require './app.route.coffee' )
.run( require './app.run.coffee' )

require './app.filters.coffee'

# Views
require './views/about'
require './views/home'
require './views/play'
require './views/settings'
require './views/tutorial'
