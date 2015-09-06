'use strict'

#===============================================================================
#
#	Assets Service
# 		Loads the sound assets needed for the game
#		http://blog.sklambert.com/html5-game-tutorial-game-ui-canvas-vs-dom/
#
#-------------------------------------------------------------------------------

app.service 'assetsService', [
	'$log'
	($log) ->
		return new class AssetLoader
			# @constructor: Setup the file paths & initalise vars
			#-------------------------------------------------------------------
			constructor: ->
				@sounds =
					addedNode: '/assets/sound/newconnection6.wav'
					removedNode: '/assets/sound/undoconnection2.wav'
					badMove: '/assets/sound/badmove.wav'
					gameOver: '/assets/sound/gameWon.wav'
					# gameOver: '/assets/sound/newconnection3.wav'

				@assetsLoaded = 0
				@totalSounds = Object.keys(@sounds).length
				@totalAssests = parseInt(@totalSounds, 10)

			# @onComplete: Callback for when ALL assets have finished loaded
			#-------------------------------------------------------------------
			onComplete: ( cb ) ->
				cb?()
				return

			# @assetLoaded
			# 	Check if an asset has finished loaded. After all assets are
			# 	loaded call @onComplete
			#-------------------------------------------------------------------
			assetLoaded: (dict, name) ->
				asset = @[dict][name]

				# don't count assets that have already loaded
				return if asset.status != 'loading'

				asset.status = 'loaded'
				@assetsLoaded += 1

				# finished callback
				@onComplete?() if @assetsLoaded == @totalAssests

			# @checkAudioState: Check if an audio asset has been downloaded
			#-------------------------------------------------------------------
			checkAudioState: ( sound ) =>
				thisSound = @sounds[sound]
				if thisSound.status is 'loading' and thisSound.readyState == 4
					@assetLoaded('sounds', sound)

			# @downloadAll: Download the sound assets (only if we haven't already)
			#-------------------------------------------------------------------
			downloadAll: ->
				if @assetsLoaded == @totalAssests
					@onComplete?()
				else
					@downloadSounds()

			# @downlonadSounds: For each of the sound files convert to an
			# Audio element and donwload
			#-------------------------------------------------------------------
			downloadSounds: =>
				$.each(@sounds, (sound, src) =>
					@sounds[sound] = new Audio()
					@sounds[sound].status = 'loading'
					@sounds[sound].name = sound

					@sounds[sound].addEventListener('canplay', =>
						@checkAudioState( sound )
					)

					@sounds[sound].src = src
					@sounds[sound].preload = 'auto'
					@sounds[sound].load()
				)

				return
]


