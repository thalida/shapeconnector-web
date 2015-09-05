'use strict'

app.service 'assetsService', [
	'$log'
	($log) ->
		# http://blog.sklambert.com/html5-game-tutorial-game-ui-canvas-vs-dom/
		return new class AssetLoader
			constructor: () ->
				@sounds =
					addedNode: '/assets/sound/buttonclick2.wav'
					removedNode: '/assets/sound/undoconnection.wav'
					gameOver: '/assets/sound/newconnection3.wav'

				@assetsLoaded = 0
				@totalSounds = Object.keys(@sounds).length
				@totalAssests = @totalSounds + 0

			onComplete: ( cb ) ->
				cb?()
				return

			assetLoaded: (dict, name) ->
				asset = @[dict][name]

				# don't count assets that have already loaded
				return if asset.status != 'loading'

				asset.status = 'loaded'
				@assetsLoaded += 1

				# finished callback
				@onComplete?() if @assetsLoaded == @totalAssests

			checkAudioState: ( sound ) =>
				thisSound = @sounds[sound]
				if thisSound.status is 'loading' and thisSound.readyState == 4
					@assetLoaded('sounds', sound)

			downloadAll: () ->
				if @assetsLoaded == @totalAssests
					@onComplete?()
				else
					@downloadSounds()

			downloadSounds: () =>
				$.each(@sounds, (sound, src) =>
					@sounds[sound] = new Audio()
					@sounds[sound].status = 'loading'
					@sounds[sound].name = sound

					@sounds[sound].addEventListener('canplay', () =>
						@checkAudioState( sound )
					)

					@sounds[sound].src = src
					@sounds[sound].preload = 'auto'
					@sounds[sound].load()
				)

				return
]


