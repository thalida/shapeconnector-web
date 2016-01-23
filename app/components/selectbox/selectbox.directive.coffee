'use strict'

#===============================================================================
#
#	ShapeConnector Selectbox Directive
#
#-------------------------------------------------------------------------------

angular.module('app').directive 'selectbox', [
	'$log'
	'$timeout'
	require '../../services/utils'
	( $log, $timeout, utils ) ->
		templateUrl: 'components/selectbox/selectbox.html'
		transclude: true
		restrict: 'E'
		scope: {}
		bindToController:
			options: '='
			model: '='
			onChangeCB: '&?onChange'
		controllerAs: 'selectbox'
		controller: ['$scope', '$element', '$transclude', ($scope, $el, $transclude) ->
			@onChange = ( e, value ) =>
				@onChangeCB({params: {
					option: @options[@model]
					value: @model
				}})

			return this
		]
		link: ($scope, el, attrs) ->
			return
]
