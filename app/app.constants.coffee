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
		label: 'Dev Mode'
		min: 3,
		max: 3,
		timer: 4
	}
	EASY: {
		label: 'Beginner'
		min: 4,
		max: 7,
		timer: 60
	}
	MEDIUM: {
		label: 'Intermediate'
		min: 8,
		max: 11,
		timer: 45
	}
	HARD: {
		label: 'Advanced'
		min: 12,
		max: 14,
		timer: 30
	}
	INSANE: {
		label: 'Master'
		min: 15,
		max: 17,
		timer: 15
	}

gameLevels.DEFAULT = {name: 'easy', info: gameLevels.EASY}

app.constant 'LEVELS', gameLevels

tutorialSteps =
	total: 4
	1: {
		header1: 'Connect two similar shapes'
		header2: 'Try it yourself'
		headerPosition: 'top'
		showGoal: false
		random: false
		shapes: [
			{color: 'yellow', type: 'triangle'}
			{color: 'green', type: 'triangle'}
		]
	},
	2: {
		header1: 'You can also connect the same colors'
		headerPosition: 'top'
		showGoal: false
		random: false
		shapes: [
			{color: 'red', type: 'diamond'}
			{color: 'red', type: 'circle'}
		]
	},
	3: {
		header1: 'Next connect the #{startNode} to a #{endNode}'
		header2: 'You cannot move at a diagonal.'
		headerPosition: 'top'
		showGoal: true
		showMovesLeft: false
		makeUnique: true
		random: true
		boardSize: 2
		pathSize: 3
	}
	4: {
		header1: 'Now connect a #{startNode} to a #{endNode} in exactly 3 moves'
		headerPosition: 'bottom'
		showGoal: true
		showMovesLeft: true
		makeUnique: true
		random: true
		boardSize: 4
		pathSize: 4
	}

app.constant 'TUTORIAL_STEPS', tutorialSteps

app.constant 'GAME_TYPES', {
	options: ['freeplay', 'timed']
	default: 'freeplay'
}


# Hex Colors: Hex versions of the colors used
#-------------------------------------------------------------------------------
app.constant 'HEXCOLORS', {
	white: '#FFFFFF'
	red: '#FF5252'
	blue: '#4B9CFF'
	green: '#8BCA22'
	yellow: '#E5D235'
	teal: '#8AE8B2'
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
