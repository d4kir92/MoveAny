local _, D4 = ...
local SNAP_RANGE = 8
local registry = _G["D4EditModeRegistry"]
if type(registry) ~= "table" then
	registry = {}
	_G["D4EditModeRegistry"] = registry
end

registry.frames = registry.frames or {}
registry.snapFrames = registry.snapFrames or {}
local function IsSnapEnabled()
	return EditModeManagerFrame ~= nil and EditModeManagerFrame.IsSnapEnabled ~= nil and EditModeManagerFrame:IsSnapEnabled()
end

local function IsEditModeActive()
	return EditModeManagerFrame ~= nil and EditModeManagerFrame.IsEditModeActive ~= nil and EditModeManagerFrame:IsEditModeActive()
end

local function GetTarget(mover)
	return mover.d4EditModeTarget or mover
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

local function CollectSnapTargets(mover)
	local own = GetTarget(mover)
	local targets = {}
	local function Add(frame)
		if frame and frame ~= own and frame ~= mover and frame.IsVisible and frame:IsVisible() then targets[frame] = true end
	end

	for other in pairs(registry.frames) do
		if other ~= mover and other.Selection:IsShown() then Add(GetTarget(other)) end
	end

	for frame in pairs(registry.snapFrames) do
		Add(frame)
	end

	local systems = EditModeManagerFrame and EditModeManagerFrame.registeredSystemFrames
	if type(systems) == "table" then
		for _, frame in ipairs(systems) do
			Add(frame)
		end
	end

	local getSnapTargets = mover.d4EditModeOptions.getSnapTargets
	if getSnapTargets then
		for _, frame in ipairs(getSnapTargets(mover) or {}) do
			Add(frame)
		end
	end

	return targets
end

local function FindSnap(mover, sizing)
	local left, right, bottom, top = GetScaledRect(GetTarget(mover))
	if not left then return nil end
	local rect = {left = left, right = right, bottom = bottom, top = top}
	local best = {}
	for target in pairs(CollectSnapTargets(mover)) do
		CheckSnapTarget(target, rect, best, sizing)
	end

	return best.x, best.y
end

local function GetSnapLines()
	if registry.snapLines then return registry.snapLines end
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
	registry.snapLines = holder
	return holder
end

local function UpdateSnapLines(mover, sizing)
	local lines = GetSnapLines()
	local snapX, snapY = FindSnap(mover, sizing)
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

function D4:StartEditModeSnap(mover, sizing)
	if not IsSnapEnabled() then return end
	local lines = GetSnapLines()
	lines:SetScript("OnUpdate", function() UpdateSnapLines(mover, sizing) end)
	lines:Show()
end

function D4:CancelEditModeSnap()
	local lines = registry.snapLines
	if not lines then return end
	lines:SetScript("OnUpdate", nil)
	lines:Hide()
end

function D4:StopEditModeSnap(mover, sizing)
	D4:CancelEditModeSnap()
	if not IsSnapEnabled() then return false end
	local target = GetTarget(mover)
	local snapX, snapY = FindSnap(mover, sizing)
	local left, top = target:GetLeft(), target:GetTop()
	if not (snapX or snapY) or not left or not top then return false end
	local scale = target:GetEffectiveScale() / UIParent:GetEffectiveScale()
	if not sizing then
		if snapX then left = left + snapX.delta / scale end
		if snapY then top = top + snapY.delta / scale end
		target:ClearAllPoints()
		target:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
		return true
	end

	local width, height = target:GetSize()
	if snapX then width = width + snapX.delta / scale end
	if snapY then height = height - snapY.delta / scale end
	if type(target.GetResizeBounds) == "function" then
		local minW, minH, maxW, maxH = target:GetResizeBounds()
		if minW and minW > 0 then width = math.max(width, minW) end
		if minH and minH > 0 then height = math.max(height, minH) end
		if maxW and maxW > 0 then width = math.min(width, maxW) end
		if maxH and maxH > 0 then height = math.min(height, maxH) end
	end

	target:ClearAllPoints()
	target:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	target:SetSize(width, height)
	return true
end

function D4:AddEditModeSnapFrame(frame)
	if frame then registry.snapFrames[frame] = true end
end

local function ShowState(mover, selected)
	if selected then
		mover.Selection:ShowSelected()
	else
		mover.Selection:ShowHighlighted()
	end

	if mover.d4EditModeOptions.hideLabel and mover.Selection.Label then mover.Selection.Label:Hide() end
	mover.isSelected = selected == true
end

