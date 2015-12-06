'use strict'

require 'angular'

angular
	.module('app')
	.service('TimerService', require './timer.service.coffee')

module.exports = 'TimerService'
