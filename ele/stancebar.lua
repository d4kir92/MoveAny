
local AddOnName, MoveAny = ...

local btnsize = 30

function MoveAny:GetStanceBarCount()
	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS or 0
	end
	return cou or 0
end

function MoveAny:UpdateStanceBar()
	if  _G["StanceButton" .. 1] then
		btnsize =  _G["StanceButton" .. 1]:GetSize()
	end

	local cou = MoveAny:GetStanceBarCount()
	if StanceBar and cou then
		if StanceBar.cou ~= cou then
			StanceBar.cou = cou

			StanceBar.btns = {}
			
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
							bb:SetParent( StanceBar )
						end

						tinsert( StanceBar.btns, bb )
					end
				end
			end

			StanceBar:SetSize( cou * btnsize, btnsize )

			if MoveAny.UpdateActionBar then
				MoveAny:UpdateActionBar( StanceBar )
			end
		end
	end

	C_Timer.After( 1, MoveAny.UpdateStanceBar )
end

function MoveAny:InitStanceBar()
	if not StanceBar then
		StanceBar = CreateFrame( "Frame", "StanceBar", UIParent )
		StanceBar:SetSize( btnsize, btnsize )
		StanceBar:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 120 )
		StanceBar.cou = -1
		StanceBar.btns = {}
	end

	if MoveAny:IsEnabled( "STANCEBAR", false ) then
		if StanceBar then
			StanceBar.btns = {}
			local cou = MoveAny:GetStanceBarCount()
			if StanceBar.actionButtons then
				for i, v in pairs( StanceBar.actionButtons ) do
					if i <= cou then
						tinsert( StanceBar.btns, v )
					end
				end
			else
				MoveAny:UpdateStanceBar()
			end
		end
	end
end
