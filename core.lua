
local AddOnName, MoveAny = ...

SLASH_RL1 = "/rl"
SlashCmdList["RL"] = function(msg)
	C_UI.Reload()
end

MABUILD = "CLASSIC"
if select(4, GetBuildInfo()) > 90000 then
	MABUILD = "RETAIL"
elseif select(4, GetBuildInfo()) > 29999 then
	MABUILD = "WRATH"
elseif select(4, GetBuildInfo()) > 19999 then
	MABUILD = "TBC"
end

local HUDDragFrames = {}
MADrag = true
local framelevel = 100

-- Colors
local colors = {}
colors["bg"] = { 0.03, 	0.03, 	0.03, 	1 		}
colors["el"] = { 0.3, 	0.3, 	1.0, 	0.3 	}

function MoveAny:GetColor( key )
	return colors[key][1], colors[key][2], colors[key][3], colors[key][4]
end
-- Colors

function MoveAny:ToggleDrag()
	MADrag = not MADrag

	MoveAny:SetEnabled( "MALOCK", MADrag )

	if MADrag then
		for i, df in pairs( HUDDragFrames ) do
			df:EnableMouse( true )
			df:SetAlpha( 1 )
		end
		if MALock then
			MALock:Show()
			MAGridFrame:Show()
		end
	else
		for i, df in pairs( HUDDragFrames ) do
			df:EnableMouse( false )
			df:SetAlpha( 0 )
		end
		if MALock then
			MALock:Hide()
			MAGridFrame:Hide()
		end
	end
end

