
local AddOnName, MoveAny = ...

MAMaxAB = 10

local btnsize = 36

local bars = {}
bars[1] = "ACTIONBUTTON"
bars[2] = "ACTIONBAR2BUTTON"
bars[3] = "MULTIACTIONBAR1BUTTON" --"MultiBarRightButton"
bars[4] = "MULTIACTIONBAR2BUTTON" --"MultiBarLeftButton"
bars[5] = "MULTIACTIONBAR2BUTTON" --"MultiBarBottomRightButton"
bars[6] = "MULTIACTIONBAR1BUTTON" --"MultiBarBottomLeftButton"
bars[7] = "ACTIONBAR7BUTTON"
bars[8] = "ACTIONBAR8BUTTON"
bars[9] = "ACTIONBAR9BUTTON"
bars[10] = "ACTIONBAR10BUTTON"

local btns = {}
btns[1] = "ActionButton"
btns[3] = "MultiBarRightButton" --"MultiBarRightButton"
btns[4] = "MultiBarLeftButton" --"MultiBarLeftButton"
btns[5] = "MultiBarBottomRightButton" --"MultiBarBottomRightButton"
btns[6] = "MultiBarBottomLeftButton" --"MultiBarBottomLeftButton"

local abpoints = {}
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
MASetPoint( 1, "BOTTOM", UIParent, "BOTTOM", 0, 0, 1 )
MASetPoint( 3, "RIGHT", UIParent, "RIGHT", 0, 0, 12 )
MASetPoint( 4, "RIGHT", UIParent, "RIGHT", -36, 0, 12 )
MASetPoint( 5, "BOTTOM", UIParent, "BOTTOM", 360, 0, 2 )
MASetPoint( 6, "BOTTOM", UIParent, "BOTTOM", 0, 36, 1 )
MASetPoint( 7, "BOTTOM", UIParent, "BOTTOM", -360, 0, 2 )
MASetPoint( 8, "CENTER", UIParent, "CENTER", -360, 0 * 36, 1 )
MASetPoint( 9, "CENTER", UIParent, "CENTER", -360, 1 * 36, 1 )
MASetPoint( 10, "CENTER", UIParent, "CENTER", -360, 2 * 36, 1 )

local abs = {}

function MAUpdateActionBar( frame )
	local name = frame:GetName()
	local opts = MoveAny:GetEleOptions( name )
	opts["ROWS"] = opts["ROWS"] or abpoints[name]["ROWS"]

	local rows = opts["ROWS"]
	rows = tonumber( rows )
	local cols = 12 / rows

	frame:SetSize( cols * btnsize, rows * btnsize )
	for id, abtn in pairs( frame.btns ) do
		abtn:SetPoint( "TOPLEFT", frame, "TOPLEFT", ( id - 1 ) % cols * btnsize, 1 - (( id - 1 ) / cols - ( id - 1 ) % cols / cols) * btnsize )
	end
end

function MAUpdateAction()
	if not InCombatLockdown() then
		if abs then
			for i, v in pairs( abs ) do
				if v.btns then
					for x, abtn in pairs( v.btns ) do
						if abtn.UpdateAction then
							abtn:UpdateAction()
						elseif ActionButton_UpdateAction then
							ActionButton_UpdateAction( abtn )
							ActionButton_Update( abtn )
						end
						if abtn.UpdateHotkeys then
							abtn:UpdateHotkeys( abtn.buttonType )
						elseif ActionButton_UpdateHotkeys then
							ActionButton_UpdateHotkeys( abtn, abtn.buttonType);
						end
					end
				else
					MoveAny:MSG_Error( "[MAUpdateAction] Missing ActionButtons" )
				end
			end
		else
			MoveAny:MSG_Error( "[MAUpdateAction] Missing ActionBars" )
		end
	end
end

