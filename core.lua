local _, MoveAny = ...
local hooksecurefunc = getglobal("hooksecurefunc")
local CreateFrame = getglobal("CreateFrame")
local InCombatLockdown = getglobal("InCombatLockdown")
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
function MoveAny:HideFrame(frame, soft)
	if not soft then
		if InCombatLockdown() then
			MoveAny:After(
				0.1,
				function()
					MoveAny:HideFrame(frame, soft)
				end, "HideFrame"
			)

			return
		end

		sethidden[frame] = true
		if sethiddenSetup[frame] == nil then
			sethiddenSetup[frame] = true
			local setparent = false
			hooksecurefunc(
				frame,
				"SetParent",
				function(sel, parent)
					if sethidden[sel] == nil then return end
					if setparent then return end
					setparent = true
					MoveAny:TrySetParent(sel, MoveAny:GetHidden())
					setparent = false
				end
			)
		end

		MoveAny:TrySetParent(frame, MoveAny:GetHidden())

		return
	end

	sethidden[frame] = true
	if sethiddenSetup[frame] == nil then
		sethiddenSetup[frame] = true
		local setalpha = false
		hooksecurefunc(
			frame,
			"SetAlpha",
			function(sel, alpha)
				if sethidden[sel] == nil then return end
				if setalpha then return end
				setalpha = true
				sel:SetAlpha(0)
				if not InCombatLockdown() then
					sel:EnableMouse(false)
				end

				if sel.GetChildren then
					MoveAny:ForeachChildren(
						sel,
						function(child)
							child:SetAlpha(0)
							if not InCombatLockdown() then
								child:EnableMouse(false)
							end
						end, "HideFrame"
					)
				end

				setalpha = false
			end
		)
	end

	frame:SetAlpha(0)
	frame:EnableMouse(false)
	if InCombatLockdown() then
		MoveAny:After(
			0.1,
			function()
				MoveAny:HideFrame(frame, soft)
			end, "HideFrame 2"
		)
	end
end

function MoveAny:ShowFrame(frame)
	sethidden[frame] = nil
	frame:SetAlpha(1)
	if not InCombatLockdown() then
		frame:EnableMouse(true)
	else
		MoveAny:After(
			0.1,
			function()
				MoveAny:ShowFrame(frame)
			end, "ShowFrame"
		)
	end
end

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
--MoveAny:RegisterEvent(uiscalecvar, "CVAR_UPDATE")
MoveAny:OnEvent(
	uiscalecvar,
	function(self, event, target, value)
		if event == "CVAR_UPDATE" and (target == "uiScale" or target == "useUiScale") then
			if MoveAny:GetCVar("useUiScale") == "1" then
				MAUIP:SetScale(MoveAny:GetCVar("uiScale"))
			else
				MAUIP:SetScale(UIParent:GetScale())
			end

			MoveAny:UpdateGrid()
		end
	end, "uiscalecvar"
)

local setScale = false
local scaleVale = 1
function MoveAny:MAUI_SetScale(scale)
	scaleVale = scale
	if setScale then return end
	setScale = true
	local worked = MoveAny:TrySetScale(MAUIP, scaleVale)
	if not worked then
		MoveAny:After(
			0.1,
			function()
				setScale = false
				MoveAny:MAUI_SetScale(scaleVale)
			end, "MAUI_SetScale"
		)
	end
end

hooksecurefunc(
	UIParent,
	"SetScale",
	function(sel, scale)
		if MoveAny:GetCVar("useUiScale") == "0" and type(scale) == "number" then
			MoveAny:MAUI_SetScale(scale)
		end
	end
)

if MoveAny:GetCVar("useUiScale") == "1" then
	MoveAny:MAUI_SetScale(MoveAny:GetCVar("uiScale"))
else
	MoveAny:After(
		0,
		function()
			MoveAny:MAUI_SetScale(UIParent:GetScale())
		end, "uiScale"
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
			df:Hide()
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
MoveAny:OnEvent(
	maLockCheck,
	function(sel, event)
		MoveAny:UpdateMALock(event)
	end, "maLockCheck"
)

function MoveAny:InitSlash()
	MoveAny:AddSlash("move", MoveAny.ToggleMALock)
	MoveAny:AddSlash("moveany", MoveAny.ToggleMALock)
	if C_UI then
		MoveAny:AddSlash("rl", C_UI.Reload)
		MoveAny:AddSlash("rel", C_UI.Reload)
	else
		MoveAny:AddSlash("rl", getglobal("ReloadUI"))
		MoveAny:AddSlash("rel", getglobal("ReloadUI"))
	end
end

if false then
	C_Timer.After(
		1,
		function()
			MoveAny:SetDebug(true)
			if false then
				MoveAny:DrawDebug(
					"MoveAny Test DrawDebug 1",
					function()
						local text = ""
						for i, v in pairs(MoveAny:GetCountAfter()) do
							if v > 200 then
								text = text .. v .. "x: " .. i .. "\n"
							end
						end

						return text
					end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 400, 0
				)
			end

			if false then
				MoveAny:DrawDebug(
					"MoveAny Test DrawDebug 2",
					function()
						local text = ""
						for i, v in pairs(MoveAny:GetCountAfterEvents()) do
							if v > 1 then
								text = text .. v .. "x: " .. i .. "\n"
							end
						end

						return text
					end, 14, 1440, 1440, "CENTER", UIParent, "CENTER", 900, 0
				)
			end
		end
	)
end
