'use strict'

#===============================================================================
#
#	TIMER
# 		http://stackoverflow.com/questions/20618355/the-simplest-possible-javascript-countdown-timer
#
#-------------------------------------------------------------------------------
app.service 'timerService', [
	'$log'
	'$timeout'
	( $log, $timeout ) ->
		return class Timer
			constructor: ( duration, step, onTick ) ->
				@duration = duration
				@step = step
				@step ?= 1000

				@running = false
				@remaining = null

				@timeout = null

			start: () =>
				return if @running

				@running = true
				start = Date.now()

				timer = () =>
					diff = @duration - parseInt((Date.now() - start) / 1000)

					if diff > 0
						@timeout = $timeout(timer, @step)
					else
						diff = 0
						@running = false

					@remaining = @parse( diff )
					@onChange()
					return

				timer()
				return

			onChange: () =>
				return @onTick?( @remaining )

			expired: () ->
				@running = false

			pause: () ->
				$timeout.cancel(@timeout)
				@duration = @remaining.total
				@running = false
				return

			stop: () ->
				$timeout.cancel(@timeout)
				@running = false
				return

			parse: ( seconds ) ->
				return {
					minutes: (seconds / 60) | 0
					seconds: (seconds % 60) | 0
					total: seconds
				}
]
