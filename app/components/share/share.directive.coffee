'use strict'

#===============================================================================
#
#	Share Link + Modal
#
#-------------------------------------------------------------------------------

angular.module('app').directive 'share', [
	'$log',
	require '../../services/gameManager'
	require '../../services/gameSettings'
	require '../../services/gameUtils'
	($log, GameManager, gameSettings, gameUtils) ->
		templateUrl: 'components/share/share.html'
		restrict: 'E'
		scope: {}
		bindToController:
			eventHandler: '&?'
		controllerAs: 'share'
		controller: ['$element', ($el) ->
			this.showModal = false

			this.onLinkClick = () =>
				if !@gameLink? and !@gameAsStr?
					@gameAsStr = gameUtils.convertGameToStr( GameManager.cacheGameBoard )
					gameUtils.convertStrToGame( @gameAsStr )

					href = window.location.href.split('?')[0]
					mode = gameSettings.getGameType()
					difficulty = gameSettings.getDifficulty()
					@gameOpts = "?mode=#{mode}&difficulty=#{difficulty}"
					@gameLink = href + @gameAsStr + @gameOpts

				$('.app-header').css('z-index', '4');
				this.showModal = true

				this.eventHandler?({params: {
					type: 'show'
				}})

				return

			this.onModalEvent = ( type ) =>
				if type is 'close'
					$('.app-header').css('z-index', '');

				this.eventHandler?({params: {
					type: type
				}})

			this.selectAll = () =>
				$input = $el.find('.share-modal-input')
				$input.focus()
				$input[0].setSelectionRange(0, @gameLink.length)
				return

			return
		]
		link: ($scope, el, attrs) -> return;

]
