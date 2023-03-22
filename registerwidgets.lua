
local AddOnName, MoveAny = ...

local MAEF = {}
function MoveAny:GetEleFrames()
	return MAEF
end

local MAAF = {}
function MoveAny:GetAlphaFrames()
	return MAAF
end

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
	frame.tabs = {}

	local sw, sh = frame:GetSize()
	for i = 1, frame.numTabs do
		local template = "CharacterFrameTabButtonTemplate"
		if MoveAny:GetWoWBuild() == "RETAIL" then
			template = "PanelTabButtonTemplate"
		end
		frame.tabs[i] = CreateFrame( "Button", frame:GetName() .. "Tab" .. i, frame, template )
		local tab = frame.tabs[i]
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
			tab:SetPoint( "TOPLEFT", _G[frame:GetName() .. "Tab" .. (i - 1)], "TOPRIGHT", 4, 0 )
		end
	end

	SelectTab( frame.tabs[1] )

	return frame.tabs
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

function MoveAny:CreateSlider( parent, x, y, name, key, value, steps, vmin, vmax, func )
	local slider = CreateFrame( "Slider", nil, parent, "OptionsSliderTemplate" )
	slider:SetWidth( parent:GetWidth() - 20 )
	slider:SetPoint( "TOPLEFT", parent, "TOPLEFT", x, y );
	slider.Low:SetText( vmin )
	slider.High:SetText( vmax )
	slider.Text:SetText( MoveAny:GT( "LID_" .. key ) .. ": " .. MoveAny:GetEleOption( name, key, value ) )
	slider:SetMinMaxValues( vmin, vmax )
	slider:SetObeyStepOnDrag( true )
	slider:SetValueStep( steps )
	slider:SetValue( MoveAny:GetEleOption( name, key, value ) )
	slider:SetScript( "OnValueChanged", function(self, val)
		val = tonumber( string.format( "%" .. steps .. "f", val ) )
		if val then
			MoveAny:SetEleOption( name, key, val )
			slider.Text:SetText( MoveAny:GT( "LID_" .. key ) .. ": " .. val )

			if func then
				func()
			end
		end
	end )
	return slider
end

