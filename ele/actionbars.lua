
local AddOnName, MoveAny = ...

MAMaxAB = 10
local btnsize = 36
local btns = {}
local abpoints = {}
local abs = {}
local oldcvar = -1

btns[1] = "ActionButton"
btns[3] = "MultiBarRightButton" --"MultiBarRightButton"
btns[4] = "MultiBarLeftButton" --"MultiBarLeftButton"
btns[5] = "MultiBarBottomRightButton" --"MultiBarBottomRightButton"
btns[6] = "MultiBarBottomLeftButton" --"MultiBarBottomLeftButton"


local function MASetPoint( id, po, pa, re, px, py, rows )
	local name = "MAActionBar" .. id

	abpoints[name] = {}
	abpoints[name]["PO"] = po
	abpoints[name]["PA"] = pa
	abpoints[name]["RE"] = re
	abpoints[name]["PX"] = px
	abpoints[name]["PY"] = py
	abpoints[name]["ROWS"] = rows
end
local dSpacing = 4
MASetPoint( 1, "BOTTOM", UIParent, "BOTTOM", 0, 0, 1 )
MASetPoint( 3, "RIGHT", UIParent, "RIGHT", 0, 0, 12 )
MASetPoint( 4, "RIGHT", UIParent, "RIGHT", -36, 0, 12 )
MASetPoint( 5, "BOTTOM", UIParent, "BOTTOM", 360, 0, 2 )
MASetPoint( 6, "BOTTOM", UIParent, "BOTTOM", 0, 36, 1 )
MASetPoint( 7, "BOTTOM", UIParent, "BOTTOM", -360, 0, 2 )
MASetPoint( 8, "CENTER", UIParent, "CENTER", -360, 0 * 36, 1 )
MASetPoint( 9, "CENTER", UIParent, "CENTER", -360, 1 * 36, 1 )
MASetPoint( 10, "CENTER", UIParent, "CENTER", -360, 2 * 36, 1 )

function MAUpdateActionBar( frame )
	local name = frame:GetName()
	local opts = MoveAny:GetEleOptions( name )

	opts["ROWS"] = opts["ROWS"] or nil
	opts["SPACING"] = opts["SPACING"] or dSpacing

	if opts["ROWS"] == nil and abpoints[name] and abpoints[name]["ROWS"] then
		opts["ROWS"] = abpoints[name]["ROWS"]
	end

	local rows = opts["ROWS"] or 1
	rows = tonumber( rows )

	if frame == MAMenuBar then
		if rows == 12 or rows == 6 or rows == 4 or rows == 3 then
			if HelpMicroButton then
				HelpMicroButton:GetParent():SetParent( MAMenuBar )
			end
			if MainMenuMicroButton then
				MainMenuMicroButton:GetParent():SetParent( MAMenuBar )
			end
		elseif rows == 10 or rows == 2 then
			if HelpMicroButton then
				HelpMicroButton:GetParent():SetParent( MAHIDDEN )
			end
			if MainMenuMicroButton then
				MainMenuMicroButton:GetParent():SetParent( MAHIDDEN )
			end
		else
			if HelpMicroButton then
				HelpMicroButton:GetParent():SetParent( MAHIDDEN )
			end
			if MainMenuMicroButton then
				MainMenuMicroButton:GetParent():SetParent( MAMenuBar )
			end
		end
	end

	local maxbtns = 0
	for i, abtn in pairs( frame.btns ) do
		if abtn:GetParent() ~= MAHIDDEN then
			maxbtns = maxbtns + 1
		end
	end
	if maxbtns == 0 then
		maxbtns = 1
	end
	local cols = maxbtns / rows

	local spacing = opts["SPACING"]
	spacing = tonumber( spacing )

	if frame.btns and frame.btns[1] then
		local fSizeW, fSizeH = frame.btns[1]:GetSize()

		if not InCombatLockdown() then
			frame:SetSize( cols * (fSizeW + spacing) - spacing, rows * (fSizeH + spacing) - spacing )
		end
		local id = 1
		for i, abtn in pairs( frame.btns ) do
			if abtn:GetParent() ~= MAHIDDEN then
				abtn:ClearAllPoints()
				abtn:SetPoint( "TOPLEFT", frame, "TOPLEFT", ( id - 1 ) % cols * (fSizeW + spacing), 1 - (( id - 1 ) / cols - ( id - 1 ) % cols / cols) * (fSizeH + spacing) )
				id = id + 1
			end
		end
	end
end

