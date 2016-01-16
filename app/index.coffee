'use strict'

window.jQuery = window.$ = require 'jquery'
window.angular = require 'angular'

# Styles
require './app.scss'

# App
require './app.module.coffee'

isAppBootstrapped = angular.element(document.querySelectorAll('.app-container')).scope()
if !isAppBootstrapped?
	angular.bootstrap(document, ['app'])
