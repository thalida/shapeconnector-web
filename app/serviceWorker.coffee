# if navigator.serviceWorker && navigator.serviceWorker.controller
# 	console.log('in here doing foo');
# 	navigator.serviceWorker.oncontrollerchange = ( event ) ->
# 		console.log( event )
# 		this.controller.onstatechange = ( e )  ->
# 			console.log( e.target.state )
# 			if e.target.state == 'redundant'
# 				$('.refresher').show();
# 				$('.refresher').on('click', ->
# 					window.location.reload();
# 				)

# 	navigator.serviceWorker.controller.onstatechange = (e) ->
# 		console.log( e.target.state )
# 		if e.target.state == 'redundant'
# 			$('.refresher').show();
# 			$('.refresher').on('click', ->
# 				window.location.reload();
# 			)

# 	ServiceWorkerRegistration.onupdatefound = ( e ) ->
# 		console.log('this:', e)
