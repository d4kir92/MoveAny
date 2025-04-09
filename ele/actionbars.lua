local _, MoveAny = ...
local MAMaxAB = 10
local btns = {}
local abpoints = {}
local abs = {}
function MoveAny:GetAllActionBars()
	return abs
end

btns[1] = "ActionButton"
btns[3] = "MultiBarRightButton" --"MultiBarRightButton"
btns[4] = "MultiBarLeftButton" --"MultiBarLeftButton"
btns[5] = "MultiBarBottomRightButton" --"MultiBarBottomRightButton"
btns[6] = "MultiBarBottomLeftButton" --"MultiBarBottomLeftButton"
local function MASetPoint(name, po, pa, re, px, py, rows)
	abpoints[name] = {}
	abpoints[name]["PO"] = po
	abpoints[name]["PA"] = pa
	abpoints[name]["RE"] = re
	abpoints[name]["PX"] = px
	abpoints[name]["PY"] = py
	abpoints[name]["ROWS"] = rows
end

local dSpacing = 2
local dFlipped = false
local BarNames = {}
function MoveAny:AddBarName(frame, name)
	BarNames[frame] = name
end

local visiTab = {}
visiTab[1] = 5
visiTab[2] = 4
visiTab[3] = 2
visiTab[4] = 3
function MoveAny:UpdateVisi()
	local barVisibles = {GetActionBarToggles()}
	if not InCombatLockdown() then
		for i = 1, 5 do
			if visiTab[i] and abs[visiTab[i]] then
				local bar = abs[visiTab[i]]
				if i ~= 4 and barVisibles[i] or barVisibles[i] and barVisibles[i - 1] then
					if not bar:IsShown() then
						bar:Show()
					end
				else
					if bar:IsShown() then
						bar:Hide()
					end
				end
			end
		end
	end

	C_Timer.After(0.3, MoveAny.UpdateVisi)
end

