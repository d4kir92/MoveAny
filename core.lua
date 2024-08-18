local _, MoveAny = ...
local colors = {}
colors["bg"] = {0.03, 0.03, 0.03}
colors["se"] = {1.0, 1.0, 0.0}
colors["el"] = {0.6, 0.84, 1.0}
colors["hidden"] = {1.0, 0.0, 0.0}
colors["clickthrough"] = {0.2, 0.2, 1.0}
function MoveAny:GetColor(key)
	return colors[key][1], colors[key][2], colors[key][3]
end

local MADF = {}
function MoveAny:GetDragFrames()
	return MADF
end

--[[ HIDEPANEL ]]
local MAHIDDEN = CreateFrame("Frame", "MAHIDDEN")
MAHIDDEN:Hide()
MAHIDDEN.unit = "player"
MAHIDDEN.auraRows = 0
--[[ HIDEPANEL ]]
--[[ NEW ]]
local MAUIP = CreateFrame("Frame", "UIParent")
MAUIP:SetAllPoints(UIParent)
MAUIP.unit = "player"
MAUIP.auraRows = 0
function MoveAny:SetMAUIPAlpha(alpha)
	if UIParent:IsShown() then
		MAUIP:SetAlpha(alpha)
	else
		MAUIP:SetAlpha(0)
	end
end

local uiscalecvar = CreateFrame("Frame")
uiscalecvar:RegisterEvent("CVAR_UPDATE")
uiscalecvar:SetScript(
	"OnEvent",
	function(self, event, target, value)
		if event == "CVAR_UPDATE" and (target == "uiScale" or target == "useUiScale") then
			if MoveAny:GetCVar("useUiScale") == "1" then
				MAUIP:SetScale(MoveAny:GetCVar("uiScale"))
			else
				MAUIP:SetScale(UIParent:GetScale())
			end

			MoveAny:UpdateGrid()
		end
	end
)

hooksecurefunc(
	UIParent,
	"SetScale",
	function(self, scale)
		if MoveAny:GetCVar("useUiScale") == "0" then
			MAUIP:SetScale(scale)
		end
	end
)

if MoveAny:GetCVar("useUiScale") == "1" then
	MAUIP:SetScale(MoveAny:GetCVar("uiScale"))
else
	C_Timer.After(
		0,
		function()
			MAUIP:SetScale(UIParent:GetScale())
		end
	)
end

MoveAny:SetMAUIPAlpha(UIParent:GetAlpha())
hooksecurefunc(
	UIParent,
	"Show",
	function(self)
		MoveAny:SetMAUIPAlpha(1)
	end
)

hooksecurefunc(
	UIParent,
	"Hide",
	function(self)
		MoveAny:SetMAUIPAlpha(0)
	end
)

hooksecurefunc(
	_G,
	"SetUIVisibility",
	function(show, ...)
		if show then
			MoveAny:SetMAUIPAlpha(1)
		else
			MoveAny:SetMAUIPAlpha(0)
		end
	end
)

function MoveAny:GetMainPanel()
	return MAUIP
end

--[[ NEW ]]
local pausedKeybinds = {"UP", "DOWN", "LEFT", "RIGHT"}
local oldKeybinds = {}
local isToggling = false
local wasDisabled = false
function MoveAny:UnlockBindings()
	if not InCombatLockdown() then
		if MoveAny:IsEnabled("DISABLEMOVEMENT", false) then
			for i, name in pairs(pausedKeybinds) do
				oldKeybinds[name] = GetBindingAction(name)
				SetBinding(name, nil)
			end

			wasDisabled = true
		end

		isToggling = false
	else
		C_Timer.After(0.1, MoveAny.UnlockBindings)
	end
end

