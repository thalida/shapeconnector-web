'use strict'

angular.module('app').animation '.modal', [
	'$log'
	($log) ->
		visiblityClass = 'js-modal-animate-visibility'
		minimizeClass = 'js-modal-animate-minimize'

		getSelectors = ( element ) ->
			$el = $(element)
			$overlay = $el.find('.modal-overlay')
			$content = $el.find('.modal-content')

			return [$el, $content, $overlay]

		setOverflow = ( state ) ->
			$('body').css({'overflow': state})
			$('.app-container').css({'overflow': state})
			$('.modal').css({'overflow': state})

		minimizeModal = ( element, done ) ->
			[$el, $content, $overlay] = getSelectors( element )

			$el.show()

			$overlay.css(opacity: '1')
			$content.css(top: '0%')

			marginTop = $(window).height() - 70

			$content.animate({marginTop: marginTop, width: '100%'},
				{
					duration: 500
					queue: false
					complete: ->
						$content.css(marginTop: marginTop, width: '100%')
						$el.addClass('minimized')
						setOverflow('auto')
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

			setOverflow('hidden')

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
						window.scrollTo(0, 0)
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
						setOverflow('auto')
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