function MoveAny:RegisterWidget( tab )
	local name = tab.name
	local lstr = tab.lstr
	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.secure
	tab.delay = tab.delay or 0.2
	if tab.delay < 2 then
		tab.delay = tab.delay + 0.2
	end

	UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil 
	
	local frame = _G[name]
	local s, e = strfind( name, ".", 1, true )
	if e then
		frame = _G[strsub( name, 1, s - 1 )][strsub( name, e + 1 )]
	end

	if _G[name .. "_DRAG"] == nil then
		_G[name .. "_DRAG"] = CreateFrame( "FRAME", name .. "_DRAG", UIParent )

		local dragframe = _G[name .. "_DRAG"]

		dragframe:SetClampedToScreen( true )
		dragframe:SetFrameStrata( "MEDIUM" )
		dragframe:SetFrameLevel( 99 )

		dragframe:Hide()

		if MoveAny:GetEleSize( name ) then
			dragframe:SetSize( MoveAny:GetEleSize( name ) )
		else
			dragframe:SetSize( 100, 100 )
		end
		
		if MoveAny:GetElePoint( name ) then
			dragframe:ClearAllPoints()
			local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
			dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
		else
			dragframe:ClearAllPoints()
			dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
		end
		
		dragframe:SetToplevel( true )

		if true then
			dragframe.t = dragframe:CreateTexture( name .. "_DRAG.t", "BACKGROUND", nil, 1 )
			dragframe.t:SetAllPoints( dragframe )
			dragframe.t:SetColorTexture( MoveAny:GetColor( "el" ) )

			dragframe.name = dragframe:CreateFontString( nil, nil, "GameFontNormal" )
			dragframe.name:SetPoint( "CENTER", dragframe, "CENTER", 0, 7 )
			dragframe.name:SetText( lstr or name )

			dragframe.pos = dragframe:CreateFontString( nil, nil, "GameFontNormal" )
			dragframe.pos:SetPoint( "CENTER", dragframe, "CENTER", 0, -7 )
			dragframe.pos:SetText( "LOADING" )

			function dragframe:UpdatePosition()
				if MADrag then
					local frame = _G[name]
					local ofsx = 0
					local ofsy = 0
					if frame then
						_, _, _, ofsx, ofsy = frame:GetPoint()
					end
					if ofsx and ofsy then
						local text = "x: " .. MAMathR( ofsx ) .. " y: " .. MAMathR( ofsy )
						dragframe.pos:SetText( text )
					end

					C_Timer.After( 0.3, dragframe.UpdatePosition )
				else
					C_Timer.After( 0.5, dragframe.UpdatePosition )
				end
			end
			dragframe:UpdatePosition()
		end

		dragframe:SetAlpha( 1 )

		dragframe:SetScript("OnMouseDown", function( self, btn )
			local frame = _G[name]
			if btn == "LeftButton" then
				dragframe:SetMovable( true )
				dragframe:StartMoving()
				dragframe.IsMoving = true
			elseif btn == "RightButton" then
				if dragframe.opt == nil then
					dragframe.opt = CreateFrame( "FRAME", name .. ".opt", UIParent, "BasicFrameTemplateWithInset" )

					dragframe.opt.TitleText:SetText( name )

					dragframe.opt:SetFrameStrata( "HIGH" )
					dragframe.opt:SetFrameLevel( framelevel )
					framelevel = framelevel + 1

					dragframe.opt:SetSize( 500, 400 )
					dragframe.opt:SetPoint( "CENTER" )
					dragframe.opt:SetClampedToScreen( true )
					dragframe.opt:SetMovable( true )
					dragframe.opt:EnableMouse( true )
					dragframe.opt:RegisterForDrag( "LeftButton" )
					dragframe.opt:SetScript( "OnDragStart", dragframe.opt.StartMoving )
					dragframe.opt:SetScript( "OnDragStop", dragframe.opt.StopMovingOrSizing )

					--[[
					dragframe.opt.bg = dragframe.opt:CreateTexture()
					dragframe.opt.bg:SetAllPoints( dragframe.opt )
					dragframe.opt.bg:SetColorTexture( MoveAny:GetColor( "bg" ) )

					dragframe.opt.f = dragframe.opt:CreateFontString( nil, nil, "GameFontNormal" )
					dragframe.opt.f:SetPoint( "TOP", dragframe.opt, "TOP", 0, -6 )
					dragframe.opt.f:SetText( lstr or name )
					]]

					dragframe.opt.close = CreateFrame( "BUTTON", name .. ".opt.close", dragframe.opt, "UIPanelButtonTemplate" )
					dragframe.opt.close:SetSize( 24, 24 )
					dragframe.opt.close:SetPoint( "TOPRIGHT", dragframe.opt, "TOPRIGHT", 0, 0 )
					dragframe.opt.close:SetText( "X" )
					dragframe.opt.close:SetScript("OnClick", function()
						dragframe.opt:Hide()
					end)

					MAMenuOptions( dragframe.opt, frame )
				elseif dragframe.opt then
					dragframe.opt:Show()
				end
			end
		end)

		dragframe:SetScript("OnMouseUp", function()
			local frame = _G[name]
			if dragframe.IsMoving then
				dragframe.IsMoving = false

				dragframe:StopMovingOrSizing()
				dragframe:SetMovable( false )

				local p1, p2, p3, p4, p5 = dragframe:GetPoint()
				p4 = MAGrid( p4 )
				p5 = MAGrid( p5 )
				MoveAny:SetElePoint( name, p1, _, p3, p4, p5 )

				dragframe:SetMovable(true)

				dragframe:ClearAllPoints()
				local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
				dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
				if frame then
					frame:ClearAllPoints()
					frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )

					local sw, sh = dragframe:GetSize()
					frame:SetSize( sw, sh )
				end
			end
		end)

		tinsert( HUDDragFrames, dragframe )
	end

	if frame == nil then
		C_Timer.After( tab.delay or 0.2, function()
			--if tab.delay < 1 then
				MoveAny:RegisterWidget( tab )
			--end
		end )
		return false
	end

	frame.secure = secure

	sw = sw or frame:GetWidth()
	sh = sh or frame:GetHeight()

	hooksecurefunc( frame, "SetSize", function( self, sw, sh )
		local dragframe = _G[name .. "_DRAG"]
		dragframe:SetSize( sw, sh )
	end )

	if MoveAny:GetElePoint( name ) == nil then
		local an, parent, re, px, py = frame:GetPoint()
		if (parent == nil or parent == UIParent) and an ~= nil and re ~= nil then
			MoveAny:SetElePoint( name, an, UIParent, re, MAGrid( px ), MAGrid( py ) ) 
		elseif frame:GetLeft() and frame:GetBottom() then
			MoveAny:SetElePoint( name, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", MAGrid( frame:GetLeft() ), MAGrid( frame:GetBottom() ) ) 
		else
			MoveAny:SetElePoint( name, "CENTER", UIParent, "CENTER", 0, 0 ) 
		end
	end
	MoveAny:SetEleSize( name, sw, sh )

	frame:SetMovable( true )
	frame:SetUserPlaced( true )
	frame:SetDontSavePosition( true )
	frame:SetClampedToScreen( true )

	frame:ClearAllPoints()
	local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
	if dbp1 and dbp3 then
		frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
	end

	hooksecurefunc( frame, "SetPoint", function( self, ... )
		if self.masetpoint_ele then return end
		self.masetpoint_ele = true

		self:SetMovable( true )
		self:ClearAllPoints()
		local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
		self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
		
		self.masetpoint_ele = false
	end )

	hooksecurefunc( frame, "SetScale", function( self, scale )
		if self.masetpoint_ele then return end
		self.masetpoint_ele = true

		local dragframe = _G[name .. "_DRAG"]
		dragframe:SetScale( scale )

		self.masetpoint_ele = false
	end )

	if MoveAny:GetEleScale( name ) ~= nil then
		frame:SetScale( MoveAny:GetEleScale( name ) )
	end

	local dragframe = _G[name .. "_DRAG"]

	frame:SetSize( sw, sh )
	dragframe:SetSize( sw, sh )
	dragframe:ClearAllPoints()
	dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
	
	dragframe:Show()
end

MAHIDDEN = CreateFrame( "FRAME", "MAHIDDEN" )
MAHIDDEN:Hide()
function MoveAny:Event( event, ... )
	--print("|cff00ff00>>> Loading " .. AddOnName )

	MoveAny:InitDB()

	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
		MainMenuBarArtFrame:Hide()
		UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBarArtFrame"] = nil
		if StatusTrackingBarManager then
			StatusTrackingBarManager:Hide()
			UIPARENT_MANAGED_FRAME_POSITIONS["StatusTrackingBarManager"] = nil
		end
	end


	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		MoveAny:CustomBars()
		MoveAny:InitPetBar()
		MoveAny:UpdateABs()
	end


	-- TOPLEFT
	if MoveAny:IsEnabled( "PLAYERFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "PlayerFrame",
			["lstr"] = PLAYER
		} )
	end
	if MoveAny:IsEnabled( "TARGETFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "TargetFrame",
			["lstr"] = TARGET
		} )
	end
	if MoveAny:IsEnabled( "FOCUSFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "FocusFrame",
			["lstr"] = FOCUS
		} )
	end



	-- TOP
	MoveAny:RegisterWidget( {
		["name"] = "ZoneTextFrame",
		["lstr"] = ZONE
	} )
	MoveAny:RegisterWidget( {
		["name"] = "UIWidgetTopCenterContainerFrame",
		["lstr"] = "UIWidgetTopCenter",
		["sw"] = 36 * 5,
		["sh"] = 36 * 2
	} )
	MoveAny:RegisterWidget( {
		["name"] = "IASkills",
		["lstr"] = "IASkills"
	} )
	


	-- TOPRIGHT
	MoveAny:RegisterWidget( {
		["name"] = "UIWidgetBelowMinimapContainerFrame",
		["lstr"] = "UIWidgetBelowMinimap",
		["sw"] = 36 * 5,
		["sh"] = 36 * 2
	} )
	if MoveAny:IsEnabled( "MINIMAP", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "Minimap",
			["lstr"] = MINIMAP_LABEL--,
			--["secure"] = true
		} )
	end
	if MoveAny:IsEnabled( "BUFFS", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MABuffBar",
			["lstr"] = BUFFOPTIONS_LABEL,
			["sw"] = 36 * 8,
			["sh"] = 36 * 6
		} )
	end
	if MoveAny:IsEnabled( "QUESTLOG", true ) then
		if ObjectiveTrackerFrame == nil then
			ObjectiveTrackerFrame = CreateFrame( "FRAME", "ObjectiveTrackerFrame", UIParent )
			ObjectiveTrackerFrame:SetSize( 224, 600 )
			ObjectiveTrackerFrame:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", 0, 0 )
			
			if QuestWatchFrame then
				hooksecurefunc( QuestWatchFrame, "SetPoint", function( self, ... )
					if self.masetpoint then return end
					self.masetpoint = true
					QuestWatchFrame:ClearAllPoints()
					QuestWatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
					self.masetpoint = false
				end )
				QuestWatchFrame:ClearAllPoints()
				QuestWatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )

				QuestWatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
			end

			if WatchFrame then
				hooksecurefunc( WatchFrame, "SetPoint", function( self, ... )
					if self.masetpoint then return end
					self.masetpoint = true
					WatchFrame:ClearAllPoints()
					WatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
					self.masetpoint = false
				end )
				WatchFrame:ClearAllPoints()
				WatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )

				WatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
			end
		end
		if ObjectiveTrackerFrame then -- RETAIL
			ObjectiveTrackerFrame:SetHeight( 600 )
			MoveAny:RegisterWidget( {
				["name"] = "ObjectiveTrackerFrame",
				["lstr"] = QUEST_LOG,
				["sh"] = 600
			} )
		end
	end
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAVehicleSeatIndicator",
			["lstr"] = VEHICLE
		} )
	end
	MoveAny:RegisterWidget( {
		["name"] = "DurabilityFrame",
		["lstr"] = DURABILITY
	} )



	-- RIGHT



	-- BOTTOMRIGHT
	if MoveAny:IsEnabled( "MICROMENU", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAMenuBar",
			["lstr"] = "MAMenuBar"
		} )
	end
	if MoveAny:IsEnabled( "BAGS", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MABagBar",
			["lstr"] = "MABagBar"
		} )
	end
	MoveAny:RegisterWidget( {
		["name"] = "IAMoneyBar",
		["lstr"] = "IAMoneyBar"
	} )
	MoveAny:RegisterWidget( {
		["name"] = "IASkills",
		["lstr"] = "IASkills"
	} )



	-- BOTTOM
	if MainMenuBarPerformanceBarFrame then
		MainMenuBarPerformanceBarFrame:SetParent( MAHIDDEN )
	end
	MoveAny:RegisterWidget( {
		["name"] = "CastingBarFrame",
		["lstr"] = "castingbar"
	} )
	MoveAny:RegisterWidget( {
		["name"] = "TalkingHeadFrame",
		["lstr"] = "talkinghead",
		["secure"] = true
	} )
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		for i = 1, 10 do
			if i ~= 2 then
				if i <= 6 or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
					MoveAny:RegisterWidget( {
						["name"] = "MAActionBar" .. i,
						["lstr"] = "MAActionBar" .. i,
						["secure"] = i == 1
					} )
				end
			end
		end
	end
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAStanceBar",
			["lstr"] = "StanceBar"
		} )
		MoveAny:RegisterWidget( {
			["name"] = "MAPetBar",
			["lstr"] = "PetBar"
		} )
		MoveAny:RegisterWidget( {
			["name"] = "PossessBarFrame",
			["lstr"] = "PossessBarFrame"
		} )
	end
	if ZoneAbilityFrame then
		ZoneAbilityFrame:SetParent( UIParent )
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 200 )
	end
	MoveAny:RegisterWidget( {
		["name"] = "ZoneAbilityFrame",
		["lstr"] = "ZoneAbilityFrame"
	} )
	
	if ExtraAbilityContainer then
		ExtraAbilityContainer:SetSize( 180, 100 )
		ExtraAbilityContainer:ClearAllPoints()
		ExtraAbilityContainer:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 330 )
	end
	MoveAny:RegisterWidget( {
		["name"] = "ExtraAbilityContainer",
		["lstr"] = "ExtraAbilityContainer"
	} )
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		if MainMenuExpBar then
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 140 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "MainMenuExpBar",
			["lstr"] = "MainMenuExpBar"
		} )
		if ReputationWatchBar then
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 130 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "ReputationWatchBar",
			["lstr"] = "ReputationWatchBar"
		} )
		if MainMenuBarVehicleLeaveButton then
			MainMenuBarVehicleLeaveButton:SetParent( UIParent )
		end
		MoveAny:RegisterWidget( {
			["name"] = "MainMenuBarVehicleLeaveButton",
			["lstr"] = LEAVE_VEHICLE
		} )
		MoveAny:RegisterWidget( {
			["name"] = "MultiCastActionBarFrame",
			["lstr"] = "totemactionbar"
		} )
	end


	-- BOTTOMLEFT
	if MoveAny:IsEnabled( "CHAT", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "ChatFrame1",
			["lstr"] = CHAT
		} )
	end



	-- LEFT



	-- CENTER
	MoveAny:RegisterWidget( {
		["name"] = "UIWidgetPowerBarContainerFrame",
		["lstr"] = "UIWidgetPowerBar",
		["sw"] = 36 * 6,
		["sh"] = 36 * 1
	} )



	MoveAny:InitBags()
	MoveAny:InitMALock()
	MoveAny:InitMicroMenu()
	MoveAny:InitMinimap()
	MoveAny:InitMAVehicleSeatIndicator()
	MoveAny:InitStanceBar()
	MoveAny:InitBuffBar()

	MoveAny:MoveFrames()

	local MoveAnyMinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("MoveAnyMinimapIcon", {
		type = "data source",
		text = "MoveAnyMinimapIcon",
		icon = 135994,
		OnClick = function(self, btn)
			if btn == "LeftButton" then
				MoveAny:ToggleDrag()
			elseif btn == "RightButton" then
				--ToggleMinimapButton()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine( "MoveAny")
			tooltip:AddLine( "LeftClick = Locks/Unlocks" )
			tooltip:AddLine( "RightClick = Options" )
		end,
	})
	if MoveAnyMinimapIcon then
		icon = LibStub("LibDBIcon-1.0", true)
		if icon then
			icon:Register( "MoveAnyMinimapIcon", MoveAnyMinimapIcon, MoveAny:GetMinimapTable() )
		end
	end

	if MoveAny:IsEnabled( "MALOCK", false ) then
		-- Not hide
	else
		MoveAny:ToggleDrag()
	end

	--print("|cff00ff00Loaded " .. AddOnName )
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", MoveAny.Event)
f:RegisterEvent( "PLAYER_LOGIN" )
f.incombat = false 

