
local AddOnName, MoveAny = ...

MADragFrames = MADragFrames or {}
MAEleFrames = MAEleFrames or {}

local framelevel = 100

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
		local template = "CharacterFrameTabButtonTemplate"
		if MABUILD == "RETAIL" then
			template = "PanelTabButtonTemplate"
		end
		local tab = CreateFrame( "Button", frame:GetName() .. "Tab" .. i, frame, template )
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
		local p1, _, p3, p4, p5 = MoveAny:GetElePoint( name )
		MoveAny:SetElePoint( name, p1, UIParent, p3, p4 + x, p5 + y )

		p1, _, p3, p4, p5 = MoveAny:GetElePoint( name )
		parent.pos:SetText( format( "Position X: %d Y:%d", p4, p5 ) )
	end )

	return btn
end

function MACreateSlider( parent, x, y, name, key, steps, vmin, vmax, func )
	local slider = CreateFrame( "Slider", nil, parent, "OptionsSliderTemplate" )
	slider:SetWidth( parent:GetWidth() - 20 )
	slider:SetPoint( "TOPLEFT", parent, "TOPLEFT", x, y );
	slider.Low:SetText( vmin )
	slider.High:SetText( vmax )
	slider.Text:SetText( MAGT( key ) .. ": " .. MoveAny:GetEleOption( name, key, 1 ) )
	slider:SetMinMaxValues( vmin, vmax )
	slider:SetObeyStepOnDrag( true )
	slider:SetValueStep( steps )
	slider:SetValue( MoveAny:GetEleOption( name, key, 1 ) )
	slider:SetScript( "OnValueChanged", function(self, val)
		val = tonumber( string.format( "%" .. steps .. "f", val ) )
		if val then
			MoveAny:SetEleOption( name, key, val )
			slider.Text:SetText( MAGT( key ) .. ": " .. val )

			if func then
				func()
			end
		end
	end )
	return slider
end

