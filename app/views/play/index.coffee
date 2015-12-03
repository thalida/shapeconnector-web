'use strict'

require '../../components/header'
require '../../components/game'

require './play.scss'
require './play.html'

module.exports = angular.module('app.play', [])
	.config( require './play.route.coffee' )
	.controller('PlayController', require './play.controller.coffee')
