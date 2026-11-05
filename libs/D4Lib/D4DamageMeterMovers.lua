local _, D4 = ...
local MAX_SESSION_WINDOWS = 10
local SNAP_RANGE = 8
local registry = _G["D4DamageMeterMovers"]
if type(registry) ~= "table" then
	registry = {}
	_G["D4DamageMeterMovers"] = registry
end

registry.owners = registry.owners or {}
registry.listeners = registry.listeners or {}
registry.snapFrames = registry.snapFrames or {}
local state = {
	movers = {},
	callbackOwner = {}
}

local function GetActiveOwner()
	local best, bestPriority
	for name, owner in pairs(registry.owners) do
		local priority = type(owner) == "table" and owner.priority or 0
		if best == nil or priority > bestPriority or (priority == bestPriority and name < best) then best, bestPriority = name, priority end
	end

	return best
end

local function IsActiveOwner()
	return state.ownerName ~= nil and GetActiveOwner() == state.ownerName
end

local function IsSnapEnabled()
	return EditModeManagerFrame and EditModeManagerFrame.IsSnapEnabled and EditModeManagerFrame:IsSnapEnabled()
end

local function GetScaledRect(frame)
	local left, bottom, width, height = frame:GetRect()
	if not D4:CanAccessValues(left, bottom, width, height) or not left then return nil end
	local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
	return left * scale, (left + width) * scale, bottom * scale, (bottom + height) * scale
end

local function CheckSnapTarget(target, rect, best, sizing)
	local left, right, bottom, top = GetScaledRect(target)
	if not left then return end
	if rect.top >= bottom - SNAP_RANGE and rect.bottom <= top + SNAP_RANGE then
		local pairsX = sizing and {{rect.right, left}, {rect.right, right}} or {{rect.left, right}, {rect.right, left}, {rect.left, left}, {rect.right, right}}
		for _, pair in ipairs(pairsX) do
			local delta = pair[2] - pair[1]
			if math.abs(delta) <= SNAP_RANGE and (not best.x or math.abs(delta) < math.abs(best.x.delta)) then best.x = {delta = delta, line = pair[2]} end
		end
	end

	if rect.right >= left - SNAP_RANGE and rect.left <= right + SNAP_RANGE then
		local pairsY = sizing and {{rect.bottom, top}, {rect.bottom, bottom}} or {{rect.top, bottom}, {rect.bottom, top}, {rect.top, top}, {rect.bottom, bottom}}
		for _, pair in ipairs(pairsY) do
			local delta = pair[2] - pair[1]
			if math.abs(delta) <= SNAP_RANGE and (not best.y or math.abs(delta) < math.abs(best.y.delta)) then best.y = {delta = delta, line = pair[2]} end
		end
	end
end

local function FindSnap(frame, sizing)
	local left, right, bottom, top = GetScaledRect(frame)
	if not left then return nil end
	local rect = {left = left, right = right, bottom = bottom, top = top}
	local best = {}
	for i = 1, MAX_SESSION_WINDOWS do
		local target = _G["DamageMeterSessionWindow" .. i]
		if target and target ~= frame and target:IsVisible() then CheckSnapTarget(target, rect, best, sizing) end
	end

	for target in pairs(registry.snapFrames) do
		if target ~= frame and target:IsVisible() then CheckSnapTarget(target, rect, best, sizing) end
	end

	return best.x, best.y
end

local function GetSnapLines()
	if state.snapLines then return state.snapLines end
	local holder = CreateFrame("Frame", nil, UIParent)
	holder:SetFrameStrata("DIALOG")
	holder:SetAllPoints(UIParent)
	holder.vertical = holder:CreateTexture(nil, "OVERLAY")
	holder.vertical:SetColorTexture(1, 0, 0, 0.9)
	holder.vertical:SetWidth(2)
	holder.horizontal = holder:CreateTexture(nil, "OVERLAY")
	holder.horizontal:SetColorTexture(1, 0, 0, 0.9)
	holder.horizontal:SetHeight(2)
	holder:Hide()
	state.snapLines = holder
	return holder
end

