
local AddOnName, MoveAny = ...

local MAFRAMES = {
	"StaticPopup1",
	"StaticPopup2",
	--"ReadyCheckListenerFrame", Buggy
	"SettingsPanel",
	"SplashFrame",
	"GameMenuFrame",
	"InterfaceOptionsFrame",
	"QuickKeybindFrame",
	"VideoOptionsFrame",
	"KeyBindingFrame",
	"MacroFrame",
	"AddonList",
	"ContainerFrameCombinedBags",
	"LFGParentFrame",
	"LootFrame",
	"CharacterFrame",
	"InspectFrame",
	"SpellBookFrame",
	"PlayerTalentFrame",
	"ClassTalentFrame",
	"FriendsFrame",
	"HelpFrame",
	"TradeFrame",
	"TradeSkillFrame",
	"QuestLogFrame",
	"WorldMapFrame",
	"ChallengesKeystoneFrame",
	"CovenantMissionFrame",
	"OrderHallMissionFrame",
	"PVPMatchScoreboard",
	"PVPParentFrame", -- BUGGY?
	"GossipFrame",
	"MerchantFrame",
	"PetStableFrame",
	"QuestFrame",
	"ClassTrainerFrame",
	"AchievementFrame",
	"PVEFrame",
	"EncounterJournal",
	"WeeklyRewardsFrame",
	"BankFrame",
	"WardrobeFrame",
	"DressUpFrame",
	"MailFrame",
	"OpenMailFrame",
	"AuctionHouseFrame",
	"AuctionFrame",
	"ProfessionsCustomerOrdersFrame",
	"AnimaDiversionFrame",
	"CovenantSanctumFrame",
	"SoulbindViewer",
	"GarrisonLandingPage",
	"PlayerChoiceFrame",
	"WorldStateScoreFrame",
	"ItemTextFrame",
	"ExpansionLandingPage",
	"MajorFactionRenownFrame",
	"GenericTraitFrame",
	"FlightMapFrame",
	"TaxiFrame",
	"ItemUpgradeFrame",
	"ProfessionsFrame",
	"CommunitiesFrame",
	"CollectionsJournal",
	"CovenantRenownFrame",
	"ChallengesKeystoneFrame",
	"ScriptErrorsFrame",
	"CalendarFrame",
	"TimeManagerFrame",
	"GuildBankFrame",
	"ItemSocketingFrame",
}

if ScriptErrorsFrame and ScriptErrorsFrame.DragArea then
	hooksecurefunc( ScriptErrorsFrame.DragArea, "SetParent", function( self )
		if self.ma_setparent then return end
		self.ma_setparent = true
		self:SetParent( MAHIDDEN )
		self.ma_setparent = false
	end )
	ScriptErrorsFrame.DragArea:SetParent( MAHIDDEN )
end

for i = 1, 20 do
	if _G["ContainerFrame" .. i] then
		if not tContains( MAFRAMES, "ContainerFrame" .. i ) then
			tinsert( MAFRAMES, "ContainerFrame" .. i )
		end
	end
end

local currentFrame = nil
local currentFrameName = nil
local scaler = CreateFrame( "Frame" )
scaler:SetScript( "OnUpdate", function()
	if currentFrame and not currentFrame:IsShown() then
		currentFrame:SetAlpha(1)
		currentFrame = nil
		currentFrameName = nil
		GameTooltip:Hide()
	end
	if currentFrame then		
		local curMouseX, curMouseY = GetCursorPosition()

		if scaler.prevMouseX and scaler.prevMouseY then
			if curMouseY > scaler.prevMouseY then
				local newScale = math.min(
					currentFrame:GetScale() + 0.006,
					1.5
				)

				if newScale > 0 then
					currentFrame:SetScale( newScale )
					MoveAny:SetFrameScale( currentFrameName, newScale )
				end
			elseif curMouseY < scaler.prevMouseY then
				local newScale = math.max(
					currentFrame:GetScale() - 0.006,
					0.5
				)

				if newScale > 0 then
					currentFrame:SetScale( newScale )
					MoveAny:SetFrameScale( currentFrameName, newScale )
				end
			end
		end

		GameTooltip:SetOwner(currentFrame)
		GameTooltip:SetText(math.floor( currentFrame:GetScale() * 100 ) .. "%")

		scaler.prevMouseX = curMouseX
		scaler.prevMouseY = curMouseY
	end
end )