function MoveAny:MenuOptions( opt, frame )
	if frame == nil then
		MoveAny:MSG( "FRAME NOT FOUND" )
		return
	end

	local name = frame:GetName()
	local opts = MoveAny:GetEleOptions( name )
	
	local tabs = { GENERAL }

	if string.find( name, "MAActionBar" ) or string.find( name, "MultiBar" ) or name == "MainMenuBar" or name == "MAMenuBar" or name == "MAPetBar" or name == "StanceBar" then
		table.insert( tabs, ACTIONBARS_LABEL )
	end

	if string.find( name, "MABuffBar" ) then
		table.insert( tabs, MoveAny:GT( "LID_BUFFS" ) )
	end

	CreateTabs( opt, tabs )

	for i, tab in pairs( opt.tabs ) do
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
			hide:SetPoint( "TOPLEFT", content, "TOPLEFT", 150, -110 )
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

			MoveAny:CreateSlider( content, 10, -190, name, "ALPHAINVEHICLE", 1, 0.1, 0, 1, MoveAny.UpdateAlphas )
			MoveAny:CreateSlider( content, 10, -220, name, "ALPHAISMOUNTED", 1, 0.1, 0, 1, MoveAny.UpdateAlphas )
			MoveAny:CreateSlider( content, 10, -250, name, "ALPHAINRESTEDAREA", 1, 0.1, 0, 1, MoveAny.UpdateAlphas )
			MoveAny:CreateSlider( content, 10, -280, name, "ALPHAINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas )
			MoveAny:CreateSlider( content, 10, -310, name, "ALPHANOTINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas )
		elseif string.find( content.name, ACTIONBARS_LABEL ) then
			local slides = {}
			local items = {}
			local function UpdateRowItems()
				local maxBtns = getn( frame.btns )
				if frame ~= MAMenuBar and frame ~= StanceBar then
					if opts["COUNT"] then
						if opts["COUNT"] > 0 then
							maxBtns = opts["COUNT"]
						end
					end
				end
				if frame == MAMenuBar then
					if MoveAny:GetWoWBuild() == "RETAIL" then
						items = { "1", "2", "3", "4", "5", "10", "11" }
					else
						items = { "1", "2", "3", "4", "5", "8", "9", "10" }
					end
				elseif maxBtns == 12 then
					items = { "1", "2", "3", "4", "6", "12" }
				elseif maxBtns == 11 then
					items = { "1", "11" }
				elseif maxBtns == 10 then
					items = { "1", "2", "5", "10" }
				elseif maxBtns == 9 then
					items = { "1", "3", "9" }
				elseif maxBtns == 8 then
					items = { "1", "2", "4", "8" }
				elseif maxBtns == 7 then
					items = { "1", "7" }
				elseif maxBtns == 6 then
					items = { "1", "2", "3", "6" }
				elseif maxBtns == 5 then
					items = { "1", "5" }
				elseif maxBtns == 4 then
					items = { "1", "2", "4" }
				elseif maxBtns == 3 then
					items = { "1", "3" }
				elseif maxBtns == 2 then
					items = { "1", "2" }
				elseif maxBtns == 1 then
					items = { "1" }
				else
					--MoveAny:MSG( "FOUND OTHER MAX: " .. maxBtns .. " for " .. name )
					items = { "1" }
				end
			end
			UpdateRowItems()

			local max = getn( frame.btns )
			local count = opts["COUNT"] or max
			local rows = opts["ROWS"] or 1

			local PY = -20

			if frame ~= MAMenuBar and frame ~= StanceBar then
				slides.sliderCount = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				local sliderCount = slides.sliderCount
				sliderCount:SetWidth( content:GetWidth() - 110 )
				sliderCount:SetPoint( "TOPLEFT", content, "TOPLEFT", 10, PY );
				sliderCount.Low:SetText( "" )
				sliderCount.High:SetText( "" )
				sliderCount.Text:SetText( MoveAny:GT("LID_COUNT") .. ": " .. count )
				sliderCount:SetMinMaxValues( 0, max )
				sliderCount:SetObeyStepOnDrag( true )
				sliderCount:SetValueStep( 1 )
				sliderCount:SetValue( count )
				sliderCount:SetScript( "OnValueChanged", function(self, val)
					val = tonumber( string.format( "%" .. 0 .. "f", val ) )
					if val and val ~= opts["ROWS"] then
						opts["COUNT"] = val
						self.Text:SetText( MoveAny:GT( "LID_COUNT" ) .. ": " .. val )
						
						UpdateRowItems()
						if slides.sliderRows then
							slides.sliderRows:SetMinMaxValues( 1, #items )
							slides.sliderRows:SetValue( slides.sliderRows:GetValue() )
						end

						if MoveAny.UpdateActionBar then
							MoveAny:UpdateActionBar( frame )
						end
					end
				end )

				PY = PY - 30
			end

			slides.sliderRows = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			local sliderRows = slides.sliderRows
			sliderRows:SetWidth( content:GetWidth() - 110 )
			sliderRows:SetPoint( "TOPLEFT", content, "TOPLEFT", 10, PY );
			sliderRows.Low:SetText( "" )
			sliderRows.High:SetText( "" )
			sliderRows.Text:SetText( MoveAny:GT("LID_ROWS") .. ": " .. rows )
			sliderRows:SetMinMaxValues( 1, #items )
			sliderRows:SetObeyStepOnDrag( true )
			sliderRows:SetValueStep( 1 )
			sliderRows:SetValue( rows )
			sliderRows:SetScript( "OnValueChanged", function(self, val)
				val = tonumber( string.format( "%" .. 0 .. "f", val ) )
				local value = items[val]
				if value and value ~= opts["ROWS"] then
					opts["ROWS"] = value
					self.Text:SetText( MoveAny:GT( "LID_ROWS" ) .. ": " .. value )
					
					if frame.UpdateSystemSettingNumRows then
						frame.numRows = value
						frame:UpdateSystemSettingNumRows()
					end

					if MoveAny.UpdateActionBar then
						MoveAny:UpdateActionBar( frame )
					end
				end
			end )

			PY = PY - 30


			local flipped = CreateFrame( "CheckButton", "flipped", content, "ChatConfigCheckButtonTemplate" )
			flipped:SetSize( btnsize, btnsize )
			flipped:SetPoint( "TOPLEFT", content, "TOPLEFT", 4, PY )
			flipped:SetChecked( MoveAny:GetEleOption( name, "FLIPPED", false ) )
			flipped:SetText( MoveAny:GT( "LID_FLIPPED" ) )
			flipped:SetScript( "OnClick", function()
				local checked = flipped:GetChecked()
				MoveAny:SetEleOption( name, "FLIPPED", checked )
				if MoveAny.UpdateActionBar then
					MoveAny:UpdateActionBar( frame )
				end
			end )
			flipped.text = flipped:CreateFontString( nil, "ARTWORK" )
			flipped.text:SetFont( STANDARD_TEXT_FONT, 12, "THINOUTLINE" )
			flipped.text:SetPoint( "LEFT", flipped, "RIGHT", 0, 0)
			flipped.text:SetText( MoveAny:GT( "LID_FLIPPED" ) )

			PY = PY - 40



			opts["SPACING"] = opts["SPACING"] or 2
			local slider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			slider:SetWidth( content:GetWidth() - 110 )
			slider:SetPoint( "TOPLEFT", content, "TOPLEFT", 10, PY );
			slider.Low:SetText( 0 )
			slider.High:SetText( 16 )
			slider.Text:SetText( MoveAny:GT("LID_SPACING") .. ": " .. opts["SPACING"] )
			slider:SetMinMaxValues( 0, 16 )
			slider:SetObeyStepOnDrag( true )
			slider:SetValueStep( 1 )
			slider:SetValue( opts["SPACING"] )
			slider:SetScript( "OnValueChanged", function(self, val)
				val = tonumber( string.format( "%" .. 0 .. "f", val ) )
				if val and val ~= opts["SPACING"] then
					opts["SPACING"] = val
					slider.Text:SetText( MoveAny:GT( "LID_SPACING" ) .. ": " .. val )

					if MoveAny.UpdateActionBar then
						MoveAny:UpdateActionBar( frame )
					end
				end
			end )
		elseif string.find( content.name, MoveAny:GT( "LID_BUFFS" ) ) then
			MoveAny:CreateSlider( content, 10, -20, name, "MABUFFLIMIT", 10, 1, 1, 20, MAUpdateBuffs )
			MoveAny:CreateSlider( content, 10, -60, name, "MABUFFSPACINGX", 4, 1, 0, 30, MAUpdateBuffs )
			MoveAny:CreateSlider( content, 10, -100, name, "MABUFFSPACINGY", 10, 1, 0, 30, MAUpdateBuffs )
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
	MoveAny:SetEnabled( "LID_SHOWMINIMAPBUTTON", not MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) )
	if MAMMBTN then
		if MoveAny:IsEnabled( "SHOWMINIMAPBUTTON", true ) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end
end

function MoveAny:HideMinimapButton()
	MoveAny:SetEnabled( "LID_SHOWMINIMAPBUTTON", false )
	if MAMMBTN then
		MAMMBTN:Hide("MoveAnyMinimapIcon")
	end
end

function MoveAny:ShowMinimapButton()
	MoveAny:SetEnabled( "LID_SHOWMINIMAPBUTTON", true )
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
		lstr = format( MoveAny:GT( lstr ), lstri )
	else
		lstr = MoveAny:GT( lstr )
	end
	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.ma_secure
	local userplaced = tab.userplaced 

	local cleft = tab.cleft
	local cright = tab.cright
	local ctop = tab.ctop
	local cbottom = tab.cbottom
	local posx = tab.posx
	local posy = tab.posy
	
	tab.delay = tab.delay or 0.2
	if tab.delay < 2 then
		tab.delay = tab.delay + 0.2
	end

	local enabled1, forced1 = MoveAny:IsInEditModeEnabled( name )
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled( lstr )
	if enabled1 or enabled2 then
		if not MoveAny:IsEnabled( "EDITMODE", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:MSG( "YOU NEED EDITMODE IN MOVEANY ENABLED" )
			return
		end
		if not forced1 and not forced2 then
			MoveAny:MSG( format( MoveAny:GT( "LID_HELPTEXT" ), lstr ) )
			return
		end
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
		
		dragframe.t = dragframe:CreateTexture( name .. "_DRAG.t", "BACKGROUND", nil, 1 )
		dragframe.t:SetAllPoints( dragframe )
		dragframe.t:SetColorTexture( MoveAny:GetColor( "el" ) )
		dragframe.t:SetAlpha( 0.33 )

		dragframe.name = dragframe:CreateFontString( nil, nil, "GameFontHighlightLarge" )
		dragframe.name:SetPoint( "CENTER", dragframe, "CENTER", 0, 0 )
		local font, fontSize, fontFlags = dragframe.name:GetFont()
		dragframe.name:SetFont( font, 15, fontFlags )
		local enab, forc = MoveAny:IsInEditModeEnabled( name )
		if enab then
			if not forc then
				lstr = lstr .. " |cFFFFFF00" .. MoveAny:GT( "LID_ISENABLEDINEDITMODE" )
			end
		end
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

					framelevel = framelevel + 510 -- 509 <- closebutton height

					dragframe.opt:SetSize( 300, 370 )
					dragframe.opt:SetPoint( "CENTER" )
					dragframe.opt:SetClampedToScreen( true )
					dragframe.opt:SetMovable( true )
					dragframe.opt:EnableMouse( true )
					dragframe.opt:RegisterForDrag( "LeftButton" )
					dragframe.opt:SetScript( "OnDragStart", dragframe.opt.StartMoving )
					dragframe.opt:SetScript( "OnDragStop", dragframe.opt.StopMovingOrSizing )

					MoveAny:MenuOptions( dragframe.opt, frame )
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
				p4 = MoveAny:Grid( p4 )
				p5 = MoveAny:Grid( p5 )
				MoveAny:SetElePoint( name, p1, UIParent, p3, p4, p5 )

				if dragframe.opt and dragframe.opt.tabs and dragframe.opt.tabs[1] then
					local tab = dragframe.opt.tabs[1]
					tab.content.pos:SetText( format( "Position X: %d Y:%d", p4, p5 ) )
				end

				dragframe:SetMovable(true)

				dragframe:ClearAllPoints()
				dragframe:SetPoint( "CENTER", frame, "CENTER", posx, posy )
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

		tinsert( MoveAny:GetDragFrames(), dragframe )
	end
	
	if frame == nil then
		C_Timer.After( tab.delay or 0.2, function()
			MoveAny:RegisterWidget( tab )
		end )
		return false
	end

	if cleft or cright or ctop or cbottom then
		local l = cleft or 0
		local r = cright or 0
		local t = ctop or 0
		local b = cbottom or 0
		if frame.SetClampRectInsets then
			frame:SetClampRectInsets( l, r, t, b )
		end
	end

	tinsert( MoveAny:GetEleFrames(), frame )
	tinsert( MoveAny:GetAlphaFrames(), frame )

	for i, btn in pairs( { frame:GetChildren() } ) do
		function btn:GetMAEle()
			return frame
		end
	end

	frame.ignoreFramePositionManager = true

	frame:SetMovable( true )
	if frame.SetUserPlaced and frame:IsMovable() then
		frame:SetUserPlaced( userplaced or false )
	end

	frame:SetDontSavePosition( true )
	frame:SetClampedToScreen( true )

	local maframe1 = _G["MA" .. name]
	local maframe2 = _G[string.gsub( name, "MA", "" )]
	local dragf = _G[name .. "_DRAG"]
	if MoveAny:GetEleOption( name, "Hide", false ) then
		frame.oldparent = frame.oldparent or frame:GetParent()
		
		hooksecurefunc( frame, "SetParent", function( self, newParent )
			local pn = newParent
			if newParent.GetName then
				pn = newParent:GetName()
			end

			if self.ma_setparent then return end
			self.ma_setparent = true
			if MoveAny:GetEleOption( name, "Hide", false ) then
				self:SetParent( MAHIDDEN )
			else
				self:SetParent( self.oldparent )
			end
			self.ma_setparent = false
		end )
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

	frame.ma_secure = secure

	local bToSmall = false
	if sw or sh then
		bToSmall = true
	end

	sw = sw or frame:GetWidth()
	sh = sh or frame:GetHeight()
	sw = math.floor( sw )
	sh = math.floor( sh )

	if MoveAny:GetElePoint( name ) == nil then
		local an, parent, re, px, py = frame:GetPoint()
		if (parent == nil or parent == UIParent) and an ~= nil and re ~= nil then
			MoveAny:SetElePoint( name, an, UIParent, re, MoveAny:Grid( px ), MoveAny:Grid( py ) ) 
		elseif frame:GetLeft() and frame:GetBottom() then
			MoveAny:SetElePoint( name, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", MoveAny:Grid( frame:GetLeft() ), MoveAny:Grid( frame:GetBottom() ) ) 
		elseif parent ~= nil then
			MoveAny:SetElePoint( name, an, UIParent, re, MoveAny:Grid( parent:GetLeft() ), MoveAny:Grid( parent:GetBottom() ) ) 
		else
			local an = tab.an or "CENTER" 
			local re = tab.re or "CENTER" 
			local px = tab.px or 0
			local py = tab.py or 0
			MoveAny:SetElePoint( name, an, UIParent, re, px, py ) 
		end
	end
	local osw, osh = MoveAny:GetEleSize( name )
	if osw ~= sw or osh ~= sh then
		MoveAny:SetEleSize( name, sw, sh )
	end

	if frame.SetPointBase then
		--frame.layoutApplyInProgress = true

		frame:HookScript( "OnUpdate", function( self, elapsed )
			if self.ma_retry_setpoint and not InCombatLockdown() then
				local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
				self:ClearAllPoints()
				self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )

				self.ma_retry_setpoint = false
			end
		end )
	end
	hooksecurefunc( frame, "SetPoint", function( self, ... )
		if self.elesetpoint then
			return
		end

		--self.layoutApplyInProgress = true

		if not self.ma_secure then
			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( userplaced or false )
			end
			
			self.elesetpoint = true
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )

			if not self.SetPointBase then
				self:ClearAllPoints()
				self:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
			else
				self.ma_retry_setpoint = true
			end
			self.elesetpoint = false
		end
	end )

	if not frame.ma_secure then
		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( name )
		if dbp1 and dbp3 then
			frame:ClearAllPoints()
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
		local isToSmall = false
		local df = _G[name .. "_DRAG"]
		df:SetSize( w, h )
		
		if w < sw then
			w = sw
			isToSmall = true
		end
		if h < sh then
			h = sh
			isToSmall = true
		end

		if bToSmall and isToSmall then
			df:SetSize( w, h )
			self:SetSize( w, h )
		end
	end )
	frame:SetSize( frame:GetSize() )

	if not InCombatLockdown() then
		frame:SetSize( sw, sh )
	end

	local dragframe = _G[name .. "_DRAG"]
	dragframe:SetSize( sw, sh )

	dragframe:ClearAllPoints()
	dragframe:SetPoint( "CENTER", frame, "CENTER", posx, posy )
	
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

	if lastSize ~= getn( MoveAny:GetAlphaFrames() ) then
		lastSize = getn( MoveAny:GetAlphaFrames() )
		MoveAny:UpdateAlphas()
	end

	local ele = GetMouseFocus()
	if ele and ele ~= CompactRaidFrameManager then
		if tContains( MoveAny:GetAlphaFrames(), ele ) then
			ele:SetAlpha( 1 )
			MoveAny:SetMouseEleAlpha( ele )
		elseif ele.GetMAEle then
			ele = ele:GetMAEle()
			ele:SetAlpha( 1 )
			MoveAny:SetMouseEleAlpha( ele )
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
	for i, ele in pairs( MoveAny:GetEleFrames() ) do
		local alphaInVehicle = MoveAny:GetEleOption( ele:GetName(), "ALPHAINVEHICLE", 1 )
		local alphaInCombat = MoveAny:GetEleOption( ele:GetName(), "ALPHAINCOMBAT", 1 )
		local alphaNotInCombat = MoveAny:GetEleOption( ele:GetName(), "ALPHANOTINCOMBAT", 1 )
		local alphaInRestedArea = MoveAny:GetEleOption( ele:GetName(), "ALPHAINRESTEDAREA", 1 )
		local alphaIsMounted = MoveAny:GetEleOption( ele:GetName(), "ALPHAISMOUNTED", 1 )
		if UnitInVehicle and invehicle then
			MoveAny:SetEleAlpha( ele, alphaInVehicle )
		elseif IsMounted and IsMounted() then
			MoveAny:SetEleAlpha( ele, alphaIsMounted )
		elseif IsResting and IsResting() then
			MoveAny:SetEleAlpha( ele, alphaInRestedArea )
		else
			if incombat then
				MoveAny:SetEleAlpha( ele, alphaInCombat )
			elseif not incombat then
				MoveAny:SetEleAlpha( ele, alphaNotInCombat )
			end
		end
	end
end

function MoveAny:AnyActionbarEnabled()
	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		return MoveAny:IsEnabled( "ACTIONBARS", true ) or MoveAny:IsEnabled( "ACTIONBAR3", true ) or MoveAny:IsEnabled( "ACTIONBAR4", true ) or MoveAny:IsEnabled( "ACTIONBAR7", true ) or MoveAny:IsEnabled( "ACTIONBAR8", true ) or MoveAny:IsEnabled( "ACTIONBAR9", true ) or MoveAny:IsEnabled( "ACTIONBAR10", true )
	else
		return false
	end
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
	
	MoveAny:InitSlash()
	MoveAny:InitDB()

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		if MoveAny:IsEnabled( "ACTIONBARS", true ) then
			if MainMenuBarPerformanceBarFrame then
				MainMenuBarPerformanceBarFrame:SetParent( MAHIDDEN )
			end
			
			if UIPARENT_MANAGED_FRAME_POSITIONS then
				UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
			end
			if MainMenuBarArtFrame then
				if UIPARENT_MANAGED_FRAME_POSITIONS then
					UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBarArtFrame"] = nil
				end
				MainMenuBarArtFrame:Hide()
			end
		end
	end

	MoveAny:InitActionBarLayouts()
	if MoveAny:AnyActionbarEnabled() then
		MoveAny:CustomBars()
		MoveAny:UpdateABs()
	end
	if MoveAny.InitStanceBar then
		MoveAny:InitStanceBar()
	end
	if MoveAny.InitPetBar then
		MoveAny:InitPetBar()
	end

	if Arena_LoadUI then
		if MoveAny.InitArenaEnemyFrames then
			MoveAny:InitArenaEnemyFrames()
		end
		if MoveAny.InitArenaPrepFrames then
			MoveAny:InitArenaPrepFrames()
		end
	end


	-- TOPLEFT
	if MoveAny:IsEnabled( "EDITMODE", MoveAny:GetWoWBuildNr() < 100000 ) then
		if MoveAny:IsEnabled( "PLAYERFRAME", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:RegisterWidget( {
				["name"] = "PlayerFrame",
				["lstr"] = "LID_PLAYERFRAME",
				["userplaced"] = true
			} )
		end
		if MoveAny:IsEnabled( "TARGETFRAME", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:RegisterWidget( {
				["name"] = "TargetFrame",
				["lstr"] = "LID_TARGETFRAME",
				["userplaced"] = true
			} )
		end
		if TargetFrameNumericalThreat and MoveAny:IsEnabled( "TargetFrameNumericalThreat", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "TargetFrameNumericalThreat",
				["lstr"] = "LID_TargetFrameNumericalThreat",
				["userplaced"] = true
			} )
		end
		if FocusFrame and MoveAny:IsEnabled( "FOCUSFRAME", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:RegisterWidget( {
				["name"] = "FocusFrame",
				["lstr"] = "LID_FOCUSFRAME",
				["userplaced"] = true
			} )
		end
		if MoveAny:IsEnabled( "BUFFS", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:RegisterWidget( {
				["name"] = "MABuffBar",
				["lstr"] = "LID_BUFFS"
			} )
		end
		if MoveAny:IsEnabled( "DEBUFFS", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "MADebuffBar",
				["lstr"] = "LID_DEBUFFS"
			} )
		end
		if MoveAny:IsEnabled( "GAMETOOLTIP", MoveAny:GetWoWBuildNr() < 100000 ) then
			MoveAny:RegisterWidget( {
				["name"] = "MAGameTooltip",
				["lstr"] = "LID_GAMETOOLTIP"
			} )
		end
		if MoveAny:IsEnabled( "PETBAR", MoveAny:GetWoWBuildNr() < 100000 ) then
			if PetActionBar then
				MoveAny:RegisterWidget( {
					["name"] = "PetActionBar",
					["lstr"] = "LID_PETBAR"
				} )
			else
				MoveAny:RegisterWidget( {
					["name"] = "MAPetBar",
					["lstr"] = "LID_PETBAR"
				} )
			end
		end
		if MoveAny:IsEnabled( "STANCEBAR", MoveAny:GetWoWBuildNr() < 100000 ) then
			if StanceBar then
				MoveAny:RegisterWidget( {
					["name"] = "StanceBar",
					["lstr"] = "LID_STANCEBAR",
					["secure"] = true
				} )
			end
		end
		if PossessActionBar then
			if MoveAny:IsEnabled( "POSSESSBAR", false ) then
				MoveAny:RegisterWidget( {
					["name"] = "PossessActionBar",
					["lstr"] = "LID_POSSESSBAR"
				} )
			end
		elseif PossessBarFrame then
			if MoveAny:IsEnabled( "POSSESSBAR", false ) then
				MoveAny:RegisterWidget( {
					["name"] = "PossessBarFrame",
					["lstr"] = "LID_POSSESSBAR"
				} )
			end
		end
		if MoveAny:IsEnabled( "LEAVEVEHICLE", MoveAny:GetWoWBuildNr() < 100000 ) then
			if MainMenuBarVehicleLeaveButton then
				MainMenuBarVehicleLeaveButton:SetParent( UIParent )
			end
			MoveAny:RegisterWidget( {
				["name"] = "MainMenuBarVehicleLeaveButton",
				["lstr"] = "LID_LEAVEVEHICLE"
			} )
		end
		if ExtraAbilityContainer and MoveAny:IsEnabled( "EXTRAABILITYCONTAINER", MoveAny:GetWoWBuildNr() < 100000 ) then
			ExtraAbilityContainer:SetSize( 180, 100 )

			MoveAny:RegisterWidget( {
				["name"] = "ExtraAbilityContainer",
				["lstr"] = "LID_EXTRAABILITYCONTAINER",
				["userplaced"] = true
			} )
		end
		if PlayerCastingBarFrame then
			if MoveAny:IsEnabled( "CASTINGBAR", MoveAny:GetWoWBuildNr() < 100000 ) then
				MoveAny:RegisterWidget( {
					["name"] = "PlayerCastingBarFrame",
					["lstr"] = "LID_CASTINGBAR",
				} )
			end
		else
			if MoveAny:IsEnabled( "CASTINGBAR", MoveAny:GetWoWBuildNr() < 100000 ) then
				MoveAny:RegisterWidget( {
					["name"] = "CastingBarFrame",
					["lstr"] = "LID_CASTINGBAR"
				} )
			end
		end
		if TalkingHeadFrame then
			if MoveAny:IsEnabled( "TALKINGHEAD", MoveAny:GetWoWBuildNr() < 100000 ) then
				MoveAny:RegisterWidget( {
					["name"] = "TalkingHeadFrame",
					["lstr"] = "LID_TALKINGHEAD",
					["secure"] = true
				} )
			end
		end

		if MoveAny:GetWoWBuild() == "RETAIL" then
			local ABNames = {}
			ABNames[1] = "MainMenuBar"
			ABNames[2] = "MultiBarBottomLeft"
			ABNames[3] = "MultiBarBottomRight"
			ABNames[4] = "MultiBarRight"
			ABNames[5] = "MultiBarLeft"
			ABNames[6] = "MultiBar" .. 5
			ABNames[7] = "MultiBar" .. 6
			ABNames[8] = "MultiBar" .. 7
			for i = 1, 8 do
				if ABNames[i] and MoveAny:IsEnabled( "ACTIONBAR" .. i, true ) then
					local name = ABNames[i]
					local lstr = "LID_ACTIONBAR" .. i
					MoveAny:RegisterWidget( {
						["name"] = name,
						["lstr"] = lstr,
						["secure"] = true,
						["userplaced"] = true,
					} )

					local ab = _G[ name ]
					if ab then
						for x = 1, 12 do
							ab.btns = ab.btns or {}
							local abtn = _G[name .. "Button" .. x]
							if i == 1 then
								abtn = _G["ActionButton" .. x]
							end
							if abtn then
								table.insert( ab.btns, abtn )
							else
								print( "[MoveAny] ACTION BUTTON NOT FOUND", name )
							end
						end
					end

					local bar = _G[name]
					if bar then
						hooksecurefunc( bar, "SetPoint", function( self, ... )
							MoveAny:UpdateActionBar( bar )
						end )
						hooksecurefunc( bar, "SetSize", function( self, ... )
							if self.ma_uab_setsize then return end
							self.ma_uab_setsize = true
							MoveAny:UpdateActionBar( bar )
							self.ma_uab_setsize = false
						end )
						MoveAny:UpdateActionBar( bar )
					end
				end
			end
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			if MoveAny:AnyActionbarEnabled()then
				for i = 1, 10 do
					if i ~= 2 then
						if ( ( i == 1 or i == 5 or i == 6 ) and MoveAny:IsEnabled( "ACTIONBARS", MoveAny:GetWoWBuildNr() < 100000 ) ) or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
							MoveAny:RegisterWidget( {
								["name"] = "MAActionBar" .. i,
								["lstr"] = "LID_ACTIONBAR" .. i
							}, true )
						end
					end
				end
			end
		end
		for i = 1, 10 do
			local cf = _G["ChatFrame" .. i]
			if cf then	
				if MoveAny:IsEnabled( "CHAT" .. i, false ) and (_G["ChatFrame" .. i .. "Tab"]:GetParent() ~= GeneralDockManager or i == 1) then
					MoveAny:RegisterWidget( {
						["name"] = "ChatFrame" .. i,
						["lstr"] = "LID_CHAT",
						["lstri"] = i
					} )
				end
			end
		end
		if MoveAny:IsEnabled( "QUESTTRACKER", true ) then
			C_Timer.After( 0, function()
				if ObjectiveTrackerFrame == nil then
					ObjectiveTrackerFrame = CreateFrame( "Frame", "ObjectiveTrackerFrame", UIParent )
					ObjectiveTrackerFrame:SetSize( 224, 600 )
					ObjectiveTrackerFrame:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -85, -180 )
				
					if QuestWatchFrame then
						hooksecurefunc( QuestWatchFrame, "SetPoint", function( self, ... )
							if self.qwfsetpoint then return end
							self.qwfsetpoint = true
		
							self:SetMovable( true )
							if self.SetUserPlaced and self:IsMovable() then
								self:SetUserPlaced( false )
							end
		
							self:SetParent( ObjectiveTrackerFrame )
		
							self:ClearAllPoints()
							self:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
							self.qwfsetpoint = false
						end )
		
						QuestWatchFrame:SetMovable( true )
						if QuestWatchFrame.SetUserPlaced and QuestWatchFrame:IsMovable() then
							QuestWatchFrame:SetUserPlaced( false )
						end
						self:SetParent( ObjectiveTrackerFrame )
						QuestWatchFrame:ClearAllPoints()
						QuestWatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
		
						QuestWatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
					end
		
					if WatchFrame then
						hooksecurefunc( WatchFrame, "SetPoint", function( self, ... )
							if self.wfsetpoint then return end
							self.wfsetpoint = true
		
							self:SetMovable( true )
							if self.SetUserPlaced and self:IsMovable() then
								self:SetUserPlaced( false )
							end
							
							self:SetParent( ObjectiveTrackerFrame )
		
							self:ClearAllPoints()
							self:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
							self.wfsetpoint = false
						end )
		
						WatchFrame:SetMovable( true )
						if WatchFrame.SetUserPlaced and WatchFrame:IsMovable() then
							WatchFrame:SetUserPlaced( false )
						end
						WatchFrame:SetParent( ObjectiveTrackerFrame )
						WatchFrame:ClearAllPoints()
						WatchFrame:SetPoint( "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0 )
		
						WatchFrame:SetSize( ObjectiveTrackerFrame:GetSize() )
					end
				end
				if ObjectiveTrackerFrame then
					hooksecurefunc( ObjectiveTrackerFrame, "SetHeight", function( self, h )
						if self.iasetheight then return end
						self.iasetheight = true
						self:SetHeight( 600 )
						self.iasetheight = false
					end )
					ObjectiveTrackerFrame:SetHeight( 600 )
					
					MoveAny:RegisterWidget( {
						["name"] = "ObjectiveTrackerFrame",
						["lstr"] = "LID_QUESTTRACKER",
						["sh"] = 600,
						["userplaced"] = true,
						["secure"] = true,
					} )
				end
			end )
		end

		if MoveAny:IsEnabled( "PARTYFRAME", false ) then
			if PartyFrame then
				MoveAny:RegisterWidget( {
					["name"] = "PartyFrame",
					["lstr"] = "LID_PARTYFRAME",
					["sw"] = 120,
					["sh"] = 244
				} )
			else
				for i = 1, 4 do
					MoveAny:RegisterWidget( {
						["name"] = "PartyMemberFrame" .. i,
						["lstr"] = "LID_PARTYMEMBERFRAME",
						["lstri"] = i
					} )
				end
			end
		end
	end
	if MoveAny:IsEnabled( "PETFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "PetFrame",
			["lstr"] = "LID_PETFRAME",
			["userplaced"] = true
		} )
	end
	if RuneFrame and MoveAny:IsEnabled( "RUNEFRAME", false ) and class == "DEATHKNIGHT" then
		MoveAny:RegisterWidget( {
			["name"] = "RuneFrame",
			["lstr"] = "LID_RUNEFRAME"
		} )
	end
	if TotemFrame and MoveAny:IsEnabled( "TOTEMFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TotemFrame",
			["lstr"] = "LID_TOTEMFRAME",
			["sw"] = 32 * 4,
			["sh"] = 32,
			["userplaced"] = true,
			["secure"] = true,
		} )
	end
	if WarlockPowerFrame and MoveAny:IsEnabled( "WARLOCKPOWERFRAME", false ) and class == "WARLOCK" then
		MoveAny:RegisterWidget( {
			["name"] = "WarlockPowerFrame",
			["lstr"] = "LID_WARLOCKPOWERFRAME"
		} )
	end
	if MonkHarmonyBarFrame and MoveAny:IsEnabled( "MONKHARMONYBARFRAME", false ) and class == "MONK" then
		MoveAny:RegisterWidget( {
			["name"] = "MonkHarmonyBarFrame",
			["lstr"] = "LID_MONKHARMONYBARFRAME"
		} )
	end
	if MonkStaggerBar and MoveAny:IsEnabled( "MONKSTAGGERBAR", false ) and class == "MONK" then
		MoveAny:RegisterWidget( {
			["name"] = "MonkStaggerBar",
			["lstr"] = "LID_MONKSTAGGERBAR"
		} )
	end
	if MageArcaneChargesFrame and MoveAny:IsEnabled( "MAGEARCANECHARGESFRAME", false ) and class == "MAGE" then
		MoveAny:RegisterWidget( {
			["name"] = "MageArcaneChargesFrame",
			["lstr"] = "LID_MAGEARCANECHARGESFRAME"
		} )
	end
	if ComboPointPlayerFrame and MoveAny:IsEnabled( "COMBOPOINTPLAYERFRAME", false ) then
		if class == "ROGUE" then
			MoveAny:RegisterWidget( {
				["name"] = "ComboPointPlayerFrame",
				["lstr"] = "LID_COMBOPOINTPLAYERFRAME"
			} )
		elseif class == "DRUID" then
			MoveAny:RegisterWidget( {
				["name"] = "ComboPointDruidPlayerFrame",
				["lstr"] = "LID_COMBOPOINTPLAYERFRAME"
			} )
		end
	end
	if EssencePlayerFrame and MoveAny:IsEnabled( "ESSENCEPLAYERFRAME", false ) and class == "EVOKER" then
		MoveAny:RegisterWidget( {
			["name"] = "EssencePlayerFrame",
			["lstr"] = "LID_ESSENCEPLAYERFRAME"
		} )
	end
	if PaladinPowerBarFrame and MoveAny:IsEnabled( "PALADINPOWERBARFRAME", false ) and class == "PALADIN" then
		MoveAny:RegisterWidget( {
			["name"] = "PaladinPowerBarFrame",
			["lstr"] = "LID_PALADINPOWERBARFRAME"
		} )
	end
	if MoveAny:IsEnabled( "TARGETFRAMESPELLBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TargetFrameSpellBar",
			["lstr"] = "LID_TARGETFRAMESPELLBAR"
		} )
	end
	if MoveAny:IsEnabled( "FOCUSFRAMESPELLBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "FocusFrameSpellBar",
			["lstr"] = "LID_FOCUSFRAMESPELLBAR"
		} )
	end
	if MoveAny:IsEnabled( "TARGETOFTARGETFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TargetFrameToT",
			["lstr"] = "LID_TARGETOFTARGETFRAME",
			["userplaced"] = true
		} )
	end
	if FocusFrameToT and MoveAny:IsEnabled( "TARGETOFFOCUSFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "FocusFrameToT",
			["lstr"] = "LID_TARGETOFFOCUSFRAME",
			["userplaced"] = true
		} )
	end
	if CompactRaidFrameManager and MoveAny:IsEnabled( "COMPACTRAIDFRAMEMANAGER", true ) then
		MACompactRaidFrameManager = CreateFrame( "Frame", "MACompactRaidFrameManager", UIParent )
		MACompactRaidFrameManager:SetSize( 20, 135 )
		MACompactRaidFrameManager:SetPoint( "TOPLEFT", UIParent, "TOPLEFT", 0, -250 )

		hooksecurefunc( CompactRaidFrameManager, "SetPoint", function( self, ... )
			if self.crfmsetpoint then return end
			self.crfmsetpoint = true

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
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
			if not InCombatLockdown() then
				if CompactRaidFrameManager.collapsed then
					MACompactRaidFrameManager:SetSize( 20, 135 )
				else
					MACompactRaidFrameManager:SetSize( 200, 135 )
				end
			end
		end )

		MoveAny:RegisterWidget( {
			["name"] = "MACompactRaidFrameManager",
			["lstr"] = "LID_COMPACTRAIDFRAMEMANAGER"
		} )
	end
	if MoveAny:IsEnabled( "MAFPSFrame", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAFPSFrame",
			["lstr"] = "LID_MAFPSFrame"
		} )
	end



	if IAPingFrame and MoveAny:IsEnabled( "IAPingFrame", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IAPingFrame",
			["lstr"] = "LID_IAPingFrame"
		} )
	end
	if IACoordsFrame and MoveAny:IsEnabled( "IACoordsFrame", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IACoordsFrame",
			["lstr"] = "LID_IACoordsFrame"
		} )
	end
	if IASkills and MoveAny:IsEnabled( "IASKILLS", true ) and MoveAny:GetWoWBuild() ~= "RETAIL" then
		MoveAny:RegisterWidget( {
			["name"] = "IASkills",
			["lstr"] = "LID_IASKILLS"
		} )
	end

	if IsAddOnLoaded( "!KalielsTracker" ) then
		if MoveAny:IsEnabled( "!KalielsTrackerButtons", true ) then
			MoveAny:RegisterWidget( {
				["name"] = "!KalielsTrackerButtons",
				["lstr"] = "LID_!KalielsTrackerButtons",
				["sw"] = 40,
				["sh"] = 40,
			} )
		end
	end


	-- TOP
	if MoveAny:IsEnabled( "ZONETEXTFRAME", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "ZoneTextFrame",
			["lstr"] = "LID_ZONETEXTFRAME",
			["userplaced"] = true
		} )
	end
	if MoveAny:IsEnabled( "UIWIDGETTOPCENTER", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetTopCenterContainerFrame",
			["lstr"] = "LID_UIWIDGETTOPCENTER",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
		} )
	end
	if MoveAny:IsEnabled( "MIRRORTIMER1", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "MirrorTimer1",
			["lstr"] = "LID_MIRRORTIMER1",
		} )
	end



	-- TOPRIGHT
	if MoveAny:IsEnabled( "UIWIDGETBELOWMINIMAP", false ) then
		--UIWidgetBelowMinimapContainerFrame:SetParent( UIParent )
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetBelowMinimapContainerFrame",
			["lstr"] = "LID_UIWIDGETBELOWMINIMAP",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
		} )
	end
	if QueueStatusButton and MoveAny:IsEnabled( "QUEUESTATUSBUTTON", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "QueueStatusButton",
			["lstr"] = "LID_QUEUESTATUSBUTTON"
		} )
	end
	if QueueStatusFrame and MoveAny:IsEnabled( "QUEUESTATUSFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "QueueStatusFrame",
			["lstr"] = "LID_QUEUESTATUSFRAME"
		} )
	end
	if BNToastFrame and MoveAny:IsEnabled( "BNToastFrame", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "BNToastFrame",
			["lstr"] = "LID_BNToastFrame"
		} )
	end
	if VehicleSeatIndicator and MoveAny:IsEnabled( "VEHICLESEATINDICATOR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAVehicleSeatIndicator",
			["lstr"] = "LID_VEHICLESEATINDICATOR"
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
			["lstr"] = "LID_DURABILITY",
			["userplaced"] = true
		} )
	end
	if Arena_LoadUI then
		if MoveAny:IsEnabled( "ARENAENEMYFRAMES", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "MAArenaEnemyFrames",
				["lstr"] = "LID_ARENAENEMYFRAMES",
				["userplaced"] = true,
				["secure"] = true
			} )
		end
		if MoveAny:IsEnabled( "ARENAPREPFRAMES", false ) then
			MoveAny:RegisterWidget( {
				["name"] = "MAArenaPrepFrames",
				["lstr"] = "LID_ARENAPREPFRAMES",
				["userplaced"] = true,
				["secure"] = true
			} )
		end
	end
	if MoveAny:IsEnabled( "BOSSTARGETFRAMECONTAINER", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "BossTargetFrameContainer",
			["lstr"] = "LID_BOSSTARGETFRAMECONTAINER",
			["userplaced"] = true,
			["secure"] = true
		} )
	end
	if MoveAny:IsEnabled( "TICKETSTATUSFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "TicketStatusFrame",
			["lstr"] = "LID_TICKETSTATUSFRAME",
			["userplaced"] = true,
			["secure"] = true
		} )
	end
	-- RIGHT



	-- BOTTOMRIGHT
	if MoveAny:IsEnabled( "MICROMENU", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MAMenuBar",
			["lstr"] = "LID_MICROMENU"
		} )
	end
	if MoveAny:IsEnabled( "BAGS", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "BagsBar",
			["lstr"] = "LID_BAGS"
		} )
	end
	if IAMoneyBar and MoveAny:IsEnabled( "MONEYBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IAMoneyBar",
			["lstr"] = "LID_MONEYBAR"
		} )
	end
	if IATokenBar and MoveAny:IsEnabled( "TOKENBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IATokenBar",
			["lstr"] = "LID_TOKENBAR"
		} )
	end
	if IAILVLBar and MoveAny:IsEnabled( "IAILVLBAR", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "IAILVLBar",
			["lstr"] = "LID_IAILVLBAR"
		} )
	end

	if MoveAny:IsEnabled( "MINIMAP", MoveAny:GetWoWBuildNr() < 100000 ) then
		MoveAny:RegisterWidget( {
			["name"] = "Minimap",
			["lstr"] = "LID_MINIMAP"
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
			elseif p2 == GameTooltipDefaultContainer then
				if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
					p4 = floor( p4 )
					p5 = floor( p5 )
					if MANearNumber( p4, 0, 1 ) and MANearNumber( p5, 0, 1 ) then
						return true
					end
				end
			end
		end				
		return false
	end

	function MAThinkGameTooltip()
		if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
			C_Timer.After( 0.1, MAThinkGameTooltip )
			return
		end

		if MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) then
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

	if MoveAny:IsEnabled( "GAMETOOLTIP", MoveAny:GetWoWBuildNr() < 100000 ) or MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) then
		MAGameTooltip = CreateFrame( "Frame", "MAGameTooltip", UIParent )
		MAGameTooltip:SetSize( 100, 100 )
		MAGameTooltip:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -100, 100 )

		hooksecurefunc( GameTooltip, "SetScale", function( self, ... )
			if self.gtsetscale then return end
			self.gtsetscale = true
			self:SetScale( MAGameTooltip:GetScale() )
			self.gtsetscale = false
		end )
		hooksecurefunc( MAGameTooltip, "SetScale", function( self, ... )
			if self.gtsetscale2 then return end
			self.gtsetscale2 = true
			GameTooltip:SetScale( MAGameTooltip:GetScale() )
			self.gtsetscale2 = false
		end )
		GameTooltip:SetScale( MAGameTooltip:GetScale() )

		hooksecurefunc( GameTooltip, "SetAlpha", function( self, ... )
			if self.gtsetalpha then return end
			self.gtsetalpha = true
			self:SetAlpha( MAGameTooltip:GetAlpha() )
			self.gtsetalpha = false
		end )
		hooksecurefunc( MAGameTooltip, "SetAlpha", function( self, ... )
			if self.gtsetalpha2 then return end
			self.gtsetalpha2 = true
			GameTooltip:SetAlpha( MAGameTooltip:GetAlpha() )
			self.gtsetalpha2 = false
		end )
		GameTooltip:SetAlpha( MAGameTooltip:GetAlpha() )

		hooksecurefunc( GameTooltip, "SetPoint", function( self, ... )
			if self.gtsetpoint then return end
			self.gtsetpoint = true

			self:SetMovable( true )
			self:SetUserPlaced( false )

			local p1, p2, p3, p4, p5 = MAGameTooltip:GetPoint()
			if MAGameTooltipOnDefaultPosition() then
				if not MoveAny:IsEnabled( "GAMETOOLTIP_ONCURSOR", false ) then
					self:ClearAllPoints()
					self:SetPoint( p1, MAGameTooltip, p3, 0, 0 )
				end
			end

			self.gtsetpoint = false
		end )
	end



	-- BOTTOM
	if ZoneAbilityFrame and MoveAny:IsEnabled( "ZONEABILITYFRAME", true ) then
		ZoneAbilityFrame:SetParent( UIParent )
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:SetPoint( "BOTTOM", UIParent, "BOTTOM", 0, 200 )
		MoveAny:RegisterWidget( {
			["name"] = "ZoneAbilityFrame",
			["lstr"] = "LID_ZONEABILITYFRAME",
			["userplaced"] = true
		} )
	end
	if UIWidgetPowerBarContainerFrame and MoveAny:IsEnabled( "UIWIDGETPOWERBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIWidgetPowerBarContainerFrame",
			["lstr"] = "LID_UIWIDGETPOWERBAR",
			["sw"] = 36 * 6,
			["sh"] = 36 * 1
		} )
	end
	if PlayerPowerBarAlt and MoveAny:IsEnabled( "POWERBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "PlayerPowerBarAlt",
			["lstr"] = "LID_POWERBAR",
			["sw"] = 36 * 6,
			["sh"] = 36 * 1
		} )
	end

	if EventToastManagerFrame and MoveAny:IsEnabled( "EventToastManagerFrame", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "EventToastManagerFrame",
			["lstr"] = "LID_EventToastManagerFrame",
			["sw"] = 36 * 2,
			["sh"] = 36 * 2
		} )
	end
	
	if MoveAny:GetWoWBuild() == "RETAIL" then
		LoadAddOn("Blizzard_ArchaeologyUI")
	end
	if ArcheologyDigsiteProgressBar and MoveAny:IsEnabled( "ARCHEOLOGYDIGSITEPROGRESSBAR", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "ArcheologyDigsiteProgressBar",
			["lstr"] = "LID_ARCHEOLOGYDIGSITEPROGRESSBAR",
		} )
	end
	if UIErrorsFrame and MoveAny:IsEnabled( "UIERRORSFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "UIErrorsFrame",
			["lstr"] = "LID_UIERRORSFRAME",
		} )
	end

	if GroupLootContainer then
		if MoveAny:IsEnabled( "GROUPLOOTCONTAINER", true ) then
			if GroupLootFrame1 then
				glfsw, glfsh = GroupLootFrame1:GetSize()

				MoveAny:RegisterWidget( {
					["name"] = "GroupLootContainer",
					["lstr"] = "LID_GROUPLOOTCONTAINER",
					["sw"] = glfsw,
					["sh"] = glfsh,
				} )
			end
		end
	else
		if MoveAny:IsEnabled( "GROUPLOOTFRAME1", true ) then
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
							if self.SetUserPlaced and self:IsMovable() then
								self:SetUserPlaced( false )
							end

							self:ClearAllPoints()
							self:SetPoint( "BOTTOM", _G["GroupLootFrame" .. (i - 1)], "TOP", 0, 4 )
							
							self.glfsetpoint = false
						end )

						hooksecurefunc( GroupLootFrame1, "SetScale", function( self, scale )
							glf:SetScale( scale )
						end )

						hooksecurefunc( GroupLootFrame1, "SetAlpha", function( self, alpha )
							glf:SetAlpha( alpha )
						end )
					end
				end
			end
				
			MoveAny:RegisterWidget( {
				["name"] = "GroupLootFrame1",
				["lstr"] = "LID_GROUPLOOTFRAME1",
				["sw"] = glfsw,
				["sh"] = glfsh,
				["px"] = 0,
				["py"] = 200,
				["an"] = "BOTTOM",
				["re"] = "BOTTOM"
			} )
		end
	end
	if MoveAny:IsEnabled( "BONUSROLLFRAME", false ) and BonusRollFrame then
		MoveAny:RegisterWidget( {
			["name"] = "BonusRollFrame",
			["lstr"] = "LID_BONUSROLLFRAME",
		} )
	end

	if MainStatusTrackingBarContainer and MoveAny:IsEnabled( "MainStatusTrackingBarContainer", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "MainStatusTrackingBarContainer",
			["lstr"] = "LID_MainStatusTrackingBarContainer",
		} )
	end
	if SecondaryStatusTrackingBarContainer and MoveAny:IsEnabled( "SecondaryStatusTrackingBarContainer", true ) then
		MoveAny:RegisterWidget( {
			["name"] = "SecondaryStatusTrackingBarContainer",
			["lstr"] = "LID_SecondaryStatusTrackingBarContainer",
		} )
	end
	if StatusTrackingBarManager then
		if MoveAny:IsEnabled( "STATUSTRACKINGBARMANAGER", true ) then
			-- StatusTrackingBarManager:EnableMouse( true ) -- destroys tooltip

			local sw, sh = StatusTrackingBarManager:GetSize()
			MoveAny:RegisterWidget( {
				["name"] = "StatusTrackingBarManager",
				["lstr"] = "LID_STATUSTRACKINGBARMANAGER",
				["sw"] = sw - 6,
				["sh"] = sh - 8,
				["cleft"] = 0,
				["cright"] = 2,
				["ctop"] = 4,
				["cbottom"] = 4,
				["posx"] = 1,
				["posy"] = 4,
			} )
		end
	end
	if MainMenuExpBar and ReputationWatchBar then
		if MoveAny:IsEnabled( "MAINMENUEXPBAR", true ) then
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 140 )
			MoveAny:RegisterWidget( {
				["name"] = "MainMenuExpBar",
				["lstr"] = "LID_MAINMENUEXPBAR"
			} )
		end
		if MoveAny:IsEnabled( "REPUTATIONWATCHBAR", true ) then
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint( "BOTTOM", UIParent , "BOTTOM", 0, 130 )
			MoveAny:RegisterWidget( {
				["name"] = "ReputationWatchBar",
				["lstr"] = "LID_REPUTATIONWATCHBAR"
			} )
		end
	end
	
	if MoveAny:IsEnabled( "TOTEMBAR", true ) and MoveAny:GetWoWBuild() == "WRATH" and class == "SHAMAN" then
		MoveAny:RegisterWidget( {
			["name"] = "MultiCastActionBarFrame",
			["lstr"] = "LID_TOTEMBAR",
			["userplaced"] = true,
			["secure"] = true
		} )
	end
	if AlertFrame and MoveAny:IsEnabled( "ALERTFRAME", true ) then
		local afsw, afsh = 276, 68
		MoveAny:RegisterWidget( {
			["name"] = "AlertFrame",
			["lstr"] = "LID_ALERTFRAME",
			["sw"] = afsw,
			["sh"] = afsh
		} )

		if AlertFrame and AlertFrame.AddAlertFrame then
			hooksecurefunc( AlertFrame, "AddAlertFrame", function( self, frame )
				if frame.ma_setup == nil then
					frame.ma_setup = true

					hooksecurefunc( AlertFrame, "SetScale", function( self, scale )
						frame:SetScale( scale )
					end )
					frame:SetScale( AlertFrame:GetScale() )

					hooksecurefunc( AlertFrame, "SetAlpha", function( self, alpha )
						frame:SetAlpha( alpha )
					end )
					frame:SetAlpha( AlertFrame:GetAlpha() )
				end
			end )
		end
	end
	


	-- BOTTOMLEFT
	for i = 1, 10 do
		local cf = _G["ChatFrame" .. i]
		if cf then	
			local left = nil
			if  MoveAny:IsEnabled( "CHATBUTTONFRAME", false ) then
				left = 0
			end
			local bottom = nil
			if MoveAny:IsEnabled( "CHATEDITBOX", false ) then
				bottom = 0
			end
			if left or bottom then
				local l = left or -35
				local b = bottom or -35
				hooksecurefunc( cf, "SetClampRectInsets", function( self, oL, oR, oT, oB )
					if self.setclamprectinsets_ma then return end
					self.setclamprectinsets_ma = true
					local le = left or -35
					local bo = bottom or -35
					self:SetClampRectInsets( le, 25, 25, bo )
					self.setclamprectinsets_ma = false
				end )
				cf:SetClampRectInsets( l, 25, 25, b )
			end
			if i > 1 then
				if MoveAny:IsEnabled( "CHATBUTTONFRAME", false ) then
					local cbf = _G["ChatFrame" .. i .. "ButtonFrame"]
					if cbf then
						hooksecurefunc( cbf, "SetPoint", function( self, ... )
							if self.cbfsetpoint then return end
							
							self:SetMovable( true )
							if self.SetUserPlaced and self:IsMovable() then
								self:SetUserPlaced( true )
							end
					
							self.cbfsetpoint = true
							C_Timer.After( 0.0, function()
								local sw, sh = _G["ChatFrame" .. 1 .. "ButtonFrame"]:GetSize()
								self:SetSize( sw, sw * 6 )
								self:ClearAllPoints()
								self:SetPoint( "BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0 )

								self.cbfsetpoint = false
							end )
						end )

						cbf:SetMovable( true )
						if cbf.SetUserPlaced and cbf:IsMovable() then
							cbf:SetUserPlaced( true )
						end
						
						cbf:ClearAllPoints()
						cbf:SetPoint( "BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0 )
					end

					function MoveAny:UpdateActiveTab()
						local selectedId = 1
						if SELECTED_CHAT_FRAME then
							selectedId = SELECTED_CHAT_FRAME:GetID()
						end
						for i = 1, 10 do
							local cbf = _G["ChatFrame" .. i .. "ButtonFrame"]
							if cbf then
								if i == selectedId then
									cbf:Show()
								else
									cbf:Hide()
								end
							end							
						end
						C_Timer.After( 0.1, MoveAny.UpdateActiveTab )
					end
					MoveAny:UpdateActiveTab()
				end
				if MoveAny:IsEnabled( "CHATEDITBOX", false ) then
					local ceb = _G["ChatFrame" .. i .. "EditBox"]
					if ceb then
						hooksecurefunc( ceb, "SetPoint", function( self, ... )
							if self.cebsetpoint then return end
							
							self:SetMovable( true )
							if self.SetUserPlaced and self:IsMovable() then
								self:SetUserPlaced( true )
							end
					
							self.cebsetpoint = true
							if _G["ChatFrame" .. 1 .. "EditBox"] then
								self:SetSize( _G["ChatFrame" .. 1 .. "EditBox"]:GetSize() )
								self:ClearAllPoints()
								self:SetPoint( "CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0 )
							end

							self.cebsetpoint = false
						end )

						ceb:SetMovable( true )
						if ceb.SetUserPlaced and ceb:IsMovable() then
							ceb:SetUserPlaced( true )
						end

						ceb:ClearAllPoints()
						ceb:SetPoint( "CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0 )
					end
				end
			end
		end
	end
	if MoveAny:IsEnabled( "CHATBUTTONFRAME", false ) then
		local cbf = _G["ChatFrame" .. 1 .. "ButtonFrame"]
		cbf:EnableMouse( true )

		MoveAny:RegisterWidget( {
			["name"] = "ChatFrame" .. 1 .. "ButtonFrame",
			["lstr"] = "LID_CHATBUTTONFRAME",
		} )
		if ChatFrameMenuButton then
			function ChatFrameMenuButton:GetMAEle()
				return cbf
			end
		end
		if ChatFrameChannelButton then
			function ChatFrameChannelButton:GetMAEle()
				return cbf
			end
		end
	end
	if MoveAny:IsEnabled( "CHATEDITBOX", false ) then
		local ceb = _G["ChatFrame" .. 1 .. "EditBox"]
		if ceb then
			local sw, sh = ceb:GetSize()
			hooksecurefunc( ceb, "SetClampRectInsets", function( self )
				if self.setclamprectinsets_ma then return end
				self.setclamprectinsets_ma = true
				self:SetClampRectInsets( 2, 2, 2, 2 )
				self.setclamprectinsets_ma = false
			end )
			ceb:SetClampRectInsets( 2, 2, 2, 2 )
		end
		MoveAny:RegisterWidget( {
			["name"] = "ChatFrame" .. 1 .. "EditBox",
			["lstr"] = "LID_CHATEDITBOX",
		} )
	end
	if QuickJoinToastButton and MoveAny:IsEnabled( "CHATQUICKJOIN", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "QuickJoinToastButton",
			["lstr"] = "LID_CHATQUICKJOIN"
		} )
	end



	-- LEFT



	-- CENTER
	if SpellActivationOverlayFrame and MoveAny:IsEnabled( "SPELLACTIVATIONOVERLAYFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "SpellActivationOverlayFrame",
			["lstr"] = "LID_SPELLACTIVATIONOVERLAYFRAME"
		} )
	end
	
	if LossOfControlFrame and MoveAny:IsEnabled( "LOSSOFCONTROLFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "LossOfControlFrame",
			["lstr"] = "LID_LOSSOFCONTROLFRAME"
		} )
	end

	if GhostFrame and MoveAny:IsEnabled( "GHOSTFRAME", false ) then
		MoveAny:RegisterWidget( {
			["name"] = "GhostFrame",
			["lstr"] = "LID_GHOSTFRAME",
			["sw"] = 130,
			["sh"] = 45,
 		} )
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] then
		ArenaEnemyFrames:SetMovable( true )
		ArenaEnemyFrames:SetUserPlaced( true )
		UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] = nil 
	end


	
	MoveAny:InitMALock()
	if MoveAny.InitMAVehicleSeatIndicator then
		MoveAny:InitMAVehicleSeatIndicator()
	end
	if MoveAny:IsEnabled( "EDITMODE", MoveAny:GetWoWBuildNr() < 100000 ) then
		if MoveAny.InitMinimap then
			MoveAny:InitMinimap()
		end
		if MoveAny.InitBuffBar then
			MoveAny:InitBuffBar()
		end
		if MoveAny.InitDebuffBar then
			MoveAny:InitDebuffBar()
		end
	end
	if MoveAny.InitMicroMenu then
		MoveAny:InitMicroMenu()
	end
	if MoveAny.InitBags then
		MoveAny:InitBags()
	end
	if MoveAny.InitMAFPSFrame then
		MoveAny:InitMAFPSFrame()
	end
	if MoveAny.InitMultiCastActionBar then
		MoveAny:InitMultiCastActionBar()
	end
	if MoveAny.InitPartyFrame then
		MoveAny:InitPartyFrame()
	end

	if MoveAny.MoveFrames then
		MoveAny:MoveFrames()
	end

	if WorldMapFrame and MoveAny:GetWoWBuild() ~= "RETAIL" then	
		WorldMapFrame.ScrollContainer.GetCursorPosition = function( f )
			local x, y = MapCanvasScrollControllerMixin.GetCursorPosition( f )
			local scale = WorldMapFrame:GetScale()
			if not IsAddOnLoaded( "Mapster" ) then
				return x / scale, y / scale
			else
				local reverseEffectiveScale = 1 / UIParent:GetEffectiveScale();
				return x / scale * reverseEffectiveScale, y / scale * reverseEffectiveScale
			end
		end
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
			tooltip:AddLine( MoveAny:GT( "LID_MMBTNLEFT" ) )
			tooltip:AddLine( MoveAny:GT( "LID_MMBTNRIGHT" ) )
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
