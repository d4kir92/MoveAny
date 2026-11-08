local _, MoveAny = ...
local hooksecurefunc = MoveAny.hooksecurefunc
local ma_setalpha = {}
local ma_mm_show = {}
local buttonBag = {buttons = {}, hooked = {}, known = {}}

function MoveAny:GetMinimapButtonLabel(button)
	if button:GetName() == "MetashiForeverMinimapButton" then return "MetashiForever" end
	return (button:GetName():gsub("^MinimapButton_D4Lib_LibDBIcon_", ""):gsub("^LibDBIcon10_", ""))
end

function MoveAny:ShouldCollectMinimapButton(button)
	local choices = MATAB.minimapButtonBag and MATAB.minimapButtonBag.choices
	local choice = choices and choices[button:GetName()]
	if choice ~= nil then return choice end
	return not MoveAny:GetMinimapButtonLabel(button):lower():find("bug", 1, true)
end

function MoveAny:ReleaseMinimapButton(button)
	local state = buttonBag.buttons[button]
	if not state then return end
	buttonBag.buttons[button] = nil
	button:SetParent(state.parent)
	button:SetFrameStrata(state.strata)
	button:SetFrameLevel(state.level)
	if state.fixedStrata then button:SetFixedFrameStrata(true) end
	if state.fixedLevel then button:SetFixedFrameLevel(true) end
	button:SetScale(state.scale)
	button:ClearAllPoints()
	for _, point in ipairs(state.points) do
		button:SetPoint(unpack(point))
	end

	button:SetScript("OnDragStart", state.dragStart)
	button:SetScript("OnDragStop", state.dragStop)
	if button.D4Think then button.D4Think(true) end
end

function MoveAny:SetMinimapButtonCollected(button, collected)
	if InCombatLockdown() or not button then return end
	MATAB.minimapButtonBag.choices = MATAB.minimapButtonBag.choices or {}
	MATAB.minimapButtonBag.choices[button:GetName()] = collected
	buttonBag.selected = nil
	MoveAny:CollectMinimapButtons()
end

