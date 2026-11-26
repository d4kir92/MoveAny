local _, MoveAny = ...
local hooksecurefunc = MoveAny.hooksecurefunc
local ma_setalpha = {}
local ma_mm_show = {}
local buttonBag = {buttons = {}, hooked = {}, known = {}, failed = {}, byName = {}, lines = {}}

function MoveAny:GetMinimapButtonLabel(button)
	if button:GetName() == "MetashiForeverMinimapButton" then return "MetashiForever" end
	return (button:GetName():gsub("^MinimapButton_D4Lib_LibDBIcon_", ""):gsub("^LibDBIcon10_", ""))
end

function MoveAny:ShouldCollectMinimapButton(button)
	local choices = MATAB.minimapButtonBag and MATAB.minimapButtonBag.choices
	local choice = choices and choices[button:GetName()]
	if choice ~= nil then return choice end
	local label = MoveAny:GetMinimapButtonLabel(button):lower()
	return not label:find("bug", 1, true) and not label:find("lfg", 1, true)
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
		button:SetPoint(unpack(point, 1, 5))
	end

	button:SetScript("OnDragStart", state.dragStart)
	button:SetScript("OnDragStop", state.dragStop)
	if button.D4Think then button.D4Think(true) end
end

function MoveAny:GetMinimapBagOrder()
	MATAB.minimapButtonBag.order = MATAB.minimapButtonBag.order or {}

	return MATAB.minimapButtonBag.order
end

function MoveAny:IsMinimapBagSeparator(key)
	return type(key) == "string" and key:find("MASEP:", 1, true) == 1
end

function MoveAny:IsMinimapBagKeyCollected(key)
	if MoveAny:IsMinimapBagSeparator(key) then return true end
	local button = buttonBag.byName[key]

	return button ~= nil and MoveAny:ShouldCollectMinimapButton(button)
end

function MoveAny:GetMinimapBagKeyLabel(key)
	if MoveAny:IsMinimapBagSeparator(key) then return MoveAny:Trans("LID_MINIMAPBUTTONBAGSEPARATOR") end
	local button = buttonBag.byName[key]

	return button and MoveAny:GetMinimapButtonLabel(button) or key
end

function MoveAny:FindMinimapBagKey(key)
	for i, entry in ipairs(MoveAny:GetMinimapBagOrder()) do
		if entry == key then return i end
	end
end

function MoveAny:SyncMinimapBagOrder()
	local order = MoveAny:GetMinimapBagOrder()
	local listed = {}
	for i = 1, #order do
		local key = order[i]
		if type(key) ~= "string" or listed[key] then
			order[i] = false
		else
			listed[key] = true
		end
	end

	for i = #order, 1, -1 do
		if order[i] == false then tremove(order, i) end
	end

	local missing = {}
	for button in pairs(buttonBag.known) do
		local name = button:GetName()
		if not listed[name] and MoveAny:ShouldCollectMinimapButton(button) then tinsert(missing, name) end
	end

	table.sort(missing, function(a, b) return a:lower() < b:lower() end)
	for _, name in ipairs(missing) do
		tinsert(order, name)
	end
end

