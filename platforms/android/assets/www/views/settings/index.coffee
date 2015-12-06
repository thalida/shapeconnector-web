'use strict'

require '../../components/header'
require '../../components/noiseToggles'

require './settings.scss'
require './settings.html'

module.exports = angular.module('app.settings', [])
	.config( require './settings.route.coffee' )
	.controller('SettingsController', require './settings.controller.coffee')
