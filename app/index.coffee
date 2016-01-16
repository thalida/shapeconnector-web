'use strict'

require 'jquery'
require 'angular'

# Styles
require './app.scss'

# App
require './app.module.coffee'

isAppBootstrapped = angular.element(document.querySelectorAll('.app-container')).scope()
if !isAppBootstrapped?
	angular.bootstrap(document, ['app'])
