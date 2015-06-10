'use strict'

app.controller 'GameCtrl', [
	'$log'
	'$scope'
	'$compile'
	($log, $scope, $compile) ->
		$gamePlaceholder = $('.game-placeholder')
		gameScope = null
		gameDirective = """
						<app:game difficulty='dev' source-game="game" on-new-game='createNewGame(params)' on-reset-game='resetGame(params)'></app:game>
						"""

		# $scope.$storage = $localstorage

		$scope.compileGame = () ->
			gameScope = $scope.$new()
			compiledDirective = $compile(gameDirective)
			directiveElement = compiledDirective(gameScope)
			$gamePlaceholder.append(directiveElement)
			return

		$scope.destoryGame = () ->
			gameScope?.$destroy()
			$gamePlaceholder.empty()
			return

		$scope.rebuildGame = () ->
			$scope.destoryGame()
			$scope.compileGame()

		$scope.createNewGame = () ->
			$scope.game = null
			$scope.rebuildGame()
			return

		$scope.resetGame = ( sourceGame ) ->
			$scope.game = sourceGame
			$scope.rebuildGame()
			return

		$scope.createNewGame()
]