function MoveAny:CustomBars()
	if MABUILD ~= "RETAIL" and MoveAny:IsEnabled( "ACTIONBARS", true ) then
		for i = 0, 3 do
			local texture = _G["MainMenuMaxLevelBar" .. i]
			if texture then
				hooksecurefunc( texture, "Show", function( self )
					if self.mahide then return end
					self.mahide = true
					self:Hide()
					self.mahide = false
				end )
				texture:Hide()
			end
		end
		if StanceBarLeft then
			hooksecurefunc( StanceBarLeft, "Show", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Hide()
				self.mahide = false
			end )
			StanceBarLeft:Hide()
		end
		if StanceBarMiddle then
			hooksecurefunc( StanceBarMiddle, "Show", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Hide()
				self.mahide = false
			end )
			StanceBarMiddle:Hide()
		end
		if StanceBarRight then
			hooksecurefunc( StanceBarRight, "Show", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Hide()
				self.mahide = false
			end )
			StanceBarRight:Hide()
		end

		if SlidingActionBarTexture0 then
			hooksecurefunc( SlidingActionBarTexture0, "Show", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Hide()
				self.mahide = false
			end )
			SlidingActionBarTexture0:Hide()
		end
		if SlidingActionBarTexture1 then
			hooksecurefunc( SlidingActionBarTexture1, "Show", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Hide()
				self.mahide = false
			end )
			SlidingActionBarTexture1:Hide()
		end
	end

	local id = 1
	if MABUILD ~= "RETAIL" then
		for i = 7, MAMaxAB do
			for x = 1, 12 do
				_G["BINDING_NAME_CLICK ActionBar" .. i .. "Button" .. x .. ":LeftButton"] = _G["BINDING_NAME_CLICK ActionBar" .. i .. "Button" .. x .. ":LeftButton"] or "Actionbar " .. i .. " Button " .. x
			end
		end
	end
	for i = 1, MAMaxAB do
		if i ~= 2 then
			if i <= 6 and MoveAny:IsEnabled( "ACTIONBARS", true ) or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
				
				local name = "MAActionBar" .. i
				_G[name] = CreateFrame( "Frame", name, UIParent, "SecureHandlerStateTemplate" )

				local bar = _G[name] 
				bar:SetSize( 36 * 12, 36 )
				bar:SetPoint( abpoints[name]["PO"], abpoints[name]["PA"], abpoints[name]["RE"], abpoints[name]["PX"], abpoints[name]["PY"] )
				
				if i > 1 then
					bar:SetAttribute( "actionpage", i )
				end

				bar.btns = {}

				tinsert( abs, bar )

				for x = 1, 12 do
					local btnname = "ActionBar" .. i .. "Button" .. x

					if btns[i] then
						btnname = btns[i] .. x
					end

					local id = (i - 1) * 12 + x
						
					if _G[btnname] == nil then
						_G[btnname] = CreateFrame( "CheckButton", btnname, bar, "ActionBarButtonTemplate, SecureActionButtonTemplate" )

						_G[btnname].commandName = "CLICK " .. btnname
						
						_G[btnname]:SetAttribute( "action", id )
					else
						_G[btnname].bindingID = x
					end

					if _G[btnname .. "FloatingBG"] == nil then
						_G[btnname .. "FloatingBG"] = _G[btnname]:CreateTexture( btnname .. "FloatingBG", "BACKGROUND" )
						_G[btnname .. "FloatingBG"]:SetParent( _G[btnname] )
						_G[btnname .. "FloatingBG"]:SetPoint( "TOPLEFT", -15, 15 )
						_G[btnname .. "FloatingBG"]:SetPoint( "BOTTOMRIGHT", 15, -15 )
						_G[btnname .. "FloatingBG"]:SetTexture("Interface/Buttons/UI-Quickslot")
						_G[btnname .. "FloatingBG"]:SetVertexColor( 1, 1, 0, 0.4 )
						_G[btnname .. "FloatingBG"]:SetDrawLayer( "BACKGROUND", -1 )
					end

					local btn = _G[btnname]
					
					btn.maid = id

					btn:ClearAllPoints()
					btn:SetParent( bar )
					btn:SetPoint( "TOPLEFT", btn:GetParent(), "TOPLEFT", (x - 1) * 36, 0 )
					btn:SetSize( 36, 36 )

					tinsert( bar.btns, btn )
				end

				MAUpdateActionBar( _G[name] )
			end
		end
	end
end

