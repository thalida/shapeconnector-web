'use strict'

# JS
window.jQuery = window.$ = require 'jquery'
window.angular = require 'angular'
window.moment = require 'moment'

# Styles
require './app.scss'

# App
require './app.module.coffee'

isAppBootstrapped = angular.element($('.app-container')).scope()
if !isAppBootstrapped?
	angular.bootstrap(document, ['app'])
