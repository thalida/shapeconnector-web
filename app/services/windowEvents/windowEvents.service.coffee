'use strict'

#===============================================================================
#
#	Window Events
# 		Handles the callbacks for the window/tab foucs + blur events
#
# 		Based on:
# 		http://stackoverflow.com/questions/1060008/is-there-a-way-to-detect-if-a-browser-window-is-not-currently-active
#
#-------------------------------------------------------------------------------

$requires = [
	'$log'
]

windowEventsSerice = ( $log ) ->
	class WindowEvents
		#	@constructor: Setup the default vars for the service
		#-------------------------------------------------------------------
		constructor: () ->
			@eventCallbacks = {
				focus: []
				blur: []
			}

			@setupEvent()

		#	@setupEvent: Setup the event listeners on the window
		#-------------------------------------------------------------------
		setupEvent: () ->
			hidden = 'hidden'

			# Wrapper function for @onChange
			onchange = ( e ) => @onChange(e, hidden)

			# Standards
			if hidden of document
				document.addEventListener('visibilitychange', onchange)
			else if (hidden = 'mozHidden') of document
				document.addEventListener('mozvisibilitychange', onchange)
			else if (hidden = 'webkitHidden') of document
				document.addEventListener('webkitvisibilitychange', onchange)
			else if (hidden = 'msHidden') of document
				document.addEventListener('msvisibilitychange', onchange)
			# IE 9 and lower:
			else if 'onfocusin' of document
				document.onfocusin = document.onfocusout = onchange
			# All others:
			else
				window.onpageshow = window.onpagehide = window.onfocus = window.onblur = onchange

			document.addEventListener('resume', onchange, false)
			document.addEventListener('pause', onchange, false)

			# set the initial state (but only if browser supports the Page Visibility API)
			if typeof document[hidden] isnt 'undefined'
				type = if document[hidden] then 'blur' else 'focus'
				onchange({ type })

		#	@onChange: After a window evetn detect the type and trigger the cb
		#-------------------------------------------------------------------
		onChange: ( e, hidden ) ->
			v = 'visible'
			h = 'hidden'

			evtMap =
				resume: v
				focus: v
				focusin: v
				pageshow: v
				pause: h
				blur: h
				focusout: h
				pagehide: h

			e = e || window.event

			if e.type of evtMap
				windowVisiblity = evtMap[e.type]
			else
				windowVisiblity = if e?.target?[hidden] then 'hidden' else 'visible'

			document.body.className = windowVisiblity

			eventType = if windowVisiblity is 'visible' then 'focus' else 'blur'
			@runCallbacks( eventType, e )
			return

		#	@runCallbacks: Trigger all of the callbacks tied to the given event
		#-------------------------------------------------------------------
		runCallbacks: ( type, e ) ->
			@eventCallbacks[type].forEach((cb) ->
				cb?( e )
			)
			return

		#	@onFocus: Setup an on focus callback
		#-------------------------------------------------------------------
		onFocus: ( callback ) =>
			@eventCallbacks.focus.push( callback )
			return

		#	@onBlur: Setup an on blur callback
		#-------------------------------------------------------------------
		onBlur: ( callback ) =>
			@eventCallbacks.blur.push( callback )
			return


windowEventsSerice.$inject = $requires
module.exports = windowEventsSerice
