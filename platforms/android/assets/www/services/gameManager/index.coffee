'use strict'

require 'angular'

angular
	.module('app')
	.service('GameManagerService', require './gameManager.service.coffee')

module.exports = 'GameManagerService'
