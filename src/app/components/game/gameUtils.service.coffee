'use strict'

#===============================================================================
#
#	Game Utils
# 		General utilities to be used by the game drawer & manger
#
#-------------------------------------------------------------------------------

app.service 'gameUtils', [
	'$log'
	'BOARD'
	'SHAPE'
	( $log, BOARD, SHAPE ) ->
		utils =
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

				return board[boardX][boardY]

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
						neighborNode = board[potX][potY]

						if checks?
							if checks.selected? and neighborNode.selected is checks.selected
								neighbors.push( neighborNode )
						else
							neighbors.push( neighborNode )

					potentialIdx += 1

				return neighbors

		return utils
]
