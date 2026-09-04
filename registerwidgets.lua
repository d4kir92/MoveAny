local _, MoveAny = ...
local ma_ismoving = {}
local ma_setup = {}
local ma_enablemouse = {}
local ma_scri = {}
local ma_setscale_ele = {}
local framelevel = 1100
local btnsize = 24
local ses = {}
local runSelectedReset = false
local fnt = {}
local MACurrentEle = nil
local MAEF = {}
local startRegisterWidget = false
local missingWidgets = {}
local giveUpWidgets = {}
local giveUpScheduled = false
local retryFrame = CreateFrame("Frame")
local function GiveUpMissingWidgets()
	for name, tab in pairs(missingWidgets) do
		giveUpWidgets[name] = tab
		missingWidgets[name] = nil
	end
end

MoveAny:OnEvent(retryFrame, function(sel, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if giveUpScheduled then return end
		giveUpScheduled = true
		MoveAny:After(60, GiveUpMissingWidgets, "Widgets GiveUp")
		return
	end

	for name, tab in pairs(giveUpWidgets) do
		if missingWidgets[name] == nil then missingWidgets[name] = tab end
		giveUpWidgets[name] = nil
	end

	MoveAny:SafeRetryRegisterWidgets()
	if giveUpScheduled then MoveAny:After(5, GiveUpMissingWidgets, "Widgets GiveUp 2") end
end, "retryFrame")

MoveAny:RegisterEvent(retryFrame, "PLAYER_ENTERING_WORLD")
function MoveAny:GetMissingWidgets()
	return missingWidgets
end

local retryLocked = false
local retrySnapshot = {}
function MoveAny:RetryRegisterWidgets()
	if retryLocked then return end
	retryLocked = true
	local count = 0
	for _, tab in pairs(MoveAny:GetMissingWidgets()) do
		count = count + 1
		retrySnapshot[count] = tab
	end

	for i = 1, count do
		local tab = retrySnapshot[i]
		retrySnapshot[i] = nil
		local ok, err = pcall(MoveAny.RegisterWidget, MoveAny, tab)
		if not ok then MoveAny:MSG("[RegisterWidget] FAILED", tab and tab.name, err) end
	end

	retryLocked = false
end

function MoveAny:SafeRetryRegisterWidgets()
	if not startRegisterWidget then return end
	MoveAny:RetryRegisterWidgets()
end

local retryPending = false
local retryThrottle = 0.1
local nextRetryAt = 0
hooksecurefunc("CreateFrame", function(...)
	if not startRegisterWidget then return end
	if retryPending then return end
	if retryLocked then return end
	if next(missingWidgets) == nil then return end
	retryPending = true
	local delay = nextRetryAt - GetTime()
	if delay < 0 then delay = 0 end
	MoveAny:After(delay, function()
		retryPending = false
		nextRetryAt = GetTime() + retryThrottle
		MoveAny:SafeRetryRegisterWidgets()
	end, "CreateFrame RetryRegisterWidgets")
end)

MoveAny:After(2, function() MoveAny:RetryRegisterWidgets() end, "Init startRegisterWidget 1")
MoveAny:After(7, function()
	startRegisterWidget = true
	MoveAny:RegisterEvent(retryFrame, "ADDON_LOADED")
	MoveAny:RetryRegisterWidgets()
end, "Init startRegisterWidget 2")

function MoveAny:GetEleFrames()
	return MAEF
end

function MoveAny:GetCurrentEle()
	return MACurrentEle
end

function MoveAny:AddFrameName(frame, name)
	if frame == nil then
		MoveAny:MSG("AddFrameName: frame is nil")
		return false
	end

	if name == nil then
		MoveAny:MSG("AddFrameName: name is nil")
		return false
	end

	fnt[frame] = name
	return true
end

function MoveAny:GetFrameName(frame)
	if frame == nil then
		MoveAny:MSG("GetFrameName: frame is nil")
		return "FAILED"
	end
	return fnt[frame]
end

local function ApplyReload()
	if C_UI then
		C_UI.Reload()
	else
		ReloadUI()
	end
end

local ARROW_UP = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up"
local ARROW_UP_PUSHED = "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down"
local ARROW_DOWN = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"
local ARROW_DOWN_PUSHED = "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down"
local ARROW_LEFT = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
local ARROW_RIGHT = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"
function MoveAny:AddElePosition(win, name)
	local label = MoveAny:Trans("LID_POSITION")
	local height = 18 + btnsize * 5
	local holder = CreateFrame("Frame", nil, win.content)
	holder:SetSize(math.max(1, win.contentWidth - 8), height)
	holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	holder.Label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	function holder:UpdateText()
		local _, _, _, p4, p5 = MoveAny:GetElePoint(name)
		holder.Label:SetText(format("%s X: %d Y: %d", label, p4 or 0, p5 or 0))
	end

	local function Arrow(col, row, x, y, texNor, texPus)
		local btn = MoveAny:CreateButton(nil, holder, true)
		btn:SetNormalTexture(texNor)
		btn:SetPushedTexture(texPus)
		btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		btn:SetSize(btnsize, btnsize)
		btn:SetPoint("TOPLEFT", holder, "TOPLEFT", col * btnsize, -18 - row * btnsize)
		btn:SetScript("OnClick", function()
			local p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
			if p1 and p3 and p4 and p5 then MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 + x, p5 + y) end
			holder:UpdateText()
		end)

		return btn
	end

	Arrow(2, 0, 0, 5, ARROW_UP, ARROW_UP_PUSHED)
	Arrow(2, 1, 0, 1, ARROW_UP, ARROW_UP_PUSHED)
	Arrow(0, 2, -5, 0, ARROW_LEFT, ARROW_LEFT)
	Arrow(1, 2, -1, 0, ARROW_LEFT, ARROW_LEFT)
	Arrow(3, 2, 1, 0, ARROW_RIGHT, ARROW_RIGHT)
	Arrow(4, 2, 5, 0, ARROW_RIGHT, ARROW_RIGHT)
	Arrow(2, 3, 0, -1, ARROW_DOWN, ARROW_DOWN_PUSHED)
	Arrow(2, 4, 0, -5, ARROW_DOWN, ARROW_DOWN_PUSHED)
	holder:UpdateText()
	MoveAny.UI:Add(win, holder, height, label, true, "POSITION")

	return holder
end