function MAMenuOptions( opt, frame )
	if frame == nil then
		MoveAny:MSG( "FRAME NOT FOUND" )
	end

	local name = frame:GetName()
	local opts = MoveAny:GetEleOptions( name )
	
	local tabs = { GENERAL }

	if string.find( name, "MAActionBar" ) or name == "MAMenuBar" or name == "MAPetBar" or name == "MAStanceBar" then
		table.insert( tabs, ACTIONBARS_LABEL )
	end

	local contents = CreateTabs( opt, tabs )
	
	for i, tab in pairs( contents ) do
		local content = tab.content

		if string.find( content.name, GENERAL ) then
			content.pos = content:CreateFontString( nil, nil, "GameFontNormal" )
			content.pos:SetPoint( "TOPLEFT", content, "TOPLEFT", 4, -4 )
			local p1, _, p3, p4, p5 = MoveAny:GetElePoint( name )
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
				if frame:GetScale() > 0.3 then
					MoveAny:SetEleScale( name, frame:GetScale() - 0.1 )
					content.scale:SetText( format( "Scale: %0.1f", MoveAny:GetEleScale( name ) ) )
				end
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

			MACreateSlider( content, 10, -210, name, "ALPHAINCOMBAT", 0.1, 0, 1, MoveAny.UpdateAlphas )
			MACreateSlider( content, 10, -260, name, "ALPHANOTINCOMBAT", 0.1, 0, 1, MoveAny.UpdateAlphas )
			MACreateSlider( content, 10, -310, name, "ALPHAINVEHICLE", 0.1, 0, 1, MoveAny.UpdateAlphas )
		elseif string.find( content.name, ACTIONBARS_LABEL ) then
			local max = getn( frame.btns )
			local items = {}
			if max == 12 then
				items = { "1", "2", "3", "4", "6", "12" }
				if frame == MAMenuBar then
					items = { "1", "2", "3", "4", "6", "10", "11", "12" }
				end
			elseif max == 11 then
				items = { "1", "11" }
			elseif max == 10 then
				items = { "1", "2", "5", "10" }
			elseif max == 8 then
				items = { "1", "2", "4", "8" }
			elseif max == 7 then
				items = { "1", "7" }
			elseif max == 6 then
				items = { "1", "2", "3", "6" }
			elseif max == 5 then
				items = { "1", "5" }
			elseif max == 4 then
				items = { "1", "2", "4" }
			elseif max == 3 then
				items = { "1", "3" }
			elseif max == 2 then
				items = { "1", "2" }
			elseif max == 1 then
				items = { "1" }
			else
				MoveAny:MSG( "FOUND OTHER MAX: " .. max .. " for " .. name )
				items = { "1" }
			end

			opts["ROWS"] = opts["ROWS"] or 1
			local rows = {
				["name"] = "raid",
				["parent"]= content,
				["title"] = MAGT( "ROWS" ),
				["items"]= items,
				["defaultVal"] = opts["ROWS"], 
				["changeFunc"] = function( dropdown_frame, dropdown_val )
					dropdown_val = tonumber( dropdown_val )
					opts["ROWS"] = dropdown_val

					MAUpdateActionBar( frame )
				end
			}
			local ddrows = MACreateDropdown( rows )
			ddrows:SetPoint( "TOPLEFT", content, "TOPLEFT", 0, -26 );



			opts["SPACING"] = opts["SPACING"] or 4
			local slider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			slider:SetWidth( content:GetWidth() - 110 )
			slider:SetPoint( "TOPLEFT", content, "TOPLEFT", 100, -26 );
			slider.Low:SetText( 0 )
			slider.High:SetText( 16 )
			slider.Text:SetText( MAGT("SPACING") .. ": " .. opts["SPACING"] )
			slider:SetMinMaxValues( 0, 16 )
			slider:SetObeyStepOnDrag( true )
			slider:SetValueStep( 1 )
			slider:SetValue( opts["SPACING"] )
			slider:SetScript( "OnValueChanged", function(self, val)
				val = tonumber( string.format( "%" .. 0 .. "f", val ) )
				if val and val ~= opts["SPACING"] then
					opts["SPACING"] = val
					slider.Text:SetText( MAGT( "SPACING" ) .. ": " .. val )

					MAUpdateActionBar( frame )
				end
			end )
		end
	end
end

function MoveAny:IsBlizEditModeEnabled()
	if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
		return true
	end
	return false
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

function MoveAny:GetFrame( ele, name )
	local s1, e1 = strfind( name, ".", 1, true )
	if e1 then
		local tab = { strsplit(".", name ) }
		for i, na in pairs( tab ) do
			if i == 1 and _G[na] then
				ele = _G[na]
			elseif i > 1 and ele[na]then
				ele = ele[na]
			end
		end
	end
	return ele
end

