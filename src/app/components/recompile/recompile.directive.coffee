'use strict'

#===============================================================================
#
#	Recompiler Directive
# 		Recompiles the contents of the directive when triggered
# 		Adapted from: http://kentcdodds.com/kcd-angular/#/kcd-recompile
#
#-------------------------------------------------------------------------------

app.directive 'recompiler', [
	'$log'
	'$parse'
	( $log, $parse ) ->
		restrict: 'A'
		transclude: true
		link: ($scope, $el, attrs, ctrls, transclude) ->
			previousElements = null

			recompile =
				run: ->
					@clean()
					@compile()

				compile: ->
					transclude($scope, (clone) ->
						previousElements = clone
						if attrs.animate is 'fadeIn'
							$el.hide().append(clone).fadeIn( 300 )
						else
							$el.append(clone)
					)

				clean: ->
					return if !previousElements?
					previousElements.remove()
					previousElements = null
					$el.empty()


			$scope.$watch(attrs.recompiler, (recompiler) ->
				return if !recompiler? or recompiler is 'false'

				# Set the recompiler back to false
				$parse(attrs.recompiler).assign($scope, false)

				# Trigger the recompile
				recompile.run()
			)
]
