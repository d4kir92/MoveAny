local _, MoveAny = ...
local colors = {}

colors["bg"] = {0.03, 0.03, 0.03}

colors["se"] = {1.0, 1.0, 0.0}

colors["el"] = {0.6, 0.84, 1.0}

colors["hidden"] = {1.0, 0.0, 0.0}

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
local Test = CreateFrame("Frame")
Test:SetAllPoints(UIParent)
Test.unit = "player"
Test.auraRows = 0

hooksecurefunc(UIParent, "SetScale", function(self, scale)
	Test:SetScale(scale)
end)

Test:SetScale(UIParent:GetScale())

hooksecurefunc(UIParent, "SetAlpha", function(self, alpha)
	Test:SetAlpha(alpha)
end)

Test:SetAlpha(UIParent:GetAlpha())

hooksecurefunc(UIParent, "Show", function(self)
	Test:SetAlpha(1)
end)

hooksecurefunc(UIParent, "Hide", function(self)
	Test:SetAlpha(0)
end)

hooksecurefunc(_G, "SetUIVisibility", function(show)
	if show then
		Test:SetAlpha(1)
	else
		Test:SetAlpha(0)
	end
end)

function MoveAny:GetMainPanel()
	return Test
end

--[[ NEW ]]
local pausedKeybinds = {"UP", "DOWN", "LEFT", "RIGHT"}

local oldKeybinds = {}
local isToggling = false

function MoveAny:UnlockBindings()
	if not InCombatLockdown() then
		for i, name in pairs(pausedKeybinds) do
			oldKeybinds[name] = GetBindingAction(name)
			SetBinding(name, nil)
		end

		isToggling = false
	else
		C_Timer.After(0.1, MoveAny.UnlockBindings)
	end
end

function MoveAny:LockBindings()
	if not InCombatLockdown() then
		for i, name in pairs(pausedKeybinds) do
			if oldKeybinds[name] then
				SetBinding(name, oldKeybinds[name])
			end
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
		MoveAny:MSG("[Unlock] Settings Frame is toggling, try again.")
	end
end

function MoveAny:Lock()
	if not isToggling then
		isToggling = true
		MoveAny:SetEnabled("MALOCK", false)
		MoveAny:LockBindings()
	else
		MoveAny:MSG("[Lock] Settings Frame is toggling, try again.")
	end
end

function MoveAny:IsMALockNotReady()
	if MALock == nil then
		MoveAny:MSG("Settings Frame is not created")

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

hooksecurefunc("ChatEdit_ParseText", function(editBox, send, parseIfNoSpace)
	if send == 0 then
		lastMessage = editBox:GetText()
	end
end)

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

function MoveAny:InitSlash()
	cmds["/MOVE"] = MoveAny.ToggleMALock
	cmds["/MOVEANY"] = MoveAny.ToggleMALock
	cmds["/RL"] = C_UI.Reload
	cmds["/REL"] = C_UI.Reload
end
-- TAINTFREE SLASH COMMANDS --