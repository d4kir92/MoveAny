
local AddOnName, MoveAny = ...

local BAGS = {
	"CharacterBag3Slot",
	"CharacterBag2Slot",
	"CharacterBag1Slot",
	"CharacterBag0Slot"
}

function MoveAny:BAGSTryAdd( fra, index )
	if _G[fra] == nil then
		return
	end
	if fra and not tContains( BAGS, fra ) then
		if index then
			tinsert( BAGS, index, tostring( fra ) )
		else
			tinsert( BAGS, tostring( fra ) )
		end
	end
end

function MoveAny:UpdateBags()
	MoveAny:BAGSTryAdd( "CharacterReagentBag0Slot", 1 )
	MoveAny:BAGSTryAdd( "KeyRingButton", 1 )
	MoveAny:BAGSTryAdd( "BagBarExpandToggle", #BAGS + 1 )
	MoveAny:BAGSTryAdd( "BagToggle", #BAGS )
	MoveAny:BAGSTryAdd( "MainMenuBarBackpackButton" )

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
	if MABagBar then
		MABagBar:SetSize( sw, sh )
		local x = 0
		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]
			if bb then
				local w, h = bb:GetSize()
				bb:SetParent( MABagBar )
				bb:ClearAllPoints()
				bb:SetPoint( "TOPLEFT", MABagBar, "TOPLEFT", x, -(sh / 2 - h / 2) )
				function bb:GetMAEle()
					return MABagBar
				end
				x = x + w
			end
		end
	end
end

function MoveAny:InitBags()
	if MoveAny:IsEnabled( "BAGS", true ) then
		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		MABagBar = CreateFrame( "Frame", "MABagBar", UIParent )

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

		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]

			if bb and MABUILD ~= "RETAIL" then
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

		MoveAny:UpdateBags()
	end
end
