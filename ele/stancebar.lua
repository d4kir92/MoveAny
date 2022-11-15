
local AddOnName, MoveAny = ...

local btnsize = 30

function MoveAny:UpdateStanceBar()
	if  _G["StanceButton" .. 1] then
		btnsize =  _G["StanceButton" .. 1]:GetSize()
	end

	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS
	end

	if MAStanceBar and cou then
		if MAStanceBar.cou ~= cou then
			MAStanceBar.cou = cou

			MAStanceBar.btns = {}
			
			if cou ~= 10 then
				for i = 1, cou do
					local bb = _G["StanceButton" .. i]
					if bb then
						if bb.setup == nil then
							bb.setup = true

							bb:SetSize( btnsize, btnsize )
							bb:SetMovable( true )
							if bb.SetUserPlaced and bb:IsMovable() then
								bb:SetUserPlaced( false )
							end
							bb:SetParent( MAStanceBar )
						end

						tinsert( MAStanceBar.btns, bb )
					end
				end
			end
			MAStanceBar:SetSize( cou * btnsize, btnsize )

			MAUpdateActionBar( MAStanceBar )
		end
	end

	C_Timer.After( 1, MoveAny.UpdateStanceBar )
end

function MoveAny:InitStanceBar()
	if MoveAny:IsEnabled( "STANCEBAR", false ) then
		if not InCombatLockdown() then
			MAStanceBar = CreateFrame( "Frame", "MAStanceBar", UIParent )
			MAStanceBar:SetSize( btnsize, btnsize )
			MAStanceBar.cou = -1
			MAStanceBar.btns = {}

			local p1, _, p3, p4, p5 = MoveAny:GetElePoint( "MAStanceBar" )
			if p1 then
				MAStanceBar:ClearAllPoints()
				MAStanceBar:SetPoint( p1, UIParent, p3, p4, p5 )
			else
				MAStanceBar:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 75 )
			end

			MoveAny:UpdateStanceBar()
		else
			C_Timer.After( 0.1, MoveAny.InitStanceBar )
		end
	end
end