function MoveAny:MoveMinimapBagEntry(key, collected, index)
	if InCombatLockdown() or not key then return end
	local order = MoveAny:GetMinimapBagOrder()
	local from = MoveAny:FindMinimapBagKey(key)
	if from then
		tremove(order, from)
		if index and index > from then index = index - 1 end
	end

	if not MoveAny:IsMinimapBagSeparator(key) then
		MATAB.minimapButtonBag.choices = MATAB.minimapButtonBag.choices or {}
		MATAB.minimapButtonBag.choices[key] = collected
	elseif not collected and buttonBag.selected == key then
		buttonBag.selected = nil
	end

	if collected and (index or MoveAny:IsMinimapBagSeparator(key)) then tinsert(order, math.max(1, math.min(index or #order + 1, #order + 1)), key) end
	MoveAny:CollectMinimapButtons()
end

function MoveAny:AddMinimapBagSeparator()
	if InCombatLockdown() then return end
	local db = MATAB.minimapButtonBag
	db.separatorId = (db.separatorId or 0) + 1
	local key = "MASEP:" .. db.separatorId
	local index = buttonBag.selected and MoveAny:IsMinimapBagKeyCollected(buttonBag.selected) and MoveAny:FindMinimapBagKey(buttonBag.selected)
	buttonBag.selected = key
	MoveAny:MoveMinimapBagEntry(key, true, index and index + 1)
end

function MoveAny:GetMinimapBagDropIndex(panel)
	local top = panel.content:GetTop()
	if not top then return #panel.entries + 1 end
	local _, y = GetCursorPosition()
	local pos = math.floor((top - y / panel.content:GetEffectiveScale()) / 28 + 0.5) + 1

	return math.max(1, math.min(#panel.entries + 1, pos))
end

function MoveAny:DropMinimapBagEntry(key)
	local window = buttonBag.settings
	local collectedPanel = window.panels[1]
	if collectedPanel:IsMouseOver() then
		local entries = collectedPanel.entries
		local pos = MoveAny:GetMinimapBagDropIndex(collectedPanel)
		local index
		if entries[pos] then
			index = MoveAny:FindMinimapBagKey(entries[pos])
		elseif entries[#entries] then
			index = (MoveAny:FindMinimapBagKey(entries[#entries]) or #MoveAny:GetMinimapBagOrder()) + 1
		end

		MoveAny:MoveMinimapBagEntry(key, true, index)
	elseif window.panels[2]:IsMouseOver() and MoveAny:IsMinimapBagKeyCollected(key) then
		MoveAny:MoveMinimapBagEntry(key, false)
	end
end

function MoveAny:CreateMinimapBagRow(panel, i)
	local window = buttonBag.settings
	local row = CreateFrame("Button", nil, panel.content)
	panel.rows[i] = row
	row:SetHeight(26)
	row:SetPoint("TOPLEFT", 0, -(i - 1) * 28)
	row:SetPoint("RIGHT", panel.content, "RIGHT")
	row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	row.selection = row:CreateTexture(nil, "BACKGROUND")
	row.selection:SetAllPoints()
	row.selection:SetColorTexture(0.2, 0.5, 0.8, 0.4)
	row.icon = row:CreateTexture(nil, "ARTWORK")
	row.icon:SetSize(20, 20)
	row.icon:SetPoint("LEFT", 4, 0)
	row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	row.label:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
	row.label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
	row.label:SetJustifyH("LEFT")
	row.label:SetWordWrap(false)
	row.line = row:CreateTexture(nil, "ARTWORK")
	row.line:SetHeight(1)
	row.line:SetColorTexture(0.6, 0.6, 0.6, 1)
	row:RegisterForDrag("LeftButton")
	row:SetScript("OnClick", function(sel)
		buttonBag.selected = sel.key
		MoveAny:RefreshMinimapButtonSettings()
	end)
	row:SetScript("OnDragStart", function(sel)
		if InCombatLockdown() then return end
		buttonBag.dragging = sel.key
		window.ghost.label:SetText(MoveAny:GetMinimapBagKeyLabel(sel.key))
		window.ghost:Show()
	end)
	row:SetScript("OnDragStop", function()
		local dragged = buttonBag.dragging
		buttonBag.dragging = nil
		window.ghost:Hide()
		if dragged then MoveAny:DropMinimapBagEntry(dragged) end
		MoveAny:RefreshMinimapButtonSettings()
	end)
	row:SetScript("OnEnter", function(sel)
		GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
		GameTooltip:SetText(MoveAny:GetMinimapBagKeyLabel(sel.key))
		GameTooltip:Show()
	end)
	row:SetScript("OnLeave", function() GameTooltip:Hide() end)

	return row
end

function MoveAny:FillMinimapBagRow(row, key)
	row.key = key
	row.label:SetText(MoveAny:GetMinimapBagKeyLabel(key))
	if MoveAny:IsMinimapBagSeparator(key) then
		row.icon:Hide()
		row.label:SetTextColor(0.6, 0.6, 0.6)
		row.line:ClearAllPoints()
		row.line:SetPoint("LEFT", row, "LEFT", 36 + row.label:GetStringWidth(), 0)
		row.line:SetPoint("RIGHT", row, "RIGHT", -6, 0)
		row.line:Show()
	else
		row.icon:Show()
		row.line:Hide()
		row.label:SetTextColor(1, 0.82, 0)
		if not pcall(MoveAny.CopyMinimapButtonIcon, MoveAny, buttonBag.byName[key], row.icon) then row.icon:SetTexture(134400) end
	end

	row.selection:SetShown(buttonBag.selected == key)
	row:Show()
end

function MoveAny:RefreshMinimapButtonSettings()
	local window = buttonBag.settings
	if not window or not window:IsShown() or buttonBag.dragging then return end
	local lists = {{}, {}}
	for _, key in ipairs(MoveAny:GetMinimapBagOrder()) do
		local button = buttonBag.byName[key]
		if MoveAny:IsMinimapBagSeparator(key) or (button and buttonBag.known[button] and MoveAny:ShouldCollectMinimapButton(button)) then tinsert(lists[1], key) end
	end

	for button in pairs(buttonBag.known) do
		if not MoveAny:ShouldCollectMinimapButton(button) then tinsert(lists[2], button:GetName()) end
	end

	table.sort(lists[2], function(a, b) return MoveAny:GetMinimapBagKeyLabel(a):lower() < MoveAny:GetMinimapBagKeyLabel(b):lower() end)
	window.title:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAG"))
	window.hint:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAGHINT"))
	window.addSeparator:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAGADDSEPARATOR"))
	window.removeSeparator:SetText(MoveAny:Trans("LID_MINIMAPBUTTONBAGREMOVESEPARATOR"))
	for side, list in ipairs(lists) do
		local panel = window.panels[side]
		panel.entries = list
		panel.title:SetText(MoveAny:Trans(side == 1 and "LID_MINIMAPBUTTONBAGCOLLECTED" or "LID_MINIMAPBUTTONBAGKEPT"))
		for _, row in ipairs(panel.rows) do
			row:Hide()
		end

		for i, key in ipairs(list) do
			MoveAny:FillMinimapBagRow(panel.rows[i] or MoveAny:CreateMinimapBagRow(panel, i), key)
		end

		panel.content:SetHeight(math.max(1, #list * 28))
		if panel.scrollBox then
			panel.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
		else
			panel.scroll:SetVerticalScroll(math.min(panel.scroll:GetVerticalScroll(), math.max(0, #list * 28 - panel.scroll:GetHeight())))
		end
	end

	local selected = buttonBag.selected
	local isSeparator = MoveAny:IsMinimapBagSeparator(selected)
	window.toMinimap:SetEnabled(selected ~= nil and not isSeparator and MoveAny:IsMinimapBagKeyCollected(selected))
	window.toBag:SetEnabled(selected ~= nil and not isSeparator and not MoveAny:IsMinimapBagKeyCollected(selected))
	window.removeSeparator:SetEnabled(isSeparator)
end

function MoveAny:CopyMinimapButtonIcon(button, target)
	local source = button.icon or button.Icon
	if not source or not source.GetTexture then
		target:SetTexture(134400)
		target:SetTexCoord(0, 1, 0, 1)
		target:SetVertexColor(1, 1, 1, 1)

		return
	end

	local atlas = source.GetAtlas and source:GetAtlas()
	if atlas then
		target:SetAtlas(atlas)
	else
		target:SetTexture(source:GetTexture() or 134400)
		target:SetTexCoord(source:GetTexCoord())
	end

	target:SetVertexColor(source:GetVertexColor())
	target:SetDesaturated(source:IsDesaturated() and true or false)
end

function MoveAny:CreateMinimapBagScroll(panel)
	if ScrollUtil and ScrollUtil.InitScrollBoxWithScrollBar and CreateScrollBoxLinearView and ScrollBoxConstants and MoveAny:CheckTemplates("WowScrollBox, MinimalScrollBar") then
		panel.scrollBox = CreateFrame("Frame", nil, panel, "WowScrollBox")
		panel.scrollBox:SetPoint("TOPLEFT", 4, -4)
		panel.scrollBox:SetPoint("BOTTOMRIGHT", -22, 4)
		panel.scrollBar = CreateFrame("EventFrame", nil, panel, "MinimalScrollBar")
		panel.scrollBar:SetPoint("TOPLEFT", panel.scrollBox, "TOPRIGHT", 6, 0)
		panel.scrollBar:SetPoint("BOTTOMLEFT", panel.scrollBox, "BOTTOMRIGHT", 6, 0)
		panel.content = CreateFrame("Frame", nil, panel.scrollBox)
		panel.content.scrollable = true
		panel.content:SetSize(218, 1)
		panel.contentInset = 26
		local view = CreateScrollBoxLinearView()
		view:SetPanExtent(28)
		ScrollUtil.InitScrollBoxWithScrollBar(panel.scrollBox, panel.scrollBar, view)

		return
	end

	panel.scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	panel.scroll:SetPoint("TOPLEFT", 4, -4)
	panel.scroll:SetPoint("BOTTOMRIGHT", -26, 4)
	panel.content = CreateFrame("Frame", nil, panel.scroll)
	panel.content:SetSize(218, 1)
	panel.contentInset = 30
	panel.scroll:SetScrollChild(panel.content)
end

function MoveAny:UpdateMinimapBagDropLine()
	local window = buttonBag.settings
	local panel = window.panels[1]
	if not buttonBag.dragging or not panel:IsMouseOver() or not panel.entries then
		window.dropLine:Hide()

		return
	end

	window.dropLine:ClearAllPoints()
	window.dropLine:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -(MoveAny:GetMinimapBagDropIndex(panel) - 1) * 28 + 1)
	window.dropLine:SetPoint("RIGHT", panel.content, "RIGHT")
	window.dropLine:Show()
end

function MoveAny:CreateMinimapBagResizeGrip(window)
	local db = MATAB.minimapButtonBag
	window:SetResizable(true)
	if window.SetResizeBounds then
		window:SetResizeBounds(520, 360)
	elseif window.SetMinResize then
		window:SetMinResize(520, 360)
	end

	if db.settingsWidth and db.settingsHeight then window:SetSize(math.max(520, db.settingsWidth), math.max(360, db.settingsHeight)) end
	local grip = CreateFrame("Button", nil, window)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", -2, 2)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetScript("OnMouseDown", function() window:StartSizing("BOTTOMRIGHT") end)
	grip:SetScript("OnMouseUp", function()
		window:StopMovingOrSizing()
		db.settingsWidth = math.floor(window:GetWidth() + 0.5)
		db.settingsHeight = math.floor(window:GetHeight() + 0.5)
	end)
end

function MoveAny:ToggleMinimapButtonSettings()
	if InCombatLockdown() then return end
	if not buttonBag.settings then
		local window = CreateFrame("Frame", "MAMinimapButtonSettings", UIParent, "BackdropTemplate")
		buttonBag.settings = window
		window:SetSize(580, 460)
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
			if side == 1 then
				panel:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -68)
				panel:SetPoint("BOTTOMRIGHT", window, "BOTTOM", -38, 76)
			else
				panel:SetPoint("TOPLEFT", window, "TOP", 38, -68)
				panel:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -16, 76)
			end

			panel:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground"})
			panel:SetBackdropColor(0, 0, 0, 0.5)
			panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			panel.title:SetPoint("BOTTOM", panel, "TOP", 0, 8)
			MoveAny:CreateMinimapBagScroll(panel)
			panel.rows = {}
			panel:SetScript("OnSizeChanged", function(sel, width)
				sel.content:SetWidth(math.max(1, width - sel.contentInset))
				if sel.scrollBox then sel.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately) end
			end)
		end

		window.dropLine = window.panels[1].content:CreateTexture(nil, "OVERLAY")
		window.dropLine:SetHeight(2)
		window.dropLine:SetColorTexture(1, 0.82, 0, 1)
		window.dropLine:Hide()
		window.addSeparator = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.addSeparator:SetHeight(22)
		window.addSeparator:SetPoint("TOPLEFT", window.panels[1], "BOTTOMLEFT", 0, -8)
		window.addSeparator:SetPoint("RIGHT", window.panels[1], "CENTER", -2, 0)
		window.addSeparator:SetScript("OnClick", function() MoveAny:AddMinimapBagSeparator() end)
		window.removeSeparator = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.removeSeparator:SetHeight(22)
		window.removeSeparator:SetPoint("TOPRIGHT", window.panels[1], "BOTTOMRIGHT", 0, -8)
		window.removeSeparator:SetPoint("LEFT", window.panels[1], "CENTER", 2, 0)
		window.removeSeparator:SetScript("OnClick", function()
			if MoveAny:IsMinimapBagSeparator(buttonBag.selected) then MoveAny:MoveMinimapBagEntry(buttonBag.selected, false) end
		end)
		MoveAny:CreateMinimapBagResizeGrip(window)

		window.toMinimap = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.toMinimap:SetSize(44, 28)
		window.toMinimap:SetPoint("CENTER", 0, 20)
		window.toMinimap:SetText(">")
		window.toMinimap:SetScript("OnClick", function() MoveAny:MoveMinimapBagEntry(buttonBag.selected, false) end)
		window.toBag = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
		window.toBag:SetSize(44, 28)
		window.toBag:SetPoint("CENTER", 0, -20)
		window.toBag:SetText("<")
		window.toBag:SetScript("OnClick", function() MoveAny:MoveMinimapBagEntry(buttonBag.selected, true) end)
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
			MoveAny:UpdateMinimapBagDropLine()
		end)
		window.ghost:SetScript("OnHide", function() window.dropLine:Hide() end)
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
	pcall(MoveAny.ArrangeMinimapButtons, MoveAny)
	buttonBag.updating = false
end

function MoveAny:GetMinimapBagGroups()
	local groups, group = {}, {}
	for _, key in ipairs(MoveAny:GetMinimapBagOrder()) do
		if MoveAny:IsMinimapBagSeparator(key) then
			if #group > 0 then
				tinsert(groups, group)
				group = {}
			end
		else
			local button = buttonBag.byName[key]
			if button and buttonBag.buttons[button] and button:IsShown() then tinsert(group, button) end
		end
	end

	if #group > 0 then tinsert(groups, group) end

	return groups
end

function MoveAny:ShowMinimapBagLine(index, y)
	local menu = buttonBag.menu
	local line = buttonBag.lines[index]
	if not line then
		line = menu:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetColorTexture(0.35, 0.35, 0.35, 1)
		buttonBag.lines[index] = line
	end

	line:ClearAllPoints()
	line:SetPoint("TOPLEFT", menu, "TOPLEFT", 8, -y)
	line:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -8, -y)
	line:Show()
end

function MoveAny:ArrangeMinimapButtons()
	local y, columns, lineCount = 6, 1, 0
	for _, list in ipairs(MoveAny:GetMinimapBagGroups()) do
		local top = y > 6 and y + 9 or y
		local placed = 0
		for _, button in ipairs(list) do
			if pcall(MoveAny.PlaceMinimapButton, MoveAny, button, placed, top) then
				placed = placed + 1
			else
				MoveAny:DropMinimapButton(button)
			end
		end

		if placed > 0 then
			if top > y then
				lineCount = lineCount + 1
				MoveAny:ShowMinimapBagLine(lineCount, y + 4)
			end

			columns = math.max(columns, math.min(6, placed))
			y = top + math.ceil(placed / 6) * 36
		end
	end

	for i = lineCount + 1, #buttonBag.lines do
		buttonBag.lines[i]:Hide()
	end

	buttonBag.menu:SetSize(columns * 36 + 12, math.max(42, y) + 6)
end

function MoveAny:DropMinimapButton(button)
	buttonBag.failed[button] = true
	pcall(MoveAny.ReleaseMinimapButton, MoveAny, button)
	buttonBag.buttons[button] = nil
end

function MoveAny:PlaceMinimapButton(button, index, top)
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
	button:SetPoint("CENTER", buttonBag.menu, "TOPRIGHT", -24 - (index % 6) * 36, -(top + 18) - math.floor(index / 6) * 36)
end

function MoveAny:IsMinimapBagCandidate(button)
	if button == buttonBag.toggle or buttonBag.buttons[button] or buttonBag.failed[button] then return false end
	if button:IsForbidden() or button:IsProtected() or not button:IsObjectType("Button") then return false end
	local name = button:GetName()
	return name ~= nil and (name:find("LibDBIcon10_", 1, true) == 1 or name:find("MinimapButton_D4Lib_LibDBIcon_", 1, true) == 1 or name == "MetashiForeverMinimapButton")
end

function MoveAny:CollectMinimapButton(button)
	if not MoveAny:IsMinimapBagCandidate(button) then return end
	buttonBag.known[button] = true
	buttonBag.byName[button:GetName()] = button
	if not MoveAny:ShouldCollectMinimapButton(button) then return end
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

function MoveAny:CollectMinimapButtons()
	if not buttonBag.enabled or InCombatLockdown() then return end
	buttonBag.childCount = Minimap:GetNumChildren()
	for button in pairs(buttonBag.buttons) do
		local ok, collect = pcall(MoveAny.ShouldCollectMinimapButton, MoveAny, button)
		if (not ok or not collect) and not pcall(MoveAny.ReleaseMinimapButton, MoveAny, button) then MoveAny:DropMinimapButton(button) end
	end

	for _, button in ipairs({Minimap:GetChildren()}) do
		if not pcall(MoveAny.CollectMinimapButton, MoveAny, button) then MoveAny:DropMinimapButton(button) end
	end

	pcall(MoveAny.SyncMinimapBagOrder, MoveAny)
	MoveAny:LayoutMinimapButtons()
	pcall(MoveAny.RefreshMinimapButtonSettings, MoveAny)
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
		if not buttonBag.watcher then
			buttonBag.watcher = CreateFrame("Frame")
			buttonBag.watcher:SetScript("OnUpdate", function()
				if Minimap:GetNumChildren() ~= buttonBag.childCount then MoveAny:CollectMinimapButtons() end
			end)
		end

		buttonBag.watcher:Show()
		if not buttonBag.ticker then buttonBag.ticker = C_Timer.NewTicker(5, function() MoveAny:CollectMinimapButtons() end) end
	else
		if buttonBag.watcher then buttonBag.watcher:Hide() end
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