function MoveAny:CustomBars()
	-- Hide Artworks
	for i = 0, 3 do
		local texture = _G["MainMenuMaxLevelBar" .. i]
		if texture then
			texture:Hide()
		end
	end
	if StanceBarLeft then
		StanceBarLeft.Show = StanceBarLeft.Hide
		StanceBarLeft:Hide()
	end
	if StanceBarMiddle then
		StanceBarMiddle.Show = StanceBarMiddle.Hide
		StanceBarMiddle:Hide()
	end
	if StanceBarRight then
		StanceBarRight.Show = StanceBarRight.Hide
		StanceBarRight:Hide()
	end



	local id = 1
	for i = 1, MAMaxAB do
		if i ~= 2 then
			if i <= 6 or MoveAny:IsEnabled( "ACTIONBAR" .. i, false ) then
				
				local name = "MAActionBar" .. i
				_G[name] = CreateFrame( "FRAME", name, UIParent, "SecureHandlerStateTemplate" )

				local bar = _G[name] 
				bar:SetSize( 36 * 12, 36 )
				bar:SetPoint( abpoints[name]["PO"], abpoints[name]["PA"], abpoints[name]["RE"], abpoints[name]["PX"], abpoints[name]["PY"] )
				
				if i > 1 then
					bar:SetAttribute( "actionpage", 1 )
				end

				bar.btns = {}

				tinsert( abs, bar )

				for x = 1, 12 do
					local btnname = "ActionBar" .. i .. "Button" .. x
					--[[local orgbtnname = btnname
					if bars[i] then
						orgbtnname = bars[i] .. x
					end]]

					if btns[i] then
						btnname = btns[i] .. x
					end

					if _G[btnname] == nil then
						_G[btnname] = CreateFrame( "CheckButton", btnname, bar, "ActionBarButtonTemplate, SecureActionButtonTemplate, SecureHandlerStateTemplate" )

						_G[btnname].commandName = "CLICK " .. btnname
						_G["BINDING_NAME_CLICK " .. btnname] = _G["BINDING_NAME_" .. btnname] or "Actionbar " .. i .. " Button " .. x
					end

					if _G[btnname .. "FloatingBG"] == nil then
						_G[btnname .. "FloatingBG"] = _G[btnname]:CreateTexture( btnname .. "FloatingBG", "BACKGROUND" )
						_G[btnname .. "FloatingBG"]:SetParent( _G[btnname] )
						_G[btnname .. "FloatingBG"]:SetPoint( "TOPLEFT", -15, 15 ) --_G[btnname])
						_G[btnname .. "FloatingBG"]:SetPoint( "BOTTOMRIGHT", 15, -15 ) --_G[btnname])
						_G[btnname .. "FloatingBG"]:SetTexture("Interface/Buttons/UI-Quickslot")
						_G[btnname .. "FloatingBG"]:SetVertexColor( 1, 1, 0, 0.4 )
						_G[btnname .. "FloatingBG"]:SetDrawLayer( "BACKGROUND", -1 )
					end

					local btn = _G[btnname]

					local id = (i - 1) * 12 + x
					btn.maid = id
					--btn:SetAttribute( "type", "action" )
					btn:SetAttribute( "action", id )
					--btn:SetAttribute( "useparent-unit", true )
					--btn:SetAttribute( "useparent-actionpage", true )
					btn:SetID( id )

					btn:ClearAllPoints()
					btn:SetParent( bar )
					btn:SetPoint( "TOPLEFT", bar, "TOPLEFT", (x - 1) * 36, 0 )
					btn:SetSize( 36, 36 )

					tinsert( bar.btns, btn )
				end

				MAUpdateActionBar( _G[name] )
			end
		end
	end

	MAUpdateAction()
end

local oldcvar = -1
function MoveAny:UpdateABs()
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
						print("NOT FOUND", btnname)
					end
				end
			end
		end
	end
	C_Timer.After( 0.5, MoveAny.UpdateABs )
end

