
local AddOnName, MoveAny = ...

MASECUREFRAMES = {
	"StaticPopup1",
	"StaticPopup2"
}

MAFRAMES = MAFRAMES or {
	"StaticPopup1",
	"StaticPopup2",
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
	"TradeSkillFrame",
	"QuestLogFrame",
	"WorldMapFrame",
	"ChallengesKeystoneFrame",
	"CovenantMissionFrame",
	"OrderHallMissionFrame",
	"PVPMatchScoreboard",
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
	"ItemUpgradeFrame",
	"ProfessionsFrame",
	"CommunitiesFrame",
	"CollectionsJournal",
	"CovenantRenownFrame",
	"ChallengesKeystoneFrame",	
}

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
		IsMouseButtonDown( "MiddleButton" ) then
			C_Timer.After( 0.01, function()
				MoveAny:FrameDragInfo( c - 1 )
			end )
		end
	else
		if IsMouseButtonDown( "RightButton" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) then
				MoveAny:MSG( MAGT( "FRAMESSHIFTSCALE" ) .. "." )
			end
		elseif IsMouseButtonDown( "LeftButton" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) then
				MoveAny:MSG( MAGT( "FRAMESSHIFTDRAG" ) .. "." )
			end
		elseif IsMouseButtonDown( "MiddleButton" ) then
			if MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) then
				MoveAny:MSG( MAGT( "FRAMESSHIFTRESET" ) .. "." )
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
				local frame = _G[name]
				if frame and frameinit[name] == nil then
					frameinit[name] = true

					local fm = _G[name .. "Move"]
					if fm == nil then
						fm = CreateFrame( "FRAME", name .. "Move", UIParent )
						fm:SetMovable( true )
						fm:SetUserPlaced( false )
						fm:SetClampedToScreen( true )
						fm:RegisterForDrag( "LeftButton", "RightButton", "MiddleButton" )
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
										frame:ClearAllPoints()
										frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
									end
								end
								C_Timer.After( 0.01, fm.UpdatePreview )
							end
						end
					end
									
					frame:SetClampedToScreen( true )

					frame:SetScript( "OnMouseDown", function( self, btn )
						if frame:GetPoint() then
							fm:SetSize( frame:GetSize() )
							fm:ClearAllPoints()
							fm:SetPoint( frame:GetPoint() )
						end

						if (MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) and IsShiftKeyDown() and btn == "RightButton") or (not MoveAny:IsEnabled( "FRAMESSHIFTSCALE", false ) and btn == "RightButton") then
							currentFrame = frame
							currentFrameName = name
							
							GameTooltip:Hide()
						elseif (MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) and IsShiftKeyDown() and btn == "LeftButton") or (not MoveAny:IsEnabled( "FRAMESSHIFTDRAG", false ) and btn == "LeftButton") then
							fm.ismoving = true
							if not InCombatLockdown() then
								fm:StartMoving()
								fm:SetUserPlaced( false )
							end
							fm:UpdatePreview()
						elseif (MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) and IsShiftKeyDown() and btn == "MiddleButton") or (not MoveAny:IsEnabled( "FRAMESSHIFTRESET", false ) and btn == "MiddleButton") then
							MoveAny:SetFramePoint( name, nil, nil, nil, nil, nil )
							MoveAny:SetFrameScale( name, nil )

							MoveAny:MSG( "[" .. name .. "] is reset, reopen the frame." )
						else
							MoveAny:FrameDragInfo( 25 )
						end
					end )

					frame:SetScript( "OnMouseUp", function( self )
						local fm = _G[name .. "Move"]
						if fm.ismoving then
							fm.ismoving = false
							fm:StopMovingOrSizing()

							fm:SetUserPlaced( false )
						end
						currentFrame = nil
						currentFrameName = nil
					end )

					hooksecurefunc( frame, "SetPoint", function( self, ... )
						if self.maframesetpoint then return end
						self.maframesetpoint = true
						
						--self:SetMovable( true )
						--[[if self.SetUserPlaced and self:IsMovable() then
							self:SetUserPlaced( false )
						end]]

						if not InCombatLockdown() then
							local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint( name )
							if dbp1 and dbp3 then
								self:ClearAllPoints()
								self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
							end
						end
						self.maframesetpoint = false
					end )

					hooksecurefunc( frame, "SetScale", function( self, scale )
						if self.masetscale then return end
						self.masetscale = true
						
						if MoveAny:GetFrameScale( name ) or scale then
							local sca = MoveAny:GetFrameScale( name ) or scale
							if sca > 0 then
								self:SetScale( sca )
							end
						end
						self.masetscale = false
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
						if not tContains( MASECUREFRAMES, frame ) then
							frame:ClearAllPoints()
							frame:SetPoint( p1, p2, p3, p4, p5 )
						elseif tContains( MASECUREFRAMES, frame ) then
							if not InCombatLockdown() then
								frame:ClearAllPoints()
								frame:SetPoint( p1, p2, p3, p4, p5 )
							else
								local function Test()
									if not InCombatLockdown() then
										frame:ClearAllPoints()
										frame:SetPoint( p1, p2, p3, p4, p5 )
									else
										C_Timer.After( 0.1, Test )
									end
								end
								Test()
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
end