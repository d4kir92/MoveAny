local _, MoveAny = ...
local config_update = 1

function MoveAny:InitMAFPSFrame()
	if MoveAny:IsEnabled("MAFPSFrame", false) then
		MAFPSFrame = CreateFrame("Frame", "MAFPSFrame", MoveAny:GetMainPanel())
		MAFPSFrame:SetSize(100, 20)
		MAFPSFrame:SetPoint("TOPLEFT", MoveAny:GetMainPanel(), "TOPLEFT", 0, 0)
		MAFPSFrame.fps = MAFPSFrame:CreateFontString("MAFPSFrame.fps", "BACKGROUND")
		MAFPSFrame.fps:SetPoint("CENTER", MAFPSFrame, "CENTER", 0, 0)
		MAFPSFrame.fps:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")

		function MAFPSThink()
			MAFPSFrame.fps:SetText(format("|cff3FC7EBFPS|r: %4d", GetFramerate()))
			C_Timer.After(config_update, MAFPSThink)
		end

		MAFPSThink()
	end
end