'use strict'

require './assets/images/logo-gradient-512.png'
require './assets/images/gameplay-mini.glow.copy.gif'

# Import manifest.json for use in index.html file
manifestJSON = require('./manifest.json')

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
