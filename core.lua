
local AddOnName, MoveAny = ...

MABUILDNR = select(4, GetBuildInfo())
MABUILD = "CLASSIC"
if MABUILDNR > 90000 then
	MABUILD = "RETAIL"
elseif MABUILDNR > 29999 then
	MABUILD = "WRATH"
elseif MABUILDNR > 19999 then
	MABUILD = "TBC"
end

SLASH_RL1 = "/rl"
SlashCmdList["RL"] = function(msg)
	C_UI.Reload()
end

SLASH_MOAN1, SLASH_MOAN2 = "/moan", "/moveany"
SlashCmdList["MOAN"] = function(msg)
	MoveAny:ToggleDrag()
end

MADragFrames = MADragFrames or {}
MADrag = true

-- Colors
local colors = {}
colors["bg"] = 		{ 0.03, 0.03, 	0.03, 	1 	}
colors["el"] = 		{ 0.3, 	0.3, 	1.0, 	0.3 }
colors["hidden"] = 	{ 1.0, 	0.0, 	0.0, 	0.3 }

MAHIDDEN = CreateFrame( "Frame", "MAHIDDEN" )
MAHIDDEN:Hide()

function MoveAny:GetColor( key )
	return colors[key][1], colors[key][2], colors[key][3], colors[key][4]
end
-- Colors

function MoveAny:ToggleDrag()
	MADrag = not MADrag

	MoveAny:SetEnabled( "MALOCK", MADrag )

	if MADrag then
		for i, df in pairs( MADragFrames ) do
			df:EnableMouse( true )
			df:SetAlpha( 1 )
		end
		if MALock then
			MALock:Show()
			MAGridFrame:Show()
		end
	else
		for i, df in pairs( MADragFrames ) do
			df:EnableMouse( false )
			df:SetAlpha( 0 )
		end
		if MALock then
			MALock:Hide()
			MAGridFrame:Hide()
		end
	end
end

local f = CreateFrame( "Frame" )
f.incombat = false 

f:SetScript( "OnUpdate", function()
	if MADrag and InCombatLockdown() then
		f.incombat = true
		MoveAny:ToggleDrag()
	elseif f.incombat and not InCombatLockdown() then
		f.incombat = false
		MoveAny:ToggleDrag()
	end
end )
