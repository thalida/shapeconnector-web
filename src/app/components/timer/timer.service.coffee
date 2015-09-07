'use strict'

#===============================================================================
#
#	Timer Service
# 		http://stackoverflow.com/questions/20618355/the-simplest-possible-javascript-countdown-timer
#
#-------------------------------------------------------------------------------

app.service 'TimerService', [
	'$log'
	'$timeout'
	( $log, $timeout ) ->
		class Timer
			#	@constructor: Set defautls for the timer vars
			#-------------------------------------------------------------------
			constructor: ( @duration, @step, @onTick ) ->
				@step ?= 1000
				@running = false
				@remaining = null
				@timeout = null

			#	@start: Start running the timer
			#-------------------------------------------------------------------
			start: =>
				return if @running

				@running = true
				start = Date.now()

				# A tick corresponds to a second of the timer
				tick = =>
					# How much time is remaining in seconds
					diff = @duration - parseInt((Date.now() - start) / 1000)

					# Tick if we have more time left
					if diff > 0
						@timeout = $timeout(tick, @step)
					else
						diff = 0
						@running = false

					# Format the remainging time into a usable obj
					@remaining = @parse( diff )

					# Let the caller know that the timer has updated
					@onChange()
					return

				# Kick things off!
				tick()

				return

			#	@onChange: Trigger the callback func
			#-------------------------------------------------------------------
			onChange: => return @onTick?( @remaining )

			#	@expired: The timer has died
			#-------------------------------------------------------------------
			expired: () ->
				@running = false

			#	@pause: Put the timer on hold; Call @start to restart
			#-------------------------------------------------------------------
			pause: () ->
				$timeout.cancel(@timeout)
				@timeout = null

				@duration = @remaining.total
				@running = false
				return

			#	@stop: Stop the timer entirely
			#-------------------------------------------------------------------
			stop: () ->
				$timeout.cancel(@timeout)
				@running = false
				return

			#	@parse: Convert the seconds into additional usable formats
			#-------------------------------------------------------------------
			parse: ( seconds ) ->
				return {
					minutes: (seconds / 60) | 0
					seconds: (seconds % 60) | 0
					total: seconds
				}
]
