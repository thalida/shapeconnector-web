'use strict'

window.isAndroid = navigator.userAgent.toLowerCase().match('android') != null

if window.isAndroid
	document.write('<script src="cordova.js"><\/script>')


# JS
window.jQuery = $ = require 'jquery'
window.angular = require 'angular'
window.moment = require 'moment'
ngstorage = require 'ngstorage'

# Styles
require './app.scss'

# Main Template
require './index.html'

# App
require './app.module.coffee'
require './app.constants.coffee'
require './app.filters.coffee'
require './app.routes.coffee'
require './app.run.coffee'

# Views
require './views/about'
require './views/home'
require './views/play'
require './views/settings'
require './views/tutorial'

if isAndroid
	document.addEventListener('deviceready', () ->
		angular.bootstrap(document, ['app'])
	, false)
else
	angular.bootstrap(document, ['app'])
