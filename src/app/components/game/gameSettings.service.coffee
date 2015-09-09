'use strict'

app.service 'gameSettingsService', [
	'$log'
	'GAME_TYPES'
	'LEVELS'
	( $log, GAME_TYPES, LEVELS ) ->
		new class GameSettings
			constructor: ->
				@gameType = GAME_TYPES.default
				@allowSounds = true
				@allowMusic = true
				@difficulty = LEVELS.default

			setGameType: ( type ) ->
				if GAME_TYPES.options.indexOf( type ) >= 0
					@gameType = type

				return @gameType

			setDifficulty: ( level ) ->
				if LEVELS[ level.toUpperCase() ]?
					@difficulty = level.toLowerCase()

				return @difficulty

			setAllowSounds: (bool) ->
				@allowSounds = bool

			setAllowMusic: (bool) ->
				@allowMusic = bool

			toggleAllowSounds: ->
				@allowSounds = !@allowSounds

			toggleAllowMusic: ->
				@allowMusic = !@allowMusic

			getGameType: -> return @gameType

			getDifficulty: -> return @difficulty

			getAllowSounds: -> return @allowSounds

			getAllowMusic: -> return @allowMusic
]
