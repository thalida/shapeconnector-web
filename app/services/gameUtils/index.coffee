'use strict'

require 'angular'

angular
	.module('app')
	.service('gameUtils', require './gameUtils.service.coffee')

module.exports = 'gameUtils'