local function DeselectAll(except)
	for mover in pairs(registry.frames) do
		if mover ~= except and mover.isSelected and mover.Selection:IsShown() then ShowState(mover, false) end
	end
end

local function HookManager()
	if registry.hooked or not EditModeManagerFrame then return end
	registry.hooked = true
	if EditModeManagerFrame.SelectSystem then hooksecurefunc(EditModeManagerFrame, "SelectSystem", function(_, system) DeselectAll(system) end) end
	if EditModeManagerFrame.ClearSelectedSystem then hooksecurefunc(EditModeManagerFrame, "ClearSelectedSystem", function() DeselectAll() end) end
end

function D4:SetEditModeSelected(mover, selected)
	if not mover or not mover.Selection then return end
	if not selected then
		ShowState(mover, false)
		return
	end

	if EditModeManagerFrame and EditModeManagerFrame.ClearSelectedSystem then EditModeManagerFrame:ClearSelectedSystem() end
	DeselectAll(mover)
	ShowState(mover, true)
	local onSelect = mover.d4EditModeOptions.onSelect
	if onSelect then onSelect(mover) end
end

function D4:CreateEditModeSelection(mover, options)
	if mover == nil or mover.Selection or not EditModeSystemSelectionMixin then return nil end
	options = options or {}
	mover.d4EditModeOptions = options
	mover.GetSystemName = function()
		if type(options.name) == "function" then return options.name(mover) end
		return options.name or mover:GetName() or ""
	end

	mover.SelectSystem = function(system) D4:SetEditModeSelected(system, true) end
	mover.HighlightSystem = function(system) ShowState(system, false) end
	mover.ClearHighlight = function(system)
		system.Selection:Hide()
		system.isSelected = false
	end

	mover.OnDragStart = function(system) if options.onDragStart then options.onDragStart(system) end end
	mover.OnDragStop = function(system) if options.onDragStop then options.onDragStop(system) end end
	mover.Selection = CreateFrame("Frame", nil, mover, "EditModeSystemSelectionTemplate")
	mover.Selection:SetAllPoints()
	mover.Selection:SetSystem(mover)
	mover.Selection:Hide()
	mover.Selection:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then D4:SetEditModeSelected(mover, true) end end)
	registry.frames[mover] = true
	HookManager()
	return mover.Selection
end

local function StartFrameDrag(frame)
	if not frame.d4EditModeActive or frame.isDragging or InCombatLockdown() then return end
	D4:SetEditModeSelected(frame, true)
	frame:StartMoving()
	frame.isDragging = true
	D4:StartEditModeSnap(frame, false)
end

local function StopFrameDrag(frame)
	if not frame.isDragging then return end
	frame.isDragging = false
	frame:StopMovingOrSizing()
	D4:StopEditModeSnap(frame, false)
	local x, y = frame:GetCenter()
	local parentX, parentY = UIParent:GetCenter()
	if not x or not parentX then return end
	local scale = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
	x = x - parentX * scale
	y = y - parentY * scale
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
	local onMoved = frame.d4EditModeCallbacks.onMoved
	if onMoved then onMoved(frame, "CENTER", "CENTER", x, y) end
end

local function SetFrameActive(frame, active)
	frame.d4EditModeActive = active
	if active then
		frame.Selection:SetFrameLevel(frame:GetFrameLevel() + 100)
		ShowState(frame, false)
	else
		StopFrameDrag(frame)
		frame.isSelected = false
		frame.Selection:Hide()
	end

	local onEditMode = frame.d4EditModeCallbacks.onEditMode
	if onEditMode then onEditMode(frame, active) end
end

function D4:RegisterEditModeFrame(frame, options)
	if frame == nil or frame.Selection or not EventRegistry then return false end
	options = options or {}
	local selection = D4:CreateEditModeSelection(frame, {
		name = options.name,
		hideLabel = options.hideLabel,
		onSelect = options.onSelect,
		getSnapTargets = options.getSnapTargets,
		onDragStart = StartFrameDrag,
		onDragStop = StopFrameDrag
	})

	if not selection then return false end
	frame.d4EditModeCallbacks = options
	frame:SetMovable(true)
	frame:HookScript("OnHide", StopFrameDrag)
	EventRegistry:RegisterCallback("EditMode.Enter", function() SetFrameActive(frame, true) end, frame)
	EventRegistry:RegisterCallback("EditMode.Exit", function() SetFrameActive(frame, false) end, frame)
	if IsEditModeActive() then SetFrameActive(frame, true) end
	return true
end

function D4:IsEditModeFrameActive(frame)
	return frame ~= nil and frame.d4EditModeActive == true
end
