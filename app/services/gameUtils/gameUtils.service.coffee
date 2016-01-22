'use strict'

#===============================================================================
#
#	Game Utils
# 		General utilities to be used by the game drawer & manger
#
#-------------------------------------------------------------------------------

$requires = [
	'$log'
	'BOARD'
	'SHAPE'
	'ALPHABET'
]

gameUtils = ( $log, BOARD, SHAPE, ALPHABET ) ->
	utils =
		#	@convertGameToStr
		# 		Convert the game data to a string
		#-------------------------------------------------------------------
		convertGameToStr: ( gameboard ) ->
			goalStr = gameboard.endNodes.reduce((prev, curr, idx, array) ->
  				prevNodeStr = utils.convertNodeToStr( prev, true )
  				currNodeStr = utils.convertNodeToStr( curr, true )

  				return prevNodeStr + ':' + currNodeStr
			)

			boardArr = []
			gameboard.board.forEach(( row, index ) ->
				row.forEach(( node ) ->
					boardArr.push( utils.convertNodeToStr(node) )
				)
			)

			gameStr = goalStr + ':' + gameboard.maxMoves + ':' + boardArr.join('')

			# console.log( gameStr, gameboard )

			return window.btoa( gameStr );

		#	@convertStrToGame
		# 		Convert string to game data
		#-------------------------------------------------------------------
		convertStrToGame: ( encodedStr ) ->
			gameStr = window.atob( encodedStr )

			game =
				maxMoves: 0,
				endNodes: [],
				board: []

			[startNodeStr, endNodeStr, movesStr, boardStr] = gameStr.split(':')

			game.maxMoves = parseInt( movesStr, 10 )

			game.endNodes.push( utils.convertStrToNode( startNodeStr ) )
			game.endNodes.push( utils.convertStrToNode( endNodeStr ) )

			flatBoardArr = boardStr.split('')
			gridSize = Math.sqrt( flatBoardArr.length )

			flatBoardArr.forEach(( nodeStr, i ) ->
				x =  Math.floor(i / gridSize)
				y = (i % gridSize)

				if !game.board[x]?
					game.board[x] = []

				game.board[x][y] = utils.convertStrToNode( nodeStr )
				game.board[x][y].coords = {x, y}
			)

			# console.log( gameStr, game )

			return game

		#	@convertNodeToStr
		#-------------------------------------------------------------------
		convertNodeToStr: ( node, includeCoords = false ) ->
			colorIdx = SHAPE.COLORS.indexOf(node.color)
			typeIdx = SHAPE.TYPES.indexOf(node.type)

			alphaIdx = (colorIdx * SHAPE.COLORS.length) + typeIdx
			nodeStr = ALPHABET[alphaIdx]

			if includeCoords
				coords = node.coords.x + '' + node.coords.y
				nodeStr += coords

			return nodeStr

		#	@convertStrToNode
		#-------------------------------------------------------------------
		convertStrToNode: ( nodeStr ) ->
			node =
				color: ''
				type: ''
				coords: {}

			[nodeAlpha, nodeX, nodeY] = nodeStr.split('')

			alphaIdx = ALPHABET.indexOf(nodeAlpha)
			totalColors = SHAPE.COLORS.length

			nodeColorIdx = Math.floor(alphaIdx / totalColors)
			nodeTypeIdx = (alphaIdx % totalColors)

			node.color = SHAPE.COLORS[nodeColorIdx]
			node.type = SHAPE.TYPES[nodeTypeIdx]

			if nodeX? and nodeY?
				node.coords =
					x: parseInt(nodeX, 10)
					y: parseInt(nodeY, 10)

			return node

		#	@calcBoardX
		# 		With a given canvas X coord get the X column of the board
		#-------------------------------------------------------------------
		calcBoardX: ( canvasX ) ->
			return Math.round((canvasX - BOARD.MARGIN.left) / SHAPE.OUTERSIZE)

		#	@calcBoardY
		# 		With a given canvas Y coord get the Y row of the board
		#-------------------------------------------------------------------
		calcBoardY: ( canvasY ) ->
			return Math.round((canvasY - BOARD.MARGIN.top) / SHAPE.OUTERSIZE)

		#	@calcCanvasX
		# 		With a given X column of the board get the canvas X coord
		#-------------------------------------------------------------------
		calcCanvasX: ( boardX ) ->
			return (boardX * SHAPE.OUTERSIZE) + BOARD.MARGIN.left

		#	@calcCanvasY
		# 		With a given Y row of the board get the canvas Y coord
		#-------------------------------------------------------------------
		calcCanvasY: ( boardY ) ->
			return (boardY * SHAPE.OUTERSIZE) + BOARD.MARGIN.top

		#	@calcShapeMinTrigger
		# 		Figure out the min coord to trigger a shape selection
		#-------------------------------------------------------------------
		calcShapeMinTrigger: ( canvasPoint ) ->
			return canvasPoint - (SHAPE.MARGIN / 2)

		#	@calcShapeMaxTrigger
		# 		Figure out the max coord to trigger a shape selection
		#-------------------------------------------------------------------
		calcShapeMaxTrigger: ( canvasPoint ) ->
			return canvasPoint + SHAPE.SIZE + (SHAPE.MARGIN / 2)

		#	@isValidBoardAxis
		# 		Check if a given X or Y coord is a valid board option
		#-------------------------------------------------------------------
		isValidBoardAxis: ( boardAxis ) ->
			return 0 <= boardAxis < BOARD.SIZE

		#	@isSameNode
		# 		Check if two nodes share the same coords
		#-------------------------------------------------------------------
		isSameNode: (nodeA, nodeB) ->
			return false if not nodeA? or not nodeB?

			isSameX = nodeA.coords.x is nodeB.coords.x
			isSameY = nodeA.coords.y is nodeB.coords.y

			return isSameX and isSameY

		#	@isSameShape
		# 		Check if two nodes are the same type + color shape
		#-------------------------------------------------------------------
		isSameShape: (nodeA, nodeB) ->
			return false if not nodeA? or not nodeB?

			isSameColor = nodeA.color is nodeB.color
			isSameType = nodeA.type is nodeB.type

			return isSameColor and isSameType

		#	@findNode
		# 		Based on a canvas x and y position find the node that is
		# 		at this point
		#-------------------------------------------------------------------
		findNode: ( board, pos ) ->
			# Get the x and y coords of the board at this canvas position
			boardX = @calcBoardX(pos.x)
			boardY = @calcBoardY(pos.y)

			# Validate that these are allowable board coords
			isValidBoardX = @isValidBoardAxis(boardX)
			isValidBoardY = @isValidBoardAxis(boardY)

			return if not isValidBoardX or not isValidBoardY

			# console.log( board[boardX], board[boardX][boardY])

			return board[boardX]?[boardY]

		#	@getNeighborNodes
		# 		Get all the nodes surrounding this one
		#-------------------------------------------------------------------
		getNeighborNodes: ( board, node, checks ) ->
			nodeX = node.coords.x
			nodeY = node.coords.y

			neighbors = []
			potentials = [
				[nodeX + 1, nodeY]
				[nodeX + 1, nodeY + 1]
				[nodeX + 1, nodeY - 1]
				[nodeX, nodeY + 1]
				[nodeX, nodeY - 1]
				[nodeX - 1, nodeY]
				[nodeX - 1, nodeY + 1]
				[nodeX - 1, nodeY - 1]
			]

			potentialIdx = 0
			while potentialIdx < potentials.length
				# Get the x and y coors of this potential move
				potNode = potentials[ potentialIdx ]
				[potX, potY] = potNode

				# Check if the x and y coords are valid
				isValidX = @isValidBoardAxis( potX )
				isValidY = @isValidBoardAxis( potY )

				if isValidX and isValidY
					neighborNode = board[potX]?[potY]

					if neighborNode?
						if checks?
							if checks.selected? and neighborNode.selected is checks.selected
								neighbors.push( neighborNode )
						else
							neighbors.push( neighborNode )

				potentialIdx += 1

			return neighbors

		isValidNextMove: ( parentNode, node ) ->
			return false if !parentNode? or parentNode.selected is false

			# Check that the node this move is closest to is one that we're
			# allowed to move to (up, down, left, or right only)
			dx = Math.abs(parentNode.coords.x - node.coords.x)
			dy = Math.abs(parentNode.coords.y - node.coords.y)
			isValidDirection = (dx + dy) is 1
			return false if not isValidDirection

			# Check that the node we're closest to is either the same color
			# or the same type as the parent node
			sameColor = parentNode.color == node.color
			sameType = parentNode.type == node.type
			isValidMove = isValidDirection and (sameColor or sameType)

			return isValidMove



	return utils


gameUtils.$inject = $requires
module.exports = gameUtils
