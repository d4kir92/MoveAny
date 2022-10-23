
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
			"CharacterBag0Slot",
			"MainMenuBarBackpackButton"
		}
		if KeyRingButton ~= nil then
			tinsert( BAGS, 1, "KeyRingButton" )
		end

		local sw, sh = CharacterBag0Slot:GetSize()
		local mbc = #BAGS
		local bagsw = sw * mbc
		if mbc > 5 then
			bagsw = bagsw - sw / 2
		end
		
		MABagBar = CreateFrame( "Frame", "MABagBar", UIParent )
		MABagBar:SetSize( bagsw, sh )
		if MicroButtonAndBagsBar then
			MABagBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		elseif MABUILD ~= "RETAIL" then
			MABagBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		else
			MABagBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end

		MainMenuBarBackpackButtonNormalTexture:Hide()
		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]
			if mbname == "KeyRingButton" then
				bb:SetSize( sw / 2, sh )
			else
				bb:SetSize( sw, sh )
			end
			bb:ClearAllPoints()
			bb:SetParent( MABagBar )
			if mbname == "KeyRingButton" then
				bb:SetPoint( "TOPLEFT", MABagBar, "TOPLEFT", 0, 0 )
			elseif mbc > 5 then
				bb:SetPoint( "TOPLEFT", MABagBar, "TOPLEFT", sw / 2 + (i - 2) * sw, 0 )
			else
				bb:SetPoint( "TOPLEFT", MABagBar, "TOPLEFT", (i - 1) * sw, 0 )
			end

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
