'use strict'

$requires = [ '$log' ]

class AboutController
	constructor: ( $log ) ->
		@year = new Date().getFullYear()

AboutController.$inject = $requires
module.exports = AboutController