function MoveAny:AddEleScale(win, name)
	local label = MoveAny:Trans("LID_SCALE")
	local height = 18 + btnsize
	local width = btnsize * 2
	local holder = CreateFrame("Frame", nil, win.content)
	holder:SetSize(math.max(1, win.contentWidth - 8), height)
	holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	holder.Label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	function holder:UpdateText()
		holder.Label:SetText(format("%s: %0.2f", label, MoveAny:GetEleScale(name) or 1))
	end

	local function Button(index, text, func)
		local btn = MoveAny:CreateButton(nil, holder)
		btn:SetSize(width, btnsize)
		btn:SetPoint("TOPLEFT", holder, "TOPLEFT", index * (width + 3), -18)
		btn:SetText(text)
		btn:SetScript("OnClick", function()
			func()
			holder:UpdateText()
		end)

		return btn
	end

	local function Step(index, step)
		return Button(index, format("%+0.2f", step), function()
			local val = tonumber(format("%.2f", (MoveAny:GetEleScale(name) or 1) + step))
			if val == nil then return end
			if val < 0.1 then val = 0.1 end
			MoveAny:SetEleScale(name, val)
		end)
	end

	Step(0, -1)
	Step(1, -0.1)
	Step(2, -0.01)
	Button(3, format("%0.2f", 1), function() MoveAny:SetEleScale(name, 1) end)
	Step(4, 0.01)
	Step(5, 0.1)
	Step(6, 1)
	holder:UpdateText()
	MoveAny.UI:Add(win, holder, height, label, true, "SCALE")

	return holder
end

function MoveAny:AddEleReset(win, name)
	local label = MoveAny:Trans("LID_RESETELEMENT")
	local holder = CreateFrame("Frame", nil, win.content)
	holder:SetSize(math.max(1, win.contentWidth - 8), MoveAny.UI.ROW)
	local btn = MoveAny:CreateButton(nil, holder)
	btn:SetSize(btnsize * 8, MoveAny.UI.ROW)
	btn:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	btn:SetText(label)
	btn:SetScript("OnClick", function()
		MoveAny:ResetElement(name)
		ApplyReload()
	end)

	holder.control = btn
	MoveAny.UI:Add(win, holder, MoveAny.UI.ROW, label, true, "RESETELEMENT")

	return holder
end

local function AddEleCategory(win, key, label, level)
	return win:AddCategory({
		["label"] = label or MoveAny:Trans("LID_" .. key),
		["level"] = level or 1,
		["key"] = "ELEOPT" .. key,
		["search"] = key,
	})
end

local function AddEleSlider(win, name, key, value, vmin, vmax, step, decimals, func, label)
	return win:AddSlider({
		["label"] = label or ("LID_" .. key),
		["search"] = key,
		["value"] = MoveAny:GetEleOption(name, key, value, "MenuOptions " .. key),
		["min"] = vmin,
		["max"] = vmax,
		["step"] = step,
		["decimals"] = decimals,
		["func"] = function(val)
			MoveAny:SetEleOption(name, key, val)
			if func then func(val) end
		end,
	})
end

local function AuraChoices(map, cur)
	local values = {}
	local found = false
	for value in pairs(map) do
		tinsert(values, value)
		if value == cur then found = true end
	end

	table.sort(values)
	local choices = {}
	for _, value in ipairs(values) do
		tinsert(
			choices,
			{
				["value"] = value,
				["label"] = "LID_" .. map[value]
			}
		)
	end

	if cur ~= nil and not found then
		tinsert(
			choices,
			{
				["value"] = cur,
				["label"] = tostring(cur)
			}
		)
	end

	return choices
end

local function AddEleDropdown(win, name, key, value, map, func, label)
	local cur = MoveAny:GetEleOption(name, key, value, "MenuOptions " .. key)

	return win:AddDropdown({
		["label"] = label or ("LID_" .. key),
		["search"] = key,
		["value"] = cur,
		["choices"] = AuraChoices(map, cur),
		["func"] = function(val)
			MoveAny:SetEleOption(name, key, val)
			if func then func(val) end
		end,
	})
end

local function AddDurationOptions(win, name, prefix, refresh)
	local apply = function()
		if MoveAny.UpdateAuraDurations then MoveAny:UpdateAuraDurations("MenuOptions") end
		if refresh then refresh() end
	end

	AddEleDropdown(win, name, prefix .. "ANCHOR", 0, MoveAny.DurationAnchors, apply, "LID_ANCHOR")
	AddEleSlider(win, name, prefix .. "SPACING", 0, -30, 30, 1, 0, apply, "LID_SPACING")
	AddEleSlider(win, name, prefix .. "SIZE", MoveAny:GetDurationDefaultSize(name), 4, 12, 1, 0, apply, "LID_TEXTSIZE")
	AddEleDropdown(win, name, prefix .. "FONT", 0, MoveAny.DurationFonts, apply, "LID_FONT")
	AddEleDropdown(win, name, prefix .. "FORMAT", 0, MoveAny.DurationFormats, apply, "LID_FORMAT")
	win:AddColorPicker({
		["label"] = "LID_COLOR",
		["search"] = prefix .. "COLOR",
		["value"] = {
			["r"] = MoveAny:GetEleOption(name, prefix .. "COLOR_R", 1),
			["g"] = MoveAny:GetEleOption(name, prefix .. "COLOR_G", 1),
			["b"] = MoveAny:GetEleOption(name, prefix .. "COLOR_B", 1),
			["a"] = MoveAny:GetEleOption(name, prefix .. "COLOR_A", 1),
		},
		["func"] = function(r, g, b, a)
			MoveAny:SetEleOption(name, prefix .. "COLOR_R", r)
			MoveAny:SetEleOption(name, prefix .. "COLOR_G", g)
			MoveAny:SetEleOption(name, prefix .. "COLOR_B", b)
			MoveAny:SetEleOption(name, prefix .. "COLOR_A", a)
			apply()
		end,
	})
end

local function AddGeneralOptions(win, name, optionFrame)
	AddEleCategory(win, "GENERAL")
	win.elePos = MoveAny:AddElePosition(win, name)
	win.eleScale = MoveAny:AddEleScale(win, name)
	local clickthrough, lockparent
	local function UpdateHideDeps(hidden)
		for _, cb in pairs({clickthrough, lockparent}) do
			cb:SetEnabled(not hidden)
			if cb.Label then
				if hidden then
					cb.Label:SetTextColor(0.5, 0.5, 0.5)
				else
					cb.Label:SetTextColor(1, 0.82, 0)
				end
			end
		end
	end

	win:AddCheckbox({
		["label"] = HIDE,
		["search"] = "HIDE",
		["value"] = MoveAny:GetEleOption(name, "Hide", false, "Hide1"),
		["func"] = function(value)
			MoveAny:SetEleOption(name, "Hide", value)
			local dragf = MoveAny:GetDragFromName(name)
			if value then
				MoveAny:HideFrame(optionFrame)
				MoveAny:UpdateEleColor(dragf)
				if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
					dragf:Hide()
				else
					dragf:Show()
				end
			else
				MoveAny:ShowFrame(optionFrame)
				MoveAny:UpdateEleColor(dragf)
			end

			UpdateHideDeps(value)
		end,
	})

	clickthrough = win:AddCheckbox({
		["label"] = "LID_CLICKTHROUGH",
		["search"] = "CLICKTHROUGH",
		["value"] = MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough1"),
		["func"] = function(value)
			MoveAny:SetEleOption(name, "ClickThrough", value)
			local dragf = MoveAny:GetDragFromName(name)
			if optionFrame == nil then
				if dragf then dragf:Hide() end

				return
			end

			if value and dragf then dragf:Show() end
			MoveAny:UpdateEleColor(dragf)
			optionFrame:EnableMouse(not value)
			local target = optionFrame.AuraContainer or optionFrame
			MoveAny:ForeachChildren(target, function(child) if C_Widget.IsWidget(child) then child:EnableMouse(not value) end end, "clickthrough")
		end,
	})

	lockparent = win:AddCheckbox({
		["label"] = "LID_LOCKPARENT",
		["search"] = "LOCKPARENT",
		["value"] = MoveAny:GetEleOption(name, "LockParent", false, "LockParent1"),
		["func"] = function(value) MoveAny:SetEleOption(name, "LockParent", value) end,
	})

	lockparent:HookScript("OnEnter", function(sel)
		GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
		GameTooltip:SetText(MoveAny:Trans("LID_LOCKPARENT"))
		GameTooltip:AddLine(MoveAny:Trans("LID_LOCKPARENTDESC"), 1, 1, 1, true)
		GameTooltip:Show()
	end)

	lockparent:HookScript("OnLeave", function() GameTooltip:Hide() end)
	UpdateHideDeps(MoveAny:GetEleOption(name, "Hide", false, "Hide1"))
	MoveAny:AddEleReset(win, name)
