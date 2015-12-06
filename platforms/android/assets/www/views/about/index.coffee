'use strict'

require './about.scss'
require './about.html'

module.exports = angular.module('app.about', [])
	.config( require './about.route.coffee' )
	.controller('AboutController', require './about.controller.coffee')
