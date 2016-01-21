'use strict'

$requires = [ '$log' ]

class AboutController
	constructor: ( $log ) ->
		@years =
			start: 2015
			current: new Date().getFullYear()

		return

AboutController.$inject = $requires
module.exports = AboutController
