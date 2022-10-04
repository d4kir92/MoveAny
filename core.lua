
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

SLASH_MOVEANY1 = "/moveany"
SlashCmdList["MOVEANY"] = function(msg)
	MoveAny:ToggleMALock()
end

MADragFrames = MADragFrames or {}

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

function MoveAny:ShowMALock()
	if MoveAny:IsEnabled( "MALOCK", false ) then
		for i, df in pairs( MADragFrames ) do
			df:EnableMouse( true )
			df:SetAlpha( 1 )
		end
		if MALock then
			MALock:Show()
			MAGridFrame:Show()
		end
	end
end

function MoveAny:HideMALock()
	if not MoveAny:IsEnabled( "MALOCK", false ) then
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

function MoveAny:ToggleMALock()
	MoveAny:SetEnabled( "MALOCK", not MoveAny:IsEnabled( "MALOCK", false ) )
	if MoveAny:IsEnabled( "MALOCK", false ) then
		MoveAny:ShowMALock()
	else
		MoveAny:HideMALock()
	end
end

local f = CreateFrame( "Frame" )
f.incombat = false 

f:SetScript( "OnUpdate", function()
	if MoveAny:IsEnabled( "MALOCK", false ) and InCombatLockdown() then
		f.incombat = true
		MoveAny:ToggleMALock()
	elseif f.incombat and not InCombatLockdown() then
		f.incombat = false
		MoveAny:ToggleMALock()
	end
end )
