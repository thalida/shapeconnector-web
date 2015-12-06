'use strict'

$requires = [
	'$log'
	'$localStorage'
	'GAME_TYPES'
	'LEVELS'
]
gameSettingsService = ( $log, $localStorage, GAME_TYPES, LEVELS ) ->
	new class GameSettings
		constructor: ->
			$localStorage.$default(
				allowSounds: true
				allowMusic: true
				difficulty: LEVELS.DEFAULT.name
			)

			@gameType = GAME_TYPES.default
			@allowSounds = $localStorage.allowSounds
			@allowMusic = $localStorage.allowMusic
			@difficulty = $localStorage.difficulty

			# $localStorage.allowSounds = @allowSounds
			# $localStorage.allowMusic = @allowMusic
			# $localStorage.difficulty = @difficulty

		setGameType: ( type ) ->
			if GAME_TYPES.options.indexOf( type ) >= 0
				@gameType = type

			return @gameType

		setDifficulty: ( level ) ->
			if LEVELS[ level.toUpperCase() ]?
				@difficulty = level.toLowerCase()

			$localStorage.difficulty = @difficulty

			return @difficulty

		setAllowSounds: (bool) ->
			@allowSounds = bool
			$localStorage.allowSounds = @allowSounds

			return @allowSounds

		setAllowMusic: (bool) ->
			@allowMusic = bool
			$localStorage.allowMusic = @allowMusic

			return @allowMusic

		toggle: ( type ) ->
			if type is 'sounds'
				return @toggleAllowSounds()
			else if type is 'music'
				return @toggleAllowMusic()

		toggleAllowSounds: ->
			return @setAllowSounds( !@allowSounds )

		toggleAllowMusic: ->
			return @setAllowMusic( !@allowMusic )

		getGameType: -> return @gameType

		getDifficulty: -> return @difficulty

		getAllowSounds: -> return @allowSounds

		getAllowMusic: -> return @allowMusic


gameSettingsService.$inject = $requires
module.exports = gameSettingsService
