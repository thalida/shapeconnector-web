'use strict'

require 'angular'

angular
	.module('app')
	.service('GameBuilderService', require './gameBuilder.service.coffee')

module.exports = 'GameBuilderService'
