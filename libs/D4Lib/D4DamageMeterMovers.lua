local _, D4 = ...
local MAX_SESSION_WINDOWS = 10
local registry = _G["D4DamageMeterMovers"]
if type(registry) ~= "table" then
	registry = {}
	_G["D4DamageMeterMovers"] = registry
end

registry.owners = registry.owners or {}
registry.listeners = registry.listeners or {}
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

local function GetSessionWindows()
	local windows = {}
	for i = 1, MAX_SESSION_WINDOWS do
		local window = _G["DamageMeterSessionWindow" .. i]
		if window then table.insert(windows, window) end
	end

	return windows
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
	if selected then
		D4:SetEditModeSelected(selected, true)
		return
	end

	for _, mover in pairs(state.movers) do
		if mover:IsShown() then D4:SetEditModeSelected(mover, false) end
	end
end

local function StopMover(mover)
	if not mover.isDragging and not mover.isSizing then return end
	local window = mover.window
	local wasDragging = mover.isDragging
	mover.isDragging = false
	mover.isSizing = false
	if not window then
		D4:CancelEditModeSnap()
		return
	end

	window:StopMovingOrSizing()
	D4:StopEditModeSnap(mover, not wasDragging)
end

local function StartMoverDrag(mover)
	local window = mover.window
	if not state.editModeActive or not window or mover.isDragging or mover.isSizing or InCombatLockdown() or not window:IsMovable() then return end
	SelectMover(mover)
	window:StartMoving()
	mover.isDragging = true
	D4:StartEditModeSnap(mover, false)
end

local function CreateMover(index)
	local mover = CreateFrame("Frame", nil, UIParent)
	mover:Hide()
	D4:CreateEditModeSelection(mover, {
		name = function() return format("%s %d", HUD_EDIT_MODE_DAMAGE_METER_LABEL or "Damage Meter", index) end,
		hideLabel = true,
		onSelect = NotifySelected,
		onDragStart = StartMoverDrag,
		onDragStop = StopMover,
		getSnapTargets = GetSessionWindows
	})

	mover.Selection:SetAllPoints()
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
		D4:StartEditModeSnap(mover, true)
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
				mover.d4EditModeTarget = window
				mover:ClearAllPoints()
				mover:SetAllPoints(window)
			end

			if not mover:IsShown() then
				mover.Selection:SetFrameStrata(window:GetFrameStrata())
				mover.Selection:SetFrameLevel(math.min(window:GetFrameLevel() + 100, 9000))
				mover:Show()
				D4:SetEditModeSelected(mover, false)
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
	if type(addonName) ~= "string" or state.ownerName or not EditModeSystemSelectionMixin then return end
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
	D4:AddEditModeSnapFrame(frame)
end

function D4:OnDamageMeterWindowMoverSelected(addonName, func)
	if type(addonName) == "string" then registry.listeners[addonName] = func end
end

function D4:ClearDamageMeterWindowMoverSelection()
	local owner = registry.owners[GetActiveOwner() or ""]
	if type(owner) == "table" and type(owner.select) == "function" then owner.select(nil) end
end
