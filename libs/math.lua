
local AddOnName, MoveAny = ...

function MAMathC( val, vmin, vmax )
	if val == nil then
		return 0
	end
	if vmin == nil then
		return 0
	end
	if vmax == nil then
		return 1
	end
	if val < vmin then
		return vmin
	elseif val > vmax then
		return vmax
	else
		return val
	end
end

function MAMathR( val, dec )
	val = val or 0
	dec = dec or 0
	return tonumber( string.format( "%0." .. dec .. "f", val ) )
end

function MAGrid( n )
	n = n or 0

	local mod = n % 5
	if mod > 2.5 then
		return n - mod + 5
	else
		return n - mod
	end
end
