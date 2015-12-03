'use script'

app.filter 'ordinal', () ->
	return ( number ) ->
		ordinal = switch
			when number is 1 then 'st'
			when number is 2 then 'nd'
			when number is 3 then 'rd'
			else 'th'

		return number + ordinal