function MoveAny:UpdateABs()
	if MABUILD ~= "RETAIL" then
		local cvar = tonumber( GetCVar( "alwaysShowActionBars" ) )
		if cvar ~= oldcvar then
			oldcvar = cvar
			for name, bar in pairs( abs ) do
				local ab = bar
				if ab and ab.btns then
					for id, abtn in pairs( ab.btns ) do
						local btnname = abtn:GetName()
						if btnname and _G[btnname .. "FloatingBG"] then
							_G[btnname .. "FloatingBG"]:Show()
						end
						if btnname and _G[btnname .. "NormalTexture"] then
							if cvar == 1 then
								_G[btnname]:SetAttribute( "showgrid", 1 )
								_G[btnname .. "NormalTexture"]:Show()
								_G[btnname]:Show()
							elseif cvar == 0 then
								_G[btnname]:SetAttribute( "showgrid", 0 )
								_G[btnname .. "NormalTexture"]:Hide()
							end
						else
							MoveAny:MSG( "NOT FOUND: " .. tostring( btnname ) )
						end
					end
				end
			end
		end
		C_Timer.After( 0.5, MoveAny.UpdateABs )
	end
end

local f = CreateFrame( "Frame" )
f:RegisterEvent( "PLAYER_ENTERING_WORLD" )
f:RegisterEvent( "UPDATE_BONUS_ACTIONBAR" )
f:RegisterEvent( "ACTIONBAR_PAGE_CHANGED" )
f:RegisterEvent( "UPDATE_SHAPESHIFT_FORM" )
f:SetScript( "OnEvent", function( self, event )
	if MABUILD ~= "RETAIL" then
		if ( event == "PLAYER_ENTERING_WORLD"
			or event == "UPDATE_BONUS_ACTIONBAR" 
			or event == "UPDATE_VEHICLE_ACTIONBAR" 
			or event == "UPDATE_OVERRIDE_ACTIONBAR"
			or event == "ACTIONBAR_PAGE_CHANGED"
			or event == "UPDATE_SHAPESHIFT_FORM" ) then
				local frame = _G["MAActionBar" .. 1]
				if frame then
					if frame.init == nil then
						frame.init = true

						frame:SetAttribute( "_onstate-page", [[ -- arguments: self, stateid, newstate
							self:SetAttribute( "actionpage", newstate );
						]] );
						RegisterStateDriver( frame, "page", "[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;1" )

						local _onAttributeChanged = [[
							if name == 'statehidden' then
								if (HasOverrideActionBar() or HasVehicleActionBar()) then
									for i = 1, 12 do
										if i < 7 then
											if overridebuttons[i]:GetAttribute('statehidden') then
												buttons[i]:SetAttribute('statehidden', true)
												buttons[i]:Hide()
											else
												buttons[i]:SetAttribute('statehidden', false)
												buttons[i]:Show()
											end
										else
											buttons[i]:SetAttribute('statehidden', true)
											buttons[i]:Hide()
										end
									end
								else
									for i = 1, 12 do
										buttons[i]:SetAttribute('statehidden', false)
										buttons[i]:Show()
									end
								end
							end
						]]
						if MABUILD == "CLASSIC" then
							_onAttributeChanged = [[
							if name == 'statehidden' then
								for i = 1, 12 do
									buttons[i]:SetAttribute('statehidden', false)
									buttons[i]:Show()
								end
							end
						]]
						end

						local AttributeChangedFrame = CreateFrame('Frame', nil, UIParent, 'SecureHandlerAttributeTemplate')
						for i = 1, 12 do
							local button = _G['ActionButton'..i]
							AttributeChangedFrame:SetFrameRef('ActionButton'..i, button)
						end
						
						for i = 1, 6 do
							local overrideButton = _G['OverrideActionBarButton'..i]
							if overrideButton then
								AttributeChangedFrame:SetFrameRef('OverrideActionBarButton'..i, overrideButton)
							end
						end
						
						AttributeChangedFrame:Execute([[
							buttons = table.new()
							for i = 1, 12 do
								buttons[i] = self:GetFrameRef('ActionButton'..i)
							end
						
							overridebuttons = table.new()
							for j = 1, 6 do
								overridebuttons[j] = self:GetFrameRef('OverrideActionBarButton'..j)
							end
						]])
						
						AttributeChangedFrame:SetAttribute('_onattributechanged', _onAttributeChanged)
						RegisterStateDriver(AttributeChangedFrame, 'visibility', '[overridebar][shapeshift][vehicleui][possessbar] show; hide')
					end
				end
		end
	end
end )
