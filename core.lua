local _, MoveAny = ...
local hooksecurefunc = _G["hooksecurefunc"]
local CreateFrame = _G["CreateFrame"]
local InCombatLockdown = _G["InCombatLockdown"]
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
function MoveAny:GetHidden()
	return MAHIDDEN
end

MoveAny:GetHidden():Hide()
MoveAny:GetHidden().unit = "player"
MoveAny:GetHidden().auraRows = 0
local sethidden = {}
local sethiddenSetup = {}
local sethiddenParent = {}
local sethiddenCanParent = {}
local oldsethiddenparent = {}
local oldsethiddenshown = {}
local createFrameHookRegistered = false
local function TrySetHiddenParent(frame)
	return pcall(function()
		local parent = frame:GetParent()
		if parent ~= MoveAny:GetHidden() then oldsethiddenparent[frame] = parent end
		frame:SetParent(MoveAny:GetHidden())
	end)
end

local function onCreateFrameHideCheck(_, _, parent)
	if parent == nil then return end
	if sethidden[parent] then MoveAny:HideFrame(parent) end
end

function MoveAny:HideFrame(frame)
	sethidden[frame] = true
	if InCombatLockdown() and frame:IsProtected() then
		MoveAny:After(0.1, function() MoveAny:HideFrame(frame) end, "HideFrame After")
	else
		frame:EnableMouse(false)
	end

	if sethiddenSetup[frame] == nil then
		sethiddenSetup[frame] = true
		local ok = TrySetHiddenParent(frame)
		if ok then
			sethiddenCanParent[frame] = true
			sethiddenParent[frame] = true
			local setparent = false
			hooksecurefunc(frame, "SetParent", function(sel)
				if sethidden[sel] == nil then return end
				if setparent then return end
				setparent = true
				sel:SetParent(MoveAny:GetHidden())
				setparent = false
			end)

			local hideAgainPending = false
			local function HideAgainNow(sel)
				if sethidden[sel] == nil then return end
				if not MoveAny:CanModify(sel) then
					if hideAgainPending then return end
					hideAgainPending = true
					MoveAny:After(0.1, function()
						hideAgainPending = false
						HideAgainNow(sel)
					end, "HideFrame HideAgain")

					return
				end

				sel:Hide()
			end

			local function HideAgain(sel, shown)
				if sethidden[sel] == nil then return end
				oldsethiddenshown[sel] = shown ~= false
				HideAgainNow(sel)
			end

			hooksecurefunc(frame, "Show", HideAgain)
			if frame.SetShown then hooksecurefunc(frame, "SetShown", HideAgain) end
		else
			local setalpha = false
			hooksecurefunc(frame, "SetAlpha", function(sel, alpha)
				if sethidden[sel] == nil then return end
				if setalpha then return end
				setalpha = true
				sel:SetAlpha(0)
				if not InCombatLockdown() then sel:EnableMouse(false) end
				if sel.GetChildren then
					MoveAny:ForeachChildren(sel, function(child)
						child:SetIgnoreParentAlpha(false)
						child:SetAlpha(0)
						if not InCombatLockdown() then child:EnableMouse(false) end
					end, "HideFrame ForeachChildren 1")
				end

				setalpha = false
			end)

			hooksecurefunc(frame, "Show", function(sel)
				if sethidden[sel] == nil then return end
				MoveAny:HideFrame(sel)
			end)

			local enableMouse = false
			hooksecurefunc(frame, "EnableMouse", function(sel, alpha)
				if sethidden[sel] == nil then return end
				if enableMouse then return end
				enableMouse = true
				sel:EnableMouse(false)
				if sel.GetChildren then MoveAny:ForeachChildren(sel, function(child) if not InCombatLockdown() then child:EnableMouse(false) end end, "HideFrame ForeachChildren 3") end
				enableMouse = false
			end)

			if not createFrameHookRegistered then
				createFrameHookRegistered = true
				hooksecurefunc("CreateFrame", onCreateFrameHideCheck)
			end
		end
	end

	frame:SetAlpha(0)
	if sethiddenCanParent[frame] then
		if sethiddenParent[frame] == nil then
			sethiddenParent[frame] = true
			TrySetHiddenParent(frame)
		end

		if MoveAny:CanModify(frame) then
			if oldsethiddenshown[frame] == nil then oldsethiddenshown[frame] = frame:IsShown() end
			frame:Hide()
		end
	end
end