MoveAny:UpdateVisi()
function MoveAny:UpdateActionBar(frame)
	if frame.ma_setpoint_ab then return end
	MoveAny:SafeExec(
		frame,
		function()
			local name = MoveAny:GetName(frame) or BarNames[frame]
			local opts = MoveAny:GetEleOptions(name, "UpdateActionBar")
			opts["ROWS"] = opts["ROWS"] or nil
			opts["OFFSET"] = opts["OFFSET"] or nil
			opts["SPACING"] = opts["SPACING"] or dSpacing
			opts["FLIPPED"] = opts["FLIPPED"] or dFlipped
			local flipped = opts["FLIPPED"]
			if opts["ROWS"] == nil and abpoints[name] and abpoints[name]["ROWS"] then
				opts["ROWS"] = abpoints[name]["ROWS"]
			end

			local offset = opts["OFFSET"] or 0
			local rows = opts["ROWS"] or 1
			rows = tonumber(rows)
			local parent = MicroMenu or MAMenuBar
			if frame == MAMenuBar then
				if MoveAny:GetWoWBuild() == "RETAIL" then
					if rows == 3 or rows == 4 or rows == 6 or rows == 7 or rows == 8 or rows == 9 or rows == 12 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(parent)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					elseif rows == 11 or rows == 1 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					elseif rows == 10 or rows == 5 or rows == 2 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(MAHIDDEN)
						end
					else
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					end
				elseif MoveAny:GetWoWBuild() == "CATA" then
					if rows == 1 or rows == 2 or rows == 3 or rows == 4 or rows == 6 or rows == 7 or rows == 8 or rows == 9 or rows == 12 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(parent)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					elseif rows == 11 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					elseif rows == 10 or rows == 5 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(MAHIDDEN)
						end
					else
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					end
				elseif MoveAny:GetWoWBuild() == "WRATH" then
					if rows == 11 or rows == 9 or rows == 8 or rows == 7 or rows == 6 or rows == 4 or rows == 1 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(parent)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					elseif rows == 10 or rows == 5 or rows == 2 then
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(parent)
						end
					else
						if HelpMicroButton then
							HelpMicroButton:SetParent(MAHIDDEN)
						end

						if MainMenuMicroButton then
							MainMenuMicroButton:SetParent(MAHIDDEN)
						end
					end
				end
			end

			local maxbtns = 0
			for i, abtn in pairs(frame.btns) do
				if MoveAny:GetParent(abtn) ~= MAHIDDEN then
					maxbtns = maxbtns + 1
				end
			end

			if maxbtns == 0 then
				maxbtns = 1
			end

			opts["COUNT"] = opts["COUNT"] or maxbtns
			local count = opts["COUNT"] or maxbtns
			count = tonumber(count)
			local maxB = maxbtns
			if frame ~= MAMenuBar and frame ~= StanceBar then
				if count > 0 then
					maxB = count
				end
			else
				maxB = maxbtns
			end

			local cols = maxB / rows
			--[[if cols % 1 ~= 0 then
		rows = maxB
		cols = maxB / rows
	end]]
			if cols % 1 ~= 0 then
				cols = math.ceil(cols)
			end

			local spacing = opts["SPACING"]
			spacing = tonumber(spacing)
			if frame.btns and frame.btns[1] then
				local fSizeW, fSizeH = frame.btns[1]:GetSize()
				local ofx = frame.btns[1].ofx or 0
				local ofy = frame.btns[1].ofy or 0
				local rsw = frame.btns[1].rsw
				local rsh = frame.btns[1].rsh
				if rsw then
					fSizeW = MoveAny:MathR(rsw, 0)
				else
					fSizeW = MoveAny:MathR(fSizeW, 0)
				end

				if rsh then
					fSizeH = MoveAny:MathR(rsh, 0)
				else
					fSizeH = MoveAny:MathR(fSizeH, 0)
				end

				local id = 1
				for i, abtn in pairs(frame.btns) do
					if not InCombatLockdown() then
						abtn:ClearAllPoints()
						if flipped then
							abtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", (id - 1) % cols * (fSizeW + spacing) + ofx + offset, ((id - 1) / cols - (id - 1) % cols / cols) * (fSizeH + spacing) + ofy - offset)
						else
							abtn:SetPoint("TOPLEFT", frame, "TOPLEFT", (id - 1) % cols * (fSizeW + spacing) + ofx + offset, 1 - ((id - 1) / cols - (id - 1) % cols / cols) * (fSizeH + spacing) + ofy - offset)
						end

						if abtn.setup == nil then
							abtn.setup = true
							if frame == MAMenuBar then
								hooksecurefunc(
									abtn,
									"Hide",
									function(sel)
										if sel.ma_abtn_hide then return end
										sel.ma_abtn_hide = true
										sel:Show()
										sel.ma_abtn_hide = false
									end
								)
							else
								hooksecurefunc(
									abtn,
									"Show",
									function(sel)
										if sel.ma_abtn_hide then return end
										sel.ma_abtn_hide = true
										if sel.hide and sel:IsShown() then
											sel:Hide()
										end

										sel.ma_abtn_hide = false
									end
								)
							end
						end

						abtn.oldparent = abtn.oldparent or MoveAny:GetParent(abtn)
						if frame ~= MAMenuBar and frame ~= StanceBar and count > 0 and i > count then
							abtn.hide = true
							abtn:SetParent(MAHIDDEN)
							if abtn:IsShown() then
								abtn:Hide()
							end
						end

						if frame == MAMenuBar then
							abtn.hide = false
							if not abtn:IsShown() then
								abtn:Show()
							end
						end

						if MoveAny:GetParent(abtn) ~= MAHIDDEN then
							id = id + 1
						end
					end
				end

				if not InCombatLockdown() then
					frame:SetSize(cols * (fSizeW + spacing) - spacing + offset * 2, rows * (fSizeH + spacing) - spacing + offset * 2)
					local mover = _G[name .. "_MA_DRAG"]
					local sw, sh = frame:GetSize()
					local osw, osh = MoveAny:GetEleSize(name)
					sw = MoveAny:MathR(sw)
					sh = MoveAny:MathR(sh)
					if osw ~= sw or osh ~= sh then
						MoveAny:SetEleSize(name, sw, sh)
					end

					if mover then
						mover:SetSize(frame:GetSize())
					end
				end
			end
		end
	)