function MoveAny:RegisterWidget( tab, debug )
	local name = tab.name
	local lstr = tab.lstr
	local lstri = tab.lstri
	if lstri then
		lstr = format( MAGT( lstr ), lstri )
	else
		lstr = MAGT( lstr )
	end
	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.secure
	local userplaced = tab.userplaced 
	
	tab.delay = tab.delay or 0.2
	if tab.delay < 2 then
		tab.delay = tab.delay + 0.2
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[name] then
		UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil 
	end

	local frame = MoveAny:GetFrame( _G[name], name )

	if _G[name .. "_DRAG"] == nil then
		_G[name .. "_DRAG"] = CreateFrame( "FRAME", name .. "_DRAG", UIParent )

		local dragframe = _G[name .. "_DRAG"]

		dragframe:SetClampedToScreen( true )
		dragframe:SetFrameStrata( "MEDIUM" )
		dragframe:SetFrameLevel( 99 )

		dragframe:SetAlpha( 0 )
		dragframe:EnableMouse( false )

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
			dragframe.t:SetAlpha( 0.33 )

			dragframe.name = dragframe:CreateFontString( nil, nil, "GameFontHighlightLarge" )
			dragframe.name:SetPoint( "CENTER", dragframe, "CENTER", 0, 0 )
			local font, fontSize, fontFlags = dragframe.name:GetFont()
			dragframe.name:SetFont( font, 15, fontFlags )
			dragframe.name:SetText( lstr )
			dragframe.name:Hide()

			dragframe:SetScript( "OnEnter", function()
				dragframe.name:Show()
				dragframe.t:SetAlpha( 0.66 )
			end )
			dragframe:SetScript( "OnLeave", function()
				dragframe.name:Hide()
				dragframe.t:SetAlpha( 0.33 )
			end )
		end

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

					dragframe.opt:SetSize( 300, 370 )
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

				MoveAny:SetElePoint( name, p1, UIParent, p3, p4, p5 )

				dragframe:SetMovable(true)

				dragframe:ClearAllPoints()
				dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
				if frame then
					local sw, sh = dragframe:GetSize()
					if not InCombatLockdown() then
						frame:SetSize( sw, sh )
					end

					local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
					frame:ClearAllPoints()
					frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
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

	tinsert( MAEleFrames, frame )

	frame.ignoreFramePositionManager = true

	frame:SetMovable( true )
	
	frame:SetDontSavePosition( true )
	frame:SetClampedToScreen( true )

	if frame.SetUserPlaced then
		frame:SetUserPlaced( userplaced or false )
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

	hooksecurefunc( frame, "SetPoint", function( self, ... )
		if self.elesetpoint then
			return
		end
		
		self:SetMovable( true )
		if self.SetUserPlaced then
			self:SetUserPlaced( userplaced or false )
		end

		if not self.secure then
			self.elesetpoint = true
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
			self:ClearAllPoints()
			self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
			self.elesetpoint = false
		end
	end )

	if not frame.secure then
		frame:ClearAllPoints()
		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
		if dbp1 and dbp3 then
			frame:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
		end
	end

	hooksecurefunc( frame, "SetScale", function( self, scale )
		if self.masetscale_ele then return end
		self.masetscale_ele = true

		if scale and scale > 0 then
			local dragframe = _G[name .. "_DRAG"]
			dragframe:SetScale( scale )
		end

		self.masetscale_ele = false
	end )

	if MoveAny:GetEleScale( name ) and MoveAny:GetEleScale( name ) > 0 then
		frame:SetScale( MoveAny:GetEleScale( name ) )
	end

	hooksecurefunc( frame, "SetSize", function( self, w, h )
		if w < 10 then
			w = sw
		end
		if h < 10 then
			h = sh
		end
		local df = _G[name .. "_DRAG"]
		df:SetSize( w, h )
	end )

	if not InCombatLockdown() then
		frame:SetSize( sw, sh )
	end

	local dragframe = _G[name .. "_DRAG"]
	dragframe:SetSize( sw, sh )

	dragframe:ClearAllPoints()
	dragframe:SetPoint( "CENTER", frame, "CENTER", 0, 0 )
	
	if MoveAny:IsEnabled( "MALOCK", false ) then
		dragframe:SetAlpha( 1 )
		dragframe:EnableMouse( true )
	else
		dragframe:SetAlpha( 0 )
		dragframe:EnableMouse( false )
	end
end

local invehicle = nil
local incombat = nil
local lastEle = nil
local lastSize = 0

function MoveAny:SetEleAlpha( ele, alpha )
	if ele:GetAlpha() ~= alpha then
		ele:SetAlpha( alpha )
	end
end

function MoveAny:SetMouseEleAlpha( ele )
	if lastEle and ele ~= lastEle then
		MoveAny:UpdateAlphas()
	end
	lastEle = ele
end

