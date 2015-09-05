'use strict'

app.service 'WatcherService', [
	'$log'
	( $log ) ->
		return class Watcher
			constructor: ( @scope ) ->
				@watching = []

			start: ( name, callback ) ->
				watch = @scope.$watchCollection(name, callback)
				@watching.push( watch )
				return watch

			stopAll: () ->
				$.each(@watching, (i, watchFunc) ->
					watchFunc?()
				)
				@watching = []

			stopOne: ( watchFunc ) ->
				watchFunc?()
]