end

function MoveAny:InitActionBarLayouts()
	if MoveAny:GetWoWBuild() == "RETAIL" then
		MASetPoint("MainMenuBar", "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 0, 1) -- MainMenuBar
		MASetPoint("MultiBarBottomLeft", "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, -60, 1) -- MultiBarBottomLeft
		MASetPoint("MultiBarBottomRight", "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, -120, 1) -- MultiBarBottomRight
		MASetPoint("MultiBarRight", "RIGHT", MoveAny:GetMainPanel(), "RIGHT", 0, 0, 12) -- MultiBarRight
		MASetPoint("MultiBarLeft", "RIGHT", MoveAny:GetMainPanel(), "RIGHT", -36, 0, 12) -- MultiBarLeft
		MASetPoint("MultiBar" .. 5, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 0, 1) -- "MultiBar" .. 5
		MASetPoint("MultiBar" .. 6, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 0, 1) -- "MultiBar" .. 6
		MASetPoint("MultiBar" .. 7, "CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0, 1) -- "MultiBar" .. 7
		MASetPoint("MultiBar" .. 8, "CENTER", MoveAny:GetMainPanel(), "CENTER", -360, 1 * 36, 1)
		MASetPoint("MultiBar" .. 9, "CENTER", MoveAny:GetMainPanel(), "CENTER", -360, 2 * 36, 1)
	else
		MASetPoint("MAActionBar" .. 1, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 0, 1)
		MASetPoint("MAActionBar" .. 3, "RIGHT", MoveAny:GetMainPanel(), "RIGHT", 0, 0, 12)
		MASetPoint("MAActionBar" .. 4, "RIGHT", MoveAny:GetMainPanel(), "RIGHT", -36, 0, 12)
		MASetPoint("MAActionBar" .. 5, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 360, 0, 2)
		MASetPoint("MAActionBar" .. 6, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 36, 1)
		MASetPoint("MAActionBar" .. 7, "BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", -360, 0, 2)
		MASetPoint("MAActionBar" .. 8, "CENTER", MoveAny:GetMainPanel(), "CENTER", -360, 0 * 36, 1)
		MASetPoint("MAActionBar" .. 9, "CENTER", MoveAny:GetMainPanel(), "CENTER", -360, 1 * 36, 1)
		MASetPoint("MAActionBar" .. 10, "CENTER", MoveAny:GetMainPanel(), "CENTER", -360, 2 * 36, 1)
	end
end

local function UpdateActionBarBackground(show)
	for name, bar in pairs(abs) do
		local ab = bar
		if ab and ab.btns then
			for id, abtn in pairs(ab.btns) do
				local btnname = MoveAny:GetName(abtn)
				if btnname and _G[btnname .. "FloatingBG"] then
					_G[btnname .. "FloatingBG"]:Show()
				end

				if btnname and _G[btnname .. "NormalTexture"] then
					if show == nil then
						if show == true or show == 1 then
							ActionButton_ShowGrid(abtn)
						elseif show == false or show == 0 then
							ActionButton_HideGrid(abtn)
						end
					end
				else
					MoveAny:MSG("NOT FOUND: " .. tostring(btnname))
				end
			end
		end
	end
end

local once = true
function MoveAny:CustomBars()
	if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:IsEnabled("ACTIONBARS", false) then
		for i = 0, 3 do
			local texture = _G["MainMenuMaxLevelBar" .. i]
			if texture then
				hooksecurefunc(
					texture,
					"Show",
					function(sel)
						if sel.mahide then return end
						sel.mahide = true
						sel:Hide()
						sel.mahide = false
					end
				)

				texture:Hide()
			end
		end

		if StanceBarLeft then
			hooksecurefunc(
				StanceBarLeft,
				"Show",
				function(sel)
					if sel.mahide then return end
					sel.mahide = true
					sel:Hide()
					sel.mahide = false
				end
			)

			StanceBarLeft:Hide()
		end

		if StanceBarMiddle then
			hooksecurefunc(
				StanceBarMiddle,
				"Show",
				function(sel)
					if sel.mahide then return end
					sel.mahide = true
					sel:Hide()
					sel.mahide = false
				end
			)

			StanceBarMiddle:Hide()
		end

		if StanceBarRight then
			hooksecurefunc(
				StanceBarRight,
				"Show",
				function(sel)
					if sel.mahide then return end
					sel.mahide = true
					sel:Hide()
					sel.mahide = false
				end
			)

			StanceBarRight:Hide()
		end

		if SlidingActionBarTexture0 then
			hooksecurefunc(
				SlidingActionBarTexture0,
				"Show",
				function(sel)
					if sel.mahide then return end
					sel.mahide = true
					sel:Hide()
					sel.mahide = false
				end
			)

			SlidingActionBarTexture0:Hide()
		end

		if SlidingActionBarTexture1 then
			hooksecurefunc(
				SlidingActionBarTexture1,
				"Show",
				function(sel)
					if sel.mahide then return end
					sel.mahide = true
					sel:Hide()
					sel.mahide = false
				end
			)

			SlidingActionBarTexture1:Hide()
		end
	end

	for i = 1, MAMaxAB do
		if i ~= 2 and i <= 6 and MoveAny:IsEnabled("ACTIONBARS", false) or MoveAny:IsEnabled("ACTIONBAR" .. i, false) then
			local name = "MAActionBar" .. i
			_G[name] = CreateFrame("Frame", name, MoveAny:GetMainPanel(), "SecureHandlerStateTemplate")
			local bar = _G[name]
			bar:SetFrameLevel(4)
			bar:SetSize(36 * 12, 36)
			bar:SetPoint(abpoints[name]["PO"], abpoints[name]["PA"], abpoints[name]["RE"], abpoints[name]["PX"], abpoints[name]["PY"])
			if i > 1 then
				bar:SetAttribute("actionpage", i)
			end

			bar.btns = {}
			tinsert(abs, bar)
			for x = 1, 12 do
				local btnname = "ActionBar" .. i .. "Button" .. x
				if btns[i] then
					btnname = btns[i] .. x
				end

				_G["BINDING_NAME_CLICK " .. btnname .. ":LeftButton"] = MoveAny:Trans("LID_BINDINGFORMAT", nil, i, x)
				local btn = _G[btnname]
				local id = (i - 1) * 12 + x
				if btn == nil then
					btn = CreateFrame("CheckButton", btnname, bar, "ActionBarButtonTemplate, SecureActionButtonTemplate")
					--btn.commandName = "CLICK " .. btnname
					btn:SetAttribute("action", id)
					btn:HookScript(
						"OnMouseDown",
						function(sel)
							if GetCVar("ActionButtonUseKeyDown") == "1" then
								if MoveAny:GetMouseFocus() == sel and IsMouseButtonDown("LeftButton") then
									btn:RegisterForClicks("AnyUp")
								else
									btn:RegisterForClicks("AnyDown")
								end
							else
								btn:RegisterForClicks("AnyUp")
							end
						end
					)
				else
					btn.bindingID = x
					btn:RegisterForClicks("AnyUp")
				end

				local alwaysShow = GetCVarBool("alwaysShowActionBars")
				if alwaysShow then
					alwaysShow = 1
				else
					alwaysShow = 0
				end

				btn:SetAttribute("statehidden", false)
				btn:SetAttribute("showgrid", alwaysShow)
				if alwaysShow then
					ActionButton_ShowGrid(btn)
				else
					ActionButton_HideGrid(btn)
				end

				if _G[btnname .. "FloatingBG"] == nil then
					_G[btnname .. "FloatingBG"] = btn:CreateTexture(btnname .. "FloatingBG", "BACKGROUND")
					_G[btnname .. "FloatingBG"]:SetParent(btn)
					_G[btnname .. "FloatingBG"]:SetPoint("TOPLEFT", -15, 15)
					_G[btnname .. "FloatingBG"]:SetPoint("BOTTOMRIGHT", 15, -15)
					_G[btnname .. "FloatingBG"]:SetTexture("Interface/Buttons/UI-Quickslot")
					_G[btnname .. "FloatingBG"]:SetVertexColor(1, 1, 0, 0.4)
					_G[btnname .. "FloatingBG"]:SetDrawLayer("BACKGROUND", -1)
				end

				btn.maid = id
				btn:SetParent(bar)
				btn:ClearAllPoints()
				btn:SetPoint("TOPLEFT", MoveAny:GetParent(btn), "TOPLEFT", (x - 1) * 36, 0)
				btn:SetSize(36, 36)
				hooksecurefunc(
					btn,
					"SetPoint",
					function(sel, ...)
						if _G[name].ma_setpoint_ab then return end
						_G[name].ma_setpoint_ab = true
						MoveAny:UpdateActionBar(_G[name])
						_G[name].ma_setpoint_ab = false
					end
				)

				hooksecurefunc(
					btn,
					"SetParent",
					function(sel, ...)
						if _G[name].ma_setpoint_ab then return end
						_G[name].ma_setpoint_ab = true
						MoveAny:UpdateActionBar(_G[name])
						_G[name].ma_setpoint_ab = false
					end
				)

				hooksecurefunc(
					btn,
					"SetSize",
					function(sel, ...)
						if _G[name].ma_setpoint_ab then return end
						_G[name].ma_setpoint_ab = true
						MoveAny:UpdateActionBar(_G[name])
						_G[name].ma_setpoint_ab = false
					end
				)

				tinsert(bar.btns, btn)
			end

			MoveAny:UpdateActionBar(_G[name])
		end
	end

	-- Masque
	if once then
		once = false
		if LibStub then
			local MSQ = LibStub("Masque", true)
			if MSQ then
				MSQ:Register("MoveAny Blizzard Action Bars", function() end, {})
				local MAMasqueGroups = {}
				MAMasqueGroups.Groups = {}
				for x, bar in pairs(abs) do
					for y, btn in pairs(bar.btns) do
						if btn then
							local btnName = MoveAny:GetName(btn)
							if _G[btnName .. "FloatingBG"] then
								_G[btnName .. "FloatingBG"]:SetParent(MAHIDDEN)
							end

							local parent = MoveAny:GetName(MoveAny:GetParent(btn))
							local group = nil
							if MAMasqueGroups.Groups["MA " .. parent] == nil then
								MAMasqueGroups.Groups["MA " .. parent] = MSQ:Group("MA Blizzard Action Bars", "MA " .. parent)
							end

							group = MAMasqueGroups.Groups["MA " .. parent]
							if not btn.MasqueButtonData then
								btn.MasqueButtonData = {
									Button = btn,
									Icon = _G[btnName .. "IconTexture"],
								}
							end

							group:AddButton(btn, btn.MasqueButtonData, "Item")
						end
					end
				end
			end
		end
	end
end

local asabf = CreateFrame("Frame")
asabf:RegisterEvent("CVAR_UPDATE")
asabf:SetScript(
	"OnEvent",
	function(self, event, target, value)
		if event == "CVAR_UPDATE" and target == "alwaysShowActionBars" then
			UpdateActionBarBackground(tonumber(value))
		end
	end
)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:SetScript(
	"OnEvent",
	function(sel, event)
		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			local frame = _G["MAActionBar" .. 1]
			if frame and frame.init == nil then
				frame.init = true
				frame:SetAttribute("_onstate-page", [[ -- arguments: self, stateid, newstate
					if newstate == "possess" or newstate == "dragon" or newstate == "11" then
						if HasVehicleActionBar() then
							newstate = GetVehicleBarIndex()
						elseif HasOverrideActionBar() then
							newstate = GetOverrideBarIndex()
						elseif HasTempShapeshiftActionBar() then
							newstate = GetTempShapeshiftBarIndex()
						elseif HasBonusActionBar() then
							newstate = GetBonusBarIndex()
						else
							newstate = nil
						end
						
						if not newstate then
							print("[MOVEANY] FAILED TO FIND NEWSTATE!: " .. tostring(newstate))
							newstate = 12
						end
					end

					self:SetAttribute("actionpage", newstate);
				]])
				if MoveAny:GetWoWBuild() ~= "RETAIL" then
					--[[
					Stances:
					cat-stealth: 10?
					cat: 7
					bear: 9
					moonkin: 1
					]]
					local bars = "[overridebar]" .. GetOverrideBarIndex() .. ";[shapeshift]" .. GetTempShapeshiftBarIndex() .. ";[vehicleui]" .. GetVehicleBarIndex() .. ";[possessbar]16;"
					for i = 6, 2, -1 do
						bars = bars .. "[bonusbar:5,bar:" .. i .. "]" .. i .. ";[bonusbar:4,bar:" .. i .. "]" .. i .. ";[bonusbar:3,bar:" .. i .. "]" .. i .. ";[bonusbar:2,bar:" .. i .. "]" .. i .. ";[bonusbar:1,bar:" .. i .. "]" .. i .. ";"
					end

					local _, class = UnitClass("player")
					if class == "DRUID" and MoveAny:IsEnabled("CHANGEONCATSTEALTH", true) then
						bars = bars .. "[bonusbar:1,stealth]10;"
					end

					bars = bars .. "[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;1"
					RegisterStateDriver(frame, "page", bars)
				else
					MoveAny:MSG("MISSING EXPANSION")
				end

				local _onAttributeChanged = [[
					if name == 'statehidden' then
						if HasOverrideActionBar() or HasVehicleActionBar() or HasTempShapeshiftActionBar() then
							for i = 1, 12 do
								if overridebuttons[i] and overridebuttons[i]:GetAttribute('statehidden') then
									buttons[i]:SetAttribute('statehidden', true)
									buttons[i]:Hide()
								elseif buttons[i] then
									buttons[i]:SetAttribute('statehidden', false)
									buttons[i]:Show()
								end
							end
						else
							for i = 1, 12 do
								if buttons[i] then
									buttons[i]:SetAttribute('statehidden', false)
									buttons[i]:Show()
								end
							end
						end
					end
				]]
				if MoveAny:GetWoWBuild() == "CLASSIC" then
					_onAttributeChanged = [[
						if name == 'statehidden' then
							for i = 1, 12 do
								if buttons[i] then
									buttons[i]:SetAttribute('statehidden', false)
									buttons[i]:Show()
								end
							end
						end
					]]
				end

				local AttributeChangedFrame = CreateFrame("Frame", nil, MoveAny:GetMainPanel(), "SecureHandlerAttributeTemplate")
				for i = 1, 12 do
					local button = _G["ActionButton" .. i]
					AttributeChangedFrame:SetFrameRef("ActionButton" .. i, button)
				end

				for i = 1, 6 do
					local overrideButton = _G["OverrideActionBarButton" .. i]
					if overrideButton then
						AttributeChangedFrame:SetFrameRef("OverrideActionBarButton" .. i, overrideButton)
					end
				end

				AttributeChangedFrame:Execute([[
					buttons = table.new()
					for i = 1, 12 do
						buttons[i] = self:GetFrameRef('ActionButton'..i)
					end
				
					overridebuttons = table.new()
					for j = 1, 12 do
						overridebuttons[j] = self:GetFrameRef('OverrideActionBarButton'..j)
					end
				]])
				AttributeChangedFrame:SetAttribute("_onattributechanged", _onAttributeChanged)
				RegisterStateDriver(AttributeChangedFrame, "visibility", "[overridebar][shapeshift][vehicleui][possessbar] show; hide")
			end
		end
	end
)