function MoveAny:RefreshMinimapButtonSettings()
	local window = buttonBag.settings
	if not window or not window:IsShown() or buttonBag.dragging then return end
	local lists = {{}, {}}
	for button in pairs(buttonBag.known) do
		tinsert(lists[MoveAny:ShouldCollectMinimapButton(button) and 1 or 2], button)
	end

	window.title:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAG"))
	window.hint:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAGHINT"))
	for side, list in ipairs(lists) do
		local panel = window.panels[side]
		panel.title:SetText(MoveAny:Trans(side == 1 and "LID_MINIMAPBUTTONBAGCOLLECTED" or "LID_MINIMAPBUTTONBAGKEPT"))
		table.sort(list, function(a, b) return MoveAny:GetMinimapButtonLabel(a):lower() < MoveAny:GetMinimapButtonLabel(b):lower() end)
		for _, row in ipairs(panel.rows) do
			row:Hide()
		end

		for i, button in ipairs(list) do
			local row = panel.rows[i]
			if not row then
				row = CreateFrame("Button", nil, panel.content)
				panel.rows[i] = row
				row:SetSize(218, 26)
				row:SetPoint("TOPLEFT", 0, -(i - 1) * 28)
				row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
				row.selection = row:CreateTexture(nil, "BACKGROUND")
				row.selection:SetAllPoints()
				row.selection:SetColorTexture(0.2, 0.5, 0.8, 0.4)
				row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				row.label:SetPoint("LEFT", 6, 0)
				row.label:SetWidth(206)
				row.label:SetJustifyH("LEFT")
				row:RegisterForDrag("LeftButton")
				row:SetScript("OnClick", function(sel)
					buttonBag.selected = sel.button
					MoveAny:RefreshMinimapButtonSettings()
				end)
				row:SetScript("OnDragStart", function(sel)
					if InCombatLockdown() then return end
					buttonBag.dragging = sel.button
					window.ghost.label:SetText(MoveAny:GetMinimapButtonLabel(sel.button))
					window.ghost:Show()
				end)
				row:SetScript("OnDragStop", function()
					local dragged = buttonBag.dragging
					buttonBag.dragging = nil
					window.ghost:Hide()
					for target, destination in ipairs(window.panels) do
						if destination:IsMouseOver() then MoveAny:SetMinimapButtonCollected(dragged, target == 1) end
					end

					MoveAny:RefreshMinimapButtonSettings()
				end)
				row:SetScript("OnEnter", function(sel)
					GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
					GameTooltip:SetText(MoveAny:GetMinimapButtonLabel(sel.button))
					GameTooltip:Show()
				end)
				row:SetScript("OnLeave", function() GameTooltip:Hide() end)
			end

			row.button = button
			row.label:SetText(MoveAny:GetMinimapButtonLabel(button))
			row.selection:SetShown(buttonBag.selected == button)
			row:Show()
		end

		panel.content:SetHeight(math.max(1, #list * 28))
		panel.scroll:SetVerticalScroll(math.min(panel.scroll:GetVerticalScroll(), math.max(0, #list * 28 - panel.scroll:GetHeight())))
	end

	window.toMinimap:SetEnabled(buttonBag.selected ~= nil and MoveAny:ShouldCollectMinimapButton(buttonBag.selected))
	window.toBag:SetEnabled(buttonBag.selected ~= nil and not MoveAny:ShouldCollectMinimapButton(buttonBag.selected))
end

function MoveAny:ToggleMinimapButtonSettings()
	if InCombatLockdown() then return end
	if not buttonBag.settings then
		local window = CreateFrame("Frame", "MAMinimapButtonSettings", UIParent, "BackdropTemplate")
		buttonBag.settings = window
		window:SetSize(580, 420)
		window:SetPoint("CENTER")
		window:SetFrameStrata("DIALOG")
		window:SetClampedToScreen(true)
		window:EnableMouse(true)
		window:SetMovable(true)
		window:RegisterForDrag("LeftButton")
		window:SetScript("OnDragStart", window.StartMoving)
		window:SetScript("OnDragStop", window.StopMovingOrSizing)
		window:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
		window:SetBackdropColor(0.05, 0.05, 0.05, 0.98)
		window:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
		window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		window.title:SetPoint("TOP", 0, -16)
		window.hint = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		window.hint:SetPoint("BOTTOM", 0, 14)
		window.hint:SetWidth(540)
		local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -2, -2)
		window.panels = {}
		for side = 1, 2 do
			local panel = CreateFrame("Frame", nil, window, "BackdropTemplate")
			window.panels[side] = panel
			panel:SetSize(244, 306)
			panel:SetPoint("TOPLEFT", side == 1 and 16 or 320, -68)
			panel:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
			panel:SetBackdropColor(0, 0, 0, 0.5)
			panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			panel.title:SetPoint("BOTTOM", panel, "TOP", 0, 8)
			panel.scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
			panel.scroll:SetPoint("TOPLEFT", 4, -4)
			panel.scroll:SetPoint("BOTTOMRIGHT", -26, 4)
			panel.content = CreateFrame("Frame", nil, panel.scroll)
			panel.content:SetSize(218, 1)
			panel.scroll:SetScrollChild(panel.content)
			panel.rows = {}
		end

		window.toMinimap = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.toMinimap:SetSize(44, 28)
		window.toMinimap:SetPoint("CENTER", 0, 20)
		window.toMinimap:SetText(">")
		window.toMinimap:SetScript("OnClick", function() MoveAny:SetMinimapButtonCollected(buttonBag.selected, false) end)
		window.toBag = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.toBag:SetSize(44, 28)
		window.toBag:SetPoint("CENTER", 0, -20)
		window.toBag:SetText("<")
		window.toBag:SetScript("OnClick", function() MoveAny:SetMinimapButtonCollected(buttonBag.selected, true) end)
		window.ghost = CreateFrame("Frame", nil, UIParent)
		window.ghost:SetFrameStrata("TOOLTIP")
		window.ghost:SetSize(220, 26)
		window.ghost.label = window.ghost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		window.ghost.label:SetAllPoints()
		window.ghost.label:SetJustifyH("LEFT")
		window.ghost:SetScript("OnUpdate", function(sel)
			local x, y = GetCursorPosition()
			local scale = UIParent:GetEffectiveScale()
			sel:ClearAllPoints()
			sel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale + 12, y / scale)
		end)
		window.ghost:Hide()
		window:SetScript("OnHide", function()
			buttonBag.dragging = nil
			window.ghost:Hide()
			window:StopMovingOrSizing()
		end)
		tinsert(UISpecialFrames, "MAMinimapButtonSettings")
		window:Hide()
	end

	buttonBag.menu:Hide()
	buttonBag.settings:SetShown(not buttonBag.settings:IsShown())
	MoveAny:CollectMinimapButtons()
end

function MoveAny:LayoutMinimapButtons()
	if buttonBag.updating or InCombatLockdown() or not buttonBag.enabled then return end
	buttonBag.updating = true
	local visible = {}
	for button in pairs(buttonBag.buttons) do
		if button:IsShown() then tinsert(visible, button) end
	end

	table.sort(visible, function(a, b) return a:GetName() < b:GetName() end)
	for i, button in ipairs(visible) do
		local state = buttonBag.buttons[button]
		button:SetParent(buttonBag.menu)
		button:SetFrameStrata(buttonBag.menu:GetFrameStrata())
		if button:GetFrameStrata() ~= buttonBag.menu:GetFrameStrata() and button.SetFixedFrameStrata then
			state.fixedStrata = true
			button:SetFixedFrameStrata(false)
			button:SetFrameStrata(buttonBag.menu:GetFrameStrata())
		end

		button:SetFrameLevel(buttonBag.menu:GetFrameLevel() + 2)
		if button:GetFrameLevel() ~= buttonBag.menu:GetFrameLevel() + 2 and button.SetFixedFrameLevel then
			state.fixedLevel = true
			button:SetFixedFrameLevel(false)
			button:SetFrameLevel(buttonBag.menu:GetFrameLevel() + 2)
		end

		button:SetScale(1)
		button:ClearAllPoints()
		button:SetPoint("CENTER", buttonBag.menu, "TOPRIGHT", -24 - ((i - 1) % 6) * 36, -24 - math.floor((i - 1) / 6) * 36)
	end

	buttonBag.menu:SetSize(math.max(1, math.min(6, #visible)) * 36 + 12, math.max(1, math.ceil(#visible / 6)) * 36 + 12)
	buttonBag.updating = false
end

function MoveAny:CollectMinimapButtons()
	if not buttonBag.enabled or InCombatLockdown() then return end
	for button in pairs(buttonBag.buttons) do
		if not MoveAny:ShouldCollectMinimapButton(button) then MoveAny:ReleaseMinimapButton(button) end
	end

	for _, button in ipairs({Minimap:GetChildren()}) do
		local name = button:GetName()
		if name and button ~= buttonBag.toggle and not buttonBag.buttons[button] and not button:IsProtected() and button:IsObjectType("Button") and (name:find("LibDBIcon10_", 1, true) == 1 or name:find("MinimapButton_D4Lib_LibDBIcon_", 1, true) == 1 or name == "MetashiForeverMinimapButton") then
			buttonBag.known[button] = true
			if MoveAny:ShouldCollectMinimapButton(button) then
				local state = {parent = button:GetParent(), scale = button:GetScale(), points = {}, dragStart = button:GetScript("OnDragStart"), dragStop = button:GetScript("OnDragStop")}
				state.strata = button:GetFrameStrata()
				state.level = button:GetFrameLevel()
				for i = 1, button:GetNumPoints() do
					tinsert(state.points, {button:GetPoint(i)})
				end

				buttonBag.buttons[button] = state
				button:SetScript("OnDragStart", nil)
				button:SetScript("OnDragStop", nil)
				button:SetParent(buttonBag.menu)
				if not buttonBag.hooked[button] then
					buttonBag.hooked[button] = true
					local function Refresh()
						if buttonBag.buttons[button] then MoveAny:LayoutMinimapButtons() end
					end

					hooksecurefunc(button, "SetPoint", Refresh)
					hooksecurefunc(button, "SetParent", Refresh)
					hooksecurefunc(button, "SetScale", Refresh)
					hooksecurefunc(button, "SetFrameStrata", Refresh)
					hooksecurefunc(button, "SetFrameLevel", Refresh)
					if button.SetFixedFrameStrata then hooksecurefunc(button, "SetFixedFrameStrata", Refresh) end
					if button.SetFixedFrameLevel then hooksecurefunc(button, "SetFixedFrameLevel", Refresh) end
					button:HookScript("OnShow", Refresh)
					button:HookScript("OnHide", Refresh)
				end
			end
		end
	end

	MoveAny:LayoutMinimapButtons()
	MoveAny:RefreshMinimapButtonSettings()
end

function MoveAny:UpdateMinimapButtonBag()
	if InCombatLockdown() then return end
	local enabled = MoveAny:IsEnabled("MINIMAPBUTTONBAG", false)
	if not buttonBag.menu then
		if not enabled then return end
		local menu = CreateFrame("Frame", "MAMinimapButtonMenu", UIParent, "BackdropTemplate")
		buttonBag.menu = menu
		menu:SetFrameStrata("DIALOG")
		menu:SetClampedToScreen(true)
		menu:EnableMouse(true)
		menu:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
		menu:SetBackdropBorderColor(0.35, 0.35, 0.35, 1)
		menu:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
		menu:Hide()
		tinsert(UISpecialFrames, "MAMinimapButtonMenu")
		MATAB.minimapButtonBag = MATAB.minimapButtonBag or {minimapPos = 180}
		buttonBag.toggle = MoveAny:CreateMinimapButton({
			name = "MoveAnyButtonBag",
			icon = 133633,
			dbtab = MATAB.minimapButtonBag,
			dbkey = "",
			nobag = true,
			addoncomp = false,
			noalpha = true,
			vTT = {},
			vTTUpdate = function(_, tooltip)
				tooltip:AddLine(MoveAny:Trans("LID_MINIMAPBUTTONBAG"))
				tooltip:AddDoubleLine(MoveAny:Trans("LID_LEFTCLICK"), MoveAny:Trans("LID_MINIMAPBUTTONBAGTOGGLE"))
				tooltip:AddDoubleLine(MoveAny:Trans("LID_RIGHTCLICK"), MoveAny:Trans("LID_MINIMAPBUTTONBAGCONFIG"))
				return false
			end,
			funcL = function()
				if InCombatLockdown() then return end
				MoveAny:CollectMinimapButtons()
				menu:SetShown(not menu:IsShown())
			end,
			funcR = function() MoveAny:ToggleMinimapButtonSettings() end,
		})
		menu:SetPoint("TOPRIGHT", buttonBag.toggle, "BOTTOMLEFT", 0, -4)
	end

	buttonBag.enabled = enabled
	buttonBag.toggle:SetShown(enabled)
	if enabled then
		MoveAny:CollectMinimapButtons()
		if not buttonBag.ticker then buttonBag.ticker = C_Timer.NewTicker(5, function() MoveAny:CollectMinimapButtons() end) end
	else
		buttonBag.menu:Hide()
		if buttonBag.settings then buttonBag.settings:Hide() end
		if buttonBag.ticker then
			buttonBag.ticker:Cancel()
			buttonBag.ticker = nil
		end

		for button in pairs(buttonBag.buttons) do
			MoveAny:ReleaseMinimapButton(button)
		end

		wipe(buttonBag.buttons)
	end
end

function MoveAny:InitMinimapButtonBag()
	local events = CreateFrame("Frame")
	events:RegisterEvent("PLAYER_REGEN_ENABLED")
	events:RegisterEvent("PLAYER_REGEN_DISABLED")
	events:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_REGEN_DISABLED" then
			if buttonBag.menu then buttonBag.menu:Hide() end
			if buttonBag.settings then buttonBag.settings:Hide() end
		else
			MoveAny:UpdateMinimapButtonBag()
		end
	end)
	MoveAny:UpdateMinimapButtonBag()
end

function MoveAny:InitMinimap()
	if not MoveAny:IsEnabled("MINIMAP", false) then return end
	if ElvUI then return end
	if MinimapToggleButton then MinimapToggleButton:SetParent(MoveAny:GetHidden()) end
	if MinimapBorderTop then MinimapBorderTop:SetParent(MoveAny:GetHidden()) end
	hooksecurefunc(Minimap, "SetAlpha", function()
		local alpha = MoveAny:GetMainPanel():GetAlpha()
		if alpha == 0 then
			if ma_setalpha[self] then return end
			ma_setalpha[self] = true
			Minimap:SetAlpha(0)
			ma_setalpha[self] = false
		end
	end)

	if MinimapBackdrop then
		hooksecurefunc(MinimapBackdrop, "SetAlpha", function()
			local alpha = MoveAny:GetMainPanel():GetAlpha()
			if alpha == 0 then
				if ma_setalpha[self] then return end
				ma_setalpha[self] = true
				MinimapBackdrop:SetAlpha(0)
				ma_setalpha[self] = false
			end
		end)
	end

	local debugMinimap = false
	local miniMapTab = {"MiniMapMailFrame", "GarrisonLandingPageMinimapButton", "QueueStatusMinimapButton", "MiniMapInstanceDifficulty", "MiniMapChallengeMode", "GuildInstanceDifficulty", "MiniMapLFGFrame", "MiniMapBattlefieldFrame", "MiniMapTracking"}
	if debugMinimap then
		for i, name in pairs(miniMapTab) do
			local btn = _G[name]
			if btn then
				hooksecurefunc(btn, "Hide", function(sel)
					if ma_mm_show[sel] then return end
					ma_mm_show[sel] = true
					sel:Show()
					ma_mm_show[sel] = false
				end)

				btn:Show()
			else
				MoveAny:MSG(tostring(name) .. " not found")
			end
		end
	end
end
