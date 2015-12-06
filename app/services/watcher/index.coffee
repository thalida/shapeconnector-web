'use strict'

require 'angular'

angular
	.module('app')
	.service('WatcherService', require './watcher.service.coffee')

module.exports = 'WatcherService'
