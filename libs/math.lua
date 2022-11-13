
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

function MAGrid( n, snap )
	n = n or 0
	snap = snap or MoveAny:GetGridSize()

	local mod = n % snap
	if mod > ( snap / 2 ) then
		return n - mod + snap
	else
		return n - mod
	end
end