function MoveAny:ShowFrame(frame)
	sethidden[frame] = nil
	if sethiddenParent[frame] then
		sethiddenParent[frame] = nil
		pcall(function()
			frame:SetParent(oldsethiddenparent[frame] or MoveAny:GetMainPanel())
			oldsethiddenparent[frame] = nil
		end)
	end

	if oldsethiddenshown[frame] ~= nil then
		if not MoveAny:CanModify(frame) then
			MoveAny:After(0.1, function() MoveAny:ShowFrame(frame) end, "ShowFrame")

			return
		end

		if oldsethiddenshown[frame] then frame:Show() end
		oldsethiddenshown[frame] = nil
	end

	frame:SetAlpha(1)
	if not InCombatLockdown() then
		frame:EnableMouse(true)
	else
		MoveAny:After(0.1, function() MoveAny:ShowFrame(frame) end, "ShowFrame")
	end
end

--[[ HIDEPANEL ]]
function MoveAny:GetMainPanel()
	return UIParent
end

local isToggling = false
function MoveAny:Unlock()
	if not isToggling then
		isToggling = true
		MoveAny:SetEnabled("MALOCK", true)
		isToggling = false
	else
		MoveAny:MSG("[Unlock] Settings Frame is toggling. ShowMenu: " .. tostring(MoveAny:IsEnabled("MALOCK", false)))
	end
end

function MoveAny:Lock()
	if not isToggling then
		isToggling = true
		MoveAny:SetEnabled("MALOCK", false)
		isToggling = false
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
			df:Show()
			if df.opt then df.opt:Show() end
		end

		if MALock then
			MALock:Show()
			if MAGridFrame then MAGridFrame:Show() end
		else
			MoveAny:MSG("[ShowMALock] Settings Frame couldn't be created, please tell dev.")
		end
	end
end

function MoveAny:HideMALock(onlyHide)
	if MoveAny:IsMALockNotReady() then return end
	if not onlyHide then MoveAny:Lock() end
	if not MoveAny:IsEnabled("MALOCK", false) then
		for i, df in pairs(MoveAny:GetDragFrames()) do
			df:Hide()
			if df.opt then df.opt:Hide() end
		end

		if MALock then
			MALock:Hide()
			if MAGridFrame then MAGridFrame:Hide() end
		else
			MoveAny:MSG("[HideMALock] Settings Frame couldn't be created, please tell dev.")
		end
	end
end

function MoveAny:ToggleMALock()
	if MoveAny:IsMALockNotReady() then return end
	if MoveAny:IsEnabled("MALOCK", false) and MALock.save and MALock.save:IsEnabled() then
		MoveAny:INFO("Can't Toggle Settings Frame when it is not saved.")
		return
	end

	if not MoveAny:IsEnabled("MALOCK", false) then
		MoveAny:ShowMALock()
	else
		MoveAny:HideMALock()
	end
end

local inCombat = false
function MoveAny:UpdateMALock(event)
	if MoveAny:IsEnabled("MALOCK", false) and InCombatLockdown() then
		inCombat = true
		MoveAny:HideMALock()
	elseif inCombat and not InCombatLockdown() then
		inCombat = false
		MoveAny:ShowMALock()
	end
end

local maLockCheck = CreateFrame("Frame")
MoveAny:RegisterEvent(maLockCheck, "PLAYER_REGEN_ENABLED")
MoveAny:RegisterEvent(maLockCheck, "PLAYER_REGEN_DISABLED")
MoveAny:OnEvent(maLockCheck, function(sel, event) MoveAny:UpdateMALock(event) end, "maLockCheck")
function MoveAny:InitSlash()
	MoveAny:AddSlash("move", MoveAny.ToggleMALock)
	MoveAny:AddSlash("moveany", MoveAny.ToggleMALock)
	MoveAny:AddSlash(MoveAny:Trans("LID_SLASHMOVE"), MoveAny.ToggleMALock)
	MoveAny:AddSlash(MoveAny:Trans("LID_SLASHMOVEANY"), MoveAny.ToggleMALock)
	local reload = _G["ReloadUI"]
	if C_UI and C_UI.Reload then reload = C_UI.Reload end
	MoveAny:AddSlash("rl", reload)
	MoveAny:AddSlash("rel", reload)
	MoveAny:AddSlash(MoveAny:Trans("LID_SLASHRELOAD"), reload)
end

if false then
	C_Timer.After(1, function()
		MoveAny:SetDebug(true)
		if false then
			MoveAny:DrawDebug("MoveAny Test DrawDebug 1", function()
				local text = ""
				for i, v in pairs(MoveAny:GetCountAfter()) do
					if v > 200 then text = text .. v .. "x: " .. i .. "\n" end
				end
				return text
			end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 400, 0)
		end

		if false then
			MoveAny:DrawDebug("MoveAny Test DrawDebug 2", function()
				local text = ""
				for i, v in pairs(MoveAny:GetCountAfterEvents()) do
					if v > 1 then text = text .. v .. "x: " .. i .. "\n" end
				end
				return text
			end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 900, 0)
		end
	end)
end
