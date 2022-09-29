
local AddOnName, MoveAny = ...

MAFRAMES = {}

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

		-- Only try to scale once there was at least one previous position
		if scaler.prevMouseX and scaler.prevMouseY then
			if curMouseY > scaler.prevMouseY then
				-- Add to scale
				local newScale = math.min(
					currentFrame:GetScale() + 0.006,
					1.5
				)

				-- Scale
				currentFrame:SetScale( newScale )
				MoveAny:SetFrameScale( currentFrameName, newScale )
			elseif curMouseY < scaler.prevMouseY then
				-- Subtract from scale
				local newScale = math.max(
					currentFrame:GetScale() - 0.006,
					0.5
				)

				-- Scale
				currentFrame:SetScale( newScale )
				MoveAny:SetFrameScale( currentFrameName, newScale )
			end
		end

		GameTooltip:SetOwner(currentFrame)
		GameTooltip:SetText(math.floor( currentFrame:GetScale() * 100 ) .. "%")

		-- Update previous mouse position
		scaler.prevMouseX = curMouseX
		scaler.prevMouseY = curMouseY
	end
end )

local frameinit = {}
function MoveAny:MoveFrames()
	if not InCombatLockdown() then
		local allsetup = true
		for i, mf in pairs( MAFRAMES ) do
			local name = mf[1]
			local frame = _G[name]
			local scale = mf[2]
			local dontscale = mf[3]
			local manparent = mf[4]
			if frame and frameinit[name] == nil then
				frameinit[name] = true
				if scale ~= 1 then
					frame:SetScale(scale)
				end
				
				frame:SetMovable( true )
				frame:SetUserPlaced( false )
				frame:EnableMouse( true )
				frame:SetClampedToScreen( true )
				frame:RegisterForDrag("LeftButton", "RightButton")
			
				frame:SetScript( "OnDragStart", function(self, btn)
					frame:SetUserPlaced( false )
					frame:SetAlpha(0.34)
					if IsShiftKeyDown() then
						MoveAny:SetFramePoint( name, nil, nil, nil, nil, nil )
						MoveAny:SetFrameScale( name, nil )

						MoveAny:MSG( "[MoveFrames] Reseted Frame: " .. name )
					else
						if btn == "RightButton" then
							frame.iscaling = true
							
							currentFrame = frame
							currentFrameName = name

							frame.prevMouseX = nil
							frame.prevMouseY = nil
							
							GameTooltip:Hide()
						elseif btn == "LeftButton" then
							frame.ismoving = true
							if not InCombatLockdown() then
								self:StartMoving()
								frame:SetUserPlaced( false )
							end
						end
					end
				end)

				function frame:UpdateValues()
					if not InCombatLockdown() then
						if frame:GetLeft() then
							frame.x = frame:GetLeft() 
							frame.y = (frame:GetTop() - frame:GetHeight()) 

							MoveAny:SetFramePoint( name, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", frame.x, frame.y )
							
							frame:ClearAllPoints()
							local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint( name )
							if dbp1 and dbp3 then
								frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
							end
						else
							C_Timer.After( 0.1, frame.UpdateValues )
						end
					end
				end

				frame:SetScript("OnDragStop", function(self)
					frame:SetAlpha(1)

					if frame.ismoving then
						frame.ismoving = false
						frame:StopMovingOrSizing()
						frame:UpdateValues()

						frame:SetUserPlaced( false )
					end
					if frame.isscaling then
						frame.isscaling = false
					end
					currentFrame = nil
					currentFrameName = nil
				end)

				hooksecurefunc(frame, "SetPoint", function( self, ... )
					if self.masetpoint_frame then return end
					self.masetpoint_frame = true
					
					self:SetMovable( true )
					if self.SetUserPlaced then
						self:SetUserPlaced( false )
					end

					if not InCombatLockdown() then
						local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint( name )
						if dbp1 and dbp3 then
							self:ClearAllPoints()
							self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
						end
					end
					self.masetpoint_frame = false
				end )

				if not dontscale then
					if MoveAny:GetFrameScale( name ) then
						if frame:GetHeight() * MoveAny:GetFrameScale( name ) > GetScreenHeight() then
							MoveAny:SetFrameScale( name, GetScreenHeight() / frame:GetHeight() )
							frame:SetScale( MoveAny:GetFrameScale( name ) )
						end
						frame:SetScale( MoveAny:GetFrameScale( name ) )
					else
						frame:SetScale( 1 )
					end
				end

				local p1, p2, p3, p4, p5 = frame:GetPoint()
				if frame.GetPoint and frame:GetPoint() then
					frame:ClearAllPoints()
					frame:SetPoint(p1, p2, p3, p4, p5)
				end
			else
				allsetup = false
			end
		end
		if not allsetup then
			C_Timer.After( 0.1, MoveAny.MoveFrames )
		end
	else
		C_Timer.After( 0.1, MoveAny.MoveFrames )
	end
end

tinsert( MAFRAMES, {
	"GameMenuFrame",
	1
} )
tinsert( MAFRAMES, {
	"InterfaceOptionsFrame",
	1
} )
tinsert( MAFRAMES, {
	"QuickKeybindFrame",
	1
} )
tinsert( MAFRAMES, {
	"VideoOptionsFrame",
	1
} )
tinsert( MAFRAMES, {
	"KeyBindingFrame",
	1
} )
tinsert( MAFRAMES, {
	"MacroFrame",
	1
} )
tinsert( MAFRAMES, {
	"AddonList",
	1
} )

tinsert( MAFRAMES, {
	"ContainerFrame" .. 1,
	1,
	true,
	nil,
	true
} )
for i = 2, 20 do
	if _G["ContainerFrame" .. i] then
		tinsert( MAFRAMES, {
			"ContainerFrame" .. i,
			1,
			true,
			"ContainerFrame" .. i - 1,
			true
		} )
	end
end

tinsert( MAFRAMES, {
	"LFGParentFrame",
	1
} )
tinsert( MAFRAMES, {
	"LootFrame",
	1
} )
tinsert( MAFRAMES, {
	"CharacterFrame",
	1
} )
tinsert( MAFRAMES, {
	"InspectFrame",
	1
} )
tinsert( MAFRAMES, {
	"SpellBookFrame",
	1
} )
tinsert( MAFRAMES, {
	"PlayerTalentFrame",
	1
} )
tinsert( MAFRAMES, {
	"FriendsFrame",
	1
} )
tinsert( MAFRAMES, {
	"HelpFrame",
	1
} )
tinsert( MAFRAMES, {
	"TradeSkillFrame",
	1
} )
tinsert( MAFRAMES, {
	"QuestLogFrame",
	1
} )
tinsert( MAFRAMES, {
	"WorldMapFrame",
	1
} )
tinsert( MAFRAMES, {
	"ChallengesKeystoneFrame",
	1
} )
tinsert( MAFRAMES, {
	"CovenantMissionFrame",
	1
} )
tinsert( MAFRAMES, {
	"OrderHallMissionFrame",
	1
} )
tinsert( MAFRAMES, {
	"PVPMatchScoreboard",
	1
} )
tinsert( MAFRAMES, {
	"GossipFrame",
	1
} )
tinsert( MAFRAMES, {
	"MerchantFrame",
	1
} )
tinsert( MAFRAMES, {
	"PetStableFrame",
	1
} )
tinsert( MAFRAMES, {
	"QuestFrame",
	1
} )
tinsert( MAFRAMES, {
	"ClassTrainerFrame",
	1
} )
tinsert( MAFRAMES, {
	"AchievementFrame",
	1
} )
tinsert( MAFRAMES, {
	"CommunitiesFrame",
	1
} )
tinsert( MAFRAMES, {
	"PVEFrame",
	1
} )
tinsert( MAFRAMES, {
	"EncounterJournal",
	1
} )
--[[tinsert( MAFRAMES, {
	"CollectionsJournal",
	1
} )]]
tinsert( MAFRAMES, {
	"WeeklyRewardsFrame",
	1
} )
tinsert( MAFRAMES, {
	"BankFrame",
	1
} )
if MABUILD ~= "RETAIL" then
	tinsert( MAFRAMES, {
		"WardrobeFrame",
		1
	} )
end
tinsert( MAFRAMES, {
	"DressUpFrame",
	1
} )
tinsert( MAFRAMES, {
	"MailFrame",
	1
} )
tinsert( MAFRAMES, {
	"OpenMailFrame",
	1
} )
tinsert( MAFRAMES, {
	"AuctionHouseFrame",
	1
} )
tinsert( MAFRAMES, {
	"AnimaDiversionFrame",
	1
} )
tinsert( MAFRAMES, {
	"CovenantSanctumFrame",
	1
} )
tinsert( MAFRAMES, {
	"SoulbindViewer",
	1
} )
tinsert( MAFRAMES, {
	"GarrisonLandingPage",
	1
} )
tinsert( MAFRAMES, {
	"PlayerChoiceFrame",
	1,
	true
} )
