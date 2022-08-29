
local AddOnName, MoveAny = ...

local btnsize = 36

function MoveAny:UpdateStanceBar()
	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS
	end

	if MAStanceBar and cou then
		if MAStanceBar.cou ~= cou then
			MAStanceBar.cou = cou

			if cou ~= 10 then
				for i = 1, cou do
					local bb = _G["StanceButton" .. i]
					if bb then
						bb:SetSize( btnsize, btnsize )
						bb:ClearAllPoints()
						bb:SetParent( MAStanceBar )
						bb:SetPoint( "TOPLEFT", MAStanceBar, "TOPLEFT", (i - 1) * btnsize, 0 )
						bb.Hide = bb.Show
						bb:Show()
					end
				end
			end
			MAStanceBar:SetSize( cou * btnsize, btnsize )
		end
	end

	C_Timer.After( 1, MoveAny.UpdateStanceBar )
end

function MoveAny:InitStanceBar()
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		MAStanceBar = CreateFrame( "FRAME", "MAStanceBar", UIParent )
		MAStanceBar:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 75 )
		MAStanceBar:SetSize( btnsize, btnsize )
		MAStanceBar.cou = -1

		MoveAny:UpdateStanceBar()
	end
end
