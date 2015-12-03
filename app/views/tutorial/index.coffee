'use strict'

require '../../components/header'

require './tutorial.scss'
require './tutorial.html'

module.exports = angular.module('app.tutorial', [])
	.config( require './tutorial.route.coffee' )
	.controller('TutorialController', require './tutorial.controller.coffee')