function MoveAny:FrameDragInfo( c )
	if c > 0 then
		if IsMouseButtonDown( "RightButton" ) or
		IsMouseButtonDown( "LeftButton" ) or
		IsMouseButtonDown( "MiddleButton" ) or IsMouseButtonDown( "Button4" ) or IsMouseButtonDown( "Button5" ) then
			C_Timer.After( 0.01, function()
				MoveAny:FrameDragInfo( c - 1 )
			end )
		end
	else
		if IsMouseButtonDown( "RightButton" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) then
				MoveAny:MSG( MoveAny:GT( "FRAMESSHIFTSCALE" ) .. "." )
			end
		elseif IsMouseButtonDown( "LeftButton" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) then
				MoveAny:MSG( MoveAny:GT( "FRAMESSHIFTDRAG" ) .. "." )
			end
		elseif IsMouseButtonDown( "MiddleButton" ) or IsMouseButtonDown( "Button4" ) or IsMouseButtonDown( "Button5" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) then
				MoveAny:MSG( MoveAny:GT( "FRAMESSHIFTRESET" ) .. "." )
			end
		end
	end
end

local frameinit = {}
function MoveAny:MoveFrames()
	if MoveAny:IsEnabled( "MOVEFRAMES", true ) then
		if not InCombatLockdown() then
			local allsetup = true
			for i, name in pairs( MAFRAMES ) do
				local frame = MoveAny:GetFrame( _G[name], name )
				if frame and frameinit[name] == nil then
					frameinit[name] = true

					local fm = _G[name .. "Move"]
					if fm == nil then
						fm = CreateFrame( "FRAME", name .. "Move", UIParent )
						fm:SetMovable( true )
						fm:SetUserPlaced( false )
						fm:SetClampedToScreen( true )
						fm:RegisterForDrag( "Any" )
						fm:EnableMouse( false )

						hooksecurefunc( frame, "SetScale", function( self, scale )
							fm:SetScale( scale )
						end )

						function fm:UpdatePreview()
							local fm = _G[name .. "Move"]
							if fm and fm.ismoving then
								if fm:GetLeft() then
									fm.x = fm:GetLeft() 
									fm.y = (fm:GetTop() - fm:GetHeight()) 
									
									MoveAny:SetFramePoint( name, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", fm.x, fm.y )
		
									local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint( name )
									if dbp1 and dbp3 then
										if not InCombatLockdown() then
											frame:ClearAllPoints()
											frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
										end
									end
								end
								C_Timer.After( 0.01, fm.UpdatePreview )
							end
						end
					end
									
					frame:SetClampedToScreen( true )

					function frame:MAStopMoving()
						local fm = _G[name .. "Move"]
						if fm.ismoving then
							fm.ismoving = false
							fm:StopMovingOrSizing()

							fm:SetUserPlaced( false )
						end
						currentFrame = nil
						currentFrameName = nil
					end

					function frame:MACheckSave()
						if not MoveAny:IsEnabled( "SAVEFRAMEPOSITION", true ) then
							MoveAny:SetFramePoint( name, nil, nil, nil, nil, nil )
							frame:SetMovable( true )
							if frame.SetUserPlaced then
								frame:SetUserPlaced( false )
							end
						end
						if not MoveAny:IsEnabled( "SAVEFRAMESCALE", true ) then
							MoveAny:SetFrameScale( name, nil )
							frame:SetScale( frame:GetScale() )
						end
					end
					frame:MACheckSave()

					frame:HookScript( "OnHide", function()
						frame:MAStopMoving()

						frame:MACheckSave()
					end )

					function MoveAny:IsResetButtonDown( btn )
						return btn == "MiddleButton" or btn == "Button4" or btn == "Button5"
					end

					frame:RegisterForDrag( "Any" )
					frame:HookScript( "OnMouseDown", function( self, btn )
						if frame:GetPoint() then
							fm:SetSize( frame:GetSize() )
							fm:ClearAllPoints()
							if frame:GetLeft() then
								local x = frame:GetLeft() 
								local y = (frame:GetTop() - frame:GetHeight()) 
								fm:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y )
							else
								fm:SetAllPoints( frame )
							end
						end
						
						if (MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) and IsShiftKeyDown() and btn == "RightButton") or (not MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) and btn == "RightButton") then
							currentFrame = frame
							currentFrameName = name
							
							GameTooltip:Hide()
						elseif (MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) and IsShiftKeyDown() and btn == "LeftButton") or (not MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) and btn == "LeftButton") then
							if not InCombatLockdown() then
								fm:StartMoving()
								fm:SetUserPlaced( false )
								fm.ismoving = true
							end
							fm:UpdatePreview()
						elseif (MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) and IsShiftKeyDown() and MoveAny:IsResetButtonDown( btn )) or (not MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) and MoveAny:IsResetButtonDown( btn )) then
							MoveAny:SetFramePoint( name, nil, nil, nil, nil, nil )
							MoveAny:SetFrameScale( name, nil )

							frame:ClearAllPoints()

							MoveAny:MSG( "[" .. name .. "] is reset, reopen the frame." )
						else
							if MoveAny:IsResetButtonDown( btn ) then
								MoveAny:FrameDragInfo( 0 )
							else
								MoveAny:FrameDragInfo( 20 )
							end
						end
					end )

					frame:HookScript( "OnMouseUp", function( self )
						frame:MAStopMoving()
					end )

					function frame:MARetrySetPoint()
						frame.maretrysetpoint = true
						if not InCombatLockdown() then
							if frame:GetPoint() then
								frame:SetPoint( frame:GetPoint() )
							else
								frame:SetPoint( "CENTER" )
							end
						else
							C_Timer.After( 0.01, frame.MARetrySetPoint )
						end
					end

					hooksecurefunc( frame, "SetPoint", function( self, ... )
						if self.maframesetpoint then return end
						self.maframesetpoint = true

						self:SetMovable( true )
						if self.SetUserPlaced and self:IsMovable() then
							self:SetUserPlaced( false )
						end
						
						local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint( name )
						if dbp1 and dbp3 then
							if not InCombatLockdown() then
								self.maretrysetpoint = nil
								local w, h = self:GetSize()
								self:ClearAllPoints()
								self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
								if self:GetNumPoints() > 1 then
									self:SetSize( w, h )
								end
							elseif self.maretrysetpoint == nil then
								frame:MARetrySetPoint()
							end
						end
						self.maframesetpoint = false
					end )

					hooksecurefunc( frame, "SetScale", function( self, scale )
						if self.masetscale_frame then return end
						self.masetscale_frame = true
						
						if MoveAny:GetFrameScale( name ) or scale then
							local sca = MoveAny:GetFrameScale( name ) or scale
							if sca > 0 then
								self:SetScale( sca )
							end
						end
						self.masetscale_frame = false
					end )
					if MoveAny:GetFrameScale( name ) and MoveAny:GetFrameScale( name ) > 0 then
						if frame:GetHeight() * MoveAny:GetFrameScale( name ) > GetScreenHeight() then
							if GetScreenHeight() / frame:GetHeight() > 0 then
								MoveAny:SetFrameScale( name, GetScreenHeight() / frame:GetHeight() )
							end
							frame:SetScale( MoveAny:GetFrameScale( name ) )
						end
						if MoveAny:GetFrameScale( name ) and MoveAny:GetFrameScale( name ) > 0 then
							frame:SetScale( MoveAny:GetFrameScale( name ) )
						end
					else
						frame:SetScale( frame:GetScale() )
					end

					if frame.GetPoint and frame:GetPoint() then
						local p1, p2, p3, p4, p5 = frame:GetPoint()
						if not InCombatLockdown() then
							frame:ClearAllPoints()
							frame:SetPoint( p1, p2, p3, p4, p5 )
						else
							function frame:MAUpdatePos()
								frame.maupdatepos = true
								if not InCombatLockdown() then
									frame:ClearAllPoints()
									frame:SetPoint( p1, p2, p3, p4, p5 )
									frame.maupdatepos = nil
								else
									C_Timer.After( 0.03, frame.MAUpdatePos )
								end
							end
							if frame.maupdatepos == nil then
								frame:MAUpdatePos()
							end
						end
					end
				else
					allsetup = false
				end
			end
			if not allsetup then
				C_Timer.After( 0.1, MoveAny.MoveFrames )
			end
		else
			C_Timer.After( 0.2, MoveAny.MoveFrames )
		end
	end

	if PVPFrame then
		PVPFrame:EnableMouse( false )
	end
	if BattlefieldFrame then
		BattlefieldFrame:EnableMouse( false )
	end
end
