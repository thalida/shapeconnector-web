'use strict'

#===============================================================================
#
#	Assets Service
# 		Loads the sound assets needed for the game
#		http://blog.sklambert.com/html5-game-tutorial-game-ui-canvas-vs-dom/
#
#-------------------------------------------------------------------------------


# Get a collection of the assets for the game
assetsSrc = {}
assetsSrc.addedNode = require '../../assets/sound/add2.wav'
assetsSrc.removedNode = require '../../assets/sound/undo3.wav'
assetsSrc.gameWon = require '../../assets/sound/win1.wav'
assetsSrc.gameLost = require '../../assets/sound/lose1.wav'
assetsSrc.badMove = require '../../assets/sound/bad2.wav'
assetsSrc.background = require '../../assets/sound/carefree.mp3'


$requires = [
	'$log'
	'$q'

	require '../gameSettings'
]

assets = ($log, $q, gameSettings) ->
	new class AssetLoader
		# @constructor: Setup the file paths & initalise vars
		#-----------------------------------------------------------------------
		constructor: ->
			@sounds = assetsSrc
			@assetsLoaded = 0
			@totalSounds = Object.keys(@sounds).length
			@totalAssests = parseInt(@totalSounds, 10)

		# @checkAudioState: Check if an audio asset has been downloaded
		#-----------------------------------------------------------------------
		checkAudioState: ( sound ) =>
			thisSound = @sounds[sound]
			return if !thisSound?
			if thisSound.status is 'loading' and thisSound.readyState == 4
				thisSound.status = 'loaded'

			return thisSound

		# @downloadAll: Download the sound assets (only if we haven't already)
		#-----------------------------------------------------------------------
		downloadAll: ->
			return @downloadSounds()

		# @downlonadSounds: For each of the sound files convert to an
		# Audio element and donwload
		#-----------------------------------------------------------------------
		downloadSounds: =>
			deferred = $q.defer()

			if @assetsLoaded >= @totalAssests
				deferred.resolve()
			else
				angular.forEach(@sounds, (src, sound) =>
					if typeof src is 'string'
						@sounds[sound] = new Audio()
						@sounds[sound].status = 'loading'
						@sounds[sound].name = sound

						@sounds[sound].addEventListener('canplay', =>
							sound = @checkAudioState( sound )
							if sound?.status is 'loaded'
								@assetsLoaded += 1

							if @assetsLoaded >= @totalAssests
								deferred.resolve()
						)

						@sounds[sound].src = src
						@sounds[sound].preload = 'auto'
						@sounds[sound].load()
					else
						@assetsLoaded += 1
						if @assetsLoaded >= @totalAssests
							deferred.resolve()
				)

			return deferred.promise

		# @playSound: Start playing the sound (if allowed)
		#-----------------------------------------------------------------------
		playSound: ( name ) =>
			sound = @sounds[name]
			return if !sound?

			if name is 'background'
				return if gameSettings.getAllowMusic() is off
				sound.currentTime = 0
				sound.volume = 0.2
				if typeof sound.loop is 'boolean'
					sound.loop = true
				else
					sound.addEventListener('ended', () ->
						sound.currentTime = 0
						sound.play()
					, false)

				sound.play()
			else
				return if gameSettings.getAllowSounds() is off

				if name isnt 'badMove'
					sound.currentTime = 0

				sound.play?()
			return

		# @pauseSound: Pause the sound
		#-----------------------------------------------------------------------
		pauseSound: ( name ) =>
			sound = @sounds[name]
			return if !sound?

			sound.pause?()


assets.$inject = $requires
module.exports = assets
