'use strict'

require 'angular'

angular
	.module('app')
	.service('assets', require './assets.service.coffee')

module.exports = 'assets'
