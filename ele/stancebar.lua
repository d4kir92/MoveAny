
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

						if bb.setup == nil then
							bb.setup = true

							hooksecurefunc( bb, "SetPoint", function( self, ... )
								if self.masetpoint then return end
								self.masetpoint = true
								
								self:SetMovable( true )
								if self.SetUserPlaced then
									self:SetUserPlaced( false )
								end

								bb:SetParent( MAStanceBar )
								bb:ClearAllPoints()
								bb:SetPoint( "TOPLEFT", MAStanceBar, "TOPLEFT", (i - 1) * btnsize, 0 )
								self.masetpoint = false
							end )
							bb:SetPoint( "CENTER" )
						end
					end
				end
			end
			MAStanceBar:SetSize( cou * btnsize, btnsize )
		end
	end

	C_Timer.After( 1, MoveAny.UpdateStanceBar )
end

function MoveAny:InitStanceBar()
	if MoveAny:IsEnabled( "STANCEBAR", true ) then
		MAStanceBar = CreateFrame( "Frame", "MAStanceBar", UIParent )
		MAStanceBar:SetSize( btnsize, btnsize )
		MAStanceBar.cou = -1

		local p1, p2, p3, p4, p5 = MoveAny:GetElePoint( "MAStanceBar" )
		if p1 then
			MAStanceBar:ClearAllPoints()
			MAStanceBar:SetPoint( p1, UIParent, p3, p4, p5 )
		else
			MAStanceBar:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 75 )
		end

		MoveAny:UpdateStanceBar()
	end
end