f:SetScript( "OnUpdate", function()
	if MADrag and InCombatLockdown() then
		f.incombat = true
		MoveAny:ToggleDrag()
	elseif f.incombat and not InCombatLockdown() then
		f.incombat = false
		MoveAny:ToggleDrag()
	end
end )



-- TABS
local function SelectTab( self )
	PanelTemplates_SetTab( self:GetParent(), self:GetID() )

	local content = self:GetParent().currentcontent
	if content then
		content:Hide()
	end

	self:GetParent().currentcontent = self.content
	self.content:Show()
end

local function CreateTabs( frame, args )
	frame.numTabs = #args

	local tabs = {}
	local sw, sh = frame:GetSize()
	for i = 1, frame.numTabs do
		local tab = CreateFrame( "Button", frame:GetName() .. "Tab" .. i, frame, "CharacterFrameTabButtonTemplate" )
		tab:SetID( i )
		tab:SetText( args[i] )
		tab:SetScript( "OnClick", function( self )
			SelectTab( self )
		end )

		tab.content = CreateFrame( "Frame", frame:GetName() .. "Tab" .. i .. "Content", frame )
		tab.content.name = args[i]
		tab.content:SetSize( sw - 12, sh - 26 - 6 )
		tab.content:SetPoint( "TOPLEFT", frame, "TOPLEFT", 6, -26 )
		tab.content:Hide()

		PanelTemplates_TabResize( tab, 0 )

		if i == 1 then
			tab:SetPoint( "TOPLEFT", frame, "BOTTOMLEFT", 5, 2 )
		else
			tab:SetPoint( "TOPLEFT", _G[frame:GetName() .. "Tab" .. (i - 1)], "TOPRIGHT", -14, 0 )
		end

		table.insert( tabs, tab )
	end

	SelectTab( tabs[1] )

	return tabs