function MoveAny:CheckAlphas()
	if incombat ~= InCombatLockdown() then
		incombat = InCombatLockdown()
		MoveAny:UpdateAlphas()
	elseif UnitInVehicle and invehicle ~= UnitInVehicle( "PLAYER" ) then
		invehicle = UnitInVehicle( "PLAYER" )
		MoveAny:UpdateAlphas()
	end

	if lastSize ~= getn( MAEleFrames ) then
		lastSize = getn( MAEleFrames )
		MoveAny:UpdateAlphas()
	end

	local ele = GetMouseFocus()
	if ele then
		if tContains( MAEleFrames, ele ) then
			ele:SetAlpha(1)
			MoveAny:SetMouseEleAlpha( ele )
		elseif ele.GetParent and ele:GetParent() then
			if tContains( MAEleFrames, ele:GetParent() ) then
				ele:GetParent():SetAlpha(1)
				MoveAny:SetMouseEleAlpha( ele:GetParent() )
			elseif ele:GetParent().GetParent and ele:GetParent():GetParent() and tContains( MAEleFrames, ele:GetParent():GetParent() ) then
				ele:GetParent():GetParent():SetAlpha(1)
				MoveAny:SetMouseEleAlpha( ele:GetParent():GetParent() )
			end
		elseif lastEle then
			lastEle = nil
			MoveAny:UpdateAlphas()
		end
	elseif lastEle then
		lastEle = nil
		MoveAny:UpdateAlphas()
	end

	C_Timer.After( 0.1, MoveAny.CheckAlphas )
end

function MoveAny:UpdateAlphas()
	for i, ele in pairs( MAEleFrames ) do
		local alphaInVehicle = MoveAny:GetEleOption( ele:GetName(), "ALPHAINVEHICLE", 1 )
		local alphaInCombat = MoveAny:GetEleOption( ele:GetName(), "ALPHAINCOMBAT", 1 )
		local alphaNotInCombat = MoveAny:GetEleOption( ele:GetName(), "ALPHANOTINCOMBAT", 1 )
		if UnitInVehicle and invehicle then
			MoveAny:SetEleAlpha( ele, alphaInVehicle )
		elseif incombat then
			MoveAny:SetEleAlpha( ele, alphaInCombat )
		elseif not incombat then
			MoveAny:SetEleAlpha( ele, alphaNotInCombat )
		end
	end
end

function MoveAny:AnyActionbarEnabled()
	return MoveAny:IsEnabled( "ACTIONBARS", true ) or MoveAny:IsEnabled( "ACTIONBAR7", true ) or MoveAny:IsEnabled( "ACTIONBAR8", true ) or MoveAny:IsEnabled( "ACTIONBAR9", true ) or MoveAny:IsEnabled( "ACTIONBAR10", true )
end

