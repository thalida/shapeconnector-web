'use strict'

#===============================================================================
#
#	ShapeConnector (SC) Modal Directive
# 		Handles the game specific modals
#
#-------------------------------------------------------------------------------

angular.module('app').directive 'scModal', [
	'$log'
	'BOARD'
	require '../../services/utils'
	( $log, BOARD, utils ) ->
		templateUrl: 'components/modal/modal.html'
		transclude: true
		restrict: 'E'
		scope:
			name: '@?'
			showModal: '=?show'
			style: '@?'
			position: '@?' # over-game | center | top
		controller: ['$scope', '$element', '$transclude', ($scope, $el, $transclude) ->
			# Trigger the modal minimize action
			@minimize = -> $scope.minimizeModal = true

			# Trigger the modal show action
			@close = -> $scope.showModal = false

			# Trigger the modal hide action
			@show = -> $scope.showModal = false

			@getIsAnimating = -> return $scope.isAnimating

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
					$scope.isAnimating = false
					return

				#	@show
				# 		Positions the modal correclty then inits the show animation
				#---------------------------------------------------------------
				show: ->
					@positionModal()

					# animateVisibility is set as a class ng animate watches
					$scope.animateVisibility = 'js-modal-animate-visibility'
					$scope.isAnimating = true
					return

				#	@hide
				# 		Removes the visibility class -> triggers animations
				#---------------------------------------------------------------
				hide: ->
					# Remove the visiblity class - triggers animate on classRemove
					$scope.animateVisibility = ''
					$scope.isAnimating = true
					return

				#	@hide
				# 		Adds the minimize class -> triggers ng animate addClass
				#---------------------------------------------------------------
				minimize: ->
					$scope.animateMinimize = 'js-modal-animate-minimize'
					$scope.isAnimating = true
					return

				#	@positionModal
				# 		Position the contents of the modal to cover the game board
				#---------------------------------------------------------------
				positionModal: ->
					currWindowHeight = $window.height()
					modalHeight = 345

					if currWindowHeight < 475
						modalHeight = BOARD.DIMENSIONS.h
						$content.removeClass('size-large')
						$content.addClass('size-normal')
					else
						$content.removeClass('size-normal')
						$content.addClass('size-large')

					marginTop = switch
						when $scope.position is 'over-game' then $gameBoard.offset().top
						when $scope.position is 'top' then 0
						when $scope.position is 'center' then (currWindowHeight - modalHeight) / 2
						else $gameBoard.offset().top

					$content.css(
						width: BOARD.DIMENSIONS.w - BOARD.MARGIN.left
						height: modalHeight
						marginTop: marginTop
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

				onAnimationDone: ( e, args ) ->
					return if $scope.name isnt args.$el.data('name')
					$scope.$apply(() ->
						$scope.isAnimating = false
					)
					return


			# Keep the contents covering the game board as the window changes
			$window.on('resize', modal.positionModal)

			# Setup watches on the show + minimize variables
			$scope.$watch('showModal', modal.showModalWatch)
			$scope.$watch('minimizeModal', modal.minimizeModalWatch)
			$scope.$on('modal-animations-done', modal.onAnimationDone)
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
			triggeredAction = false
			triggeredEvt = null

			runAction = ( e ) ->
				# Check if a valid action was assigned
				return if not action?

				$scope.$apply(() ->
					action()
					triggeredAction = true
					triggeredEvt = e
				)

			$(el).on('click', runAction)

			$scope.$watch(
				() -> modalCtrl.getIsAnimating()
				( isAnimating ) ->
					if triggeredAction and !isAnimating and hasCallback
						triggeredAction = false
						triggeredEvt = null
						eventCallback($scope, { e: triggeredEvt })

					return
			)

			return
]