local f = CreateFrame( "FRAME" )
f:RegisterEvent( "PLAYER_ENTERING_WORLD" )
f:RegisterEvent( "UPDATE_BONUS_ACTIONBAR" )
f:RegisterEvent( "ACTIONBAR_PAGE_CHANGED" )
f:RegisterEvent( "UPDATE_SHAPESHIFT_FORM" )
f:SetScript( "OnEvent", function( self, event )
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

					if ActionButton1.UpdateAction then
						frame:SetAttribute( "_onstate-page", [[ -- arguments: self, stateid, newstate
							self:SetAttribute( "actionpage", newstate );

							if ActionButton1 then
								ActionButton1:UpdateAction()
								ActionButton1:UpdateHotkeys( nil )
							end
							if ActionButton2 then
								ActionButton2:UpdateAction()
								ActionButton2:UpdateHotkeys( nil )
							end
							if ActionButton3 then
								ActionButton3:UpdateAction()
								ActionButton3:UpdateHotkeys( nil )
							end
							if ActionButton4 then
								ActionButton4:UpdateAction()
								ActionButton4:UpdateHotkeys( nil )
							end
							if ActionButton5 then
								ActionButton5:UpdateAction()
								ActionButton5:UpdateHotkeys( nil )
							end
							if ActionButton6 then
								ActionButton6:UpdateAction()
								ActionButton6:UpdateHotkeys( nil )
							end
							if ActionButton7 then
								ActionButton7:UpdateAction()
								ActionButton7:UpdateHotkeys( nil )
							end
							if ActionButton8 then
								ActionButton8:UpdateAction()
								ActionButton8:UpdateHotkeys( nil )
							end
							if ActionButton9 then
								ActionButton9:UpdateAction()
								ActionButton9:UpdateHotkeys( nil )
							end
							if ActionButton10 then
								ActionButton10:UpdateAction()
								ActionButton10:UpdateHotkeys( nil )
							end
							if ActionButton11 then
								ActionButton11:UpdateAction()
								ActionButton11:UpdateHotkeys( nil )
							end
							if ActionButton12 then
								ActionButton12:UpdateAction()
								ActionButton12:UpdateHotkeys( nil )
							end
						]] );
					else
						frame:SetAttribute( "_onstate-page", [[ -- arguments: self, stateid, newstate
						self:SetAttribute( "actionpage", newstate );

						if ActionButton1 then
							ActionButton_UpdateAction( ActionButton1 )
							ActionButton_Update( ActionButton1 )
							ActionButton_UpdateHotkeys( ActionButton1, nil );
						end
						if ActionButton2 then
							ActionButton_UpdateAction( ActionButton2 )
							ActionButton_Update( ActionButton2 )
							ActionButton_UpdateHotkeys( ActionButton2, nil );
						end
						if ActionButton3 then
							ActionButton_UpdateAction( ActionButton3 )
							ActionButton_Update( ActionButton3 )
							ActionButton_UpdateHotkeys( ActionButton3, nil );
						end
						if ActionButton4 then
							ActionButton_UpdateAction( ActionButton4 )
							ActionButton_Update( ActionButton4 )
							ActionButton_UpdateHotkeys( ActionButton4, nil );
						end
						if ActionButton5 then
							ActionButton_UpdateAction( ActionButton5 )
							ActionButton_Update( ActionButton5 )
							ActionButton_UpdateHotkeys( ActionButton5, nil );
						end
						if ActionButton6 then
							ActionButton_UpdateAction( ActionButton6 )
							ActionButton_Update( ActionButton6 )
							ActionButton_UpdateHotkeys( ActionButton6, nil );
						end
						if ActionButton7 then
							ActionButton_UpdateAction( ActionButton7 )
							ActionButton_Update( ActionButton7 )
							ActionButton_UpdateHotkeys( ActionButton7, nil );
						end
						if ActionButton8 then
							ActionButton_UpdateAction( ActionButton8 )
							ActionButton_Update( ActionButton8 )
							ActionButton_UpdateHotkeys( ActionButton8, nil );
						end
						if ActionButton9 then
							ActionButton_UpdateAction( ActionButton9 )
							ActionButton_Update( ActionButton9 )
							ActionButton_UpdateHotkeys( ActionButton9, nil );
						end
						if ActionButton10 then
							ActionButton_UpdateAction( ActionButton10 )
							ActionButton_Update( ActionButton10 )
							ActionButton_UpdateHotkeys( ActionButton10, nil );
						end
						if ActionButton11 then
							ActionButton_UpdateAction( ActionButton11 )
							ActionButton_Update( ActionButton11 )
							ActionButton_UpdateHotkeys( ActionButton11, nil );
						end
						if ActionButton12 then
							ActionButton_UpdateAction( ActionButton12 )
							ActionButton_Update( ActionButton12 )
							ActionButton_UpdateHotkeys( ActionButton12, nil );
						end
					]] );
					end
					RegisterStateDriver( frame, "page", "[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;1")
						
					if frame.btns then
						for id, abtn in pairs( frame.btns ) do
							abtn:SetAttribute( "_onstate-page", [[ -- arguments: self, stateid, newstate

							]] );
							RegisterStateDriver( abtn, "page", "[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;1")
						end
					end
				end
			end
	end
end )
