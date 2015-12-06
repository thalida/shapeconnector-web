'use strict'

require 'angular'

angular
	.module('app')
	.service('WindowEvents', require './windowEvents.service.coffee')

module.exports = 'WindowEvents'
