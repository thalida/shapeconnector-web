'use strict'

#===============================================================================
#
#	Window Events
# 		Handles the callbacks for the window/tab foucs + blur events
#
#-------------------------------------------------------------------------------

app.service 'WindowEvents', [
	'$log'
	'$rootScope'
	( $log, $rootScope ) ->
		class WindowEvents
			constructor: () ->
				@eventCallbacks = {
					focus: []
					blur: []
				}

				@setupEvent()

			setupEvent: () ->
				hidden = 'hidden'

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

				# set the initial state (but only if browser supports the Page Visibility API)
				if typeof document[hidden] isnt 'undefined'
					type = if document[hidden] then 'blur' else 'focus'
					onchange({ type })

			onChange: ( e, hidden ) ->
				v = 'visible'
				h = 'hidden'

				evtMap =
					focus: v
					focusin: v
					pageshow: v
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

			runCallbacks: ( type, e ) ->
				$.each(@eventCallbacks[type], (i, cb) ->
					cb?( e )
				)
				return

			onFocus: ( callback ) =>
				@eventCallbacks.focus.push( callback )
				return

			onBlur: ( callback ) =>
				@eventCallbacks.blur.push( callback )
				return


]