end

local btnsize = 24
local function MAMoveButton( parent, name, ofsx, ofsy, x, y, texNor, texPus )
	local btn = CreateFrame( "Button", "MOVE" .. x .. y, parent )
	btn:SetNormalTexture( texNor )
	btn:SetPushedTexture( texPus )
	btn:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight" )
	btn:SetSize( btnsize, btnsize )
	btn:SetPoint( "TOPLEFT", parent, "TOPLEFT", ofsx, ofsy )
	btn:SetScript( "OnClick", function()
		local p1, p2, p3, p4, p5 = MoveAny:GetElePoint( name )
		MoveAny:SetElePoint( name, p1, p2, p3, p4 + x, p5 + y )
	end )

	return btn
end

function MAMenuOptions( opt, frame )
	local name = frame:GetName()
	local opts = MoveAny:GetEleOptions( name )
	
	local tabs = { GENERAL }

	if string.find( name, "MAActionBar" ) then
		table.insert( tabs, ACTIONBARS_LABEL )
	end

	local contents = CreateTabs( opt, tabs )
	
	for i, tab in pairs( contents ) do
		local content = tab.content

		if string.find( content.name, GENERAL ) then
			local yp1 = MAMoveButton( content, name, btnsize * 2, 0, 0, 1,				"Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )
			local yp5 = MAMoveButton( content, name, btnsize * 2, -btnsize * 1, 0, 5, 	"Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )

			local ym5 = MAMoveButton( content, name, btnsize * 2, -btnsize * 3, 0, -5,	"Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
			local ym1 = MAMoveButton( content, name, btnsize * 2, -btnsize * 4, 0, -1, 	"Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )

			local xm1 = MAMoveButton( content, name, 0, -btnsize * 2, -1, 0, 			"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up" )
			local xm5 = MAMoveButton( content, name, btnsize * 1, -btnsize * 2, -5, 0,	"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up" )

			local xp5 = MAMoveButton( content, name, btnsize * 3, -btnsize * 2, 5, 0, 	"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up" )
			local xp1 = MAMoveButton( content, name, btnsize * 4, -btnsize * 2, 1, 0,	"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up" )
		
			local sup = CreateFrame( "Button", "sup", content )
			sup:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up" )
			sup:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )
			sup:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight" )
			sup:SetSize( btnsize, btnsize )
			sup:SetPoint( "TOPLEFT", content, "TOPLEFT", 200, -24 )
			sup:SetScript( "OnClick", function()
				MoveAny:SetEleScale( name, frame:GetScale() + 0.1 )
			end )

			local sdn = CreateFrame( "Button", "sdn", content )
			sdn:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up" )
			sdn:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
			sdn:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight" )
			sdn:SetSize( btnsize, btnsize )
			sdn:SetPoint( "TOPLEFT", content, "TOPLEFT", 200, -48 )
			sdn:SetScript( "OnClick", function()
				MoveAny:SetEleScale( name, frame:GetScale() - 0.1 )
			end )
		elseif string.find( content.name, ACTIONBARS_LABEL ) then
			opts["ROWS"] = opts["ROWS"] or 1
			
			local rows = {
				["name"] = "raid",
				["parent"]= content,
				["title"] = "ROWS",
				["items"]= { "1", "2", "3", "4", "6", "12" },
				["defaultVal"] = opts["ROWS"], 
				["changeFunc"] = function( dropdown_frame, dropdown_val )
					opts["ROWS"] = dropdown_val

					MAUpdateActionBar( frame )
				end
			}

			local ddrows = MACreateDropdown( rows )
			ddrows:SetPoint( "TOPLEFT", content, "TOPLEFT", 0, -36 );
		end
	end
end
