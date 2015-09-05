'use strict'

app.directive 'appTemplate', () ->
	templateUrl: 'app/components/_template/_template.html'
	restrict: 'E'
	replace: true
	link: ($scope, el, attrs) ->
