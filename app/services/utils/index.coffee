'use strict'

require 'angular'

angular
	.module('app')
	.service('utils', require './utils.service.coffee')

module.exports = 'utils'
