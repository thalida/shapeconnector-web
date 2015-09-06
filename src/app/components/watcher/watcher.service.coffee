'use strict'

#===============================================================================
#
#	Watcher Service
# 		Stores + Manages scope watchers assigned to it
#
#-------------------------------------------------------------------------------

app.service 'WatcherService', [
	'$log'
	( $log ) ->
		class Watcher
			#	@constructor: Sets up the scope & defaults for the watcher
			#-------------------------------------------------------------------
			constructor: ( @scope, @watching = [] ) ->

			#	@start: Start watcing a collection of items and trigger the cb
			#-------------------------------------------------------------------
			start: ( items, callback ) ->
				watch = @scope.$watchCollection(items, callback)
				@watching.push( watch )

				return watch

			#	@stopAll: Stop all of the watchers set on this scope
			#-------------------------------------------------------------------
			stopAll: () ->
				$.each(@watching, (i, watchFunc) ->
					watchFunc?()
				)
				@watching = []

]
