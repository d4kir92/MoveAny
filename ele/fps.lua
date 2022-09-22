
local AddOnName, MoveAny = ...

local config_update = 1 -- in seconds

function MoveAny:InitMAFPSFrame()
	MAFPSFrame = CreateFrame( "Frame", "MAFPSFrame", UIParent )
	MAFPSFrame:SetSize( 100, 20 )
	MAFPSFrame:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", 0, 0 )
	
	MAFPSFrame.fps = MAFPSFrame:CreateFontString( "MAFPSFrame.fps", "BACKGROUND" )
	MAFPSFrame.fps:SetPoint( "CENTER", MAFPSFrame, "CENTER", 0, 0 )
	MAFPSFrame.fps:SetFont( STANDARD_TEXT_FONT, 14, "THINOUTLINE" )

	function MAFPSThink()

		MAFPSFrame.fps:SetText( format( "|cff3FC7EBFPS|r: %3d", GetFramerate() ) )
		C_Timer.After( config_update, MAFPSThink )
	end
	MAFPSThink()
end
