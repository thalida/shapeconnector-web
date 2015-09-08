'use strict'

#===============================================================================
#
#	ShapeConnector (SC) Modal Directive
# 		Handles the game specific modals
#
#-------------------------------------------------------------------------------

app.directive 'scModal', [
	'$log'
	'BOARD'
	( $log, BOARD ) ->
		templateUrl: 'app/components/modal/modal.html'
		transclude: true
		restrict: 'E'
		scope:
			name: '@?'
			showModal: '=?show'
			style: '@?'
		controller: ['$scope', '$element', '$transclude', ($scope, $el, $transclude) ->
			# Trigger the modal minimize action
			@minimize = -> $scope.minimizeModal = true

			# Trigger the modal show action
			@close = -> $scope.showModal = false

			# Trigger the modal hide action
			@show = -> $scope.showModal = false

			$transclude((clone) ->
				mainContent = $el.find('.modal-content')
				minimizeSection = $el.find('.modal-minimized')
				transcludedContent = clone

				angular.forEach(transcludedContent, ( content ) ->
					if angular.element( content ).hasClass('scmodal-minimized-content')
						minimizeSection.append( content )
					else
						mainContent.append( content )
				)
			)

			return this
		]
		link: ($scope, el, attrs) ->
			$window = $(window)
			$gameBoard = $('.game-board')
			$modal = el.find('.modal')
			$content = $modal.find('.modal-content')

			modal = new class Modal
				constructor: ->
					$scope.minimizeModal = false

				#	@show
				# 		Positions the modal correclty then inits the show animation
				#---------------------------------------------------------------
				show: ->
					@positionModal()

					# animateVisibility is set has a clase that ng animate watches
					$scope.animateVisibility = 'js-modal-animate-visibility'

					$('body').css(overflow: 'hidden')
					window.scrollTo(0, 0)
					return

				#	@hide
				# 		Removes the visibility class -> triggers animations
				#---------------------------------------------------------------
				hide: ->
					# Remove the visiblity class - triggers animate on classRemove
					$scope.animateVisibility = ''

					$('body').css(overflow: 'auto')
					return

				#	@hide
				# 		Adds the minimize class -> triggers ng animate addClass
				#---------------------------------------------------------------
				minimize: ->
					$scope.animateMinimize = 'js-modal-animate-minimize'

					$('body').css(overflow: 'auto')
					return

				#	@positionModal
				# 		Position the contents of the modal to cover the game board
				#---------------------------------------------------------------
				positionModal: ->
					$content.css(
						width: BOARD.DIMENSIONS.w - BOARD.MARGIN.left
						height: BOARD.DIMENSIONS.h + 50
						marginTop: $gameBoard.offset().top
					)
					return

				#	@showModalWatch
				# 		The callback for the $watch on 'showModal'
				# 		Calls the approriate action if the modal visibility has changed
				#---------------------------------------------------------------
				showModalWatch: ( show, lastState ) ->
					return if show is lastState

					modal.show() if show is true
					modal.hide() if show is false
					return

				#	@minimizeModalWatch
				# 		The callback for the $watch on 'minimizeModal'
				# 		Calls the approriate action if the modal has been minimized
				#---------------------------------------------------------------
				minimizeModalWatch: ( minimized, lastState ) ->
					return if minimized is lastState

					modal.minimize() if minimized is true
					return

			# Keep the contents covering the game board as the window changes
			$window.on('resize', modal.positionModal)

			# Setup watches on the show + minimize variables
			$scope.$watch('showModal', modal.showModalWatch)
			$scope.$watch('minimizeModal', modal.minimizeModalWatch)
			return
]

#===============================================================================
#
#	ShapeConnector (SC) Modal Action Directive
# 		Handles the game specific modals
#
#-------------------------------------------------------------------------------

app.directive 'scModalAction', [
	'$log'
	'$parse'
	'$timeout'
	( $log, $parse, $timeout ) ->
		require: '^scModal'
		restrict: 'A'
		link: ( $scope, el, attrs, modalCtrl ) ->
			# What action are we trying to perform? [close, show, or minimize]
			action = modalCtrl[attrs.scModalAction]

			# Convert attr.onComplete back into a function if one has been passed
			if attrs.onComplete?
				hasCallback = true
				eventCallback = $parse( attrs.onComplete )
			else
				hasCallback = false

			# wait the duration of the modal animation before calling the eventCallback
			callbackDelay = if attrs.noDelay? then 0 else 400

			runAction = ( e ) ->
				# Check if a valid action was assigned
				return if not action?

				$scope.$apply(() ->
					action()

					# If a callback has been passed, wait the duration of the
					# modal animation before calling the eventCallback
					if hasCallback
						$timeout(() ->
							eventCallback($scope, { e })
						, callbackDelay)
				)

			$(el).on('click', runAction)

			return
]

