
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
		if bb and bb:IsShown() then
			local w, h = bb:GetSize()
			
			sw = sw + w
			if h > sh then
				sh = h
			end
		end
	end
	if BagsBar then
		BagsBar:SetSize( sw, sh )

		local x = 0
		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]
			if bb and bb:IsShown()then
				local w, h = bb:GetSize()
				bb:SetParent( BagsBar )
				if bb.setup == nil then
					bb.setup = true
					hooksecurefunc( bb, "SetPoint", function( self, ... )
						if self.ma_bags_setpoint then return end
						self.ma_bags_setpoint = true
						self:ClearAllPoints()
						self:SetPoint( "TOPLEFT", BagsBar, "TOPLEFT", self.px, -(self.psh / 2 - self.ph / 2) )
						self.ma_bags_setpoint = false
					end )

					function bb:GetMAEle()
						return BagsBar
					end
				end
				bb.px = x
				bb.psh = sh
				bb.ph = h
				bb:ClearAllPoints()
				bb:SetPoint( "TOPLEFT", BagsBar, "TOPLEFT", x, -(sh / 2 - h / 2) )
				
				x = x + w
			end
		end
	end
end

function MoveAny:InitBags()
	if not BagsBar then
		BagsBar = CreateFrame( "Frame", "BagsBar", UIParent )
		BagsBar:SetSize( 100, 100 )
	end

	if MoveAny:IsEnabled( "BAGS", true ) then

		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		hooksecurefunc( BagsBar, "SetSize", function( self, w, h )
			if self.ma_bags_setsize then return end
			self.ma_bags_setsize = true
			MoveAny:UpdateBags()
			self.ma_bags_setsize = false
		end )

		if MicroButtonAndBagsBar then
			BagsBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		elseif MoveAny:GetWoWBuild() ~= "RETAIL" then
			BagsBar:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36 )
		else
			BagsBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			MainMenuBarBackpackButtonNormalTexture:Hide()
		end

		for i, mbname in pairs( BAGS ) do
			local bb = _G[mbname]

			if bb and MoveAny:GetWoWBuild() ~= "RETAIL" then
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