function MoveAny:LockBindings()
	if not InCombatLockdown() then
		if MoveAny:IsEnabled("DISABLEMOVEMENT", false) or wasDisabled then
			for i, name in pairs(pausedKeybinds) do
				if oldKeybinds[name] then
					SetBinding(name, oldKeybinds[name])
				end
			end

			wasDisabled = false
		end

		isToggling = false
	else
		C_Timer.After(0.1, MoveAny.LockBindings)
	end
end

function MoveAny:Unlock()
	if not isToggling then
		isToggling = true
		MoveAny:SetEnabled("MALOCK", true)
		MoveAny:UnlockBindings()
	else
		MoveAny:MSG("[Unlock] Settings Frame is toggling. ShowMenu: " .. tostring(MoveAny:IsEnabled("MALOCK", false)))
	end
end

function MoveAny:Lock()
	if not isToggling then
		isToggling = true
		MoveAny:SetEnabled("MALOCK", false)
		MoveAny:LockBindings()
	else
		MoveAny:MSG("[Lock] Settings Frame is toggling. ShowMenu: " .. tostring(MoveAny:IsEnabled("MALOCK", false)))
	end
end

function MoveAny:IsMALockNotReady()
	if MALock == nil then
		MoveAny:MSG("Settings Frame is not created yet, maybe you got an error? If not error, please install BugSack, Buggrabber to see the error.")

		return true
	end

	return false
end

function MoveAny:ShowMALock()
	if MoveAny:IsMALockNotReady() then return end
	MoveAny:Unlock()
	if MoveAny:IsEnabled("MALOCK", false) then
		for i, df in pairs(MoveAny:GetDragFrames()) do
			df:EnableMouse(true)
			df:SetAlpha(1)
			if df.opt then
				df.opt:Show()
			end
		end

		if MALock then
			MALock:Show()
			if MAGridFrame then
				MAGridFrame:Show()
			end
		else
			MoveAny:MSG("[ShowMALock] Settings Frame couldn't be created, please tell dev.")
		end
	end
end

function MoveAny:HideMALock(onlyHide)
	if MoveAny:IsMALockNotReady() then return end
	if not onlyHide then
		MoveAny:Lock()
	end

	if not MoveAny:IsEnabled("MALOCK", false) then
		for i, df in pairs(MoveAny:GetDragFrames()) do
			df:EnableMouse(false)
			df:SetAlpha(0)
			if df.opt then
				df.opt:Hide()
			end
		end

		if MALock then
			MALock:Hide()
			if MAGridFrame then
				MAGridFrame:Hide()
			end
		else
			MoveAny:MSG("[HideMALock] Settings Frame couldn't be created, please tell dev.")
		end
	end
end

function MoveAny:ToggleMALock()
	if MoveAny:IsMALockNotReady() then return end
	if InCombatLockdown() then
		MoveAny:MSG("You are in Combat")

		return
	end

	if MoveAny:IsEnabled("MALOCK", false) and MALock.save and MALock.save:IsEnabled() then
		MoveAny:MSG("Can't Toggle Settings Frame when it is not saved.")

		return
	end

	if not MoveAny:IsEnabled("MALOCK", false) then
		MoveAny:ShowMALock()
	else
		MoveAny:HideMALock()
	end
end

local inCombat = false
function MoveAny:UpdateMALock()
	if MoveAny:IsEnabled("MALOCK", false) and InCombatLockdown() then
		inCombat = true
		MoveAny:HideMALock()
	elseif inCombat and not InCombatLockdown() then
		inCombat = false
		MoveAny:ShowMALock()
	end

	C_Timer.After(0.1, MoveAny.UpdateMALock)
end

function MoveAny:InitSlash()
	MoveAny:AddSlash("move", MoveAny.ToggleMALock)
	MoveAny:AddSlash("moveany", MoveAny.ToggleMALock)
	if C_UI then
		MoveAny:AddSlash("rl", C_UI.Reload)
		MoveAny:AddSlash("rel", C_UI.Reload)
	else
		MoveAny:AddSlash("rl", ReloadUi)
		MoveAny:AddSlash("rel", ReloadUi)
	end
end