end

local function AddActionBarOptions(win, name, opts, frame, optionFrame)
	AddEleCategory(win, "ACTIONBARS", ACTIONBARS_LABEL)
	local btns = MoveAny:GetAbBtns(frame)
	local maxBtns = 1
	if btns then maxBtns = getn(btns) end
	local rowsMax = maxBtns
	if frame ~= MAMenuBar and frame ~= StanceBar and opts["COUNT"] and opts["COUNT"] > 0 then rowsMax = opts["COUNT"] end
	local vmin = 1
	if frame == MAActionBar1 or frame == MainActionBar or frame == MainMenuBar then vmin = 6 end
	local sliderRows = nil
	if frame ~= MAMenuBar and optionFrame ~= StanceBarAnchor then
		win:AddSlider({
			["label"] = MoveAny:Trans("LID_COUNT"),
			["search"] = "COUNT",
			["value"] = opts["COUNT"] or maxBtns,
			["min"] = vmin,
			["max"] = maxBtns,
			["step"] = 1,
			["decimals"] = 0,
			["func"] = function(value)
				if value == opts["COUNT"] then return end
				opts["COUNT"] = value
				if sliderRows then
					sliderRows.slider:SetMinMaxValues(1, value)
					if sliderRows.High then sliderRows.High:SetText(value) end
					if sliderRows.value > value then sliderRows.slider:SetValue(value) end
				end

				if MoveAny.UpdateActionBar then MoveAny:UpdateActionBar(frame, "MenuOptions") end
			end,
		})
	end

	if btns and rowsMax >= 1 and optionFrame ~= StanceBarAnchor then
		sliderRows = win:AddSlider({
			["label"] = MoveAny:Trans("LID_ROWS"),
			["search"] = "ROWS",
			["value"] = opts["ROWS"] or 1,
			["min"] = 1,
			["max"] = rowsMax,
			["step"] = 1,
			["decimals"] = 0,
			["func"] = function(value)
				if value == opts["ROWS"] then return end
				opts["ROWS"] = value
				if frame.UpdateSystemSettingNumRows then
					frame.numRows = value
					frame:UpdateSystemSettingNumRows()
				end

				if MoveAny.UpdateActionBar then MoveAny:UpdateActionBar(frame, "MenuOptions2") end
			end,
		})
	end

	if optionFrame ~= StanceBarAnchor then
		win:AddSlider({
			["label"] = MoveAny:Trans("LID_OFFSET"),
			["search"] = "OFFSET",
			["value"] = opts["OFFSET"] or 0,
			["min"] = -4,
			["max"] = 8,
			["step"] = 1,
			["decimals"] = 0,
			["func"] = function(value)
				if value == opts["OFFSET"] then return end
				opts["OFFSET"] = value
				if MoveAny.UpdateActionBar then MoveAny:UpdateActionBar(frame, "MenuOptions3") end
			end,
		})

		win:AddCheckbox({
			["label"] = "LID_FLIPPED",
			["search"] = "FLIPPED",
			["value"] = MoveAny:GetEleOption(name, "FLIPPED", false, "Flipped1"),
			["func"] = function(value)
				MoveAny:SetEleOption(name, "FLIPPED", value)
				if MoveAny.UpdateActionBar then MoveAny:UpdateActionBar(frame, "MenuOptions4") end
			end,
		})
	end

	opts["SPACING"] = opts["SPACING"] or 2
	win:AddSlider({
		["label"] = MoveAny:Trans("LID_SPACING"),
		["search"] = "SPACING",
		["value"] = opts["SPACING"],
		["min"] = 0,
		["max"] = 16,
		["step"] = 1,
		["decimals"] = 0,
		["func"] = function(value)
			if value == opts["SPACING"] then return end
			opts["SPACING"] = value
			if MoveAny.UpdateActionBar then MoveAny:UpdateActionBar(frame, "MenuOptions5") end
		end,
	})

	if frame == MAActionBar1 or frame == MainActionBar then
		win:AddCheckbox({
			["label"] = "LID_CHANGEONCATSTEALTH",
			["search"] = "CHANGEONCATSTEALTH",
			["value"] = MoveAny:IsEnabled("CHANGEONCATSTEALTH", true),
			["func"] = function(value)
				MoveAny:SetEnabled("CHANGEONCATSTEALTH", value)
				ApplyReload()
			end,
		})
	end

	if optionFrame == StanceBarAnchor then
		opts["ORIENTATION"] = opts["ORIENTATION"] or "CENTERED"
		win:AddDropdown({
			["label"] = MoveAny:Trans("LID_ORIENTATION"),
			["search"] = "ORIENTATION",
			["value"] = opts["ORIENTATION"],
			["choices"] = {
				{
					["value"] = "LEFTALIGNED",
					["label"] = "LID_LEFTALIGNED"
				},
				{
					["value"] = "CENTERED",
					["label"] = "LID_CENTERED"
				},
				{
					["value"] = "RIGHTALIGNED",
					["label"] = "LID_RIGHTALIGNED"
				},
			},
			["func"] = function(value)
				opts["ORIENTATION"] = value
				MoveAny:SetPoint(StanceBar, "CENTER", StanceBarAnchor, "CENTER", 0, 0)
			end,
		})
	end
end

