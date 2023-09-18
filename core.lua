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

hooksecurefunc(UIParent, "SetScale", function(self, scale)
	MAUIP:SetScale(scale)
end)

MAUIP:SetScale(UIParent:GetScale())

hooksecurefunc(UIParent, "SetAlpha", function(self, alpha)
	MAUIP:SetAlpha(alpha)
end)

MAUIP:SetAlpha(UIParent:GetAlpha())

hooksecurefunc(UIParent, "Show", function(self)
	MAUIP:SetAlpha(1)
end)

hooksecurefunc(UIParent, "Hide", function(self)
	MAUIP:SetAlpha(0)
end)

hooksecurefunc(_G, "SetUIVisibility", function(show)
	if show then
		MAUIP:SetAlpha(1)
	else
		MAUIP:SetAlpha(0)
	end
end)

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
			MAGridFrame:Show()
			MALock:UpdateShowErrors()
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
			MAGridFrame:Hide()
			MALock:UpdateShowErrors()
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

-- TAINTFREE SLASH COMMANDS --
local lastMessage = ""
local cmds = {}

if ChatEdit_ParseText and type(ChatEdit_ParseText) == "function" then
	hooksecurefunc("ChatEdit_ParseText", function(editBox, send, parseIfNoSpace)
		if send == 0 then
			lastMessage = editBox:GetText()
		end
	end)
else
	MoveAny:MSG("FAILED TO ADD SLASH COMMAND #1")
end

if ChatFrame_DisplayHelpTextSimple and type(ChatFrame_DisplayHelpTextSimple) == "function" then
	hooksecurefunc("ChatFrame_DisplayHelpTextSimple", function(frame)
		if lastMessage and lastMessage ~= "" then
			local cmd = string.upper(lastMessage)
			cmd = strsplit(" ", cmd)

			if cmds[cmd] ~= nil then
				local count = 1
				local numMessages = frame:GetNumMessages()

				local function predicateFunction(entry)
					if count == numMessages and entry == HELP_TEXT_SIMPLE then return true end
					count = count + 1
				end

				frame:RemoveMessagesByPredicate(predicateFunction)
				cmds[cmd]()
			end
		end
	end)
else
	MoveAny:MSG("FAILED TO ADD SLASH COMMAND #2")
end

function MoveAny:InitSlash()
	cmds["/MOVE"] = MoveAny.ToggleMALock
	cmds["/MOVEANY"] = MoveAny.ToggleMALock
	cmds["/RL"] = C_UI.Reload
	cmds["/REL"] = C_UI.Reload
end
-- TAINTFREE SLASH COMMANDS --