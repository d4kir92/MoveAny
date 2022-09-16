
local AddOnName, MoveAny = ...

function MoveAny:InitMicroMenu()
	if MoveAny:IsEnabled( "MICROMENU", true ) then
		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		local sw, sh = CharacterMicroButton:GetSize()
		if MABUILD ~= "RETAIL" then
			sh = sh - 21
		end
		local mbc = 11
		if MICRO_BUTTONS then
			mbc = #MICRO_BUTTONS
		end

		MAMenuBar = CreateFrame( "Frame", "MAMenuBar", UIParent )
		MAMenuBar:SetSize( (sw - 4) * mbc, sh - 4 )
		if MicroButtonAndBagsBar then
			local p1, p2, p3, p4, p5 = MicroButtonAndBagsBar:GetPoint()
			MAMenuBar:SetPoint( p1, UIParent, p3, p4, p5 )
		elseif MABUILD ~= "RETAIL" then
			MAMenuBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0 )
		else
			MAMenuBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end

		if MICRO_BUTTONS then
			for i, mbname in pairs( MICRO_BUTTONS ) do
				local mb = _G[mbname] 
				hooksecurefunc( mb, "SetPoint", function( self, ... )
					if self.masetpoint then return end
					self.masetpoint = true
					mb:ClearAllPoints()
					mb:SetParent( MAMenuBar )
					mb:SetPoint( "TOPLEFT", MAMenuBar, "TOPLEFT", (i - 1) * (sw - 4) - 2, 2 )
					if MABUILD ~= "RETAIL" then
						mb:SetPoint( "TOPLEFT", MAMenuBar, "TOPLEFT", (i - 1) * (sw - 4) - 2, 2 + 21 )
					end
					self.masetpoint = false
				end )
				hooksecurefunc( mb, "SetParent", function( self, ... )
					if self.masetparent then return end
					self.masetparent = true
					mb:SetParent( MAMenuBar )
					self.masetparent = false
				end )
				mb:ClearAllPoints()
				mb:SetParent( MAMenuBar )
				mb:SetPoint( "TOPLEFT", MAMenuBar, "TOPLEFT", (i - 1) * (sw - 4) - 2, 2 )
				if MABUILD ~= "RETAIL" then
					mb:SetPoint( "TOPLEFT", MAMenuBar, "TOPLEFT", (i - 1) * (sw - 4) - 2, 2 + 21 )
				end

				hooksecurefunc( mb, "Hide", function( self )
					mb:Show()
				end )
				hooksecurefunc( mb, "SetAlpha", function( self, alpha )
					if alpha <= 0 then
						self:SetAlpha( 1 )
					end
				end )
				mb:Show()
			end
		end
	end
end