local function RefreshBuffs()
	if MoveAny.UpdateBuffs then MoveAny:UpdateBuffs() end
	if MoveAny.UpdateTargetBuffs then MoveAny:UpdateTargetBuffs() end
	if MoveAny.UpdateTargetToTBuffs then MoveAny:UpdateTargetToTBuffs() end
	if MoveAny.UpdateFocusBuffs then MoveAny:UpdateFocusBuffs() end
	if MoveAny.UpdateFocusToTBuffs then MoveAny:UpdateFocusToTBuffs() end
end

local function RefreshDebuffs()
	if MoveAny.UpdateDebuffs then MoveAny:UpdateDebuffs("MenuOptions") end
	if MoveAny.UpdateTargetDebuffs then MoveAny:UpdateTargetDebuffs() end
	if MoveAny.UpdateTargetToTDebuffs then MoveAny:UpdateTargetToTDebuffs() end
	if MoveAny.UpdateFocusDebuffs then MoveAny:UpdateFocusDebuffs() end
	if MoveAny.UpdateFocusToTDebuffs then MoveAny:UpdateFocusToTDebuffs() end
end

local MODES_FULL = {
	[0] = "AUTO",
	[1] = "TOPRIGHT",
	[2] = "TOPLEFT",
	[3] = "BOTTOMRIGHT",
	[4] = "BOTTOMLEFT",
	[5] = "CENTER",
}

local MODES_SIMPLE = {
	[0] = "BOTTOM",
	[1] = "TOP",
}

local function HasFullAuraModes()
	local build = MoveAny:GetWoWBuild()

	return build ~= "RETAIL" and build ~= "CLASSIC" and build ~= "TBC" and build ~= "MISTS"
end

local function AddAuraOptions(win, name, cat, prefix, ownBar, refresh)
	AddEleCategory(win, cat)
	if name == ownBar then
		if HasFullAuraModes() then AddEleDropdown(win, name, prefix .. "MODE", 0, MODES_FULL, refresh) end
	else
		AddEleDropdown(win, name, prefix .. "MODE", 0, MODES_SIMPLE, refresh)
	end

	AddEleSlider(win, name, prefix .. "LIMIT", 10, 2, 20, 1, 0, refresh)
	AddEleSlider(win, name, prefix .. "SPACINGX", 4, 0, 30, 1, 0, refresh)
	AddEleSlider(win, name, prefix .. "SPACINGY", 10, 0, 30, 1, 0, refresh)
	AddEleCategory(win, cat .. "DURATION", MoveAny:Trans("LID_DURATION"), 2)
	AddDurationOptions(win, name, prefix .. "DURATION", refresh)
end

local function AddStatusBarOptions(win, opts, frame, label)
	AddEleCategory(win, "STATUSBAR", label)
	opts["WIDTH"] = opts["WIDTH"] or 1024
	opts["HEIGHT"] = opts["HEIGHT"] or 15
	win:AddSlider({
		["label"] = MoveAny:Trans("LID_WIDTH"),
		["search"] = "WIDTH",
		["value"] = opts["WIDTH"],
		["min"] = 100,
		["max"] = 1024,
		["step"] = 2,
		["decimals"] = 0,
		["func"] = function(value)
			if value == opts["WIDTH"] then return end
			opts["WIDTH"] = value
			if frame and frame.UpdateSize then frame:UpdateSize() end
		end,
	})

	win:AddSlider({
		["label"] = MoveAny:Trans("LID_HEIGHT"),
		["search"] = "HEIGHT",
		["value"] = opts["HEIGHT"],
		["min"] = 2,
		["max"] = 64,
		["step"] = 1,
		["decimals"] = 0,
		["func"] = function(value)
			if value == opts["HEIGHT"] then return end
			opts["HEIGHT"] = value
			if frame and frame.UpdateSize then frame:UpdateSize() end
		end,
	})
end

local function AddBagOptions(win, name)
	AddEleCategory(win, "BAGEXTRAS")
	win:AddCheckbox({
		["label"] = HIDE .. " (" .. MoveAny:Trans("LID_HIDESMALLBAGS") .. ")",
		["search"] = "HIDESMALLBAGS",
		["value"] = MoveAny:GetEleOption(name, "HideSmallBags", false, "HideSmallBags1"),
		["func"] = function(value)
			MoveAny:SetEleOption(name, "HideSmallBags", value)
			MoveAny:UpdateBags()
		end,
	})

	if KeyRingButton then
		win:AddCheckbox({
			["label"] = HIDE .. " (" .. MoveAny:Trans("LID_HIDEKEYBAG") .. ")",
			["search"] = "HIDEKEYBAG",
			["value"] = MoveAny:GetEleOption(name, "HideKeyBag", false, "HideKeyBag1"),
			["func"] = function(value)
				MoveAny:SetEleOption(name, "HideKeyBag", value)
				MoveAny:UpdateBags()
			end,
		})
	end
end

local function AddAlphaOptions(win, name)
	AddEleCategory(win, "ALPHA")
	local apply = function() MoveAny:SafeUpdateAlphas("MenuOptions") end
	AddEleSlider(win, name, "ALPHAINCOMBAT", 1, 0, 1, 0.1, 1, apply)
	if MoveAny:GetWoWBuildNr() < 120000 then
		win:AddCheckbox({
			["label"] = "LID_FULLHPENABLED",
			["search"] = "FULLHPENABLED",
			["value"] = MoveAny:GetEleOption(name, "FULLHPENABLED", false, "fullhp1"),
			["func"] = function(value) MoveAny:SetEleOption(name, "FULLHPENABLED", value) end,
		})

		AddEleSlider(win, name, "ALPHAISFULLHEALTH", 1, 0, 1, 0.1, 1, apply)
	end

	AddEleSlider(win, name, "ALPHAINVEHICLE", 1, 0, 1, 0.1, 1, apply)
	AddEleSlider(win, name, "ALPHAISMOUNTED", 1, 0, 1, 0.1, 1, apply)
	AddEleSlider(win, name, "ALPHAINRESTEDAREA", 1, 0, 1, 0.1, 1, apply)
	AddEleSlider(win, name, "ALPHAISSTEALTHED", 1, 0, 1, 0.1, 1, apply)
	if MoveAny:IsPetBattleAvailable() then AddEleSlider(win, name, "ALPHAISINPETBATTLE", 1, 0, 1, 0.1, 1, apply) end
	if DragonridingUtil then AddEleSlider(win, name, "ALPHAISSKYRIDING", 1, 0, 1, 0.1, 1, apply) end
	AddEleSlider(win, name, "ALPHANOTINCOMBAT", 1, 0, 1, 0.1, 1, apply)
end

