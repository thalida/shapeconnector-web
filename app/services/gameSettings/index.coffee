'use strict'

require 'angular'

angular
	.module('app')
	.service('gameSettingsService', require './gameSettings.service.coffee')

module.exports = 'gameSettingsService'
