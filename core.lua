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

MAHIDDEN = CreateFrame("Frame", "MAHIDDEN")
MAHIDDEN:Hide()

function MoveAny:ShowMALock()
	if MALock == nil then return end

	if MoveAny:IsEnabled("MALOCK", false) then
		for i, df in pairs(MoveAny:GetDragFrames()) do
			df:EnableMouse(true)
			df:SetAlpha(1)
		end

		if MALock then
			MALock:Show()
			MAGridFrame:Show()
			MALock:UpdateShowErrors()
		end
	end
end

function MoveAny:HideMALock()
	if MALock == nil then return end

	if not MoveAny:IsEnabled("MALOCK", false) then
		for i, df in pairs(MoveAny:GetDragFrames()) do
			df:EnableMouse(false)
			df:SetAlpha(0)
		end

		if MALock then
			MALock:Hide()
			MAGridFrame:Hide()
			MALock:UpdateShowErrors()
		end
	end
end

function MoveAny:ToggleMALock()
	if MALock == nil then return end
	if MoveAny:IsEnabled("MALOCK", false) and MALock.save and MALock.save:IsEnabled() then return end
	MoveAny:SetEnabled("MALOCK", not MoveAny:IsEnabled("MALOCK", false))

	if MoveAny:IsEnabled("MALOCK", false) then
		MoveAny:ShowMALock()
	else
		MoveAny:HideMALock()
	end
end

local inCombat = false

function MoveAny:UpdateMALock()
	if MoveAny:IsEnabled("MALOCK", false) and InCombatLockdown() then
		inCombat = true
		MoveAny:ToggleMALock()
	elseif inCombat and not InCombatLockdown() then
		inCombat = false
		MoveAny:ToggleMALock()
	end
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