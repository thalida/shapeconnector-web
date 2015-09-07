'use strict'

#===============================================================================
#
#	Game Dict: General game constants
#
#-------------------------------------------------------------------------------


# Levels: Game level min + max # of nodes and total time allowed
#-------------------------------------------------------------------------------
gameLevels =
	DEV: {
		min: 3,
		max: 3,
		timer: 105
	}
	EASY: {
		min: 5,
		max: 8,
		timer: 90
	}
	MEDIUM: {
		min: 9,
		max: 13,
		timer: 60
	}
	HARD: {
		min: 14,
		max: 18,
		timer: 60
	}

gameLevels.DEFAULT = {name: 'easy', info: gameLevels.EASY}

app.constant 'LEVELS', gameLevels


# Hex Colors: Hex versions of the colors used
#-------------------------------------------------------------------------------
app.constant 'HEXCOLORS', {
	white: '#FFFFFF'
	red: '#FF5252'
	blue: '#4B9CFF'
	green: '#8BCA22'
	yellow: '#E5D235'
}


# Shapes: The allowed colors + types for the game boards nodes
#-------------------------------------------------------------------------------
app.constant 'SHAPES', {
	COLORS: [
		'red'
		'blue'
		'green'
		'yellow'
	]
	TYPES: [
		'square'
		'circle'
		'diamond'
		'triangle'
	]
}


# Board & Shape: The dimensions of the game board and shapes
#-------------------------------------------------------------------------------
boardConsts =
	SIZE: 5 # game board grid size - n x n
	DIMENSIONS: {} # only width & height dimensions
	MARGIN: {} # only the top & left margins

shapeConsts = {}
shapeConsts.SIZE = 18 # size in px for each node
shapeConsts.MARGIN = shapeConsts.SIZE * 2 # padding around each shape
shapeConsts.BORDER = 2

# Give the board top + left margins that match the shape margins
boardConsts.MARGIN.top = shapeConsts.MARGIN
boardConsts.MARGIN.left = shapeConsts.MARGIN

shapeConsts.OUTERSIZE = shapeConsts.SIZE + shapeConsts.MARGIN

# Calculate the total width + height of the game board
boardSize = boardConsts.SIZE * shapeConsts.OUTERSIZE
boardConsts.DIMENSIONS.w = boardSize + boardConsts.MARGIN.left
boardConsts.DIMENSIONS.h = boardSize + boardConsts.MARGIN.top

app.constant 'BOARD', boardConsts
app.constant 'SHAPE', shapeConsts