local function UpdateSnapLines(frame, sizing)
	local lines = GetSnapLines()
	local snapX, snapY = FindSnap(frame, sizing)
	lines.vertical:SetShown(snapX ~= nil)
	lines.horizontal:SetShown(snapY ~= nil)
	if snapX then
		lines.vertical:ClearAllPoints()
		lines.vertical:SetPoint("TOP", UIParent, "TOPLEFT", snapX.line, 0)
		lines.vertical:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", snapX.line, 0)
	end

	if snapY then
		lines.horizontal:ClearAllPoints()
		lines.horizontal:SetPoint("LEFT", UIParent, "BOTTOMLEFT", 0, snapY.line)
		lines.horizontal:SetPoint("RIGHT", UIParent, "BOTTOMRIGHT", 0, snapY.line)
	end
end

local function IsWindowMinimized(window)
	if type(window.IsMinimized) ~= "function" then return false end
	local ok, minimized = pcall(window.IsMinimized, window)
	return ok and minimized == true
end

local function SetButtonAtlas(button, setter, getter, atlas)
	if type(button[setter]) ~= "function" then return false end
	local ok, result = pcall(button[setter], button, atlas)
	if not ok or result == false or type(button[getter]) ~= "function" then return false end
	local texture = button[getter](button)
	if not texture or type(texture.GetAtlas) ~= "function" then return false end
	local okAtlas, current = pcall(texture.GetAtlas, texture)
	return okAtlas and type(current) == "string" and string.lower(current) == string.lower(atlas)
end

local function NotifySelected()
	for _, func in pairs(registry.listeners) do
		if type(func) == "function" then xpcall(func, geterrorhandler()) end
	end
end

local function SelectMover(selected)
	for _, mover in pairs(state.movers) do
		if mover:IsShown() then
			if mover == selected then
				mover.Selection:ShowSelected()
			else
				mover.Selection:ShowHighlighted()
			end

			if mover.Selection.Label then mover.Selection.Label:Hide() end
		end
	end

	if selected then NotifySelected() end
end

local function StopMover(mover)
	if not mover.isDragging and not mover.isSizing then return end
	local window = mover.window
	local wasDragging = mover.isDragging
	mover.isDragging = false
	mover.isSizing = false
	local lines = GetSnapLines()
	lines:SetScript("OnUpdate", nil)
	lines:Hide()
	if not window then return end
	window:StopMovingOrSizing()
	if not IsSnapEnabled() then return end
	local snapX, snapY = FindSnap(window, not wasDragging)
	local left, top = window:GetLeft(), window:GetTop()
	if not (snapX or snapY) or not left or not top then return end
	local scale = window:GetEffectiveScale() / UIParent:GetEffectiveScale()
	if wasDragging then
		if snapX then left = left + snapX.delta / scale end
		if snapY then top = top + snapY.delta / scale end
		window:ClearAllPoints()
		window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		return
	end

	local width, height = window:GetSize()
	if snapX then width = width + snapX.delta / scale end
	if snapY then height = height - snapY.delta / scale end
	if type(window.GetResizeBounds) == "function" then
		local minW, minH, maxW, maxH = window:GetResizeBounds()
		if minW and minW > 0 then width = math.max(width, minW) end
		if minH and minH > 0 then height = math.max(height, minH) end
		if maxW and maxW > 0 then width = math.min(width, maxW) end
		if maxH and maxH > 0 then height = math.min(height, maxH) end
	end

	window:ClearAllPoints()
	window:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	window:SetSize(width, height)
end

local function StartSnapLines(window, sizing)
	if not IsSnapEnabled() then return end
	local lines = GetSnapLines()
	lines:SetScript("OnUpdate", function() UpdateSnapLines(window, sizing) end)
	lines:Show()
end

local function StartMoverDrag(mover)
	local window = mover.window
	if not state.editModeActive or not window or mover.isDragging or mover.isSizing or InCombatLockdown() or not window:IsMovable() then return end
	SelectMover(mover)
	window:StartMoving()
	mover.isDragging = true
	StartSnapLines(window, false)
end

