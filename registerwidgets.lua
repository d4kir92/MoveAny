
local AddOnName, MoveAny = ...

MADragFrames = MADragFrames or {}

local framelevel = 100

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

		p1, p2, p3, p4, p5 = MoveAny:GetElePoint( name )
		parent.pos:SetText( format( "Position X: %d Y:%d", p4, p5 ) )
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
			content.pos = content:CreateFontString( nil, nil, "GameFontNormal" )
			content.pos:SetPoint( "TOPLEFT", content, "TOPLEFT", 4, -4 )
			local p1, p2, p3, p4, p5 = MoveAny:GetElePoint( name )
			content.pos:SetText( format( "Position X: %d Y:%d", p4, p5 ) )

			local yp5 = MAMoveButton( content, name, btnsize * 2, -btnsize * 1, 0, 5, 	"Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )
			local yp1 = MAMoveButton( content, name, btnsize * 2, -btnsize * 2, 0, 1,				"Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )
			
			local ym1 = MAMoveButton( content, name, btnsize * 2, -btnsize * 4, 0, -1, 	"Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
			local ym5 = MAMoveButton( content, name, btnsize * 2, -btnsize * 5, 0, -5,	"Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
			
			local xm5 = MAMoveButton( content, name, 0, -btnsize * 3, -5, 0,	"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up" )
			local xm1 = MAMoveButton( content, name, btnsize * 1, -btnsize * 3, -1, 0, 			"Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up" )

			local xp1 = MAMoveButton( content, name, btnsize * 3, -btnsize * 3, 1, 0,	"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up" )
			local xp5 = MAMoveButton( content, name, btnsize * 4, -btnsize * 3, 5, 0, 	"Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up" )

			content.scale = content:CreateFontString( nil, nil, "GameFontNormal" )
			content.scale:SetPoint( "TOPLEFT", content, "TOPLEFT", 200, -4 )
			local scale = MoveAny:GetEleScale( name ) or 1
			content.scale:SetText( format( "Scale: %0.1f", scale ) )

			local sup = CreateFrame( "Button", "sup", content )
			sup:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up" )
			sup:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down" )
			sup:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight" )
			sup:SetSize( btnsize, btnsize )
			sup:SetPoint( "TOPLEFT", content, "TOPLEFT", 200, -24 )
			sup:SetScript( "OnClick", function()
				MoveAny:SetEleScale( name, frame:GetScale() + 0.1 )
				content.scale:SetText( format( "Scale: %0.1f", MoveAny:GetEleScale( name ) ) )
			end )

			local sdn = CreateFrame( "Button", "sdn", content )
			sdn:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up" )
			sdn:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
			sdn:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight" )
			sdn:SetSize( btnsize, btnsize )
			sdn:SetPoint( "TOPLEFT", content, "TOPLEFT", 200, -48 )
			sdn:SetScript( "OnClick", function()
				MoveAny:SetEleScale( name, frame:GetScale() - 0.1 )
				content.scale:SetText( format( "Scale: %d", MoveAny:GetEleScale( name ) ) )
			end )

			local hide = CreateFrame( "CheckButton", "hide", content, "ChatConfigCheckButtonTemplate" )
			hide:SetSize( btnsize, btnsize )
			hide:SetPoint( "TOPLEFT", content, "TOPLEFT", 4, -160 )
			hide:SetChecked( MoveAny:GetEleOption( name, "Hide", false ) )
			hide:SetText( HIDE )
			hide:SetScript( "OnClick", function()
				local checked = hide:GetChecked()
				MoveAny:SetEleOption( name, "Hide", checked )
				
				local maframe1 = _G["MA" .. name]
				local maframe2 = _G[string.gsub( name, "MA", "" )]
				local dragf = _G[name .. "_DRAG"]
				if checked then
					frame.oldparent = frame.oldparent or frame:GetParent()
					frame:SetParent( MAHIDDEN )
					if maframe1 then
						maframe1.oldparent = maframe1.oldparent or maframe1:GetParent()
						maframe1:SetParent( MAHIDDEN )
					end
					if maframe2 then
						maframe2.oldparent = maframe2.oldparent or maframe2:GetParent()
						maframe2:SetParent( MAHIDDEN )
					end
					dragf.t:SetColorTexture( MoveAny:GetColor( "hidden" ) )
				else
					frame:SetParent( frame.oldparent )
					if maframe1 then
						maframe1:SetParent( maframe1.oldparent )
					end
					if maframe2 then
						maframe2:SetParent( maframe2.oldparent )
					end
					dragf.t:SetColorTexture( MoveAny:GetColor( "el" ) )
				end		
			end )
			hide.text = hide:CreateFontString( nil, "ARTWORK" )
			hide.text:SetFont( STANDARD_TEXT_FONT, 12, "THINOUTLINE" )
			hide.text:SetPoint( "LEFT", hide, "RIGHT", 0, 0)
			hide.text:SetText( getglobal("HIDE") )
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

function MoveAny:UpdateMinimapButton()
	if MAMMBTN then
		if MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end
end

function MoveAny:ToggleMinimapButton()
	MoveAny:SetEnabled( "SHOWMINIMAPBUTTON", not MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) )
	if MAMMBTN then
		if MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end
end

function MoveAny:HideMinimapButton()
	MoveAny:SetEnabled( "SHOWMINIMAPBUTTON", false )
	if MAMMBTN then
		MAMMBTN:Hide("MoveAnyMinimapIcon")
	end
end

function MoveAny:ShowMinimapButton()
	MoveAny:SetEnabled( "SHOWMINIMAPBUTTON", true )
	if MAMMBTN then
		MAMMBTN:Show("MoveAnyMinimapIcon")
	end
end

function MoveAny:RegisterWidget( tab, debug )
	local name = tab.name
	local lstr = tab.lstr
	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.secure
	tab.delay = tab.delay or 0.2
	if tab.delay < 2 then
		tab.delay = tab.delay + 0.2
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[name] then
		UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil 
	end

	local frame = _G[name]
	local s, e = strfind( name, ".", 1, true )
	if e then
		frame = _G[strsub( name, 1, s - 1 )][strsub( name, e + 1 )]
	end

	if _G[name .. "_DRAG"] == nil then
		_G[name .. "_DRAG"] = CreateFrame( "Frame", name .. "_DRAG", UIParent )

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
		
		dragframe:ClearAllPoints()
		dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )

		dragframe:SetToplevel( true )

		if true then
			dragframe.t = dragframe:CreateTexture( name .. "_DRAG.t", "BACKGROUND", nil, 1 )
			dragframe.t:SetAllPoints( dragframe )
			dragframe.t:SetColorTexture( MoveAny:GetColor( "el" ) )

			dragframe.name = dragframe:CreateFontString( nil, nil, "GameFontNormal" )
			dragframe.name:SetPoint( "CENTER", dragframe, "CENTER", 0, 0 )
			local font, fontSize, fontFlags = dragframe.name:GetFont()
			dragframe.name:SetFont( font, 15, fontFlags )
			dragframe.name:SetText( MAGT( lstr ) )
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
					dragframe.opt = CreateFrame( "Frame", name .. ".opt", UIParent, "BasicFrameTemplateWithInset" )

					dragframe.opt.TitleText:SetText( name )

					dragframe.opt:SetFrameStrata( "HIGH" )
					dragframe.opt:SetFrameLevel( framelevel )
					framelevel = framelevel + 1

					dragframe.opt:SetSize( 300, 250 )
					dragframe.opt:SetPoint( "CENTER" )
					dragframe.opt:SetClampedToScreen( true )
					dragframe.opt:SetMovable( true )
					dragframe.opt:EnableMouse( true )
					dragframe.opt:RegisterForDrag( "LeftButton" )
					dragframe.opt:SetScript( "OnDragStart", dragframe.opt.StartMoving )
					dragframe.opt:SetScript( "OnDragStop", dragframe.opt.StopMovingOrSizing )

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
					if not InCombatLockdown() then
						frame:SetSize( sw, sh )
					end
				end
			end
		end)

		tinsert( MADragFrames, dragframe )
	end

	if frame == nil then
		C_Timer.After( tab.delay or 0.2, function()
			--if tab.delay < 1 then
				MoveAny:RegisterWidget( tab )
			--end
		end )
		return false
	end

	frame:SetMovable( true )
	
	frame:SetDontSavePosition( true )
	frame:SetClampedToScreen( true )

	if frame.SetUserPlaced then
		--frame:SetUserPlaced( false )
	end

	local maframe1 = _G["MA" .. name]
	local maframe2 = _G[string.gsub( name, "MA", "" )]
	local dragf = _G[name .. "_DRAG"]
	if MoveAny:GetEleOption( name, "Hide", false ) then
		frame.oldparent = frame.oldparent or frame:GetParent()
		frame:SetParent( MAHIDDEN )
		if maframe1 then
			maframe1.oldparent = maframe1.oldparent or frame:GetParent()
			maframe1:SetParent( MAHIDDEN )
		end
		if maframe2 then
			maframe2.oldparent = maframe2.oldparent or frame:GetParent()
			maframe2:SetParent( MAHIDDEN )
		end
		dragf.t:SetColorTexture( MoveAny:GetColor( "hidden" ) )
	else
		dragf.t:SetColorTexture( MoveAny:GetColor( "el" ) )
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
		elseif parent ~= nil then
			MoveAny:SetElePoint( name, an, UIParent, re, MAGrid( parent:GetLeft() ), MAGrid( parent:GetBottom() ) ) 
		else
			local an = tab.an or "CENTER" 
			local re = tab.re or "CENTER" 
			local px = tab.px or 0
			local py = tab.py or 0
			MoveAny:SetElePoint( name, an, UIParent, re, px, py ) 
		end
	end
	MoveAny:SetEleSize( name, sw, sh )

	if not frame.secure then
		frame:ClearAllPoints()
		local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
		if dbp1 and dbp3 then
			frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
		end
	end

	hooksecurefunc( frame, "SetPoint", function( self, ... )
		if self.masetpoint_ele then return end
		self.masetpoint_ele = true

		self:SetMovable( true )
		if self.SetUserPlaced then
			--self:SetUserPlaced( false )
		end

		if not self.secure then
			self:ClearAllPoints()
			local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
			self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
		end

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

	if not InCombatLockdown() then
		frame:SetSize( sw, sh )
	end
	dragframe:SetSize( sw, sh )
	dragframe:ClearAllPoints()
	dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
	
	dragframe:Show()
end

function MoveAny:Event( event, ... )
	local _, class = UnitClass( "PLAYER" )
	if IsAddOnLoaded("D4KiR MoveAndImprove") then
		MoveAny:MSG( "DON'T use MoveAndImprove, when you use MoveAny" )
	end

	MoveAny:InitDB()

	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "ACTIONBARS", true ) then
			if UIPARENT_MANAGED_FRAME_POSITIONS then
				UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
			end
			if MainMenuBarArtFrame then
				if UIPARENT_MANAGED_FRAME_POSITIONS then
					UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBarArtFrame"] = nil
				end
				MainMenuBarArtFrame:Hide()
			end
			
			if StatusTrackingBarManager then
				StatusTrackingBarManager:Hide()
				if UIPARENT_MANAGED_FRAME_POSITIONS then
					UIPARENT_MANAGED_FRAME_POSITIONS["StatusTrackingBarManager"] = nil
				end
			end

			MoveAny:CustomBars()
			MoveAny:UpdateABs()
		end
		MoveAny:InitPetBar()
	end
	


	-- TOPLEFT
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "PLAYERFRAME", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "PlayerFrame",
				["lstr"] = "PLAYERFRAME"
			} )
		end
		if MoveAny:IsEnabled( "PETFRAME", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "PetFrame",
				["lstr"] = "PETFRAME"
			} )
		end
	end
	if MoveAny:IsEnabled( "RUNEFRAME", false ) and class == "DEATHKNIGHT" then
		MoveAny:RegisterWidget( {
			["name"] = "RuneFrame",
			["lstr"] = "RUNEFRAME"
		} )
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "TARGETFRAME", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "TargetFrame",
				["lstr"] = "TARGETFRAME"
			} )
		end
		if MoveAny:IsEnabled( "TARGETOFTARGETFRAME", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "TargetFrameToT",
				["lstr"] = "TARGETOFTARGETFRAME"
			} )
		end
		if MoveAny:IsEnabled( "FOCUSFRAME", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "FocusFrame",
				["lstr"] = "FOCUSFRAME"
			} )
		end
	end
	if MoveAny:IsEnabled( "COMPACTRAIDFRAMEMANAGER", true ) then
		MACompactRaidFrameManager = CreateFrame( "Frame", "MACompactRaidFrameManager", UIParent )
		MACompactRaidFrameManager:SetSize( 20, 135 )
		MACompactRaidFrameManager:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", 0, -250 )

		hooksecurefunc( CompactRaidFrameManager, "SetPoint", function( self, ... )
			if self.crfmsetpoint then return end
			self.crfmsetpoint = true

			self:SetMovable( true )
			if self.SetUserPlaced then
				self:SetUserPlaced( false )
			end

			self:ClearAllPoints()
			self:SetPoint( "RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0 )
			self.crfmsetpoint = false
		end )
		CompactRaidFrameManager:SetPoint( "RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0 )
		
		hooksecurefunc( CompactRaidFrameManager, "SetParent", function( self, ... )
			self:SetFrameStrata( "LOW" )
		end )

		CompactRaidFrameManagerToggleButton:HookScript( "OnClick", function( self, ... )
			if CompactRaidFrameManager.collapsed then
				MACompactRaidFrameManager:SetSize( 20, 135 )
			else
				MACompactRaidFrameManager:SetSize( 200, 135 )
			end
		end )

		MoveAny:RegisterWidget( {
			["name"] = "MACompactRaidFrameManager",
			["lstr"] = "COMPACTRAIDFRAMEMANAGER"
		} )
	end
	if MoveAny:IsEnabled( "MAFPSFrame", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAFPSFrame",
			["lstr"] = "MAFPSFrame"
		} )
	end
	MoveAny:RegisterWidget( {
		["name"] = "IASkills",
		["lstr"] = "IASKILLS"
	} )



	-- TOP
	if MoveAny:IsEnabled( "ZONETEXTFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "ZoneTextFrame",
			["lstr"] = "ZONETEXTFRAME"
		} )
	end
	if MoveAny:IsEnabled( "UIWIDGETTOPCENTER", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetTopCenterContainerFrame",
			["lstr"] = "UIWIDGETTOPCENTER",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2
		} )
	end
	


	-- TOPRIGHT
	if MoveAny:IsEnabled( "UIWIDGETBELOWMINIMAP", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetBelowMinimapContainerFrame",
			["lstr"] = "UIWIDGETBELOWMINIMAP",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2
		} )
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "MINIMAP", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "Minimap",
				["lstr"] = "MINIMAP"
			} )
		end
		if MoveAny:IsEnabled( "BUFFS", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "MABuffBar",
				["lstr"] = "BUFFS"
			} )
		end
		if MoveAny:IsEnabled( "DEBUFFS", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "MADebuffBar",
				["lstr"] = "DEBUFFS"
			} )
		end
		if MoveAny:IsEnabled( "QUESTTRACKER", true ) then
			if ObjectiveTrackerFrame == nil then
				ObjectiveTrackerFrame = CreateFrame( "Frame", "ObjectiveTrackerFrame", UIParent )
				ObjectiveTrackerFrame:SetSize( 224, 600 )
				ObjectiveTrackerFrame:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -85, -180 )
			
				if QuestWatchFrame then
					hooksecurefunc( QuestWatchFrame, "SetPoint", function( self, ... )
						if self.masetpoint then return end
						self.masetpoint = true

						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end

						self:SetParent( ObjectiveTrackerFrame )

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

						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end
						
						self:SetParent( ObjectiveTrackerFrame )

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
					["lstr"] = "QUESTTRACKER",
					["sh"] = 600
				} )
			end
		end
	end
	MoveAny:RegisterWidget( {
		["name"] = "MAVehicleSeatIndicator",
		["lstr"] = "LEAVEVEHICLE"
	} )
	MoveAny:RegisterWidget( {
		["name"] = "DurabilityFrame",
		["lstr"] = "DURABILITY"
	} )



	-- RIGHT



	-- BOTTOMRIGHT
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "MICROMENU", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "MAMenuBar",
				["lstr"] = "MICROMENU"
			} )
		end
		if MoveAny:IsEnabled( "BAGS", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "MABagBar",
				["lstr"] = "BAGS"
			} )
		end
	end
	MoveAny:RegisterWidget( {
		["name"] = "IAMoneyBar",
		["lstr"] = "MONEYBAR"
	} )
	MoveAny:RegisterWidget( {
		["name"] = "IATokenBar",
		["lstr"] = "TOKENBAR"
	} )
	if MoveAny:IsEnabled( "GAMETOOLTIP", true ) then
		if MABUILDNR < 100000 then
			MAGameTooltip = CreateFrame( "Frame", "MAGameTooltip", UIParent )
			MAGameTooltip:SetSize( 100, 100 )
			MAGameTooltip:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 100 )
		end

		GameTooltip:SetMovable( true )
		GameTooltip:SetUserPlaced( false )

		local gtp4 = nil
		local gtp5 = nil

		function MANearNumber( num1, num2, near )
			if num1 + near >= num2 and num1 - near <= num2 then
				return true
			end
			return false
		end

		function MAGameTooltipOnDefaultPosition()
			local p1, p2, p3, p4, p5 = GameTooltip:GetPoint()
			if p1 and p2 and p3 and p4 and p5 then
				if p2 == MAGameTooltip then
					return true
				elseif p2 == UIParent then
					if gtp4 == nil and gtp5 == nil then
						_, _, _, gtp4, gtp5 = GameTooltip:GetPoint()
						
						gtp4 = floor( gtp4 )
						gtp5 = floor( gtp5 )
					end

					if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
						p4 = floor( p4 )
						p5 = floor( p5 )
						if MANearNumber( p4, gtp4, 1 ) and MANearNumber( p5, gtp5, 1 ) then
							return true
						end
					end
				end
			end
			return false
		end

		function MAThinkGameTooltip()
			if MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) == true then
				local point, parent, relativePoint, ofsx, ofsy = GameTooltip:GetPoint()
				local owner = GameTooltip:GetOwner()
				if owner and owner == UIParent then
					local scale = GameTooltip:GetEffectiveScale()
					local mX, mY = GetCursorPosition()
					mX = mX / scale
					mY = mY / scale
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", mX + 22, mY + 22)
					GameTooltip.default = 1
				end
			end
			C_Timer.After( 0.01, MAThinkGameTooltip )
		end
		MAThinkGameTooltip()

		if MABUILDNR < 100000 then
			hooksecurefunc( GameTooltip, "SetPoint", function( self, ... )
				if self.masetpoint_gt then return end
				self.masetpoint_gt = true

				self:SetMovable( true )
				self:SetUserPlaced( false )

				local p1, p2, p3, p4, p5 = MAGameTooltip:GetPoint()

				if MAGameTooltipOnDefaultPosition() then
					if MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) == false then
						self:ClearAllPoints()
						self:SetPoint( p1, MAGameTooltip, p3, 0, 0 )
					end
				end

				self.masetpoint_gt = false
			end )
		end
		if MABUILDNR < 100000 then
			MoveAny:RegisterWidget( {
				["name"] = "MAGameTooltip",
				["lstr"] = "GAMETOOLTIP"
			} )
		end
	end



	-- BOTTOM
	if MainMenuBarPerformanceBarFrame then
		MainMenuBarPerformanceBarFrame:SetParent( MAHIDDEN )
	end
	if MoveAny:IsEnabled( "ACTIONBARS", true ) then
		for i = 1, 10 do
			if i ~= 2 then
				if i <= 6 or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
					MoveAny:RegisterWidget( {
						["name"] = "MAActionBar" .. i,
						["lstr"] = "ACTIONBAR" .. i
					}, true )
				end
			end
		end
	end
	if MoveAny:IsEnabled( "STANCEBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAStanceBar",
			["lstr"] = "STANCEBAR"
		} )
	end
	if MoveAny:IsEnabled( "PETBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAPetBar",
			["lstr"] = "PETBAR"
		} )
	end
	if MoveAny:IsEnabled( "POSSESSBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "PossessBarFrame",
			["lstr"] = "POSSESSBAR"
		} )
	end
	if ZoneAbilityFrame then
		ZoneAbilityFrame:SetParent( UIParent )
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 200 )
	end
	MoveAny:RegisterWidget( {
		["name"] = "ZoneAbilityFrame",
		["lstr"] = "ZONEABILITYFRAME"
	} )
	if MoveAny:IsEnabled( "GROUPLOOTCONTAINER", true ) then
		local glfsw, glfsh = 244, 84
		if GroupLootFrame1 then
			glfsw, glfsh = GroupLootFrame1:GetSize()
			for i = 2, 10 do
				local glf = _G["GroupLootFrame" .. i]
				if glf then -- i till 4 in classic
					hooksecurefunc( glf, "SetPoint", function( self, ... )
						if self.masetpoint then return end
						self.masetpoint = true
				
						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end

						self:ClearAllPoints()
						self:SetPoint( "BOTTOM", _G["GroupLootFrame" .. (i - 1)], "TOP", 0, 4 )
						
						self.masetpoint = false
					end )
				end
			end
		end
		MoveAny:RegisterWidget( {
			["name"] = "GroupLootFrame1",
			["lstr"] = "GROUPLOOTCONTAINER",
			["sw"] = glfsw,
			["sh"] = glfsh,
			["px"] = 0,
			["py"] = 200,
			["an"] = "BOTTOM",
			["re"] = "BOTTOM"
		} )
	end
	if MABUILDNR < 100000 then
		if ExtraAbilityContainer then
			ExtraAbilityContainer:SetSize( 180, 100 )
			ExtraAbilityContainer:ClearAllPoints()
			ExtraAbilityContainer:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 330 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "ExtraAbilityContainer",
			["lstr"] = "EXTRAABILITYCONTAINER"
		} )
	end
	if MoveAny:IsEnabled( "MAINMENUEXPBAR", true ) then
		if MainMenuExpBar then
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 140 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "MainMenuExpBar",
			["lstr"] = "MAINMENUEXPBAR"
		} )
	end
	if MoveAny:IsEnabled( "REPUTATIONWATCHBAR", true ) then
		if ReputationWatchBar then
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 130 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "ReputationWatchBar",
			["lstr"] = "REPUTATIONWATCHBAR"
		} )
	end
	if MoveAny:IsEnabled( "TOTEMBAR", true ) and MABUILD == "WRATH" and class == "SHAMAN" then
		MoveAny:RegisterWidget( {
			["name"] = "MultiCastActionBarFrame",
			["lstr"] = "TOTEMBAR"
		} )
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "LEAVEVEHICLE", true ) then
			if MainMenuBarVehicleLeaveButton then
				MainMenuBarVehicleLeaveButton:SetParent( UIParent )
			end
			MoveAny:RegisterWidget( {
				["name"] = "MainMenuBarVehicleLeaveButton",
				["lstr"] = "LEAVEVEHICLE"
			} )
		end
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "CASTINGBAR", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "CastingBarFrame",
				["lstr"] = "CASTINGBAR"
			} )
		end
		if MoveAny:IsEnabled( "TALKINGHEAD", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "TalkingHeadFrame",
				["lstr"] = "TALKINGHEAD",
				["secure"] = true
			} )
		end
	end
	


	-- BOTTOMLEFT
	if MoveAny:IsEnabled( "CHAT", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "ChatFrame1",
			["lstr"] = "CHAT"
		} )
	end



	-- LEFT



	-- CENTER
	MoveAny:RegisterWidget( {
		["name"] = "UIWidgetPowerBarContainerFrame",
		["lstr"] = "UIWIDGETPOWERBAR",
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
	MoveAny:InitDebuffBar()
	MoveAny:InitMAFPSFrame()
	
	MoveAny:MoveFrames()

	MoveAnyMinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("MoveAnyMinimapIcon", {
		type = "data source",
		text = "MoveAnyMinimapIcon",
		icon = 135994,
		OnClick = function(self, btn)
			if btn == "LeftButton" then
				MoveAny:ToggleDrag()
			elseif btn == "RightButton" then
				MoveAny:HideMinimapButton()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine( "MoveAny")
			tooltip:AddLine( MAGT( "MMBTNLEFT" ) )
			tooltip:AddLine( MAGT( "MMBTNRIGHT" ) )
		end,
	})
	if MoveAnyMinimapIcon then
		MAMMBTN = LibStub("LibDBIcon-1.0", true)
		if MAMMBTN then
			MAMMBTN:Register( "MoveAnyMinimapIcon", MoveAnyMinimapIcon, MoveAny:GetMinimapTable() )
		end
	end

	if MAMMBTN then
		if MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end

	if MoveAny:IsEnabled( "MALOCK", false ) then
		-- Not hide
	else
		MoveAny:ToggleDrag()
	end
end

local f = CreateFrame( "Frame" )
f:SetScript( "OnEvent", MoveAny.Event )
f:RegisterEvent( "PLAYER_LOGIN" )
