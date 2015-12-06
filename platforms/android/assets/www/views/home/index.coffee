'use strict'

require './home.scss'
require './home.html'

module.exports = angular.module('app.home', [])
	.config( require './home.route.coffee' )
	.controller('HomeController', require './home.controller.coffee')
