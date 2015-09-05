'use strict'

app.constant 'LEVELS', {
	DEV: {
		min: 3,
		max: 3
	}
	EASY: {
		min: 5,
		max: 8
	}
	MEDIUM: {
		min: 9,
		max: 13
	}
	HARD: {
		min: 14,
		max: 18
	}
}

app.constant 'HEXCOLORS', {
	white: '#FFFFFF'
	red: '#FF5252'
	blue: '#4B9CFF'
	green: '#8BCA22'
	yellow: '#E5D235'
}

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

boardConsts =
	SIZE: 5
	DIMENSIONS: {}
	MARGIN: {}

shapeConsts =
	SIZE: 16
	MARGIN: 30

boardConsts.MARGIN.top = shapeConsts.MARGIN
boardConsts.MARGIN.left = shapeConsts.MARGIN
shapeConsts.OUTERSIZE = shapeConsts.SIZE + shapeConsts.MARGIN

maxBoardSize = boardConsts.SIZE * shapeConsts.OUTERSIZE
boardConsts.DIMENSIONS.w = maxBoardSize + boardConsts.MARGIN.left
boardConsts.DIMENSIONS.h = maxBoardSize + boardConsts.MARGIN.top

app.constant 'BOARD', boardConsts
app.constant 'SHAPE', shapeConsts