function MoveAny:MenuOptions(win, frame)
	local optionFrame = frame
	if frame == StanceBarAnchor then frame = StanceBar end
	if frame == nil then
		MoveAny:MSG("FRAME NOT FOUND")

		return
	end

	local name = MoveAny:GetFrameName(optionFrame)
	local opts = MoveAny:GetEleOptions(name, "MenuOptions")
	win:SuspendLayout()
	AddGeneralOptions(win, name, optionFrame)
	AddAlphaOptions(win, name)
	if string.find(name, "MAActionBar") or string.find(name, "MultiBar") or name == "MainActionBar" or name == "MainMenuBar" or name == "MAMenuBar" or name == "PetActionBar" or name == "MAPetBar" or name == "StanceBarAnchor" then AddActionBarOptions(win, name, opts, frame, optionFrame) end
	if string.find(name, "MABuffBar") or string.find(name, "BuffFrame") or string.find(name, "TargetFrameBuffMover") or string.find(name, "FocusFrameBuffMover") then AddAuraOptions(win, name, "BUFFS", "MABUFF", "MABuffBar", RefreshBuffs) end
	if string.find(name, "MADebuffBar") or string.find(name, "DebuffFrame") or string.find(name, "TargetFrameDebuffMover") or string.find(name, "FocusFrameDebuffMover") then AddAuraOptions(win, name, "DEBUFFS", "MADEBUFF", "MADebuffBar", RefreshDebuffs) end
	if string.find(name, "MainMenuExpBar") then
		AddStatusBarOptions(win, opts, frame, MoveAny:Trans("LID_MAINMENUEXPBAR"))
	elseif string.find(name, "ReputationWatchBar") then
		AddStatusBarOptions(win, opts, frame, MoveAny:Trans("LID_REPUTATIONWATCHBAR"))
	end

	if string.find(name, "BagsBar") then AddBagOptions(win, name) end
	win:ResumeLayout()
end

function MoveAny:ResetSelectedText()
	if MoveAny.GetLastSelected == nil then return end
	if not runSelectedReset then
		runSelectedReset = true
		local cb = MoveAny:GetLastSelected()
		if cb then cb:UpdateLabel() end
		runSelectedReset = false
	end
end

function MoveAny:UpdateEleColor(dragframe)
	if dragframe == nil or dragframe.t == nil then return end
	if dragframe == MACurrentEle then
		dragframe.t:SetVertexColor(MoveAny:GetColor("se"))
		return
	end

	local name = dragframe.maName
	if name and MoveAny:GetEleOption(name, "Hide", false, "UpdateEleColor Hide") then
		dragframe.t:SetVertexColor(MoveAny:GetColor("hidden"))
	elseif name and MoveAny:GetEleOption(name, "ClickThrough", false, "UpdateEleColor ClickThrough") then
		dragframe.t:SetVertexColor(MoveAny:GetColor("clickthrough"))
	else
		dragframe.t:SetVertexColor(MoveAny:GetColor("el"))
	end
end

function MoveAny:ClearSelectEle()
	local old = MACurrentEle
	MACurrentEle = nil
	if old and old.t then
		MoveAny:UpdateEleColor(old)
		old.name:Hide()
		old.desc:Hide()
	end

	if MoveAny.GridFrameThink then MoveAny:GridFrameThink() end
	MoveAny:ResetSelectedText()
end

function MoveAny:SelectEle(ele)
	if ele == nil then return end
	local old = MACurrentEle
	MACurrentEle = ele
	if old and old ~= ele and old.t then
		MoveAny:UpdateEleColor(old)
		old.name:Hide()
		old.desc:Hide()
	end

	if MoveAny.GridFrameThink then MoveAny:GridFrameThink() end
	if MACurrentEle and MACurrentEle.t then
		MoveAny:UpdateEleColor(MACurrentEle)
		MACurrentEle.name:Show()
		MACurrentEle.desc:Show()
	end

	MoveAny:ResetSelectedText()
end

function MoveAny:GetSelectEleName(lstr)
	return ses[lstr]
end

function MoveAny:RegisterSelectEle(lstr, name)
	ses[lstr] = name
end

function MoveAny:UpdateHiddenFrames()
	for i, v in pairs(MoveAny:GetDragFrames()) do
		if v.t:GetVertexColor() == MoveAny:GetColor("hidden") then
			if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
				v:Hide()
			else
				v:Show()
			end
		end
	end
end

function MoveAny:IsPresetProfileActive()
	if C_Widget.IsWidget(EditModeManagerFrame) then
		if not EditModeManagerFrame:IsInitialized() or EditModeManagerFrame.layoutApplyInProgress then return true end
		local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
		local isPresetLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Preset
		return isPresetLayout
	end
	return true
end

if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "CLASSIC" or MoveAny:GetWoWBuild() == "TBC" or MoveAny:GetWoWBuild() == "MISTS" then
	local lastCheck = false
	local wasPreset = false
	function MoveAny:ThinkHelpFrame()
		local isPreset = MoveAny:IsPresetProfileActive()
		if lastCheck ~= isPreset then
			lastCheck = isPreset
			if isPreset then
				MoveAny:MSG(MoveAny:Trans("LID_PLEASESWITCHPROFILE1") .. " " .. MoveAny:Trans("LID_PLEASESWITCHPROFILE2") .. " " .. MoveAny:Trans("LID_PLEASESWITCHPROFILE3"))
			elseif wasPreset then
				MoveAny:MSG("ALL GOOD.")
			end
		end
	end

	MoveAny:After(1, function()
		wasPreset = MoveAny:IsPresetProfileActive()
		MoveAny:ThinkHelpFrame()
		local helpEventFrame = CreateFrame("Frame")
		MoveAny:RegisterEvent(helpEventFrame, "EDIT_MODE_LAYOUTS_UPDATED")
		MoveAny:OnEvent(helpEventFrame, function() MoveAny:ThinkHelpFrame() end, "ThinkHelpFrame Event")
	end, "ThinkHelpFrame Init")
end

