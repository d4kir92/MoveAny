
local AddOnName, MoveAny = ...

local btnsize = 36

function MoveAny:UpdatePetBar()
	if UnitExists( "pet" ) then
		MAPetBar:SetAlpha( 1 )
		for i = 1, 10 do
			local bb = _G["PetActionButton" .. i]
			if bb then
				bb:SetAlpha( 1 )
			end
		end
	else
		MAPetBar:SetAlpha( 0 )
		for i = 1, 10 do
			local bb = _G["PetActionButton" .. i]
			if bb then
				bb:SetAlpha( 0 )
			end
		end
	end

	C_Timer.After( 0.4, MoveAny.UpdatePetBar )
end

function MoveAny:InitPetBar()
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		MAPetBar = CreateFrame( "FRAME", "MAPetBar", UIParent )
		MAPetBar:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 110 )

		for i = 1, 10 do
			local bb = _G["PetActionButton" .. i]
			if bb then
				bb:SetSize( btnsize, btnsize )

				hooksecurefunc( MAPetBar, "SetPoint", function( self, ... )
					bb:SetParent( PetActionBarFrame )
				end )
				bb:ClearAllPoints()
				bb:SetPoint( "TOPLEFT", MAPetBar, "TOPLEFT", (i - 1) * btnsize, 0 )
			end
		end
		MAPetBar:SetSize( 10 * btnsize, btnsize )

		MoveAny:UpdatePetBar()
	end
end
