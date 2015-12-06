'use strict'

require 'angular'

angular
	.module('app')
	.service('GameDrawerService', require './gameDrawer.service.coffee')

module.exports = 'GameDrawerService'