function MoveAny:Event( event, ... )
	MoveAny.init = MoveAny.init or false
	if MoveAny.init then
		return
	end
	MoveAny.init = true

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
		end
		if MoveAny:AnyActionbarEnabled() then
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
				["lstr"] = "PLAYERFRAME",
				["userplaced"] = true
			} )
		end
	end
	if MoveAny:IsEnabled( "PETFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "PetFrame",
			["lstr"] = "PETFRAME",
			["userplaced"] = true
		} )
	end
	if RuneFrame and MoveAny:IsEnabled( "RUNEFRAME", false ) and class == "DEATHKNIGHT" then
		MoveAny:RegisterWidget( {
			["name"] = "RuneFrame",
			["lstr"] = "RUNEFRAME"
		} )
	end
	if TotemFrame and MoveAny:IsEnabled( "TOTEMFRAME", false ) and class == "SHAMAN" then
		MoveAny:RegisterWidget( {
			["name"] = "TotemFrame",
			["lstr"] = "TOTEMFRAME"
		} )
	end
	if WarlockPowerFrame and MoveAny:IsEnabled( "WARLOCKPOWERFRAME", false ) and class == "WARLOCK" then
		MoveAny:RegisterWidget( {
			["name"] = "WarlockPowerFrame",
			["lstr"] = "WARLOCKPOWERFRAME"
		} )
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "TARGETFRAME", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "TargetFrame",
				["lstr"] = "TARGETFRAME",
				["userplaced"] = true
			} )
		end
	end
	if MoveAny:IsEnabled( "TARGETFRAMESPELLBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TargetFrameSpellBar",
			["lstr"] = "TARGETFRAMESPELLBAR"
		} )
	end
	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "FOCUSFRAME", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "FocusFrame",
				["lstr"] = "FOCUSFRAME",
				["userplaced"] = true
			} )
		end
	end
	if MoveAny:IsEnabled( "FOCUSFRAMESPELLBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "FocusFrameSpellBar",
			["lstr"] = "FOCUSFRAMESPELLBAR"
		} )
	end
	if MoveAny:IsEnabled( "TARGETOFTARGETFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TargetFrameToT",
			["lstr"] = "TARGETOFTARGETFRAME",
			["userplaced"] = true
		} )
	end
	if MoveAny:IsEnabled( "TARGETOFFOCUSFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "FocusFrameToT",
			["lstr"] = "TARGETOFFOCUSFRAME",
			["userplaced"] = true
		} )
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
			if not InCombatLockdown() then
				self:ClearAllPoints()
				self:SetPoint( "RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0 )
			end
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
	if IASkills and MoveAny:IsEnabled( "IASKILLS", true ) and MABUILD ~= "RETAIL" then
		MoveAny:RegisterWidget( {
			["name"] = "IASkills",
			["lstr"] = "IASKILLS"
		} )
	end



	-- TOP
	if MoveAny:IsEnabled( "ZONETEXTFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "ZoneTextFrame",
			["lstr"] = "ZONETEXTFRAME",
			["userplaced"] = true
		} )
	end
	if MoveAny:IsEnabled( "UIWIDGETTOPCENTER", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetTopCenterContainerFrame",
			["lstr"] = "UIWIDGETTOPCENTER",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
		} )
	end
	


	-- TOPRIGHT
	if MoveAny:IsEnabled( "UIWIDGETBELOWMINIMAP", true ) then
		UIWidgetBelowMinimapContainerFrame:SetParent( UIParent )
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetBelowMinimapContainerFrame",
			["lstr"] = "UIWIDGETBELOWMINIMAP",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
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
						if self.qwfsetpoint then return end
						self.qwfsetpoint = true

						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end

						self:SetParent( ObjectiveTrackerFrame )

						QuestWatchFrame:ClearAllPoints()
						QuestWatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
						self.qwfsetpoint = false
					end )
					QuestWatchFrame:ClearAllPoints()
					QuestWatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )

					QuestWatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
				end

				if WatchFrame then
					hooksecurefunc( WatchFrame, "SetPoint", function( self, ... )
						if self.wfsetpoint then return end
						self.wfsetpoint = true

						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end
						
						self:SetParent( ObjectiveTrackerFrame )

						WatchFrame:ClearAllPoints()
						WatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
						self.wfsetpoint = false
					end )
					WatchFrame:ClearAllPoints()
					WatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )

					WatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
				end
			end
			if ObjectiveTrackerFrame then
				ObjectiveTrackerFrame:SetHeight( 600 )
				MoveAny:RegisterWidget( {
					["name"] = "ObjectiveTrackerFrame",
					["lstr"] = "QUESTTRACKER",
					["sh"] = 600,
					["userplaced"] = true
				} )
			end
		end
	else
		if MoveAny:IsEnabled( "QUEUESTATUSBUTTON", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "QueueStatusButton",
				["lstr"] = "QUEUESTATUSBUTTON"
			} )
		end
	end
	if MoveAny:IsEnabled( "VEHICLESEATINDICATOR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAVehicleSeatIndicator",
			["lstr"] = "VEHICLESEATINDICATOR"
		} )
	end
	if MoveAny:IsEnabled( "DURABILITY", true ) then
		if DurabilityFrame.SetAlerts ~= nil then
			DurabilityFrame:SetAlerts()
		elseif DurabilityFrame_SetAlerts ~= nil then
			DurabilityFrame_SetAlerts()
		end
		MoveAny:RegisterWidget( {
			["name"] = "DurabilityFrame",
			["lstr"] = "DURABILITY",
			["userplaced"] = true
		} )
	end



	-- RIGHT



	-- BOTTOMRIGHT
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
	if IAMoneyBar and MoveAny:IsEnabled( "MONEYBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IAMoneyBar",
			["lstr"] = "MONEYBAR"
		} )
	end
	if IATokenBar and MoveAny:IsEnabled( "TOKENBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IATokenBar",
			["lstr"] = "TOKENBAR"
		} )
	end
	
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
		if MoveAny:IsBlizEditModeEnabled() then
			C_Timer.After( 0.1, MAThinkGameTooltip )
			return
		end
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

	GameTooltip:SetMovable( true )
	GameTooltip:SetUserPlaced( false )

	if MABUILDNR < 100000 then
		if MoveAny:IsEnabled( "GAMETOOLTIP", true ) then
			MAGameTooltip = CreateFrame( "Frame", "MAGameTooltip", UIParent )
			MAGameTooltip:SetSize( 100, 100 )
			MAGameTooltip:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 100 )
		
			hooksecurefunc( GameTooltip, "SetPoint", function( self, ... )
				if self.gtsetpoint then return end
				self.gtsetpoint = true
	
				self:SetMovable( true )
				self:SetUserPlaced( false )
	
				local p1, p2, p3, p4, p5 = MAGameTooltip:GetPoint()
	
				if MAGameTooltipOnDefaultPosition() then
					if MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) == false then
						self:ClearAllPoints()
						self:SetPoint( p1, MAGameTooltip, p3, 0, 0 )
					end
				end
	
				self.gtsetpoint = false
			end )
		end

		if MoveAny:IsEnabled( "GAMETOOLTIP", true ) then
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
	if MABUILDNR < 100000 then
		if MoveAny:AnyActionbarEnabled()then
			for i = 1, 10 do
				if i ~= 2 then
					if i <= 6 and MoveAny:IsEnabled( "ACTIONBARS", true ) or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
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
				["lstr"] = "STANCEBAR",
				["secure"] = true
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
	end

	if ZoneAbilityFrame and MoveAny:IsEnabled( "ZONEABILITYFRAME", true ) then
		ZoneAbilityFrame:SetParent( UIParent )
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 200 )
		MoveAny:RegisterWidget( {
			["name"] = "ZoneAbilityFrame",
			["lstr"] = "ZONEABILITYFRAME",
			["userplaced"] = true
		} )
	end
	if MoveAny:IsEnabled( "GROUPLOOTCONTAINER", true ) then
		local glfsw, glfsh = 244, 84
		if GroupLootFrame1 then
			glfsw, glfsh = GroupLootFrame1:GetSize()
			for i = 2, 10 do
				local glf = _G["GroupLootFrame" .. i]
				if glf then
					hooksecurefunc( glf, "SetPoint", function( self, ... )
						if self.glfsetpoint then return end
						self.glfsetpoint = true
				
						self:SetMovable( true )
						if self.SetUserPlaced then
							self:SetUserPlaced( false )
						end

						self:ClearAllPoints()
						self:SetPoint( "BOTTOM", _G["GroupLootFrame" .. (i - 1)], "TOP", 0, 4 )
						
						self.glfsetpoint = false
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
		
			MoveAny:RegisterWidget( {
				["name"] = "ExtraAbilityContainer",
				["lstr"] = "EXTRAABILITYCONTAINER",
				["userplaced"] = true
			} )
		end
	end
	if MABUILDNR < 100000 then
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
	end

	if StatusTrackingBarManager then
		if MoveAny:IsEnabled( "STATUSTRACKINGBARMANAGER", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "StatusTrackingBarManager",
				["lstr"] = "STATUSTRACKINGBARMANAGER"
			} )
		end
	end
	
	if MoveAny:IsEnabled( "TOTEMBAR", true ) and MABUILD == "WRATH" and class == "SHAMAN" then
		C_Timer.After( 4, function()
			MoveAny:RegisterWidget( {
				["name"] = "MultiCastActionBarFrame",
				["lstr"] = "TOTEMBAR",
				["userplaced"] = true
			} )
		end )
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
		if TalkingHeadFrame then
			if MoveAny:IsEnabled( "TALKINGHEAD", true ) then
				MoveAny:RegisterWidget( {
					["name"] = "TalkingHeadFrame",
					["lstr"] = "TALKINGHEAD",
					["secure"] = true
				} )
			end
		end
	end
	if AlertFrame and MoveAny:IsEnabled( "ALERTFRAME", true ) then
		local afsw, afsh = 276, 68
		MoveAny:RegisterWidget( {
			["name"] = "AlertFrame",
			["lstr"] = "ALERTFRAME",
			["sw"] = afsw,
			["sh"] = afsh
		} )
	end
	


	-- BOTTOMLEFT
	for i = 1, 4 do
		if _G["ChatFrame" .. i] then
			if MoveAny:IsEnabled( "CHATBUTTONFRAME" .. i, false ) then
				MoveAny:RegisterWidget( {
					["name"] = "ChatFrame" .. i .. "ButtonFrame",
					["lstr"] = "CHATBUTTONFRAME",
					["lstri"] = i
				} )
			end


			
			local left = -35
			if  MoveAny:IsEnabled( "CHATBUTTONFRAME" .. i, false ) then
				left = 0
			end
			local bottom = -35
			if MoveAny:IsEnabled( "CHATEDITBOX" .. i, false ) then
				bottom = 0
			end
			hooksecurefunc( _G["ChatFrame" .. i], "SetClampRectInsets", function( self )
				if self.setclamprectinsets_ma then return end
				self.setclamprectinsets_ma = true
				_G["ChatFrame" .. i]:SetClampRectInsets( left, 25, 25, bottom )
				self.setclamprectinsets_ma = false
			end )
			_G["ChatFrame" .. i]:SetClampRectInsets( left, 25, 25, bottom )
			


			if MoveAny:IsEnabled( "CHAT" .. i, false ) then
				MoveAny:RegisterWidget( {
					["name"] = "ChatFrame" .. i,
					["lstr"] = "CHAT",
					["lstri"] = i
				} )
			end
		end

		if MoveAny:IsEnabled( "CHATEDITBOX" .. i, false ) then
			MoveAny:RegisterWidget( {
				["name"] = "ChatFrame" .. i .. "EditBox",
				["lstr"] = "CHATEDITBOX",
				["lstri"] = i
			} )
		end
	end
	if QuickJoinToastButton and MoveAny:IsEnabled( "CHATQUICKJOIN", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "QuickJoinToastButton",
			["lstr"] = "CHATQUICKJOIN"
		} )
	end



	-- LEFT



	-- CENTER
	if UIWidgetPowerBarContainerFrame and MoveAny:IsEnabled( "UIWIDGETPOWERBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetPowerBarContainerFrame",
			["lstr"] = "UIWIDGETPOWERBAR",
			["sw"] = 36 * 6,
			["sh"] = 36 * 1
		} )
	end



	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] then
		ArenaEnemyFrames:SetMovable( true )
		ArenaEnemyFrames:SetUserPlaced( true )
		UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] = nil 
	end


	
	MoveAny:InitMALock()
	MoveAny:InitMAVehicleSeatIndicator()
	if MABUILDNR < 100000 then
		MoveAny:InitStanceBar()
		MoveAny:InitMinimap()
		MoveAny:InitBuffBar()
		MoveAny:InitDebuffBar()
	end
	MoveAny:InitMicroMenu()
	MoveAny:InitBags()
	MoveAny:InitMAFPSFrame()
	
	if MoveAny.MoveFrames then
		MoveAny:MoveFrames()
	end

	MoveAnyMinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("MoveAnyMinimapIcon", {
		type = "data source",
		text = "MoveAnyMinimapIcon",
		icon = 135994,
		OnClick = function(self, btn)
			if btn == "LeftButton" then
				MoveAny:ToggleMALock()
			elseif IsShiftKeyDown() and btn == "RightButton" then
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
		MoveAny:ShowMALock()
	end
	if MoveAny:IsEnabled( "MAPROFILES", false ) then
		MoveAny:ShowProfiles()
	end

	MoveAny:CheckAlphas()
end

local f = CreateFrame( "Frame" )
f:SetScript( "OnEvent", MoveAny.Event )
f:RegisterEvent( "PLAYER_LOGIN" )
