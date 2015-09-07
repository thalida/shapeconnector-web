'use strict'

app.directive 'scModal', [
	'$log'
	'BOARD'
	( $log, BOARD ) ->
		templateUrl: 'app/components/modal/modal.html'
		transclude: true
		restrict: 'E'
		scope:
			showModal: '=?show'
			style: '@?'
		link: ($scope, el, attrs) ->
			$window = $(window)
			$gameBoard = $('.game-board')
			$modal = el.find('.modal')
			$content = $modal.find('.modal-content')
			$closeBtns = $modal.find('.js-close-modal')
			$minBtns = $modal.find('.js-minimize-modal')

			modal = new class Modal
				constructor: ->
					$scope.minimizeModal = false

				closeBtnOnClick: ( e ) =>
					$scope.$apply(() =>
						$scope.showModal = false
					)
					return

				minimizeBtnOnClick: ( e ) =>
					$scope.$apply(() =>
						$scope.minimizeModal = true
					)
					return

				show: ->
					@positionModal()
					$scope.animateVisibility = 'js-modal-animate-visibility'
					$('body').css(overflow: 'hidden')
					window.scrollTo(0, 0)
					return

				hide: ->
					$scope.animateVisibility = ''
					$('body').css(overflow: 'auto')
					return

				minimize: ->
					$scope.animateMinimize = 'js-modal-animate-minimize'
					$('body').css(overflow: 'auto')

				positionModal: ->
					offset = $gameBoard.offset()
					$content.css(
						width: BOARD.DIMENSIONS.w - BOARD.MARGIN.left
						height: BOARD.DIMENSIONS.h + 50
						marginTop: offset.top
					)
					return

				showModalWatch: ( show, lastState ) ->
					return if show is lastState

					modal.show() if show is true
					modal.hide() if show is false


				minimizeModalWatch: ( minimized, lastState ) ->
					return if minimized is lastState

					modal.minimize() if minimized is true


			$window.on('resize', modal.positionModal)
			$closeBtns.on('click', modal.closeBtnOnClick)
			$minBtns.on('click', modal.minimizeBtnOnClick)

			$scope.$watch('showModal', modal.showModalWatch)
			$scope.$watch('minimizeModal', modal.minimizeModalWatch)
]

app.animation '.modal', [
	'$log'
	($log) ->
		visiblityClass = 'js-modal-animate-visibility'
		minimizeClass = 'js-modal-animate-minimize'

		getSelectors = ( element ) ->
			$el = $(element)
			$overlay = $el.find('.modal-overlay')
			$content = $el.find('.modal-content')

			return [$el, $content, $overlay]

		minimizeModal = ( element, done ) ->
			console.log('minimizing')
			[$el, $content, $overlay] = getSelectors( element )

			$el.show()

			$overlay.css(opacity: '1')
			$content.css(top: '0%')

			marginTop = $(window).height() - 50

			$content.animate({marginTop: marginTop, width: '100%'},
				{
					duration: 500
					queue: false
					complete: ->
						$content.css(marginTop: marginTop, width: '100%')
						$el.addClass('minimized')
						done()
				}
			)

			$overlay.animate({opacity: '0'},
				{
					duration: 350
					queue: false
					complete: ->
						$overlay.css(opacity: '0')
				}
			)

			return


		showModal = ( element, done ) ->
			[$el, $content, $overlay] = getSelectors( element )

			$el.hide()

			$overlay.css(opacity: '0')
			$content.css(top: '100%')

			$el.show()

			$content.animate({top: '0%'},
				{
					duration: 500
					queue: false
					complete: ->
						$el.show()
						$content.css(top: '0%')
						done()
				}
			)

			$overlay.animate({opacity: '1'},
				{
					duration: 400
					queue: false
					complete: ->
						$overlay.css(opacity: '1')
				}
			)

		hideModal = ( element, done ) ->
			[$el, $content, $overlay] = getSelectors( element )

			$el.show()

			$overlay.css(opacity: '1')
			$content.css(top: '0%')

			$content.animate({top: '100%'},
				{
					duration: 400
					queue: false
					complete: ->
						$el.hide()
						$content.css(top: '100%')
						done()
				}
			)

			$overlay.animate({opacity: '0'},
				{
					duration: 350
					queue: false
					complete: ->
						$overlay.css(opacity: '0')
				}
			)

		return {
			addClass: (element, className, done) ->
				if className.indexOf(visiblityClass) >= 0
					showModal( element, done )
				else if className.indexOf(minimizeClass) >= 0
					minimizeModal( element, done )
				else
					done()
				return

			removeClass: (element, className, done) ->
				if className.indexOf(visiblityClass) >= 0
					hideModal( element, done )
				else
					done()
				return
		}
]
