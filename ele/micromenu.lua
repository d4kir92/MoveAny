
local AddOnName, MoveAny = ...

function MoveAny:InitMicroMenu()
	if MoveAny:IsEnabled( "MICROMENU", true ) then
		local MBTNS = MICRO_BUTTONS
		if MICRO_BUTTONS == nil then
			MBTNS = {
				"CharacterMicroButton",
				"SpellbookMicroButton",
				"TalentMicroButton",
				"AchievementMicroButton",
				"QuestLogMicroButton",
				"GuildMicroButton",
				"LFDMicroButton",
				"CollectionsMicroButton",
				"EJMicroButton",
				"StoreMicroButton",
				"HelpMicroButton",
				"MainMenuMicroButton",
			}
		end

		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		local sw, sh = CharacterMicroButton:GetSize()
		if MABUILD ~= "RETAIL" then
			sh = sh - 21
		end
		local mbc = 11
		if MBTNS then
			mbc = #MBTNS
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
		MAMenuBar.btns = {}
		
		if MBTNS then
			for i, mbname in pairs( MBTNS ) do
				local mb = _G[mbname] 

				local sw, sh = mb:GetSize()
				if MABUILD ~= "RETAIL" then
					sw = sw - 2
					sh = sh - 24
				end

				local hb = CreateFrame( "FRAME" )
				hb:SetParent( MAMenuBar )
				hb:SetSize( sw, sh )
				hb:SetPoint( "TOPLEFT", MAMenuBar, "TOPLEFT", 0, 0 )

				if false then
					hb.t = hb:CreateTexture( "hb_debug" .. i, "BACKGROUND", nil, 1 )
					hb.t:SetAllPoints( hb )
					hb.t:SetColorTexture( 0, 1, 0, 0.5 )
				end

				hooksecurefunc( mb, "SetPoint", function( self, ... )
					if self.masetpoint then return end
					self.masetpoint = true

					mb:SetMovable( true )
					if mb.SetUserPlaced then
						mb:SetUserPlaced( false )
					end

					mb:ClearAllPoints()
					mb:SetParent( hb )
					if MABUILD == "RETAIL" then
						mb:SetPoint( "BOTTOM", hb, "BOTTOM", 0, -2 )
					else
						mb:SetPoint( "BOTTOM", hb, "BOTTOM", 0, -2 )
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
				mb:SetParent( hb )
				if MABUILD == "RETAIL" then
					mb:SetPoint( "BOTTOM", hb, "BOTTOM", 0, -2 )
				else
					mb:SetPoint( "BOTTOM", hb, "BOTTOM", 0, -2 )
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
				tinsert( MAMenuBar.btns, hb )
			end
		end

		MAUpdateActionBar( MAMenuBar )
	end
end