function MoveAny:ToggleElementOptions(name, fram, dragframe)
	if dragframe.opt == nil then
		dragframe.opt = MoveAny:CreateUIWindow({
			["name"] = name .. "MAOptions",
			["parent"] = MoveAny:GetMainPanel(),
			["pTab"] = {"CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0},
			["title"] = name,
			["width"] = 500,
			["height"] = MoveAny:MClamp(500, 200, GetScreenHeight()),
			["minWidth"] = 400,
			["minHeight"] = 200,
			["maxWidth"] = 800,
			["maxHeight"] = GetScreenHeight(),
			["getCollapsed"] = function(key) return MoveAny:GetCollapsed(key) end,
			["setCollapsed"] = function(key, collapsed) MoveAny:SetCollapsed(key, collapsed) end,
		})

		dragframe.opt:SetFrameLevel(framelevel)
		framelevel = framelevel + 1
		if dragframe.opt.CloseButton then dragframe.opt.CloseButton:SetFrameLevel(framelevel) end
		framelevel = framelevel + 100
		MoveAny:MenuOptions(dragframe.opt, fram)
		dragframe.opt:HookScript("OnShow", function(sel)
			if sel.elePos then sel.elePos:UpdateText() end
			if sel.eleScale then sel.eleScale:UpdateText() end
		end)
	end

	dragframe.opt:Show()
end

local cacheDrags = {}
function MoveAny:GetDragFromName(name)
	return cacheDrags[name]
end

local reapplyPoints = {}
local reapplyPending = false
function MoveAny:ReapplyElePoints(from)
	for _, applyElePoint in pairs(reapplyPoints) do
		applyElePoint()
	end
end

local reapplyFrame = CreateFrame("Frame")
MoveAny:OnEvent(reapplyFrame, function(sel, event)
	if reapplyPending then return end
	reapplyPending = true
	MoveAny:After(0.5, function()
		reapplyPending = false
		MoveAny:ReapplyElePoints(event)
	end, "ReapplyElePoints")
end, "reapplyFrame")

MoveAny:RegisterEvent(reapplyFrame, "PLAYER_ENTERING_WORLD")
MoveAny:RegisterEvent(reapplyFrame, "UI_SCALE_CHANGED")
MoveAny:RegisterEvent(reapplyFrame, "DISPLAY_SIZE_CHANGED")
function MoveAny:SafeAnchorDrag(dragframe, anchor, posx, posy)
	if not dragframe or not dragframe.SetPoint then return false end
	posx = posx or 0
	posy = posy or 0
	if anchor and anchor ~= UIParent then
		if anchor.IsForbidden and anchor:IsForbidden() then anchor = UIParent end
		if anchor.IsAnchoringRestricted and anchor:IsAnchoringRestricted() then anchor = UIParent end
	end

	if not anchor then anchor = UIParent end
	dragframe:ClearAllPoints()
	if pcall(dragframe.SetPoint, dragframe, "CENTER", anchor, "CENTER", posx, posy) then return true end
	dragframe:ClearAllPoints()
	pcall(dragframe.SetPoint, dragframe, "CENTER", UIParent, "CENTER", 0, 0)
	return false
end

function MoveAny:RegisterWidget(tab)
	local name = tab.name
	local lstr = tab.lstr
	local lstri = tab.lstri
	MoveAny:RegisterSelectEle(lstr, name)
	if lstri then
		lstr = format(MoveAny:Trans(lstr), lstri)
	else
		lstr = MoveAny:Trans(lstr)
	end

	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.ma_secure
	local noreparent = tab.noreparent or false
	local userplaced = tab.userplaced
	local cleft = tab.cleft
	local cright = tab.cright
	local ctop = tab.ctop
	local cbottom = tab.cbottom
	local posx = tab.posx
	local posy = tab.posy
	local setup = tab.setup
	tab.delay = tab.delay or 0.2
	local enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
	if (enabled1 or enabled2) and (not forced1 and not forced2) then
		MoveAny:MSG(format(MoveAny:Trans("LID_HELPTEXT"), lstr))
		return
	end

	local frame = MoveAny:GetFrameByName(name)
	if frame then MoveAny:AddFrameName(frame, name) end
	if MoveAny:GetDragFromName(name) == nil then
		cacheDrags[name] = CreateFrame("FRAME", name .. "_MA_DRAG", MoveAny:GetMainPanel())
		local dragframe = MoveAny:GetDragFromName(name)
		dragframe.maName = name
		MoveAny:SetClampedToScreen(dragframe, true, "RegisterWidget 1")
		dragframe:SetFrameStrata("MEDIUM")
		dragframe:SetFrameLevel(99)
		dragframe:Hide()
		if MoveAny:GetEleSize(name) then
			dragframe:SetSize(MoveAny:GetEleSize(name))
		else
			dragframe:SetSize(100, 100)
		end

		MoveAny:SafeAnchorDrag(dragframe, frame or UIParent, 0, 0)
		dragframe:SetToplevel(true)
		dragframe.t = dragframe:CreateTexture(name .. "_MA_DRAG.t", "BACKGROUND", nil, 1)
		dragframe.t:SetAllPoints(dragframe)
		if dragframe.t.SetColorTexture then
			dragframe.t:SetColorTexture(1, 1, 1, 1)
		else
			dragframe.t:SetTexture(1, 1, 1, 1)
		end

		dragframe.t:SetVertexColor(MoveAny:GetColor("el"))
		dragframe.t:SetAlpha(0.4)
		do
			dragframe.name = dragframe:CreateFontString(nil, nil, "GameFontHighlightLarge")
			dragframe.name:SetPoint("CENTER", dragframe, "CENTER", 0, 6)
			local enab, forc = MoveAny:IsInEditModeEnabled(name)
			if enab and not forc then lstr = lstr .. " |cFFFFFF00" .. MoveAny:Trans("LID_ISENABLEDINEDITMODE") end
			dragframe.name:SetText(lstr)
			local font, _, fontFlags = dragframe.name:GetFont()
			if font then dragframe.name:SetFont(font, 15, fontFlags) end
			dragframe.name:SetText(lstr)
			dragframe.name:Hide()
		end

		do
			dragframe.desc = dragframe:CreateFontString(nil, nil, "GameFontHighlightLarge")
			dragframe.desc:SetPoint("CENTER", dragframe, "CENTER", 0, -9)
			dragframe.desc:SetText(MoveAny:Trans("LID_RIGHTCLICKFOROPTIONS"))
			local font2, _, fontFlags2 = dragframe.name:GetFont()
			if font2 then dragframe.desc:SetFont(font2, 10, fontFlags2) end
			dragframe.desc:SetText(MoveAny:Trans("LID_RIGHTCLICKFOROPTIONS"))
			dragframe.desc:Hide()
		end

		dragframe:SetScript("OnEnter", function()
			if dragframe ~= MACurrentEle then
				dragframe.name:Show()
				dragframe.desc:Show()
			end

			dragframe.t:SetAlpha(0.8)
			if ma_setup[dragframe] == nil and not InCombatLockdown() then
				ma_setup[dragframe] = true
				dragframe:EnableKeyboard(true)
				dragframe:SetPropagateKeyboardInput(true)
				dragframe:HookScript("OnKeyDown", function(sel, btn)
					if dragframe == MACurrentEle then
						local p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
						if btn == "RIGHT" then
							MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 + 1, p5)
						elseif btn == "LEFT" then
							MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 - 1, p5)
						elseif btn == "UP" then
							MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4, p5 + 1)
						elseif btn == "DOWN" then
							MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4, p5 - 1)
						end
					else
						return
					end
				end)
			end
		end)

		dragframe:SetScript("OnLeave", function()
			if dragframe ~= MACurrentEle then
				dragframe.name:Hide()
				dragframe.desc:Hide()
			end

			dragframe.t:SetAlpha(0.4)
		end)

		dragframe:SetScript("OnMouseDown", function(sel, btn)
			local fram = _G[name]
			if btn == "LeftButton" then MoveAny:SelectEle(sel) end
			if btn == "LeftButton" then
				dragframe:SetMovable(true)
				dragframe:StartMoving()
				ma_ismoving[dragframe] = true
			elseif btn == "RightButton" then
				MoveAny:ToggleElementOptions(name, fram, dragframe)
			end
		end)

		dragframe:SetScript("OnMouseUp", function()
			local fram = _G[name]
			if ma_ismoving[dragframe] then
				ma_ismoving[dragframe] = false
				dragframe:StopMovingOrSizing()
				dragframe:SetMovable(false)
				local op1, _, op3, op4, op5 = MoveAny:GetElePoint(name)
				local np1, _, np3, p4, p5 = dragframe:GetPoint()
				local np4 = MoveAny:Snap(p4)
				local np5 = MoveAny:Snap(p5)
				if np1 ~= op1 or np3 ~= op3 or np4 ~= op4 or np5 ~= op5 then MoveAny:SetElePoint(name, np1, MoveAny:GetMainPanel(), np3, np4, np5) end
				if dragframe.opt and dragframe.opt.elePos then dragframe.opt.elePos:UpdateText() end

				dragframe:SetMovable(true)
				MoveAny:SafeAnchorDrag(dragframe, fram, posx, posy)
			end
		end)

		tinsert(MoveAny:GetDragFrames(), dragframe)
	end

	local dragf = MoveAny:GetDragFromName(name)
	if frame then
		dragf:Show()
	else
		dragf:Hide()
	end

	if frame == nil then
		if missingWidgets[name] == nil then missingWidgets[name] = tab end
		return false
	end

	if missingWidgets[name] then missingWidgets[name] = nil end
	if giveUpWidgets[name] then giveUpWidgets[name] = nil end
	MoveAny:After(1, function()
		enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
		enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
		if (enabled1 or enabled2) and (not forced1 and not forced2) then
			MoveAny:MSG(format(MoveAny:Trans("LID_HELPTEXT"), lstr))
			return
		end
	end, "RegisterWidget 1")

	--MoveAny:TrySetParent(frame, MoveAny:GetMainPanel())
	if cleft or cright or ctop or cbottom then
		local l = cleft or 0
		local r = cright or 0
		local t = ctop or 0
		local b = cbottom or 0
		if frame.SetClampRectInsets then
			hooksecurefunc(frame, "SetClampRectInsets", function(sel, ...)
				if ma_scri[sel] then return end
				ma_scri[sel] = true
				sel:SetClampRectInsets(l, r, t, b)
				local df = MoveAny:GetDragFromName(name)
				if df then df:SetClampRectInsets(l, r, t, b) end
				ma_scri[sel] = false
			end)

			frame:SetClampRectInsets(l, r, t, b)
		end
	end

	tinsert(MoveAny:GetEleFrames(), frame)
	MoveAny:AddAlphaFrame(frame)
	if MoveAny.SafeUpdateAlphas then MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().ADDED) end
	if frame and frame.GetChildren then
		MoveAny:ForeachChildren(frame, function(child)
			function child:GetMAEle()
				return frame
			end

			MoveAny:RegisterChildAlphaFrame(child, frame)
		end, "GetMAEle 1")
	end

	if frame.SetMovable then
		frame:SetMovable(true)
		if frame.SetUserPlaced and frame:IsMovable() then frame:SetUserPlaced(userplaced or false) end
	end

	if frame.SetDontSavePosition then frame:SetDontSavePosition(true) end
	MoveAny:SetClampedToScreen(frame, true, "RegisterWidget 3")
	if frame ~= TalkingHeadFrame and frame ~= Minimap and frame ~= MinimapCluster and frame.SetIgnoreParentAlpha ~= nil and MoveAny:GetParent(frame) ~= UIParent and MoveAny:GetParent(frame) ~= MoveAny:GetMainPanel() then frame:SetIgnoreParentAlpha(true) end
	if not MoveAny:GetEleOption(name, "Hide", false, "Hide2") then
		if frame == MACurrentEle then
			dragf.t:SetVertexColor(MoveAny:GetColor("se"))
		elseif MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough2") then
			dragf.t:SetVertexColor(MoveAny:GetColor("clickthrough"))
			if frame == MABuffBar then
				function frame:UpdateBuffMouse()
					for i = 1, 32 do
						local bb = _G["BuffButton" .. i]
						if bb then
							function bb:GetMAEle()
								return MABuffBar or BuffFrame
							end

							bb:EnableMouse(false)
						end

						if not MoveAny:IsEnabled("DEBUFFS", false) then
							local db = _G["DebuffButton" .. i]
							if db then
								function db:GetMAEle()
									return MABuffBar or BuffFrame
								end

								db:EnableMouse(false)
							end
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "player")
				MoveAny:OnEvent(bbf, function() frame:UpdateBuffMouse() end, "bbf 12")
				frame:UpdateBuffMouse()
			elseif frame == MoveAny:GetDebuffBar() then
				function frame:UpdateDebuffMouse()
					for i = 1, 32 do
						local db = _G["DebuffButton" .. i]
						if db then
							function db:GetMAEle()
								return MADebuffBar or DebuffFrame
							end

							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "player")
				MoveAny:OnEvent(bbf, function() frame:UpdateDebuffMouse() end, "bbf 11")
				frame:UpdateDebuffMouse()
			elseif frame == TargetFrameBuffMover then
				function frame:UpdateBuffMouse()
					for i, bb in pairs(MoveAny:UpdateTargetFrameBuffs()) do
						if bb then bb:EnableMouse(false) end
					end

					for i, db in pairs(MoveAny:UpdateTargetFrameDebuffs()) do
						if db then db:EnableMouse(false) end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
				MoveAny:OnEvent(bbf, function() frame:UpdateBuffMouse() end, "bbf 10")
				frame:UpdateBuffMouse()
			elseif frame == _G["FocusFrameBuffMover"] then
				function frame:UpdateBuffMouse()
					for i = 1, 32 do
						local bb = _G["FocusFrameBuff" .. i]
						if bb then bb:EnableMouse(false) end
						local db = _G["FocusFrameDebuff" .. i]
						if db then db:EnableMouse(false) end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
				MoveAny:OnEvent(bbf, function() frame:UpdateBuffMouse() end, "bbf 9")
				frame:UpdateBuffMouse()
			end
		else
			dragf.t:SetVertexColor(MoveAny:GetColor("el"))
		end
	end

	if MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough3") then
		hooksecurefunc(frame, "EnableMouse", function(sel, bo)
			if ma_enablemouse[sel] then return end
			ma_enablemouse[sel] = true
			sel:EnableMouse(false)
			if sel.AuraContainer then
				MoveAny:ForeachChildren(sel.AuraContainer, function(child) if C_Widget.IsWidget(child) then child:EnableMouse(false) end end, "EnableMouse 2")
			else
				MoveAny:ForeachChildren(sel, function(child) if C_Widget.IsWidget(child) then child:EnableMouse(false) end end, "EnableMouse 1")
			end

			ma_enablemouse[sel] = false
		end)

		frame:EnableMouse(false)
	end

	local elesetpoint = false
	local movableSetup = false
	local ma_secure = secure
	local bToSmall = false
	if sw or sh then bToSmall = true end
	sw = sw or frame:GetWidth()
	sh = sh or frame:GetHeight()
	sw = MoveAny:MathR(sw)
	sh = MoveAny:MathR(sh)
	if MoveAny:GetElePoint(name) == nil then
		local an, parent, re, px, py = frame:GetPoint()
		if parent == nil or parent == UIParent or parent == MoveAny:GetMainPanel() and an ~= nil and re ~= nil then
			MoveAny:SetElePoint(name, an, MoveAny:GetMainPanel(), re, MoveAny:Snap(px), MoveAny:Snap(py))
		elseif frame:GetLeft() and frame:GetBottom() then
			MoveAny:SetElePoint(name, "BOTTOMLEFT", MoveAny:GetMainPanel(), "BOTTOMLEFT", MoveAny:Snap(frame:GetLeft()), MoveAny:Snap(frame:GetBottom()))
		elseif parent ~= nil then
			MoveAny:SetElePoint(name, an, MoveAny:GetMainPanel(), re, MoveAny:Snap(parent:GetLeft()), MoveAny:Snap(parent:GetBottom()))
		else
			local an1 = tab.an or "CENTER"
			local re1 = tab.re or "CENTER"
			local px1 = tab.px or 0
			local py1 = tab.py or 0
			MoveAny:SetElePoint(name, an1, MoveAny:GetMainPanel(), re1, px1, py1)
		end
	end

	local osw, osh = MoveAny:GetEleSize(name)
	if osw ~= sw or osh ~= sh then MoveAny:SetEleSize(name, sw, sh) end
	local pointFunc = "SetPoint"
	if frame.SetPointBase then pointFunc = "SetPointBase" end
	hooksecurefunc(frame, pointFunc, function(sel, p1, p2, p3, p4, p5)
		if elesetpoint then return end
		if not ma_secure then
			if not movableSetup then
				movableSetup = true
				pcall(function()
					if sel.SetMovable then sel:SetMovable(true) end
					if sel.SetUserPlaced and sel.SetMovable and sel:IsMovable() then sel:SetUserPlaced(userplaced or false) end
				end)
			end

			elesetpoint = true
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
			if dbp1 and dbp3 then MoveAny:SetPoint(sel, dbp1, nil, dbp3, dbp4, dbp5) end
			if sel == MAMenuBar then MoveAny:UpdateActionBar(sel, "RegisterWidget sel == MAMenuBar") end
			elesetpoint = false
		end
	end)

	hooksecurefunc(frame, "SetParent", function(sel, parent)
		if MoveAny:GetEleOption(name, "Hide", false, "Hide4") then return end
		if not MoveAny:GetEleOption(name, "LockParent", false, "LockParent1") then return end
		local target = MoveAny:GetMainPanel()
		if parent ~= target then
			if InCombatLockdown() and sel:IsProtected() then return end
			sel:SetParent(target)
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
			if dbp1 and dbp3 then MoveAny:SetPoint(sel, dbp1, target, dbp3, dbp4, dbp5) end
		end
	end)

	if not ma_secure then
		local function applyElePoint()
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
			if dbp1 and dbp3 then
				if noreparent then
					MoveAny:SetPoint(frame, dbp1, MoveAny:GetParent(frame), dbp3, dbp4, dbp5)
				else
					MoveAny:SetPoint(frame, dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
				end
			end
		end

		reapplyPoints[name] = applyElePoint
		applyElePoint()
	end

	hooksecurefunc(frame, "SetScale", function(sel, scale)
		local icl = InCombatLockdown()
		if icl and sel:IsProtected() then return false end
		if ma_setscale_ele[sel] then return end
		ma_setscale_ele[sel] = true
		local newScale = MoveAny:GetEleScale(name) or 1
		if MoveAny:CheckIfMicroMenuInVehicle(frame) then newScale = 1 end
		if newScale and type(newScale) == "number" and newScale > 0 and scale ~= newScale and not icl then sel:SetScale(newScale) end
		local dragframe = MoveAny:GetDragFromName(name)
		if dragframe then dragframe:SetScale(newScale) end
		ma_setscale_ele[sel] = false
	end)

	hooksecurefunc(frame, "SetSize", function(sel, w, h)
		if InCombatLockdown() and sel:IsProtected() then return false end
		local isToSmall = false
		local df = MoveAny:GetDragFromName(name)
		if df.SetSize then df:SetSize(w, h) end
		if w < sw then
			w = sw
			isToSmall = true
		end

		if h < sh then
			h = sh
			isToSmall = true
		end

		if bToSmall and isToSmall then
			if df.SetSize then df:SetSize(w, h) end
			if sel.SetSize then sel:SetSize(w, h) end
		end
	end)

	MoveAny:SafeExec(frame, function()
		frame:SetSize(sw, sh)
		if MoveAny:GetEleScale(name) and MoveAny:GetEleScale(name) > 0 then frame:SetScale(MoveAny:GetEleScale(name)) end
	end, "RegisterWidget SetScale " .. tostring(name))

	local dragframe = MoveAny:GetDragFromName(name)
	dragframe:SetSize(sw, sh)
	MoveAny:SafeAnchorDrag(dragframe, frame, posx, posy)
	if MoveAny:GetEleOption(name, "Hide", false, "Hide3") then
		MoveAny:HideFrame(frame)
		MoveAny:After(1, function() MoveAny:HideFrame(frame) end, "HIDE DELAY 1")
		MoveAny:After(4, function() MoveAny:HideFrame(frame) end, "HIDE DELAY 2")
		dragframe.t:SetVertexColor(MoveAny:GetColor("hidden"))
		if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
			dragframe:Hide()
		else
			if MoveAny:IsEnabled("MALOCK", false) then
				dragframe:Show()
			else
				dragframe:Hide()
			end
		end
	else
		if MoveAny:IsEnabled("MALOCK", false) then
			dragframe:Show()
		else
			dragframe:Hide()
		end
	end

	if setup then setup() end
end

function MoveAny:AnyActionbarEnabled()
	if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "CLASSIC" and MoveAny:GetWoWBuild() ~= "TBC" and MoveAny:GetWoWBuild() ~= "MISTS" then
		return MoveAny:IsEnabled("ACTIONBARS", false) or MoveAny:IsEnabled("ACTIONBAR1", false) or MoveAny:IsEnabled("ACTIONBAR3", false) or MoveAny:IsEnabled("ACTIONBAR4", false) or MoveAny:IsEnabled("ACTIONBAR7", false) or MoveAny:IsEnabled("ACTIONBAR8", false) or MoveAny:IsEnabled("ACTIONBAR9", false) or MoveAny:IsEnabled("ACTIONBAR10", false)
	else
		return false
	end
end
