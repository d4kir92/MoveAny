
local AddOnName, MoveAny = ...

function MoveAny:InitBags()
	if MoveAny:IsEnabled( "BAGS", true ) then
		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end
		
		local BAGS = {
			"CharacterBag3Slot",
			"CharacterBag2Slot",
			"CharacterBag1Slot",
			"CharacterBag0Slot"
		}

		if CharacterReagentBag0Slot ~= nil then
			tinsert( BAGS, 1, "CharacterReagentBag0Slot" )
		end
		if KeyRingButton ~= nil then
			tinsert( BAGS, 1, "KeyRingButton" )
		end
		if BagBarExpandToggle ~= nil then
			tinsert( BAGS, "BagBarExpandToggle" )
		end
		if MainMenuBarBackpackButton ~= nil then
			tinsert( BAGS, "MainMenuBarBackpackButton" )
		end

		local sw, sh = 0, 0
		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]
			if bb then
				local w, h = bb:GetSize()
				sw = sw + w
				if h > sh then
					sh = h
				end
			end
		end

		MABagBar = CreateFrame( "Frame", "MABagBar", UIParent )
		MABagBar:SetSize( sw, sh )
		if MicroButtonAndBagsBar then
			MABagBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		elseif MABUILD ~= "RETAIL" then
			MABagBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		else
			MABagBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end

		if MABUILD ~= "RETAIL" then
			MainMenuBarBackpackButtonNormalTexture:Hide()
		end
		local x = 0
		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]

			local w, h = bb:GetSize()
			bb:ClearAllPoints()
			bb:SetParent( MABagBar )
			bb:SetPoint( "TOPLEFT", MABagBar, "TOPLEFT", x, -(sh / 2 - h / 2) )
			x = x + w

			if MABUILD ~= "RETAIL" then
				hooksecurefunc( bb, "Hide", function( self )
					if self.mashow then return end
					self.mashow = true
					self:Show()
					self.mashow = false
				end )
				bb:Show()

				local border = _G[mbname .. "NormalTexture"]
				if border then
					hooksecurefunc( border, "Show", function( self )
						self:Hide()
					end )
					border:Hide()

					hooksecurefunc( border, "SetAlpha", function( self, alpha )
						if self.iasetalpha then return end
						self.iasetalpha = true
						self:SetAlpha( 0 )
						self.iasetalpha = false							
					end )
					border:SetAlpha( 0 )
				end
			end
		end
	end
end
