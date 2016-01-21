'use strict'

require('./favicon.ico')

# Import manifest.json for use in index.html file
manifestJSON = require('./manifest.json')

# ServiceWorker for Offline Support
# if MODE.production is true
# 	require('offline-plugin/runtime').install( null )

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
