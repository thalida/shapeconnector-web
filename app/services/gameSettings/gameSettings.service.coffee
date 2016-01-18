'use strict'

#===============================================================================
#
#	Game Settings Service
# 		User defined settings for the game
#
#-------------------------------------------------------------------------------

$requires = [
	'$log'
	'$localStorage'
	'GAME_TYPES'
	'LEVELS'
]
gameSettingsService = ( $log, $localStorage, GAME_TYPES, LEVELS ) ->
	new class GameSettings
		#	@constructor: Sets up all of the variables to be used
		#-------------------------------------------------------------------
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

		#	@setGameType: Is the game freeplay/timed?
		#-------------------------------------------------------------------
		setGameType: ( type ) ->
			if GAME_TYPES.options.indexOf( type ) >= 0
				@gameType = type

			return @gameType

		#	@setDifficulty: How difficult is the game going to be?
		#-------------------------------------------------------------------
		setDifficulty: ( level ) ->
			# Make sure that it's a valid difficulty
			if LEVELS[ level?.toUpperCase() ]?
				@difficulty = level.toLowerCase()

			$localStorage.difficulty = @difficulty

			return @difficulty

		#	@setAllowSounds: Set the allowed sounds to a either true/false
		#-------------------------------------------------------------------
		setAllowSounds: (bool) ->
			@allowSounds = bool
			$localStorage.allowSounds = @allowSounds

			return @allowSounds

		#	@setAllowMusic: Set the allowed music to either true/false
		#-------------------------------------------------------------------
		setAllowMusic: (bool) ->
			@allowMusic = bool
			$localStorage.allowMusic = @allowMusic

			return @allowMusic

		#	@toggle: Alias to toggle the sounds/music
		#-------------------------------------------------------------------
		toggle: ( type ) ->
			if type is 'sounds'
				return @toggleAllowSounds()
			else if type is 'music'
				return @toggleAllowMusic()

		#	@toggleAllowSounds
		#-------------------------------------------------------------------
		toggleAllowSounds: ->
			return @setAllowSounds( !@allowSounds )

		#	@toggleAllowMusic
		#-------------------------------------------------------------------
		toggleAllowMusic: ->
			return @setAllowMusic( !@allowMusic )

		#	@getGameType
		#-------------------------------------------------------------------
		getGameType: -> return @gameType

		#	@getDifficulty
		#-------------------------------------------------------------------
		getDifficulty: -> return @difficulty

		#	@getAllowSounds
		#-------------------------------------------------------------------
		getAllowSounds: -> return @allowSounds

		#	@getAllowMusic
		#-------------------------------------------------------------------
		getAllowMusic: -> return @allowMusic


gameSettingsService.$inject = $requires
module.exports = gameSettingsService
