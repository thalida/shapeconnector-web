'use strict'

# Vendors
require 'jquery'
require 'angular'

# Styles
require './app.scss'

# App
require './app.module.coffee'

# Bootstrap the angular app (if it hasn't been done already)
isAppBootstrapped = angular.element(document.querySelectorAll('.app-container')).scope()
if !isAppBootstrapped?
	angular.bootstrap(document, ['app'])
