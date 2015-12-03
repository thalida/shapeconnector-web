'use strict'

require 'angular'

angular
	.module('app')
	.service('CanvasDrawService', require './canvasDraw.service.coffee')

module.exports = 'CanvasDrawService'