local function CreateMover(index)
	local mover = CreateFrame("Frame", nil, UIParent)
	mover:Hide()
	mover.GetSystemName = function() return format("%s %d", HUD_EDIT_MODE_DAMAGE_METER_LABEL or "Damage Meter", index) end
	mover.OnDragStart = StartMoverDrag
	mover.OnDragStop = StopMover
	mover.Selection = CreateFrame("Frame", nil, mover, "EditModeSystemSelectionTemplate")
	mover.Selection:SetAllPoints()
	mover.Selection:SetSystem(mover)
	mover.Selection:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then SelectMover(mover) end end)
	mover.Grip = CreateFrame("Button", nil, mover)
	mover.Grip:SetSize(60, 60)
	mover.Grip:SetPoint("BOTTOMRIGHT", mover, "BOTTOMRIGHT", 9, -8)
	mover.Grip:SetFrameStrata("HIGH")
	if type(mover.Grip.SetToplevel) == "function" then mover.Grip:SetToplevel(true) end
	if SetButtonAtlas(mover.Grip, "SetNormalAtlas", "GetNormalTexture", "damagemeters-scalehandle") then
		SetButtonAtlas(mover.Grip, "SetHighlightAtlas", "GetHighlightTexture", "damagemeters-scalehandle-hover")
		SetButtonAtlas(mover.Grip, "SetPushedAtlas", "GetPushedTexture", "damagemeters-scalehandle-pressed")
	else
		mover.Grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		mover.Grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		mover.Grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	end

	mover.Grip:SetScript("OnMouseDown", function(_, button)
		local window = mover.window
		if button ~= "LeftButton" or not window or mover.isDragging or InCombatLockdown() or not window:IsResizable() or IsWindowMinimized(window) then return end
		SelectMover(mover)
		window:StartSizing("BOTTOMRIGHT")
		mover.isSizing = true
		StartSnapLines(window, true)
	end)

	mover.Grip:SetScript("OnMouseUp", function() StopMover(mover) end)
	mover:SetScript("OnHide", StopMover)
	return mover
end

local function UpdateMovers()
	local active = state.editModeActive and EditModeSystemSelectionMixin ~= nil and IsActiveOwner()
	for index = 2, MAX_SESSION_WINDOWS do
		local window = _G["DamageMeterSessionWindow" .. index]
		local mover = state.movers[index]
		if active and window and window:IsVisible() then
			if not mover then
				mover = CreateMover(index)
				state.movers[index] = mover
			end

			if mover.window ~= window then
				mover.window = window
				mover:ClearAllPoints()
				mover:SetAllPoints(window)
			end

			if not mover:IsShown() then
				mover.Selection:SetFrameStrata(window:GetFrameStrata())
				mover.Selection:SetFrameLevel(math.min(window:GetFrameLevel() + 100, 9000))
				mover:Show()
				mover.Selection:ShowHighlighted()
				if mover.Selection.Label then mover.Selection.Label:Hide() end
			end

			mover.Grip:SetShown(window:IsResizable() and not IsWindowMinimized(window))
		elseif mover and mover:IsShown() then
			mover:Hide()
		end
	end
end

local function SetEditModeActive(active)
	state.editModeActive = active == true
	if not state.ticker then
		state.ticker = CreateFrame("Frame")
		state.ticker.elapsed = 0
	end

	if state.editModeActive then
		state.ticker.elapsed = 0
		state.ticker:SetScript("OnUpdate", function(frame, elapsed)
			frame.elapsed = frame.elapsed + elapsed
			if frame.elapsed < 0.2 then return end
			frame.elapsed = 0
			UpdateMovers()
		end)
	else
		state.ticker:SetScript("OnUpdate", nil)
	end

	UpdateMovers()
end

function D4:EnableDamageMeterWindowMovers(addonName, priority)
	if type(addonName) ~= "string" or state.ownerName then return end
	state.ownerName = addonName
	registry.owners[addonName] = {
		priority = tonumber(priority) or 0,
		select = SelectMover
	}

	if EventRegistry == nil then return end
	EventRegistry:RegisterCallback("EditMode.Enter", function() SetEditModeActive(true) end, state.callbackOwner)
	EventRegistry:RegisterCallback("EditMode.Exit", function() SetEditModeActive(false) end, state.callbackOwner)
	if EditModeManagerFrame and EditModeManagerFrame.IsEditModeActive and EditModeManagerFrame:IsEditModeActive() then SetEditModeActive(true) end
end

function D4:AddDamageMeterSnapFrame(frame)
	if frame then registry.snapFrames[frame] = true end
end

function D4:OnDamageMeterWindowMoverSelected(addonName, func)
	if type(addonName) == "string" then registry.listeners[addonName] = func end
end

function D4:ClearDamageMeterWindowMoverSelection()
	local owner = registry.owners[GetActiveOwner() or ""]
	if type(owner) == "table" and type(owner.select) == "function" then owner.select(nil) end
end
