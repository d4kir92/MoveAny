local _, MoveAny = ...
local hooksecurefunc = getglobal("hooksecurefunc")
local strsplit = getglobal("strsplit")
local CreateFrame = getglobal("CreateFrame")
local InCombatLockdown = getglobal("InCombatLockdown")
local GetScreenWidth = getglobal("GetScreenWidth")
local GetScreenHeight = getglobal("GetScreenHeight")
local tinsert = getglobal("tinsert")
local strfind = getglobal("strfind")
local strupper = getglobal("strupper")
local strlower = getglobal("strlower")
local format = getglobal("format")
local C_Widget = getglobal("C_Widget")
local C_UI = getglobal("C_UI")
local C_ChatInfo = getglobal("C_ChatInfo")
local SHOW_MULTI_ACTIONBAR_3 = getglobal("SHOW_MULTI_ACTIONBAR_3")
local Enum = getglobal("Enum")
local PREFIX = "MOAN"
local MASendProfiles = {}
local MAWantProfiles = {}
local WebStatus = 0.0
local WebProfile = ""
local WebOwner = ""
local WebProfileData = {}
local searchStr = ""
local br = 8
local sw = 550
local sh = MoveAny:MClamp(640, 200, GetScreenHeight())
local posy = -4
local cas = {}
local cbs = {}
local sls = {}
local buffsDelay = 0.1
local EMMapForced = {}
local keybinds = {}
local sptab = {}
function MoveAny:SetPoint(window, p1, p2, p3, p4, p5)
	if window == nil then
		MoveAny:INFO("[SetPoint] WINDOW IS NIL")

		return
	end

	sptab[window] = sptab[window] or false
	MoveAny:SafeExec(
		window,
		function()
			if p1 then
				local ClearAllPoints = window.FClearAllPoints or window.ClearAllPoints
				local SetPoint = window.FSetPointBase or window.FSetPoint or window.SetPointBase or window.SetPoint
				sptab[window] = true
				ClearAllPoints(window)
				SetPoint(window, p1, p2 or "UIParent", p3, p4, p5)
				sptab[window] = false
			end
		end, "MoveAny:SetPoint"
	)

	return true
end

function MoveAny:CheckBuffType(id, child, tab, isDebuff)
	if child == nil then return 0 end
	if child:IsShown() == false then return 0 end
	local csw, csh = child:GetSize()
	if csw < 16 or csw > 22 or csh < 16 or csh > 22 then return 0 end
	local debuff = false
	local childName = MoveAny:GetName(child)
	if childName then
		if strfind(childName, "Debuff", 1, true) ~= nil then
			debuff = true
		end
	else
		MoveAny:ForeachRegions(
			child,
			function(region, x)
				if region and MoveAny:GetName(region) and (MoveAny:GetName(region) == "TargetFrameBorder" or MoveAny:GetName(region) == "FocusFrameBorder") then
					debuff = true
				end
			end
		)
	end

	if not isDebuff and not debuff or isDebuff and debuff then
		if tab[id] == nil then
			tab[id] = child
		end

		return 1
	end

	return 0
end

function MoveAny:CheckBuffs(frame, tab, isDebuff)
	local id = 1
	if frame then
		MoveAny:ForeachChildren(
			frame,
			function(child, i)
				id = id + MoveAny:CheckBuffType(id, child, tab, isDebuff)
			end
		)
	end

	return tab
end

function MoveAny:UpdateChildBuffs(bb, name)
	if bb ~= nil then
		if bb.setup == nil then
			bb.setup = true
			hooksecurefunc(
				bb,
				"SetAlpha",
				function()
					if bb.setalpha then return end
					bb.setalpha = true
					if MoveAny:GetEleOption(name, "Hide", false, "Hide4") then
						bb:SetAlpha(0)
						if not InCombatLockdown() then
							bb:EnableMouse(false)
						end
					end

					bb.setalpha = false
				end
			)
		end

		if MoveAny:GetEleOption(name, "Hide", false, "Hide5") then
			bb:SetAlpha(0)
			if not InCombatLockdown() then
				bb:EnableMouse(false)
			end
		else
			local p1, p2, p3, p4, p5 = bb:GetPoint()
			if p1 and p3 then
				bb:SetPoint(p1, p2, p3, p4, p5)
			end
		end
	end
end

local targetBuffs = {}
function MoveAny:UpdateTargetFrameBuffs()
	targetBuffs = {}
	MoveAny:CheckBuffs(TargetFrame, targetBuffs, false)

	return targetBuffs
end

local targetDebuffs = {}
function MoveAny:UpdateTargetFrameDebuffs()
	targetDebuffs = {}
	MoveAny:CheckBuffs(TargetFrame, targetDebuffs, true)

	return targetDebuffs
end

local targetBuffsTOT = {}
function MoveAny:UpdateTargetFrameToTBuffs()
	targetBuffsTOT = {}
	MoveAny:CheckBuffs(TargetFrameToT, targetBuffsTOT, false)

	return targetBuffsTOT
end

local targetDebuffsTOT = {}
function MoveAny:UpdateTargetFrameToTDebuffs()
	targetDebuffsTOT = {}
	MoveAny:CheckBuffs(TargetFrameToT, targetDebuffsTOT, true)

	return targetDebuffsTOT
end

local focusBuffs = {}
function MoveAny:UpdateFocusFrameBuffs()
	focusBuffs = {}
	MoveAny:CheckBuffs(FocusFrame, focusBuffs, false)

	return focusBuffs
end

local focusDebuffs = {}
function MoveAny:UpdateFocusFrameDebuffs()
	focusDebuffs = {}
	MoveAny:CheckBuffs(FocusFrame, focusDebuffs, true)

	return focusDebuffs
end

local focusBuffsTOT = {}
function MoveAny:UpdateFocusFrameToTBuffs()
	focusBuffsTOT = {}
	MoveAny:CheckBuffs(FocusFrameToT, focusBuffsTOT, false)

	return focusBuffsTOT
end

local focusDebuffsTOT = {}
function MoveAny:UpdateFocusFrameToTDebuffs()
	focusDebuffsTOT = {}
	MoveAny:CheckBuffs(FocusFrameToT, focusDebuffsTOT, true)

	return focusDebuffsTOT
end

keybinds[1] = "SHIFT"
keybinds[2] = "CTRL"
keybinds[3] = "ALT"
function MoveAny:AddToEMMapForced(key)
	EMMapForced[key] = true
	EMMapForced[strupper(key)] = true
end

MoveAny:AddToEMMapForced("Minimap")
MoveAny:AddToEMMapForced("MinimapCluster")
MoveAny:AddToEMMapForced("PlayerFrame")
MoveAny:AddToEMMapForced("ObjectiveTrackerFrame")
MoveAny:AddToEMMapForced("QuestTracker")
MoveAny:AddToEMMapForced("ChatFrame1")
MoveAny:AddToEMMapForced("Chat")
MoveAny:AddToEMMapForced("GameTooltip")
MoveAny:AddToEMMapForced("Castingbar")
MoveAny:AddToEMMapForced("MainMenuBar")
MoveAny:AddToEMMapForced("MultiBarBottomLeft")
MoveAny:AddToEMMapForced("MultiBarBottomRight")
MoveAny:AddToEMMapForced("MultiBarRight")
MoveAny:AddToEMMapForced("MultiBarLeft")
MoveAny:AddToEMMapForced("MultiBar5")
MoveAny:AddToEMMapForced("MultiBar6")
MoveAny:AddToEMMapForced("MultiBar7")
MoveAny:AddToEMMapForced("MainStatusTrackingBarContainer")
for i = 1, 8 do
	MoveAny:AddToEMMapForced("ACTIONBAR" .. i)
end

local EMMap = {}
function MoveAny:AddToEMMap(key, value)
	EMMap[key] = value
	EMMap[strupper(key)] = value
end

MoveAny:AddToEMMap("MAPetBar", "ShowPetActionBar")
MoveAny:AddToEMMap("PetBar", "ShowPetActionBar")
MoveAny:AddToEMMap("PetActionBar", "ShowPetActionBar")
MoveAny:AddToEMMap("EncounterBar", "ShowEncounterBar")
MoveAny:AddToEMMap("StanceBar", "ShowStanceBar")
MoveAny:AddToEMMap("MAStanceBar", "ShowStanceBar")
MoveAny:AddToEMMap("StanceBarAnchor", "ShowStanceBar")
MoveAny:AddToEMMap("MAGameTooltip", "ShowHudTooltip")
MoveAny:AddToEMMap("TalkingHeadFrame", "ShowTalkingHeadFrame")
MoveAny:AddToEMMap("TalkingHead", "ShowTalkingHeadFrame")
MoveAny:AddToEMMap("Buffs", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("BuffFrame", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("MABuffBar", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("Debuffs", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("DebuffFrame", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("MADebuffBar", "ShowBuffsAndDebuffs")
MoveAny:AddToEMMap("TargetFrame", "ShowTargetAndFocus")
MoveAny:AddToEMMap("FocusFrame", "ShowTargetAndFocus")
MoveAny:AddToEMMap("ExtraAbilityFrame", "ShowExtraAbilities")
MoveAny:AddToEMMap("ExtraAbilityContainer", "ShowExtraAbilities")
MoveAny:AddToEMMap("PossessActionBar", "ShowPossessActionBar")
MoveAny:AddToEMMap("PossessBarFrame", "ShowPossessActionBar")
MoveAny:AddToEMMap("PossessBar", "ShowPossessActionBar")
MoveAny:AddToEMMap("MainMenuBarVehicleLeaveButton", "ShowVehicleLeaveButton")
MoveAny:AddToEMMap("LeaveVehicle", "ShowVehicleLeaveButton")
MoveAny:AddToEMMap("PlayerCastingBarFrame", "ShowCastBar")
MoveAny:AddToEMMap("PetFrame", "ShowPetFrame")
MoveAny:AddToEMMap("MAPetFrame", "ShowPetFrame")
MoveAny:AddToEMMap("BossTargetFrameContainer", "ShowBossFrames")
MoveAny:AddToEMMap("SecondaryStatusTrackingBarContainer", "ShowStatusTrackingBar2")
MoveAny:AddToEMMap("VehicleSeatIndicator", "ShowVehicleSeatIndicator")
MoveAny:AddToEMMap("MAVehicleSeatIndicator", "ShowVehicleSeatIndicator")
MoveAny:AddToEMMap("PartyFrame", "ShowPartyFrames")
MoveAny:AddToEMMap("CompactRaidFrameContainer", "ShowRaidFrames")
MoveAny:AddToEMMap("CompactArenaFrame", "ShowArenaFrames")
function MoveAny:IsBlizEditModeEnabled()
	if (MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC") or (C_Widget.IsWidget(EditModeManagerFrame) and EditModeManagerFrame.numLayouts) then return true end

	return false
end

function MoveAny:IsValidFrame(frame)
	if frame and C_Widget.IsWidget(frame) then return true end

	return false
end

local onceDebug = false
function MoveAny:IsInEditModeEnabled(val)
	local editModeEnum = nil
	if not MoveAny:IsBlizEditModeEnabled() then return false, false end
	if EMMapForced[val] then return true, true end
	if Enum and Enum.EditModeAccountSetting then
		if EMMap[val] then
			editModeEnum = Enum.EditModeAccountSetting[EMMap[val]]
		else
			editModeEnum = Enum.EditModeAccountSetting[val]
		end

		if EMMap[val] and editModeEnum == nil then
			MoveAny:ERR("MISSING ENUM FOR val: " .. tostring(val))
		end
	end

	if EditModeManagerFrame.accountSettings == nil then
		EditModeManagerFrame:InitializeAccountSettings()
	end

	if C_Widget.IsWidget(GameMenuButtonEditMode) and not GameMenuButtonEditMode:IsEnabled() then
		GameMenuButtonEditMode:SetEnabled(true)
	end

	if editModeEnum and C_Widget.IsWidget(EditModeManagerFrame) and tContains(Enum.EditModeAccountSetting, editModeEnum) and EditModeManagerFrame:GetAccountSettingValueBool(editModeEnum) then return true, false end
	-- DEBUG EDITMODE
	if false and onceDebug then
		onceDebug = false
		for i, v in pairs(Enum.EditModeAccountSetting) do
			if string.find(strlower(i), "arena") then
				MoveAny:ERR("ENUM i: " .. tostring(i) .. " v: " .. tostring(v))
			end
		end
	end

	return false, false
end

local lastSelected = nil
function MoveAny:GetLastSelected()
	return lastSelected
end

local function AddCategory(key, layer, hud, noTranslate)
	if layer == nil then
		layer = 1
	end

	if cas[key] == nil then
		cas[key] = CreateFrame("Frame", key .. "_Category", MALock.SC)
		local ca = cas[key]
		ca:SetSize(24, 24)
		ca.f = ca:CreateFontString(nil, nil, "GameFontNormal")
		ca.f:SetPoint("LEFT", ca, "LEFT", 0, 0)
		if noTranslate == nil or noTranslate == false then
			if hud then
				ca.f:SetText(MoveAny:Trans("LID_" .. key) .. " (" .. MoveAny:Trans("LID_MOVEANYINFO") .. ")")
			else
				ca.f:SetText(MoveAny:Trans("LID_" .. key))
			end
		else
			ca.f:SetText(key)
		end
	end

	cas[key]:ClearAllPoints()
	if strfind(strlower(key), strlower(searchStr)) or strfind(strlower(MoveAny:Trans("LID_" .. key)), strlower(searchStr)) then
		cas[key]:Show()
		if posy < -4 then
			posy = posy - 10
		end

		cas[key]:SetPoint("TOPLEFT", MALock.SC, "TOPLEFT", 6 + (layer - 1) * 20, posy)
		posy = posy - 24
	else
		cas[key]:Hide()
	end
end

local function AddCheckBox(x, key, val, func, id, editModeEnum, showReload, requiresFor, requiredFor)
	local lkey = key
	if id then
		key = key .. id
	end

	local oldVal = MoveAny:IsEnabled(key, val, true) or false
	local bRequiresFor = nil
	if requiresFor ~= nil then
		bRequiresFor = MoveAny:IsEnabled(requiresFor)
	end

	local bRequiredFor = nil
	if requiredFor ~= nil then
		bRequiredFor = MoveAny:IsEnabled(requiredFor)
	end

	local bShowReload = showReload
	local bGreyed = false
	if bShowReload == nil then
		bShowReload = true
	end

	if oldVal == nil then
		MoveAny:ERR("Missing Value For: " .. tostring(key))
		oldVal = true
	end

	if cbs[key] == nil then
		cbs[key] = MoveAny:CreateCheckButton(key .. "_CB", MALock.SC)
		local cb = cbs[key]
		cb:SetSize(24, 24)
		cb:SetChecked(oldVal)
		cb.func = func or nil
		cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
		cb.f:SetPoint("LEFT", cb, "RIGHT", 0, 0)
		function cb:UpdateText(checked)
			checked = checked or false
			local lstr = MoveAny:Trans("LID_" .. lkey)
			if id then
				lstr = format(lstr, id)
			end

			if string.find(lkey, "FRAMESKEY", 1, true) then
				local keybind = keybinds[MoveAny:MAGV("KEYBINDWINDOW", 1)]
				lstr = format(MoveAny:Trans("LID_" .. lkey), MoveAny:Trans("LID_" .. keybind))
			end

			local ele = MoveAny:GetSelectEleName("LID_" .. key)
			if ele and _G[ele .. "_MA_DRAG"] and MoveAny:GetCurrentEle() == _G[ele .. "_MA_DRAG"] then
				lstr = "|cFFFFFF00" .. lstr .. "|r"
				MoveAny:ResetSelectedText()
				lastSelected = cb
			end

			local enabled1, forced1 = MoveAny:IsInEditModeEnabled(key)
			local enabled2, forced2 = MoveAny:IsInEditModeEnabled(editModeEnum)
			if enabled1 or enabled2 then
				if forced1 or forced2 then
					lstr = lstr .. " |cFFFF0000" .. MoveAny:Trans("LID_CANBREAKBECAUSEOFEDITMODE")
				else
					lstr = lstr .. " |cFFFFFF00" .. MoveAny:Trans("LID_ISENABLEDINEDITMODE")
				end
			end

			lstr = "|cFFFFFFFF" .. lstr
			if bRequiresFor == false then
				lstr = lstr .. " (" .. format(MoveAny:Trans("LID_REQUIRESFOR"), MoveAny:Trans("LID_" .. requiresFor)) .. ")"
			end

			if bRequiredFor == true then
				lstr = lstr .. " (" .. format(MoveAny:Trans("LID_REQUIREDFOR"), MoveAny:Trans("LID_" .. requiredFor)) .. ")"
			end

			if bShowReload and checked ~= oldVal then
				cb.f:SetText(format("[%s] %s", MoveAny:Trans("LID_NEEDSARELOAD"), lstr))
			else
				cb.f:SetText(lstr)
			end
		end

		cb:SetScript(
			"OnClick",
			function(sel, btn)
				MoveAny:SetEnabled(key, sel:GetChecked())
				if sel.f then
					cb:UpdateText(sel:GetChecked())
				end

				if cb.func then
					cb:func(sel:GetChecked())
				end
			end
		)

		cb.btn = MoveAny:CreateButton("cb.btn", cb, true)
		cb.btn:SetSize(MALock.SC:GetWidth() - 24, 24)
		cb.btn:SetPoint("LEFT", cb, "RIGHT", 0, 0)
		cb.btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		cb.btn:SetScript(
			"OnClick",
			function(sel, btn)
				local ele = MoveAny:GetSelectEleName("LID_" .. key)
				if ele then
					local f = _G[ele]
					local df = _G[ele .. "_MA_DRAG"]
					if df then
						if btn == "LeftButton" then
							MoveAny:SelectEle(df)
							cb:UpdateText(cb:GetChecked())
						elseif btn == "RightButton" then
							if f then
								MoveAny:ToggleElementOptions(ele, f, df)
							end
						end
					end
				end
			end
		)

		if requiresFor ~= nil or requiredFor ~= nil then
			function cb:Think()
				if requiresFor ~= nil and cb.rf1 ~= bRequiresFor then
					bRequiresFor = MoveAny:IsEnabled(requiresFor)
					cb.rf1 = bRequiresFor
					cb:UpdateText(cb:GetChecked())
				end

				if requiredFor ~= nil and cb.rf2 ~= bRequiredFor then
					bRequiredFor = MoveAny:IsEnabled(requiredFor)
					cb.rf2 = bRequiredFor
					cb:UpdateText(cb:GetChecked())
				end

				if MoveAny:IsEnabled("MALOCK", false) then
					MoveAny:After(0.6, cb.Think, "cb.Think")
				else
					MoveAny:After(1.2, cb.Think, "cb.Think")
				end
			end

			cb:UpdateText(cb:GetChecked())
			cb:Think()
		end
	end

	cbs[key]:UpdateText(cbs[key]:GetChecked())
	cbs[key]:ClearAllPoints()
	if bGreyed then
		cbs[key]:SetEnabled(false)
	else
		cbs[key]:SetEnabled(true)
	end

	if strfind(strlower(key), strlower(searchStr)) or strfind(strlower(MoveAny:Trans("LID_" .. lkey)), strlower(searchStr)) then
		cbs[key]:Show()
		cbs[key]:SetPoint("TOPLEFT", MALock.SC, "TOPLEFT", x, posy)
		posy = posy - 24
	else
		cbs[key]:Hide()
	end
end

local function AddSlider(x, key, val, func, vmin, vmax, steps, tab)
	if sls[key] == nil and DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
		posy = posy - 10
		local name = "sls[" .. key .. "]"
		sls[key] = CreateFrame("Slider", name, MALock.SC, "UISliderTemplate")
		sls[key]:SetPoint("TOPLEFT", MALock.SC, "TOPLEFT", x + 5, posy)
		sls[key]:SetSize(MALock.SC:GetWidth() - 30 - x, 16)
		if sls[key].Low == nil then
			sls[key].Low = sls[key]:CreateFontString(nil, nil, "GameFontNormal")
			sls[key].Low:SetPoint("BOTTOMLEFT", sls[key], "BOTTOMLEFT", 0, -12)
			sls[key].Low:SetTextColor(1, 1, 1)
		end

		if sls[key].High == nil then
			sls[key].High = sls[key]:CreateFontString(nil, nil, "GameFontNormal")
			sls[key].High:SetPoint("BOTTOMRIGHT", sls[key], "BOTTOMRIGHT", 0, -12)
			sls[key].High:SetTextColor(1, 1, 1)
		end

		if sls[key].Text == nil then
			sls[key].Text = sls[key]:CreateFontString(nil, nil, "GameFontNormal")
			sls[key].Text:SetPoint("TOP", sls[key], "TOP", 0, 16)
			sls[key].Text:SetTextColor(1, 1, 1)
		end

		sls[key].Low:SetText(vmin)
		sls[key].High:SetText(vmax)
		if tab and tab[MoveAny:MAGV(key, val)] then
			sls[key].Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. MoveAny:Trans("LID_" .. tab[MoveAny:MAGV(key, val)]))
		else
			sls[key].Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. MoveAny:MAGV(key, val))
		end

		sls[key]:SetMinMaxValues(vmin, vmax)
		sls[key]:SetObeyStepOnDrag(true)
		sls[key]:SetValueStep(steps)
		sls[key]:SetValue(MoveAny:MAGV(key, val))
		sls[key]:SetScript(
			"OnValueChanged",
			function(sel, valu)
				valu = tonumber(string.format("%" .. steps .. "f", valu))
				if valu and valu ~= MoveAny:MAGV(key) then
					MoveAny:SV(MATAB, key, valu)
					if tab and tab[valu] then
						sls[key].Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. MoveAny:Trans("LID_" .. tab[valu]))
					else
						sls[key].Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. valu)
					end

					if func then
						func(valu)
					end
				end
			end
		)

		MoveAny:SetFontSize(sls[key].Low, 10, "THINOUTLINE")
		MoveAny:SetFontSize(sls[key].High, 10, "THINOUTLINE")
		MoveAny:SetFontSize(sls[key].Text, 12, "THINOUTLINE")
		posy = posy - 10
	end

	if sls[key] then
		sls[key]:ClearAllPoints()
		if strfind(strlower(key), strlower(searchStr)) or strfind(strlower(MoveAny:Trans("LID_" .. key)), strlower(searchStr)) then
			sls[key]:Show()
			posy = posy - 10
			sls[key]:SetPoint("TOPLEFT", MALock.SC, "TOPLEFT", x, posy)
			posy = posy - 30
		else
			sls[key]:Hide()
		end
	end
end

local needReload = false
local est = {}
function MoveAny:EnableSave(from, key, val, oldVal, ignoreReload)
	ignoreReload = ignoreReload or false
	if MALock == nil then return end
	if not MALock:IsVisible() then return end
	if not ignoreReload then
		if est[key] == nil then
			est[key] = oldVal
		elseif est[key] == val then
			est[key] = nil
		end

		local c = 0
		for i, v in pairs(est) do
			if v ~= nil then
				c = c + 1
			end
		end

		if c ~= 0 then
			needReload = true
			if MALock.save then
				MALock.save:Enable()
			end

			if MALock.CloseButton then
				MALock.CloseButton:Disable()
			end
		else
			needReload = false
			if MALock.save then
				MALock.save:Disable()
			end

			if MALock.CloseButton then
				MALock.CloseButton:Enable()
			end
		end
	else
		if MALock.save then
			MALock.save:Enable()
		end
	end
end

function MoveAny:IsFrameKeyDown()
	local keybind = MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")
	if keybind == "SHIFT" then
		return IsShiftKeyDown()
	elseif keybind == "CTRL" then
		return IsControlKeyDown()
	elseif keybind == "ALT" then
		return IsAltKeyDown()
	end

	return false
end

local find = false
function MoveAny:SetFinder(val)
	find = val
end

function MoveAny:GetFinder()
	return find
end

function MoveAny:GetAllParents(hoverFrame)
	local parents = {}
	local currentFrame = hoverFrame
	if currentFrame and MoveAny:GetName(currentFrame) ~= "Moveany_hover" then
		table.insert(parents, currentFrame)
		while currentFrame and currentFrame:GetParent() and currentFrame:GetParent() ~= UIParent and currentFrame:GetParent() ~= MoveAny:GetMainPanel() and MoveAny:GetName(currentFrame:GetParent()) ~= "Moveany_hover" do
			currentFrame = currentFrame:GetParent()
			table.insert(parents, currentFrame)
		end
	end

	return parents
end

function MoveAny:InitMALock()
	sh = MoveAny:MClamp(640, 200, GetScreenHeight())
	MALock = CreateFrame("Frame", "MALock", MoveAny:GetMainPanel(), "BasicFrameTemplate")
	MALock:SetSize(sw, sh)
	MALock:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
	MALock:SetFrameStrata("HIGH")
	MALock:SetFrameLevel(999)
	if MALock.CloseButton then
		MALock.CloseButton:SetFrameLevel(1000)
	end

	MoveAny:SetClampedToScreen(MALock, true)
	MALock:SetMovable(true)
	MALock:EnableMouse(true)
	MALock:RegisterForDrag("LeftButton")
	MALock:SetScript("OnDragStart", MALock.StartMoving)
	MALock:SetScript(
		"OnDragStop",
		function()
			MALock:StopMovingOrSizing()
			local p1, _, p3, p4, p5 = MALock:GetPoint()
			p4 = MoveAny:Snap(p4)
			p5 = MoveAny:Snap(p5)
			MoveAny:SetElePoint("MALock", p1, _, p3, p4, p5)
		end
	)

	MALock:SetResizable(true)
	MoveAny:After(
		0,
		function()
			MALock:SetResizeBounds(sw, 200, sw + 200, GetScreenHeight())
			if MALock:GetHeight() > GetScreenHeight() then
				MALock:SetHeight(GetScreenHeight())
			end
		end, "InitMALock"
	)

	local rb = MoveAny:CreateButton(nil, MALock, true)
	rb:EnableMouse("true")
	rb:SetPoint("BOTTOMRIGHT")
	rb:SetSize(32, 32)
	rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	rb:SetScript(
		"OnMouseDown",
		function(sel)
			MoveAny:GetParent(sel):StartSizing("BOTTOMRIGHT")
		end
	)

	rb:SetScript(
		"OnMouseUp",
		function(sel)
			MoveAny:GetParent(sel):StopMovingOrSizing("BOTTOMRIGHT")
		end
	)

	MoveAny:SetVersion(135994, "1.8.227")
	MALock.TitleText:SetText(format("|T135994:16:16:0:0|t M|cff3FC7EBove|rA|cff3FC7EBny|r v|cff3FC7EB%s", MoveAny:GetVersion()))
	MALock.CloseButton:SetScript(
		"OnClick",
		function()
			MoveAny:ToggleMALock()
			if needReload then
				if C_UI then
					C_UI.Reload()
				else
					ReloadUI()
				end
			end
		end
	)

	function MoveAny:UpdateFrameKeybindText()
		cbs["FRAMESKEYDRAG"]:UpdateText(cbs["FRAMESKEYDRAG"]:GetChecked())
		cbs["FRAMESKEYSCALE"]:UpdateText(cbs["FRAMESKEYSCALE"]:GetChecked())
		cbs["FRAMESKEYRESET"]:UpdateText(cbs["FRAMESKEYRESET"]:GetChecked())
	end

	function MoveAny:UpdateFrameKeybind()
		local keybind = keybinds[MoveAny:MAGV("KEYBINDWINDOW", 1)]
		MoveAny:MASV("KEYBINDWINDOWKEY", keybind)
		MoveAny:UpdateFrameKeybindText()
	end

	function MoveAny:UpdateElementList()
		local _, class = UnitClass("player")
		posy = -4
		AddCategory("GENERAL")
		AddCheckBox(4, "SHOWTIPS", true)
		AddCheckBox(
			4,
			"SHOWMINIMAPBUTTON",
			MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC",
			function(sel, value)
				if value then
					MoveAny:ShowMMBtn("MoveAny")
				else
					MoveAny:HideMMBtn("MoveAny")
				end
			end, nil, nil, false
		)

		AddCheckBox(4, "HIDEHIDDENFRAMES", false, MoveAny.UpdateHiddenFrames, nil, nil, false)
		AddSlider(8, "SNAPSIZE", 5, nil, 1, 50, 1)
		AddSlider(8, "GRIDSIZE", 10, MoveAny.UpdateGrid, 1, 100, 1)
		AddCategory("FRAMES")
		AddCheckBox(4, "MOVEFRAMES", true)
		AddCheckBox(24, "CLAMPWINDOWTOSCREEN", true)
		AddCheckBox(24, "MOVESMALLBAGS", false)
		AddCheckBox(24, "MOVELOOTFRAME", false)
		AddCheckBox(24, "SCALELOOTFRAME", false)
		AddSlider(26, "KEYBINDWINDOW", 1, MoveAny.UpdateFrameKeybind, 1, 3, 1, keybinds)
		AddCategory("MOVEFRAMES", 2)
		AddCheckBox(24, "SAVEFRAMEPOSITION", true)
		AddCheckBox(24, "FRAMESKEYDRAG", false)
		AddSlider(40, "SNAPWINDOWSIZE", 1, nil, 1, 50, 1)
		AddCategory("SCALEFRAMES", 2)
		AddCheckBox(24, "SCALEFRAMES", true)
		AddCheckBox(36, "SAVEFRAMESCALE", true)
		AddCheckBox(36, "FRAMESKEYSCALE", false)
		AddCategory("RESETFRAMES", 2)
		AddCheckBox(24, "FRAMESKEYRESET", false)
		MoveAny:UpdateFrameKeybindText()
		AddCategory("BUILTIN", 1, true)
		local posx = 4
		AddCheckBox(posx, "PLAYERFRAME", false)
		AddCheckBox(posx, "TARGETFRAME", false, nil, nil, "ShowTargetAndFocus", nil, nil, "TARGETFRAMESPELLBAR")
		AddCheckBox(posx, "TARGETFRAMEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
		AddCheckBox(posx, "TARGETFRAMEDEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
		if TargetFrameToT then
			AddCheckBox(posx, "TARGETFRAMETOTBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
			AddCheckBox(posx, "TARGETFRAMETOTDEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
		end

		if FocusFrame then
			AddCheckBox(posx, "FOCUSFRAME", false, nil, nil, "ShowTargetAndFocus")
			AddCheckBox(posx, "FOCUSFRAMEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
			AddCheckBox(posx, "FOCUSFRAMEDEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
			if FocusFrameToT then
				AddCheckBox(posx, "FOCUSFRAMETOTBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
				AddCheckBox(posx, "FOCUSFRAMETOTDEBUFFMOVER", false, nil, nil, "ShowTargetAndFocus")
			end
		end

		AddCheckBox(posx, "BUFFS", false, nil, nil, "ShowBuffFrame")
		AddCheckBox(posx, "DEBUFFS", false, nil, nil, "ShowDebuffFrame")
		AddCheckBox(posx, "GAMETOOLTIP", false, nil, nil, "ShowHudTooltip")
		AddCheckBox(posx, "PETBAR", false, nil, nil, "ShowPetActionBar")
		AddCheckBox(posx, "STANCEBARANCHOR", false, nil, nil, "ShowStanceBar")
		if PossessActionBar or getglobal("PossessBarFrame") then
			AddCheckBox(posx, "POSSESSBAR", false, nil, nil, "ShowPossessActionBar")
		end

		AddCheckBox(posx, "LEAVEVEHICLE", false, nil, nil, "ShowVehicleLeaveButton")
		if ExtraAbilityContainer then
			AddCheckBox(posx, "EXTRAABILITYCONTAINER", false, nil, nil, "ShowExtraAbilities")
		elseif ExtraActionBarFrame then
			AddCheckBox(posx, "ExtraActionBarFrame", true, nil, nil, "ShowExtraAbilities")
		elseif ExtraActionButton1 then
			AddCheckBox(posx, "ExtraActionButton1", true, nil, nil, "ShowExtraAbilities")
		end

		AddCheckBox(posx, "CASTINGBAR", false, nil, nil, "ShowCastBar")
		if PlayerCastingBarFrame then
			AddCheckBox(posx, "CASTINGBARTIMER", false, nil, nil, "ShowCastBar")
		end

		if TalkingHeadFrame then
			AddCheckBox(posx, "TALKINGHEAD", false, nil, nil, "ShowTalkingHeadFrame")
		end

		if OverrideActionBar then
			AddCheckBox(posx, "OVERRIDEACTIONBAR", false)
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
			AddCheckBox(posx, "ACTIONBARS", false)
			AddCheckBox(4, "ACTIONBAR3", false)
			AddCheckBox(4, "ACTIONBAR4", false)
			AddCheckBox(4, "ACTIONBAR7", false)
			AddCheckBox(4, "ACTIONBAR8", false)
			AddCheckBox(4, "ACTIONBAR9", false)
			AddCheckBox(4, "ACTIONBAR10", false)
		else
			for i = 1, 8 do
				AddCheckBox(posx, "ACTIONBAR" .. i, false)
			end
		end

		if getglobal("ActionBarUpButton") and getglobal("ActionBarDownButton") then
			AddCheckBox(4, "MAPAGES", false)
		end

		for i = 1, 10 do
			if _G["ChatFrame" .. i] and _G["ChatFrame" .. i .. "Tab"] and MoveAny:GetParent(_G["ChatFrame" .. i .. "Tab"]) ~= GeneralDockManager or i == 1 then
				AddCheckBox(posx, "CHAT", false, nil, i)
			end
		end

		AddCheckBox(posx, "MINIMAP", false)
		AddCheckBox(posx, "QUESTTRACKER", false)
		AddCheckBox(posx, "QUESTITEMSANCHOR", false)
		if getglobal("QuestTimerFrame") then
			AddCheckBox(posx, "QUESTTIMERFRAME", false)
		end

		AddCheckBox(posx, "MAPETFRAME", false)
		local PetFrameHappiness = getglobal("PetFrameHappiness")
		if PetFrameHappiness then
			AddCheckBox(posx, "PETFRAMEHAPPINESS", false)
		end

		if PartyFrame or getglobal("PartyMemberFrame1") then
			AddCheckBox(posx, "PARTYFRAME", false, nil, nil, "ShowPartyFrames")
		end

		if CompactRaidFrameContainer then
			AddCheckBox(posx, "COMPACTRAIDFRAMECONTAINER", false, nil, nil, "ShowRaidFrames")
		end

		if BossTargetFrameContainer or Boss1TargetFrame then
			AddCheckBox(posx, "BOSSTARGETFRAMECONTAINER", false, nil, nil, "ShowBossFrames")
		end

		if MainStatusTrackingBarContainer then
			AddCheckBox(posx, "MainStatusTrackingBarContainer", false)
		end

		if SecondaryStatusTrackingBarContainer then
			AddCheckBox(posx, "SecondaryStatusTrackingBarContainer", false)
		end

		if MainStatusTrackingBarContainer == nil and SecondaryStatusTrackingBarContainer == nil and StatusTrackingBarManager then
			AddCheckBox(posx, "STATUSTRACKINGBARMANAGER", false)
		end

		if VehicleSeatIndicator then
			AddCheckBox(posx, "VEHICLESEATINDICATOR", false)
		end

		AddCategory("NORMAL", 1, true)
		if TargetFrameToT then
			AddCheckBox(4, "TARGETOFTARGETFRAME", false)
		end

		if FocusFrameToT then
			AddCheckBox(4, "TARGETOFFOCUSFRAME", false)
		end

		AddCheckBox(4, "ZONETEXTFRAME", false)
		if ObjectiveTrackerBonusBannerFrame then
			AddCheckBox(4, "OBJECTIVETRACKERBONUSBANNERFRAME", false)
		end

		if RaidBossEmoteFrame then
			AddCheckBox(4, "RAIDBOSSEMOTEFRAME", false)
		end

		AddCheckBox(4, "DURABILITY", false)
		AddCheckBox(4, "MICROMENU", false)
		AddCheckBox(4, "BAGS", false)
		if MoveAny:IsValidFrame(QueueStatusButton) then
			AddCheckBox(4, "QUEUESTATUSBUTTON", false)
		end

		if MoveAny:IsValidFrame(QueueStatusFrame) then
			AddCheckBox(4, "QUEUESTATUSFRAME", false)
		end

		local MainMenuExpBar = getglobal("MainMenuExpBar")
		if MoveAny:IsValidFrame(MainMenuExpBar) then
			AddCheckBox(4, "MAINMENUEXPBAR", false)
			AddCheckBox(4, "REPUTATIONWATCHBAR", false)
		end

		AddCheckBox(4, "MAFPSFrame", false)
		if MoveAny:IsValidFrame(ZoneAbilityFrame) then
			AddCheckBox(4, "ZONEABILITYFRAME", false)
		end

		if MoveAny:IsValidFrame(EncounterBar) then
			AddCheckBox(4, "ENCOUNTERBAR", false, nil, nil, "ShowEncounterBar")
		elseif MoveAny:IsValidFrame(UIWidgetPowerBarContainerFrame) then
			AddCheckBox(4, "UIWIDGETPOWERBAR", false)
		end

		if MoveAny:IsValidFrame(PlayerPowerBarAlt) or MoveAny:IsValidFrame(PlayerPowerBarAltCounterBar) or MoveAny:IsValidFrame(BuffTimer1) then
			AddCheckBox(4, "POWERBAR", false)
		end

		--AddCheckBox( 4, "BUFFTIMER1", true )
		if MoveAny:IsValidFrame(ArcheologyDigsiteProgressBar) then
			AddCheckBox(4, "ARCHEOLOGYDIGSITEPROGRESSBAR", false)
		end

		AddCheckBox(4, "UIERRORSFRAME", false)
		if MoveAny:IsValidFrame(QuickJoinToastButton) then
			AddCheckBox(4, "CHATQUICKJOIN", false)
		end

		if MoveAny:IsValidFrame(SpellActivationOverlayFrame) then
			AddCheckBox(4, "SPELLACTIVATIONOVERLAYFRAME", false)
		end

		if MoveAny:IsValidFrame(LossOfControlFrame) then
			AddCheckBox(4, "LOSSOFCONTROLFRAME", false)
		end

		if MoveAny:IsValidFrame(GhostFrame) then
			AddCheckBox(4, "GHOSTFRAME", false)
		end

		AddCategory("CLASSSPECIFIC", 1, true)
		if MoveAny:IsValidFrame(RuneFrame) and class == "DEATHKNIGHT" then
			AddCheckBox(4, "RUNEFRAME", false)
		end

		if (MoveAny:GetWoWBuild() == "WRATH" or MoveAny:GetWoWBuild() == "CATA") and class == "SHAMAN" then
			AddCheckBox(4, "TOTEMBAR", false)
		end

		if MoveAny:IsValidFrame(WarlockPowerFrame) and class == "WARLOCK" then
			AddCheckBox(4, "WARLOCKPOWERFRAME", false)
		end

		-- CATA
		if MoveAny:IsValidFrame(ShardBarFrame) and class == "WARLOCK" then
			AddCheckBox(4, "SHARDBARFRAME", false)
		end

		if (MoveAny:IsValidFrame(MonkHarmonyBar) or MoveAny:IsValidFrame(MonkHarmonyBarFrame)) and class == "MONK" then
			AddCheckBox(4, "MONKHARMONYBARFRAME", false)
		end

		if MoveAny:IsValidFrame(MonkStaggerBar) and class == "MONK" then
			AddCheckBox(4, "MONKSTAGGERBAR", false)
		end

		if MoveAny:IsValidFrame(MageArcaneChargesFrame) and class == "MAGE" then
			AddCheckBox(4, "MAGEARCANECHARGESFRAME", false)
		end

		if MoveAny:IsValidFrame(PriestBarFrame) and class == "PRIEST" then
			AddCheckBox(4, "PRIESTBARFRAME", false)
		end

		if (MoveAny:IsValidFrame(RogueComboPointBarFrame) or MoveAny:IsValidFrame(DruidComboPointBarFrame)) and (class == "ROGUE" or class == "DRUID") then
			AddCheckBox(4, "COMBOPOINTPLAYERFRAME", false)
		elseif ComboFrame then
			AddCheckBox(posx, "COMBOFRAME", false)
		end

		if class == "DRUID" and MoveAny:IsValidFrame(EclipseBarFrame) then
			AddCheckBox(4, "EclipseBarFrame", false)
		end

		if MoveAny:IsValidFrame(EssencePlayerFrame) and class == "EVOKER" then
			AddCheckBox(4, "ESSENCEPLAYERFRAME", false)
		end

		if MoveAny:IsValidFrame(PaladinPowerBarFrame) and class == "PALADIN" then
			AddCheckBox(4, "PALADINPOWERBARFRAME", false)
		end

		-- CATA
		if MoveAny:IsValidFrame(PaladinPowerBar) and class == "PALADIN" then
			AddCheckBox(4, "PALADINPOWERBAR", false)
		end

		AddCategory("ADVANCED", 1, true)
		if SuperTrackedFrame then
			AddSlider(
				8,
				"SUPERTRACKEDFRAME",
				1,
				function(val)
					SuperTrackedFrame:SetScale(val)
				end, 0.1, 4.0, 0.1
			)

			if MoveAny:GV(MATAB, "SUPERTRACKEDFRAME", 1.0) > 0 and MoveAny:GV(MATAB, "SUPERTRACKEDFRAME", 1.0) ~= 1 then
				SuperTrackedFrame:SetScale(MoveAny:GV(MATAB, "SUPERTRACKEDFRAME", 1.0))
			end
		end

		if MoveAny:IsValidFrame(EssentialCooldownViewer) then
			AddCheckBox(4, "EssentialCooldownViewer", false)
		end

		if MoveAny:IsValidFrame(BuffIconCooldownViewer) then
			AddCheckBox(4, "BuffIconCooldownViewer", false)
		end

		if MoveAny:IsValidFrame(BuffBarCooldownViewer) then
			AddCheckBox(4, "BuffBarCooldownViewer", false)
		end

		if MoveAny:IsValidFrame(UtilityCooldownViewer) then
			AddCheckBox(4, "UtilityCooldownViewer", false)
		end

		AddCheckBox(4, "MINIMAPFLAG", false)
		if MiniMapLFGFrame then
			AddCheckBox(4, "MINIMAPLFGFRAME", false)
		end

		if LFGMinimapFrame then
			AddCheckBox(4, "LFGMINIMAPFRAME", false)
		end

		AddCheckBox(4, "ExpansionLandingPageMinimapButton", false)
		if MoveAny:IsValidFrame(TotemFrame) then
			AddCheckBox(4, "TOTEMFRAME", false)
		end

		if MoveAny:IsValidFrame(MinimapZoneTextButton) then
			AddCheckBox(4, "MINIMAPZONETEXT", false)
		end

		if PlayerLevelText then
			AddCheckBox(4, "PLAYERLEVELTEXT", false)
		end

		AddCheckBox(4, "ENDCAPS", false)
		if MainMenuBarTexture0 then
			AddCheckBox(4, "BLIZZARDACTIONBUTTONSART", false)
		end

		AddCheckBox(24, "TARGETFRAMESPELLBAR", false, nil, nil, nil, nil, "TARGETFRAME")
		if MoveAny:IsValidFrame(FocusFrame) then
			AddCheckBox(24, "FOCUSFRAMESPELLBAR", false, nil, nil, nil, nil, "FOCUSFRAME")
		end

		AddCheckBox(4, "UIWIDGETTOPCENTER", false)
		AddCheckBox(4, "UIWIDGETBELOWMINIMAP", false)
		AddCheckBox(4, "MIRRORTIMER1", false)
		if TimerTracker then
			AddCheckBox(4, "TIMERTRACKER1", false)
		end

		if ArenaEnemyFramesContainer then
			AddCheckBox(4, "ARENAENEMYFRAMESCONTAINER", false)
		else
			if Arena_LoadUI then
				AddCheckBox(4, "ARENAENEMYFRAMES", false)
				AddCheckBox(4, "ARENAPREPFRAMES", false)
			end
		end

		if MoveAny:IsValidFrame(CompactArenaFrame) then
			AddCheckBox(4, "COMPACTARENAFRAME", false)
		end

		if MoveAny:IsValidFrame(BattlefieldMapFrame) then
			AddCheckBox(4, "BATTLEFIELDMAPFRAME", false)
		end

		if RolePollPopup then
			AddCheckBox(4, "ROLEPOLLPOPUP", false)
		end

		if ReadyCheckListenerFrame then
			AddCheckBox(4, "READYCHECKLISTENERFRAME", false)
		end

		AddCheckBox(4, "GAMETOOLTIP_ONCURSOR", false)
		AddCheckBox(4, "GAMETOOLTIP_ONCURSOR_NOTINCOMBAT", false)
		if BossBanner then
			AddCheckBox(4, "BOSSBANNER", false)
		end

		if GroupLootContainer then
			AddCheckBox(4, "GROUPLOOTCONTAINER", false)
		else
			AddCheckBox(4, "GROUPLOOTFRAME1", false)
		end

		if BonusRollFrame then
			AddCheckBox(4, "BONUSROLLFRAME", false)
		end

		AddCheckBox(4, "ALERTFRAME", false)
		for i = 1, 10 do
			if _G["ChatFrame" .. i] and _G["ChatFrame" .. i .. "Tab"] and _G["ChatFrame" .. i .. "ButtonFrame"] ~= nil then
				AddCheckBox(4, "CHATBUTTONFRAME" .. i, false)
			end
		end

		AddCheckBox(4, "CHATEDITBOX", false, nil, "")
		AddCheckBox(4, "CHATTAB", false, nil, "")
		if BNToastFrame then
			AddCheckBox(4, "BNToastFrame", false)
		end

		AddCheckBox(4, "EventToastManagerFrame", false)
		AddCheckBox(4, "COMPACTRAIDFRAMEMANAGER", false)
		if TicketStatusFrame then
			AddCheckBox(4, "TICKETSTATUSFRAME", false)
		end

		if TargetFrame and TargetFrameNumericalThreat then
			AddCheckBox(4, "TargetFrameNumericalThreat", false)
		end

		if PlayerFrameBackground then
			AddCheckBox(4, "PLAYERFRAMEBACKGROUND", false)
		end

		if TargetFrameNameBackground then
			AddCheckBox(4, "TARGETFRAMENAMEBACKGROUND", false)
		end

		if MoveAny:IsAddOnLoaded("ImproveAny", 1, true) then
			AddCategory("ImproveAny", nil, nil, true)
			if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
				AddCheckBox(4, "IASKILLS", true)
			end

			AddCheckBox(4, "MONEYBAR", true)
			AddCheckBox(4, "TOKENBAR", true)
			AddCheckBox(4, "IAILVLBAR", true)
			AddCheckBox(4, "IAPingFrame", true)
			AddCheckBox(4, "IACoordsFrame", true)
		end

		if MoveAny:IsAddOnLoaded("!KalielsTracker") then
			AddCategory("!KalielsTracker", 1, true)
			AddCheckBox(4, "!KalielsTrackerButtons", false)
		end

		AddCheckBox(4, "DISABLEMOVEMENT", false)
	end

	MALock.Pipette = MoveAny:CreateButton("MALock_Pipette", MALock)
	MALock.Pipette:SetSize(24, 24)
	MALock.Pipette:SetText("")
	MALock.Pipette.texture = MALock.Pipette:CreateTexture()
	MALock.Pipette.texture:SetTexture("Interface\\Addons\\MoveAny\\media\\pipette")
	MALock.Pipette.texture:SetSize(12, 12)
	MALock.Pipette.texture:SetPoint("CENTER", MALock.Pipette, "CENTER", 0, 0)
	MALock.Pipette:SetScript(
		"OnClick",
		function()
			if MoveAny.Lock then
				MoveAny:Lock()
			end

			if MoveAny.HideMALock then
				MoveAny:HideMALock()
			end

			MoveAny:SetFinder(true)
			MoveAny:HoverLogic()
			MoveAny:FinderThink()
		end
	)

	MALock.Search = CreateFrame("EditBox", "MALock_Search", MALock, "InputBoxTemplate")
	MALock.Search:SetAutoFocus(false)
	MALock.Search.f = MALock.Search:CreateFontString(nil, nil, "GameFontNormal")
	MALock.Search.f:SetText(MoveAny:Trans("LID_SEARCH") .. ":")
	local searchLen = MALock.Search.f:GetStringWidth() + 10
	MALock.Pipette:SetPoint("TOPLEFT", MALock, "TOPLEFT", br, -26)
	MALock.Search:SetPoint("TOPLEFT", MALock, "TOPLEFT", 12 + searchLen + br + 24 + br, -26)
	MALock.Search:SetPoint("TOPRIGHT", MALock, "TOPRIGHT", -br - 100 - br, 20)
	MALock.Search:SetSize(sw - 2 * br - br - 100 - searchLen, 24)
	MALock.Search.f:SetPoint("RIGHT", MALock.Search, "LEFT", -10, 0)
	MALock.Search:SetScript(
		"OnTextChanged",
		function(sel, ...)
			searchStr = MALock.Search:GetText()
			MoveAny:UpdateElementList()
		end
	)

	MALock.Profiles = MoveAny:CreateButton("MALock_Profiles", MALock)
	MALock.Profiles:SetPoint("TOPRIGHT", MALock, "TOPRIGHT", -br, -26)
	MALock.Profiles:SetSize(100, 24)
	MALock.Profiles:SetText(MoveAny:Trans("LID_PROFILES"))
	MALock.Profiles:SetScript(
		"OnClick",
		function()
			if MoveAny.Lock then
				MoveAny:Lock()
			end

			if MoveAny.HideMALock then
				MoveAny:HideMALock()
			end

			MoveAny:SetEnabled("MAPROFILES", true)
			MoveAny:ShowProfiles()
		end
	)

	MALock.Profiles:SetResizable(true)
	MoveAny:After(
		0,
		function()
			MALock.Profiles:SetResizeBounds(sw, 200, sw + 200, GetScreenHeight())
			if MALock.Profiles:GetHeight() > GetScreenHeight() then
				MALock.Profiles:SetHeight(GetScreenHeight())
			end
		end, "InitMALock 2"
	)

	MALock.SF = CreateFrame("ScrollFrame", "MALock_SF", MALock, "UIPanelScrollFrameTemplate")
	MALock.SF:SetPoint("TOPLEFT", MALock, br, -30 - 24)
	MALock.SF:SetPoint("BOTTOMRIGHT", MALock, -32, 24 + br)
	MALock.SC = CreateFrame("Frame", "MALock_SC", MALock.SF)
	MALock.SC:SetSize(400, 400)
	MALock.SC:SetPoint("TOPLEFT", MALock.SF, "TOPLEFT", 0, 0)
	MALock.SF:SetScrollChild(MALock.SC)
	MALock.SF.bg = MALock.SF:CreateTexture("MALock.SF.bg", "ARTWORK")
	MALock.SF.bg:SetAllPoints(MALock.SF)
	MALock.SF.bg:SetColorTexture(0.03, 0.03, 0.03, 0.5)
	MALock.save = MoveAny:CreateButton("MALock" .. ".save", MALock)
	MALock.save:SetSize(120, 24)
	MALock.save:SetPoint("BOTTOMLEFT", MALock, "BOTTOMLEFT", 4, 4)
	MALock.save:SetText(SAVE)
	MALock.save:SetScript(
		"OnClick",
		function()
			MoveAny:TrySaveEditMode()
			if MALock.save then
				MALock.save:Disable()
			end

			if MALock.CloseButton then
				MALock.CloseButton:Enable()
			end
		end
	)

	MALock.save:Disable()
	MALock.reload = MoveAny:CreateButton("MALock" .. ".reload", MALock)
	MALock.reload:SetSize(120, 24)
	MALock.reload:SetPoint("BOTTOMLEFT", MALock, "BOTTOMLEFT", 4 + 120 + 4, 4)
	MALock.reload:SetText(RELOADUI or "RELOADUI")
	MALock.reload:SetScript(
		"OnClick",
		function()
			if C_UI then
				C_UI.Reload()
			else
				ReloadUI()
			end
		end
	)

	MALock.DISCORD = CreateFrame("EditBox", "MALock" .. ".DISCORD", MALock, "InputBoxTemplate")
	MALock.DISCORD:SetText("discord.gg/qxpK6PKYAD")
	MALock.DISCORD:SetSize(160, 24)
	MALock.DISCORD:SetPoint("BOTTOMRIGHT", MALock, "BOTTOMRIGHT", -4 - 20, 4)
	MALock.DISCORD:SetAutoFocus(false)
	local finder = CreateFrame("Frame", "MoveAny_finder", UIParent)
	local hovers = {}
	for i = 1, 6 do
		local hover = CreateFrame("Frame", "Moveany_hover" .. i, UIParent)
		hover:EnableMouse(false)
		hover:SetFrameLevel(2000)
		hover.f = hover:CreateTexture("Moveany_hover" .. i .. "_f", "OVERLAY")
		hover.f:SetAllPoints(hover)
		hover.f:SetColorTexture(1, 1, 1, 0.3)
		hover.t = hover:CreateFontString("Moveany_hover" .. i .. "_t", nil, "GameFontNormal")
		hover.t:SetPoint("CENTER", hover, "CENTER", 0, 0)
		MoveAny:SetFontSize(hover.t, 16, "THINOUTLINE")
		if i == 1 then
			hover.t2 = hover:CreateFontString("Moveany_hover" .. i .. "_t2", nil, "GameFontNormal")
			hover.t2:SetPoint("CENTER", hover, "CENTER", 0, -20)
			MoveAny:SetFontSize(hover.t2, 14, "THINOUTLINE")
			hover.t2:SetText(MoveAny:Trans("LID_PRESSESCTOLEAVE"))
		end

		hovers[i] = hover
	end

	local hoverFrames = nil
	local finding = false
	function MoveAny:HoverLogic()
		if MoveAny:GetFinder() then
			hoverFrames = MoveAny:GetAllParents(MoveAny:GetMouseFocus())
			if finder:GetScript("OnKeyDown") == nil then
				if not InCombatLockdown() then
					finder:SetPropagateKeyboardInput(true)
				end

				finder:SetScript(
					"OnKeyDown",
					function(sel, key, ...)
						if key == "ESCAPE" then
							MoveAny:SetFinder(false)
							MoveAny:Unlock()
							MoveAny:ShowMALock()
							if hovers[1].t:GetText() then
								MALock.Search:SetText(hovers[1].t:GetText())
							end

							finder:SetScript("OnKeyDown", nil)
						end
					end
				)
			end

			MoveAny:After(
				0.3,
				function()
					MoveAny:HoverLogic()
				end, "HoverLogic FINDER FOUND"
			)
		end
	end

	function MoveAny:FinderThink()
		if MoveAny:GetFinder() then
			finding = true
			if hoverFrames then
				for i = 1, 10 do
					if hovers[i] then
						hovers[i]:Hide()
					end
				end

				for i, hoverFrame in pairs(hoverFrames) do
					if hovers[i] and hoverFrame then
						hovers[i]:Show()
						hovers[i]:SetSize(hoverFrame:GetSize())
						hovers[i]:ClearAllPoints()
						hovers[i]:SetPoint(hoverFrame:GetPoint())
						hovers[i]:SetScale(hoverFrame:GetScale())
						hovers[i].t:SetText(MoveAny:GetName(hoverFrame))
					end
				end
			else
				for i = 1, 10 do
					if hovers[i] then
						hovers[i]:Hide()
					end
				end
			end

			if InCombatLockdown() then
				MoveAny:After(0.4, MoveAny.FinderThink, "FinderThink Visible Combat")
			else
				MoveAny:After(0.3, MoveAny.FinderThink, "FinderThink Visible")
			end
		elseif finding then
			finding = false
			for i = 1, 10 do
				if hovers[i] then
					hovers[i]:Hide()
				end
			end

			if InCombatLockdown() then
				MoveAny:After(0.6, MoveAny.FinderThink, "FinderThink Hidden Combat")
			else
				MoveAny:After(0.4, MoveAny.FinderThink, "FinderThink Hidden")
			end
		end
	end

	MoveAny:After(
		0.1,
		function()
			MAGridFrame = CreateFrame("Frame", "MAGridFrame", MoveAny:GetMainPanel())
			function MoveAny:GridFrameThink()
				if getglobal("MACurrentEle") then
					MAGridFrame:EnableMouse(true)
				else
					MAGridFrame:EnableMouse(false)
				end
			end

			MAGridFrame:HookScript(
				"OnMouseDown",
				function(sel, btn)
					if MoveAny:IsEnabled("MOVEFRAMES", true) and btn == "LeftButton" then
						MoveAny:ClearSelectEle()
					end
				end
			)

			MAGridFrame:SetSize(GetScreenWidth(), GetScreenHeight())
			MAGridFrame:ClearAllPoints()
			MAGridFrame:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			MAGridFrame:SetFrameStrata("LOW")
			MAGridFrame:SetFrameLevel(1)
			MAGridFrame.hor = MAGridFrame:CreateTexture()
			MAGridFrame.hor:SetPoint("CENTER", 0, -0.5)
			MAGridFrame.hor:SetSize(MoveAny:GetMainPanel():GetWidth(), 1)
			MAGridFrame.hor:SetColorTexture(1, 1, 1, 1)
			MAGridFrame.ver = MAGridFrame:CreateTexture()
			MAGridFrame.ver:SetPoint("CENTER", 0.5, 0)
			MAGridFrame.ver:SetSize(1, MoveAny:GetMainPanel():GetHeight())
			MAGridFrame.ver:SetColorTexture(1, 1, 1, 1)
			MoveAny:UpdateGrid()
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint("MALock")
			if dbp1 and dbp3 then
				MALock:ClearAllPoints()
				MALock:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			end

			if MoveAny.HideMALock then
				MoveAny:HideMALock(true)
			end
		end, "InitMALock 3"
	)
end

function MoveAny:UpdateGrid()
	local id = 0
	if not MAGridFrame then return end
	MAGridFrame.lines = MAGridFrame.lines or {}
	for i, v in pairs(MAGridFrame.lines) do
		v:Hide()
	end

	for x = 0, MoveAny:GetMainPanel():GetWidth() / 2, MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint("CENTER", 0.5 + x, 0)
		MAGridFrame.lines[id]:SetSize(1.09, MoveAny:GetMainPanel():GetHeight())
		if x % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
		else
			MAGridFrame.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
		end

		MAGridFrame.lines[id]:Show()
		id = id + 1
	end

	for x = 0, -MoveAny:GetMainPanel():GetWidth() / 2, -MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint("CENTER", 0.5 + x, 0)
		MAGridFrame.lines[id]:SetSize(1.09, MoveAny:GetMainPanel():GetHeight())
		if x % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
		else
			MAGridFrame.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
		end

		MAGridFrame.lines[id]:Show()
		id = id + 1
	end

	for y = 0, MoveAny:GetMainPanel():GetHeight() / 2, MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint("CENTER", 0, 0.5 + y)
		MAGridFrame.lines[id]:SetSize(MoveAny:GetMainPanel():GetWidth(), 1.09, MoveAny:GetMainPanel():GetHeight())
		if y % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
		else
			MAGridFrame.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
		end

		MAGridFrame.lines[id]:Show()
		id = id + 1
	end

	for y = 0, -MoveAny:GetMainPanel():GetHeight() / 2, -MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint("CENTER", 0, 0.5 + y)
		MAGridFrame.lines[id]:SetSize(MoveAny:GetMainPanel():GetWidth(), 1.09)
		if y % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture(1, 1, 0.5, 0.25)
		else
			MAGridFrame.lines[id]:SetColorTexture(0.5, 0.5, 0.5, 0.25)
		end

		MAGridFrame.lines[id]:Show()
		id = id + 1
	end
end

function MoveAny:AddUploadProfileLine(source, profile)
	local delay = 0.01
	C_ChatInfo.SendAddonMessage(PREFIX, "UP;" .. profile .. ";0", "WHISPER", source)
	MoveAny:CheckDB("MAShareProfile")
	if MATAB["PROFILES"][profile] then
		local max = 0
		local count = 0
		local cur = 0
		for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["POINTS"]) do
			for j, w in pairs(v) do
				max = max + 1
			end
		end

		for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["SIZES"]) do
			for j, w in pairs(v) do
				max = max + 1
			end
		end

		for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["OPTIONS"]) do
			for j, w in pairs(v) do
				max = max + 1
			end
		end

		for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["POINTS"]) do
			for j, w in pairs(v) do
				count = count + 1
				MoveAny:After(
					count * delay,
					function()
						cur = cur + 1
						local per = string.format("%0.1f", cur / max * 100)
						WebStatus = tonumber(per) or 0.0
						C_ChatInfo.SendAddonMessage(PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source)
						if w ~= nil then
							local typ = type(w)
							local val = w
							if typ == "boolean" then
								if w then
									val = 1
								else
									val = 0
								end
							elseif typ == "table" then
								val = ""
							end

							if typ ~= "table" then
								C_ChatInfo.SendAddonMessage(PREFIX, "DL;" .. profile .. ";" .. "POINTS" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source)
							end
						end
					end, "AddUploadProfileLine"
				)
			end
		end

		MoveAny:After(
			count * delay,
			function()
				count = 0
				for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["SIZES"]) do
					for j, w in pairs(v) do
						count = count + 1
						MoveAny:After(
							count * delay,
							function()
								cur = cur + 1
								local per = string.format("%0.1f", cur / max * 100)
								WebStatus = tonumber(per) or 0.0
								C_ChatInfo.SendAddonMessage(PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source)
								if w ~= nil then
									local typ = type(w)
									local val = w
									if typ == "boolean" then
										if w then
											val = 1
										else
											val = 0
										end
									elseif typ == "table" then
										val = ""
									end

									if typ ~= "table" then
										C_ChatInfo.SendAddonMessage(PREFIX, "DL;" .. profile .. ";" .. "SIZES" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source)
									end
								end
							end, "t1"
						)
					end
				end

				MoveAny:After(
					count * delay,
					function()
						count = 0
						for i, v in pairs(MATAB["PROFILES"][profile]["ELES"]["OPTIONS"]) do
							for j, w in pairs(v) do
								count = count + 1
								MoveAny:After(
									count * delay,
									function()
										cur = cur + 1
										local per = string.format("%0.1f", cur / max * 100)
										WebStatus = tonumber(per) or 0.0
										C_ChatInfo.SendAddonMessage(PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source)
										if w ~= nil then
											local typ = type(w)
											local val = w
											if typ == "boolean" then
												if w then
													val = 1
												else
													val = 0
												end
											elseif typ == "table" then
												val = ""
											end

											if typ ~= "table" then
												C_ChatInfo.SendAddonMessage(PREFIX, "DL;" .. profile .. ";" .. "OPTIONS" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source)
											end
										end
									end, "t4"
								)
							end
						end
					end, "t2"
				)
			end, "t3"
		)
	end

	MAShareProfile:Hide()
	if MAUploadProfile == nil then
		MAUploadProfile = CreateFrame("Frame", "MAUploadProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
		MAUploadProfile:SetSize(120, 120)
		MAUploadProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
		MAUploadProfile:SetFrameStrata("HIGH")
		MAUploadProfile:SetFrameLevel(1010)
		MoveAny:SetClampedToScreen(MAUploadProfile, true)
		MAUploadProfile:SetMovable(true)
		MAUploadProfile:EnableMouse(true)
		MAUploadProfile:RegisterForDrag("LeftButton")
		MAUploadProfile:SetScript("OnDragStart", MAUploadProfile.StartMoving)
		MAUploadProfile:SetScript("OnDragStop", MAUploadProfile.StopMovingOrSizing)
		MAUploadProfile.TitleText:SetText(MoveAny:Trans("LID_DOWNLOAD"))
		MAUploadProfile.CloseButton:SetScript(
			"OnClick",
			function()
				MAUploadProfile:Hide()
			end
		)

		MAUploadProfile.name = MAUploadProfile:CreateFontString(nil, nil, "GameFontNormal")
		MAUploadProfile.name:SetPoint("TOPLEFT", MAUploadProfile, "TOPLEFT", 12, -26)
		MAUploadProfile.btn = MoveAny:CreateButton("MAUploadProfile.X", MAUploadProfile)
		MAUploadProfile.btn:SetPoint("TOPLEFT", MAUploadProfile, "TOPLEFT", 12, -78)
		MAUploadProfile.btn:SetSize(100, 24)
		MAUploadProfile.btn:SetText("X")
		MAUploadProfile.btn:SetScript(
			"OnClick",
			function()
				MAUploadProfile:Hide()
			end
		)

		function MAUploadProfile:UpdateStatus()
			if WebStatus <= 0.0 then
				MAUploadProfile.name:SetText(MoveAny:Trans("LID_WAITINGFOROWNER"))
				MAUploadProfile.btn:SetEnabled(false)
			elseif WebStatus >= 100.0 then
				MAUploadProfile.name:SetText(MoveAny:Trans("LID_DONE"))
				MAUploadProfile.btn:SetEnabled(true)
			else
				MAUploadProfile.name:SetText(MoveAny:Trans("LID_STATUS") .. ": " .. WebStatus .. "%")
				MAUploadProfile.btn:SetEnabled(false)
			end

			MoveAny:After(0.1, MAUploadProfile.UpdateStatus, "UpdateStatus")
		end

		MAUploadProfile:UpdateStatus()
		MAUploadProfile.CloseButton:SetScript(
			"OnClick",
			function()
				MAUploadProfile:Hide()
			end
		)
	else
		MAUploadProfile:Show()
	end
end

function MoveAny:ShowProfiles()
	if MAProfiles == nil then
		MAProfiles = CreateFrame("Frame", "MAProfiles", MoveAny:GetMainPanel(), "BasicFrameTemplate")
		MAProfiles:SetSize(sw, sh)
		MAProfiles:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
		MAProfiles:SetFrameStrata("HIGH")
		MAProfiles:SetFrameLevel(999)
		MoveAny:SetClampedToScreen(MAProfiles, true)
		MAProfiles:SetMovable(true)
		MAProfiles:EnableMouse(true)
		MAProfiles:RegisterForDrag("LeftButton")
		MAProfiles:SetScript(
			"OnDragStart",
			function()
				MAProfiles:StartMoving()
			end
		)

		MAProfiles:SetScript(
			"OnDragStop",
			function()
				MAProfiles:StopMovingOrSizing()
				local p1, _, p3, p4, p5 = MAProfiles:GetPoint()
				p4 = MoveAny:Snap(p4)
				p5 = MoveAny:Snap(p5)
				MoveAny:SetElePoint("MALock", p1, _, p3, p4, p5)
			end
		)

		MAProfiles.TitleText:SetText(format("|T135994:16:16:0:0|t M|cff3FC7EBove|rA|cff3FC7EBny|r v|cff3FC7EB%s", MoveAny:GetVersion()))
		MAProfiles.CloseButton:SetScript(
			"OnClick",
			function()
				MoveAny:SetEnabled("MAPROFILES", false)
				MAProfiles:Hide()
				MoveAny:Unlock()
				MoveAny:ShowMALock()
			end
		)

		MAProfiles:SetResizable(true)
		MoveAny:After(
			0,
			function()
				MAProfiles:SetResizeBounds(sw, 200, sw + 200, GetScreenHeight())
				if MAProfiles:GetHeight() > GetScreenHeight() then
					MAProfiles:SetHeight(GetScreenHeight())
				end
			end, "ShowProfiles"
		)

		MAProfiles.DISCORD = CreateFrame("EditBox", "MAProfiles" .. ".DISCORD", MAProfiles, "InputBoxTemplate")
		MAProfiles.DISCORD:SetText("discord.gg/qxpK6PKYAD")
		MAProfiles.DISCORD:SetSize(160, 24)
		MAProfiles.DISCORD:SetPoint("BOTTOMRIGHT", MAProfiles, "BOTTOMRIGHT", -4 - 20, 4)
		MAProfiles.DISCORD:SetAutoFocus(false)
		local rb2 = MoveAny:CreateButton(nil, MAProfiles, true)
		rb2:EnableMouse("true")
		rb2:SetPoint("BOTTOMRIGHT")
		rb2:SetSize(32, 32)
		rb2:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
		rb2:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb2:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb2:SetScript(
			"OnMouseDown",
			function(sel)
				MoveAny:GetParent(sel):StartSizing("BOTTOMRIGHT")
			end
		)

		rb2:SetScript(
			"OnMouseUp",
			function(sel)
				MoveAny:GetParent(sel):StopMovingOrSizing("BOTTOMRIGHT")
			end
		)

		MAProfiles.SF = CreateFrame("ScrollFrame", "MAProfiles_SF", MAProfiles, "UIPanelScrollFrameTemplate")
		MAProfiles.SF:SetPoint("TOPLEFT", MAProfiles, br, -30 - 24)
		MAProfiles.SF:SetPoint("BOTTOMRIGHT", MAProfiles, -32, 24 + br)
		MAProfiles.SC = CreateFrame("Frame", "MAProfiles_SC", MAProfiles.SF)
		MAProfiles.SC:SetSize(400, 400)
		MAProfiles.SC:SetPoint("TOPLEFT", MAProfiles.SF, "TOPLEFT", 0, 0)
		MAProfiles.SF:SetScrollChild(MAProfiles.SC)
		MAProfiles.SF.bg = MAProfiles.SF:CreateTexture()
		MAProfiles.SF.bg:SetAllPoints(MAProfiles.SF)
		MAProfiles.SF.bg:SetColorTexture(0.03, 0.03, 0.03, 0.5)
		MAProfiles.AddProfile = MoveAny:CreateButton("MAProfiles_AddProfile", MAProfiles)
		MAProfiles.AddProfile:SetPoint("TOPLEFT", MAProfiles, "TOPLEFT", br, -26)
		MAProfiles.AddProfile:SetSize(160, 24)
		MAProfiles.AddProfile:SetText(MoveAny:Trans("LID_ADDPROFILE"))
		MAProfiles.AddProfile:SetScript(
			"OnClick",
			function()
				if MAAddProfile == nil then
					MAAddProfile = CreateFrame("Frame", "MAAddProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
					MAAddProfile:SetSize(300, 130)
					MAAddProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
					MAAddProfile:SetFrameStrata("HIGH")
					MAAddProfile:SetFrameLevel(1010)
					MoveAny:SetClampedToScreen(MAAddProfile, true)
					MAAddProfile:SetMovable(true)
					MAAddProfile:EnableMouse(true)
					MAAddProfile:RegisterForDrag("LeftButton")
					MAAddProfile:SetScript("OnDragStart", MAAddProfile.StartMoving)
					MAAddProfile:SetScript("OnDragStop", MAAddProfile.StopMovingOrSizing)
					MAAddProfile.name = "NEW"
					MAAddProfile.inheritFrom = ""
					MAAddProfile.TitleText:SetText(MoveAny:Trans("LID_ADDPROFILE"))
					MAAddProfile.CloseButton:SetScript(
						"OnClick",
						function()
							MAAddProfile:Hide()
						end
					)

					MAAddProfile.Name = CreateFrame("EditBox", "MAAddProfile_Search", MAAddProfile, "InputBoxTemplate")
					MAAddProfile.Name:SetPoint("TOPLEFT", MAAddProfile, "TOPLEFT", 12, -26)
					MAAddProfile.Name:SetSize(300 - 24, 24)
					MAAddProfile.Name:SetAutoFocus(false)
					MAAddProfile.Name:SetText(MAAddProfile.name)
					MAAddProfile.Name:SetScript(
						"OnTextChanged",
						function(sel, text)
							MAAddProfile.name = MAAddProfile.Name:GetText()
						end
					)

					local profileNames = {}
					tinsert(profileNames, "")
					for name, tab in pairs(MoveAny:GetProfiles()) do
						tinsert(profileNames, name)
					end

					if DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
						local sliderProfiles = CreateFrame("Slider", nil, MAAddProfile, "UISliderTemplate")
						sliderProfiles:SetSize(MAAddProfile:GetWidth() - 20, 16)
						sliderProfiles:SetPoint("TOPLEFT", MAAddProfile, "TOPLEFT", 10, -26 - 30 - br)
						if sliderProfiles.Low == nil then
							sliderProfiles.Low = sliderProfiles:CreateFontString(nil, nil, "GameFontNormal")
							sliderProfiles.Low:SetPoint("BOTTOMLEFT", sliderProfiles, "BOTTOMLEFT", 0, -12)
							MoveAny:SetFontSize(sliderProfiles.Low, 10, "THINOUTLINE")
							sliderProfiles.Low:SetTextColor(1, 1, 1)
						end

						if sliderProfiles.High == nil then
							sliderProfiles.High = sliderProfiles:CreateFontString(nil, nil, "GameFontNormal")
							sliderProfiles.High:SetPoint("BOTTOMRIGHT", sliderProfiles, "BOTTOMRIGHT", 0, -12)
							MoveAny:SetFontSize(sliderProfiles.High, 10, "THINOUTLINE")
							sliderProfiles.High:SetTextColor(1, 1, 1)
						end

						if sliderProfiles.Text == nil then
							sliderProfiles.Text = sliderProfiles:CreateFontString(nil, nil, "GameFontNormal")
							sliderProfiles.Text:SetPoint("TOP", sliderProfiles, "TOP", 0, 16)
							MoveAny:SetFontSize(sliderProfiles.Text, 12, "THINOUTLINE")
							sliderProfiles.Text:SetTextColor(1, 1, 1)
						end

						sliderProfiles.Low:SetText("")
						sliderProfiles.High:SetText("")
						sliderProfiles.Text:SetText(MoveAny:Trans("LID_INHERITFROM") .. ": " .. MAAddProfile.inheritFrom)
						sliderProfiles:SetMinMaxValues(1, #profileNames)
						sliderProfiles:SetObeyStepOnDrag(true)
						sliderProfiles:SetValueStep(1)
						sliderProfiles:SetValue(1)
						sliderProfiles:SetScript(
							"OnValueChanged",
							function(sel, val)
								val = tonumber(string.format("%" .. 0 .. "f", val))
								local value = profileNames[val]
								if value and value ~= MAAddProfile.inheritFrom then
									MAAddProfile.inheritFrom = value
									sel.Text:SetText(MoveAny:Trans("LID_INHERITFROM") .. ": " .. value)
								end
							end
						)
					end

					MAAddProfile.AddProfile = MoveAny:CreateButton("MAAddProfile_Profiles", MAAddProfile)
					MAAddProfile.AddProfile:SetPoint("TOPLEFT", MAAddProfile, "TOPLEFT", br, -26 - 24 - br - 30 - br)
					MAAddProfile.AddProfile:SetSize(160, 24)
					MAAddProfile.AddProfile:SetText(MoveAny:Trans("LID_ADD"))
					MAAddProfile.AddProfile:SetScript(
						"OnClick",
						function()
							MoveAny:AddProfile(MAAddProfile.name, MAAddProfile.inheritFrom)
							if C_UI then
								C_UI.Reload()
							else
								ReloadUI()
							end
						end
					)
				else
					MAAddProfile:Show()
				end
			end
		)

		MAProfiles.GetProfile = MoveAny:CreateButton("MAProfiles_GetProfile", MAProfiles)
		MAProfiles.GetProfile:SetPoint("TOPLEFT", MAProfiles, "TOPLEFT", br + 160 + br, -26)
		MAProfiles.GetProfile:SetSize(160, 24)
		MAProfiles.GetProfile:SetText(MoveAny:Trans("LID_GETPROFILE"))
		MAProfiles.GetProfile:SetScript(
			"OnClick",
			function()
				if MAGetProfile == nil then
					MAGetProfile = CreateFrame("Frame", "MAGetProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
					MAGetProfile:SetSize(600, 200)
					MAGetProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
					MAGetProfile:SetFrameStrata("HIGH")
					MAGetProfile:SetFrameLevel(1010)
					MoveAny:SetClampedToScreen(MAGetProfile, true)
					MAGetProfile:SetMovable(true)
					MAGetProfile:EnableMouse(true)
					MAGetProfile:RegisterForDrag("LeftButton")
					MAGetProfile:SetScript("OnDragStart", MAGetProfile.StartMoving)
					MAGetProfile:SetScript("OnDragStop", MAGetProfile.StopMovingOrSizing)
					MAGetProfile.TitleText:SetText(MoveAny:Trans("LID_GETPROFILE"))
					MAGetProfile.CloseButton:SetScript(
						"OnClick",
						function()
							MAGetProfile:Hide()
						end
					)

					MAGetProfile.f = MAGetProfile:CreateFontString(nil, nil, "GameFontNormal")
					MAGetProfile.f:SetPoint("TOPLEFT", MAGetProfile, "TOPLEFT", 6, -26)
					MAGetProfile.f:SetText(MoveAny:Trans("LID_GETPROFILE"))
					MAGetProfile.f2 = MAGetProfile:CreateFontString(nil, nil, "GameFontNormal")
					MAGetProfile.f2:SetPoint("BOTTOMLEFT", MAGetProfile, "BOTTOMLEFT", 6, 6)
					MAGetProfile.f2:SetText(MoveAny:Trans("LID_WAITFORPLAYERPROFILE2"))
					MAGetProfile.SF = CreateFrame("ScrollFrame", "MAGetProfile_SF", MAGetProfile, "UIPanelScrollFrameTemplate")
					MAGetProfile.SF:SetPoint("TOPLEFT", MAGetProfile, br, -30 - 24)
					MAGetProfile.SF:SetPoint("BOTTOMRIGHT", MAGetProfile, -32, 24 + br)
					MAGetProfile.SC = CreateFrame("Frame", "MAGetProfile_SC", MAGetProfile.SF)
					MAGetProfile.SC:SetSize(600, 200)
					MAGetProfile.SC:SetPoint("TOPLEFT", MAGetProfile.SF, "TOPLEFT", 0, 0)
					MAGetProfile.SF:SetScrollChild(MAGetProfile.SC)
					MAGetProfile.SF.bg = MAGetProfile.SF:CreateTexture()
					MAGetProfile.SF.bg:SetAllPoints(MAGetProfile.SF)
					MAGetProfile.SF.bg:SetColorTexture(0.03, 0.03, 0.03, 0.5)
				else
					MAGetProfile:Show()
				end

				MAGetProfile.f:SetText(MoveAny:Trans("LID_PROFILES") .. ":")
				MASendProfiles = {} -- Reset
				local function AddLine(id, source, profile)
					MAGetProfile.lines = MAGetProfile.lines or {}
					if MAGetProfile.lines[id] == nil then
						MAGetProfile.lines[id] = CreateFrame("Frame", "lines[" .. id .. "]", MAGetProfile.SC)
						MAGetProfile.lines[id]:SetSize(600, 25)
						MAGetProfile.lines[id]:SetPoint("TOPLEFT", MAGetProfile.SC, "TOPLEFT", 0, 0)
						MAGetProfile.lines[id].name = MAGetProfile.lines[id]:CreateFontString(nil, nil, "GameFontNormal")
						MAGetProfile.lines[id].name:SetPoint("LEFT", MAGetProfile.lines[id], "LEFT", 0, 0)
						MAGetProfile.lines[id].profile = MAGetProfile.lines[id]:CreateFontString(nil, nil, "GameFontNormal")
						MAGetProfile.lines[id].profile:SetPoint("LEFT", MAGetProfile.lines[id], "LEFT", 250, 0)
						MAGetProfile.lines[id].btn = MoveAny:CreateButton(source .. "btn", MAGetProfile.lines[id])
						MAGetProfile.lines[id].btn:SetPoint("LEFT", MAGetProfile.lines[id], "LEFT", 450, 0)
						MAGetProfile.lines[id].btn:SetSize(100, 24)
						MAGetProfile.lines[id].btn:SetText(MoveAny:Trans("LID_DOWNLOAD"))
						MAGetProfile.lines[id].btn:SetScript(
							"OnClick",
							function()
								MAGetProfile:Hide()
								WebOwner = source
								WebProfile = profile
								WebProfileData = {}
								C_ChatInfo.SendAddonMessage(PREFIX, "WP;" .. profile, "WHISPER", source)
								if MADownloadProfile == nil then
									MADownloadProfile = CreateFrame("Frame", "MADownloadProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
									MADownloadProfile:SetSize(300, 120)
									MADownloadProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
									MADownloadProfile:SetFrameStrata("HIGH")
									MADownloadProfile:SetFrameLevel(1010)
									MoveAny:SetClampedToScreen(MADownloadProfile, true)
									MADownloadProfile:SetMovable(true)
									MADownloadProfile:EnableMouse(true)
									MADownloadProfile:RegisterForDrag("LeftButton")
									MADownloadProfile:SetScript("OnDragStart", MADownloadProfile.StartMoving)
									MADownloadProfile:SetScript("OnDragStop", MADownloadProfile.StopMovingOrSizing)
									MADownloadProfile.TitleText:SetText(MoveAny:Trans("LID_DOWNLOAD"))
									MADownloadProfile.name = MADownloadProfile:CreateFontString(nil, nil, "GameFontNormal")
									MADownloadProfile.name:SetPoint("TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -26)
									MADownloadProfile.ProfileName = CreateFrame("EditBox", "MADownloadProfile", MADownloadProfile, "InputBoxTemplate")
									MADownloadProfile.ProfileName:SetPoint("TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -52)
									MADownloadProfile.ProfileName:SetSize(300 - 24, 24)
									MADownloadProfile.ProfileName:SetAutoFocus(false)
									MADownloadProfile.ProfileName:SetScript(
										"OnTextChanged",
										function(sel, text)
											MADownloadProfile.profileName = MADownloadProfile.ProfileName:GetText()
										end
									)

									MADownloadProfile.btn = MoveAny:CreateButton(source .. "btn", MADownloadProfile)
									MADownloadProfile.btn:SetPoint("TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -78)
									MADownloadProfile.btn:SetSize(100, 24)
									MADownloadProfile.btn:SetText(MoveAny:Trans("LID_ADD"))
									MADownloadProfile.btn:SetScript(
										"OnClick",
										function()
											local profileName = MADownloadProfile.ProfileName:GetText()
											MoveAny:CheckDB("PROFILES")
											if MATAB["PROFILES"][profileName] == nil then
												MoveAny:ImportProfile(profileName, WebProfileData)
												if C_UI then
													C_UI.Reload()
												else
													ReloadUI()
												end
											else
												MoveAny:ERR("[AddProfile] can't add, Name already exists.")
											end
										end
									)

									function MADownloadProfile:UpdateStatus()
										if WebStatus == 0 then
											MADownloadProfile.name:SetText(MoveAny:Trans("LID_WAITINGFOROWNER"))
											MADownloadProfile.btn:SetEnabled(false)
										elseif WebStatus == 100 then
											MADownloadProfile.name:SetText(MoveAny:Trans("LID_DONE"))
											MADownloadProfile.btn:SetEnabled(true)
										else
											MADownloadProfile.name:SetText(MoveAny:Trans("LID_STATUS") .. ": " .. WebStatus .. "%")
											MADownloadProfile.btn:SetEnabled(false)
										end

										MoveAny:After(0.1, MADownloadProfile.UpdateStatus, "UpdateStatus 2")
									end

									MADownloadProfile:UpdateStatus()
									MADownloadProfile.CloseButton:SetScript(
										"OnClick",
										function()
											MADownloadProfile:Hide()
										end
									)
								end

								MADownloadProfile.profileName = WebProfile
								MADownloadProfile.ProfileName:SetText(MADownloadProfile.profileName)
								MADownloadProfile:Show()
							end
						)
					end

					MAGetProfile.lines[id].name:SetText(MoveAny:Trans("LID_PLAYER") .. ": " .. source)
					MAGetProfile.lines[id].profile:SetText(MoveAny:Trans("LID_PROFILE") .. ": " .. profile)
				end

				local function GetProfiles()
					if MAGetProfile:IsVisible() then
						MAGetProfile.lines = MAGetProfile.lines or {}
						local id = 0
						for name1, tab1 in pairs(MASendProfiles) do
							AddLine(id, name1, tab1.profile)
							id = id + 1
						end

						MoveAny:After(1, GetProfiles, "GetProfiles")
					end
				end

				GetProfiles()
			end
		)

		MAProfiles.back = MoveAny:CreateButton("MAProfiles_Back", MAProfiles)
		MAProfiles.back:SetSize(120, 24)
		MAProfiles.back:SetPoint("BOTTOMLEFT", MAProfiles, "BOTTOMLEFT", 4, 4)
		MAProfiles.back:SetText(BACK)
		MAProfiles.back:SetScript(
			"OnClick",
			function()
				MoveAny:SetEnabled("MAPROFILES", false)
				MAProfiles:Hide()
				MoveAny:Unlock()
				MoveAny:ShowMALock()
			end
		)

		local index = 0
		for name, tab in pairs(MoveAny:GetProfiles()) do
			local btn = MoveAny:CreateButton(name, MAProfiles.SC)
			btn:SetPoint("TOPLEFT", MAProfiles.SC, "TOPLEFT", br, -index * 40 - br)
			btn:SetSize(160, 24)
			if name == MoveAny:GetCP() then
				btn:SetText("(" .. MoveAny:Trans("LID_CURRENT") .. ") " .. name)
			else
				btn:SetText(name)
			end

			btn:SetScript(
				"OnClick",
				function()
					MoveAny:SetCP(name)
					if C_UI then
						C_UI.Reload()
					else
						ReloadUI()
					end
				end
			)

			local btnShare = MoveAny:CreateButton(name, MAProfiles.SC)
			btnShare:SetPoint("TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160 + br, -index * 40 - br)
			btnShare:SetSize(80, 24)
			btnShare:SetText(MoveAny:Trans("LID_SHARE"))
			btnShare:SetScript(
				"OnClick",
				function()
					if MAShareProfile == nil then
						MAShareProfile = CreateFrame("Frame", "MAShareProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
						MAShareProfile:SetSize(600, 200)
						MAShareProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
						MAShareProfile:SetFrameStrata("HIGH")
						MAShareProfile:SetFrameLevel(1010)
						MoveAny:SetClampedToScreen(MAShareProfile, true)
						MAShareProfile:SetMovable(true)
						MAShareProfile:EnableMouse(true)
						MAShareProfile:RegisterForDrag("LeftButton")
						MAShareProfile:SetScript("OnDragStart", MAShareProfile.StartMoving)
						MAShareProfile:SetScript("OnDragStop", MAShareProfile.StopMovingOrSizing)
						MAShareProfile.TitleText:SetText(MoveAny:Trans("LID_SHAREPROFILE"))
						MAShareProfile.CloseButton:SetScript(
							"OnClick",
							function()
								MAShareProfile:Hide()
							end
						)

						MAShareProfile.f = MAShareProfile:CreateFontString(nil, nil, "GameFontNormal")
						MAShareProfile.f:SetPoint("TOPLEFT", MAShareProfile, "TOPLEFT", 6, -26)
						MAShareProfile.f:SetText(MoveAny:Trans("LID_PROFILE") .. ": " .. name)
						MAShareProfile.f2 = MAShareProfile:CreateFontString(nil, nil, "GameFontNormal")
						MAShareProfile.f2:SetPoint("BOTTOMLEFT", MAShareProfile, "BOTTOMLEFT", 6, 6)
						MAShareProfile.f2:SetText(MoveAny:Trans("LID_WAITFORPLAYERPROFILE"))
						MAShareProfile.SF = CreateFrame("ScrollFrame", "MAShareProfile_SF", MAShareProfile, "UIPanelScrollFrameTemplate")
						MAShareProfile.SF:SetPoint("TOPLEFT", MAShareProfile, br, -30 - 24)
						MAShareProfile.SF:SetPoint("BOTTOMRIGHT", MAShareProfile, -32, 24 + br)
						MAShareProfile.SC = CreateFrame("Frame", "MAShareProfile_SC", MAShareProfile.SF)
						MAShareProfile.SC:SetSize(600, 200)
						MAShareProfile.SC:SetPoint("TOPLEFT", MAShareProfile.SF, "TOPLEFT", 0, 0)
						MAShareProfile.SF:SetScrollChild(MAShareProfile.SC)
						MAShareProfile.SF.bg = MAShareProfile.SF:CreateTexture()
						MAShareProfile.SF.bg:SetAllPoints(MAShareProfile.SF)
						MAShareProfile.SF.bg:SetColorTexture(0.03, 0.03, 0.03, 0.5)
					else
						MAShareProfile:Show()
					end

					MAShareProfile.f:SetText(MoveAny:Trans("LID_PROFILE") .. ": " .. name)
					MAWantProfiles = {} -- Reset
					local function AddLine(id, source, profile)
						MAShareProfile.lines = MAShareProfile.lines or {}
						if MAShareProfile.lines[id] == nil then
							MAShareProfile.lines[id] = CreateFrame("Frame", "lines[" .. id .. "]", MAShareProfile.SC)
							MAShareProfile.lines[id]:SetSize(600, 25)
							MAShareProfile.lines[id]:SetPoint("TOPLEFT", MAShareProfile.SC, "TOPLEFT", 0, id * 25)
							MAShareProfile.lines[id].name = MAShareProfile.lines[id]:CreateFontString(nil, nil, "GameFontNormal")
							MAShareProfile.lines[id].name:SetPoint("LEFT", MAShareProfile.lines[id], "LEFT", 0, id * 25)
							MAShareProfile.lines[id].btn = MoveAny:CreateButton(profile, MAShareProfile.lines[id])
							MAShareProfile.lines[id].btn:SetPoint("LEFT", MAShareProfile.lines[id], "LEFT", 450, 0)
							MAShareProfile.lines[id].btn:SetSize(100, 24)
							MAShareProfile.lines[id].btn:SetText(MoveAny:Trans("LID_UPLOAD"))
							MAShareProfile.lines[id].btn:SetScript(
								"OnClick",
								function()
									MoveAny:AddUploadProfileLine(source, profile)
								end
							)
						end

						MAShareProfile.lines[id].name:SetText(MoveAny:Trans("LID_PLAYER") .. ": " .. source)
					end

					-- Receive Buyers
					local function GetProfiles()
						if MAShareProfile:IsVisible() then
							MAShareProfile.lines = MAShareProfile.lines or {}
							local id = 0
							for name2, tab2 in pairs(MAWantProfiles) do
								AddLine(id, name2, tab2.profile)
								id = id + 1
							end

							MoveAny:After(1, GetProfiles, "GetProfiles2")
						end
					end

					GetProfiles()
					-- Send out Profile Shop
					local function ShareProfile()
						if MAShareProfile:IsVisible() then
							C_ChatInfo.SendAddonMessage(PREFIX, "SP;" .. name, "PARTY")
							MoveAny:After(4, ShareProfile, "ShareProfile")
						end
					end

					ShareProfile()
				end
			)

			if name ~= "DEFAULT" then
				local btnRen = MoveAny:CreateButton(name, MAProfiles.SC)
				btnRen:SetPoint("TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160 + br + 80 + br, -index * 40 - br)
				btnRen:SetSize(100, 24)
				btnRen:SetText(MoveAny:Trans("LID_RENAME"))
				btnRen:SetScript(
					"OnClick",
					function()
						if MARenameProfile == nil then
							MARenameProfile = CreateFrame("Frame", "MARenameProfile", MoveAny:GetMainPanel(), "BasicFrameTemplate")
							MARenameProfile:SetSize(300, 130)
							MARenameProfile:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
							MARenameProfile:SetFrameStrata("HIGH")
							MARenameProfile:SetFrameLevel(1010)
							MoveAny:SetClampedToScreen(MARenameProfile, true)
							MARenameProfile:SetMovable(true)
							MARenameProfile:EnableMouse(true)
							MARenameProfile:RegisterForDrag("LeftButton")
							MARenameProfile:SetScript("OnDragStart", MARenameProfile.StartMoving)
							MARenameProfile:SetScript("OnDragStop", MARenameProfile.StopMovingOrSizing)
							MARenameProfile.TitleText:SetText(MoveAny:Trans("LID_RENAME"))
							MARenameProfile.CloseButton:SetScript(
								"OnClick",
								function()
									MARenameProfile:Hide()
								end
							)

							MARenameProfile.Name = CreateFrame("EditBox", "MARenameProfile_Search", MARenameProfile, "InputBoxTemplate")
							MARenameProfile.Name:SetPoint("TOPLEFT", MARenameProfile, "TOPLEFT", 12, -26)
							MARenameProfile.Name:SetSize(300 - 24, 24)
							MARenameProfile.Name:SetAutoFocus(false)
							MARenameProfile.Name:SetScript(
								"OnTextChanged",
								function(sel, text)
									MARenameProfile.name = MARenameProfile.Name:GetText()
								end
							)

							MARenameProfile.RenameProfile = MoveAny:CreateButton("MARenameProfile_Profiles", MARenameProfile)
							MARenameProfile.RenameProfile:SetPoint("TOPLEFT", MARenameProfile, "TOPLEFT", br, -26 - 24 - br - 30 - br)
							MARenameProfile.RenameProfile:SetSize(160, 24)
							MARenameProfile.RenameProfile:SetText(MoveAny:Trans("LID_RENAME"))
							MARenameProfile.RenameProfile:SetScript(
								"OnClick",
								function()
									if MARenameProfile.oldname ~= MARenameProfile.name then
										MoveAny:RenameProfile(MARenameProfile.oldname, MARenameProfile.name)
									else
										MoveAny:ERR("[RENAME PROFILE] New name is same as old name.")
									end
								end
							)
						else
							MARenameProfile:Show()
						end

						MARenameProfile.oldname = name
						MARenameProfile.name = name
						MARenameProfile.Name:SetText(name)
					end
				)
			end

			local btnRem = MoveAny:CreateButton(name, MAProfiles.SC)
			btnRem:SetPoint("TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160 + br + 80 + br + 100 + br, -index * 40 - br)
			btnRem:SetSize(100, 24)
			btnRem:SetText(MoveAny:Trans("LID_REMOVE"))
			btnRem:SetScript(
				"OnClick",
				function()
					MoveAny:RemoveProfile(name)
					if C_UI then
						C_UI.Reload()
					else
						ReloadUI()
					end
				end
			)

			index = index + 1
		end

		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint("MALock")
		if dbp1 and dbp3 then
			MAProfiles:ClearAllPoints()
			MAProfiles:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
		end
	else
		MAProfiles:Show()
	end
end

local f = CreateFrame("Frame")
MoveAny:RegisterEvent(f, "CHAT_MSG_ADDON")
MoveAny:RegisterEvent(f, "PLAYER_ENTERING_WORLD")
MoveAny:OnEvent(
	f,
	function(sel, event, ...)
		if event == "CHAT_MSG_ADDON" then
			local prefix, data, _, source, _ = ...
			if prefix == PREFIX then
				local tab = {strsplit(";", data)}
				local name, realm = UnitName("player")
				if realm == nil then
					realm = GetRealmName()
				end

				local cmd = tab[1]
				-- SendProfile
				if cmd == "SP" then
					if source ~= name .. "-" .. realm and not MASendProfiles[source] then
						local ptab = {}
						ptab.name = source
						ptab.profile = tab[2]
						MASendProfiles[source] = ptab
					end
				elseif cmd == "WP" then
					-- WantProfile
					if source ~= name .. "-" .. realm and not MAWantProfiles[source] then
						local ptab = {}
						ptab.name = source
						ptab.profile = tab[2]
						MAWantProfiles[source] = ptab
					end
				elseif cmd == "UP" then
					local target = tab[2]
					local percent = tab[3]
					if source and target and source == WebOwner and target == WebProfile then
						WebStatus = tonumber(percent) or 0.0
					end
				elseif cmd == "DL" then
					local target = tab[2]
					local mainIndex = tab[3]
					local subIndex = tab[4]
					local index = tab[5]
					local typ = tab[6]
					local val = tab[7]
					if source and target and source == WebOwner and target == WebProfile then
						WebProfileData = WebProfileData or {}
						WebProfileData[mainIndex] = WebProfileData[mainIndex] or {}
						WebProfileData[mainIndex][subIndex] = WebProfileData[mainIndex][subIndex] or {}
						if typ == "boolean" then
							if val == "1" then
								val = true
							else
								val = false
							end
						elseif typ == "number" then
							val = tonumber(val)
						end

						WebProfileData[mainIndex][subIndex][index] = val
					end
				end
			end
		elseif event == "PLAYER_ENTERING_WORLD" then
			local isInitialLogin, isReloadingUi = ...
			if isInitialLogin or isReloadingUi then
				C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
			end
		end
	end, "settings"
)

local hookedRep = false
local hookedRepStatus = false
function MoveAny:PlayerLogin()
	MoveAny:InitActionBarLayouts()
	if MoveAny.AnyActionbarEnabled and MoveAny:AnyActionbarEnabled() then
		MoveAny:CustomBars()
		for i, bar in pairs(MoveAny:GetAllActionBars()) do
			MoveAny:UpdateActionBar(bar)
		end
	end

	if MoveAny.GetVersion and MoveAny:GetVersion() and MoveAny.Trans then
		MoveAny:CreateMinimapButton(
			{
				["name"] = "MoveAny",
				["icon"] = 135994,
				["dbtab"] = MATAB,
				["vTT"] = {{"|T135994:16:16:0:0|t M|cff3FC7EBove|rA|cff3FC7EBny|r", "v|cff3FC7EB" .. MoveAny:GetVersion()}, {MoveAny:Trans("LID_LEFTCLICK"), MoveAny:Trans("LID_OPENSETTINGS")}, {MoveAny:Trans("LID_RIGHTCLICK"), MoveAny:Trans("LID_HIDEMINIMAPBUTTON")}},
				["funcL"] = function()
					MoveAny:ToggleMALock()
				end,
				["funcR"] = function()
					MoveAny:SetEnabled("SHOWMINIMAPBUTTON", false)
					MoveAny:HideMMBtn("MoveAny")
				end,
				["dbkey"] = "SHOWMINIMAPBUTTON"
			}
		)
	end
end

function MoveAny:IsEnabledBartender4(element)
	if not MoveAny:IsAddOnLoaded("Bartender4") then return false end
	local name, realm = UnitName("player")
	if realm == nil then
		realm = GetRealmName()
	end

	local Bartender4DB = getglobal("Bartender4DB")
	if Bartender4DB == nil then return false end
	if Bartender4DB["namespaces"] == nil then return false end
	if Bartender4DB["namespaces"][element] == nil then return false end
	if Bartender4DB["namespaces"][element]["profiles"] == nil then return false end
	if Bartender4DB["namespaces"][element]["profiles"][name .. " - " .. realm] == nil then return false end
	if Bartender4DB["namespaces"][element]["profiles"][name .. " - " .. realm].enabled ~= nil then
		return Bartender4DB["namespaces"][element]["profiles"][name .. " - " .. realm].enabled
	else
		return false
	end
end

function MoveAny:LoadAddon()
	MoveAny.init = MoveAny.init or false
	if MoveAny.init then return end
	MoveAny.init = true
	local _, class = UnitClass("player")
	if MoveAny:IsEnabled("SHOWTIPS", true) then
		if MoveAny:IsAddOnLoaded("Dominos") then
			MoveAny:INFO("Dominos Detected, please make sure that an element is only controlled by one addon at a time!")
		end

		if MoveAny:IsAddOnLoaded("Bartender4") then
			MoveAny:INFO("Bartender4 Detected, please make sure that an element is only controlled by one addon at a time!")
		end
	end

	if MoveAny:IsAddOnLoaded("D4KiR MoveAndImprove") then
		MoveAny:INFO("DON'T use MoveAndImprove, when you use MoveAny")
	end

	if MoveAny.InitSlash then
		MoveAny:InitSlash()
	end

	if MoveAny.InitDB then
		MoveAny:InitDB()
	end

	if MoveAny:IsEnabled("SHOWTIPS", true) then
		MoveAny:MSG(MoveAny:Trans("LID_STARTHELP"))
		MoveAny:MSG(MoveAny:Trans("LID_STARTHELP2"))
		MoveAny:MSG(MoveAny:Trans("LID_STARTHELP3"))
	end

	if PetBattleFrame then
		PetBattleFrame:SetFrameLevel(1001)
		PetBattleFrame.BottomFrame:SetFrameLevel(1002)
		if not MoveAny:IsAddOnLoaded("ElvUI") then
			PetBattleFrame:SetFrameStrata("DIALOG")
			PetBattleFrame.BottomFrame:SetFrameStrata("DIALOG")
		end
	end

	local MainMenuExpBar = getglobal("MainMenuExpBar")
	local UIPARENT_MANAGED_FRAME_POSITIONS = getglobal("UIPARENT_MANAGED_FRAME_POSITIONS")
	if (MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC") and MoveAny:IsEnabled("ACTIONBARS", false) then
		local MainMenuBarPerformanceBarFrame = getglobal("MainMenuBarPerformanceBarFrame")
		if MainMenuBarPerformanceBarFrame then
			MainMenuBarPerformanceBarFrame:SetParent(MoveAny:GetHidden())
		end

		if UIPARENT_MANAGED_FRAME_POSITIONS then
			UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
		end

		local MainMenuBarArtFrame = getglobal("MainMenuBarArtFrame")
		if MainMenuBarArtFrame then
			if UIPARENT_MANAGED_FRAME_POSITIONS then
				UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBarArtFrame"] = nil
			end

			MainMenuBarArtFrame:SetParent(MoveAny:GetHidden())
		end

		if MainMenuBar then
			MainMenuBar:SetParent(MoveAny:GetHidden())
		end

		local MainMenuBarOverlayFrame = getglobal("MainMenuBarOverlayFrame")
		if MainMenuBarOverlayFrame then
			MainMenuBarOverlayFrame:SetParent(MoveAny:GetHidden())
		end

		local MainMenuBarExpText = getglobal("MainMenuBarExpText")
		if MainMenuBarExpText then
			MainMenuBarExpText:SetParent(MainMenuExpBar)
			MainMenuBarExpText:SetDrawLayer("OVERLAY")
		end
	end

	if MoveAny.InitStanceBar then
		MoveAny:InitStanceBar()
	end

	if MoveAny.InitPetBar then
		MoveAny:InitPetBar()
	end

	if Arena_LoadUI then
		if MoveAny.InitArenaEnemyFrames then
			MoveAny:InitArenaEnemyFrames()
		end

		if MoveAny.InitArenaPrepFrames then
			MoveAny:InitArenaPrepFrames()
		end
	end

	if ContainerFrameContainer then
		ContainerFrameContainer:EnableMouse(false) -- Contains all bags
	end

	if MoveAny.RegisterWidget then
		if MoveAny:IsEnabled("EssentialCooldownViewer", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "EssentialCooldownViewer",
					["lstr"] = "LID_EssentialCooldownViewer"
				}
			)
		end

		if MoveAny:IsEnabled("UtilityCooldownViewer", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "UtilityCooldownViewer",
					["lstr"] = "LID_UtilityCooldownViewer"
				}
			)
		end

		if MoveAny:IsEnabled("BuffIconCooldownViewer", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "BuffIconCooldownViewer",
					["lstr"] = "LID_BuffIconCooldownViewer"
				}
			)
		end

		if MoveAny:IsEnabled("BuffBarCooldownViewer", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "BuffBarCooldownViewer",
					["lstr"] = "LID_BuffBarCooldownViewer"
				}
			)
		end

		if MoveAny:IsEnabled("BATTLEFIELDMAPFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "BattlefieldMapFrame",
					["lstr"] = "LID_BATTLEFIELDMAPFRAME"
				}
			)
		end

		if MoveAny:IsEnabled("COMPACTARENAFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "CompactArenaFrame",
					["lstr"] = "LID_COMPACTARENAFRAME"
				}
			)
		end

		if MoveAny:IsEnabled("ROLEPOLLPOPUP", false) then
			RolePollPopup:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			MoveAny:RegisterWidget(
				{
					["name"] = "RolePollPopup",
					["lstr"] = "LID_ROLEPOLLPOPUP"
				}
			)
		end

		if MoveAny:IsEnabled("READYCHECKLISTENERFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "ReadyCheckListenerFrame",
					["lstr"] = "LID_READYCHECKLISTENERFRAME"
				}
			)
		end

		if MiniMapLFGFrame and MoveAny:IsEnabled("MINIMAPLFGFRAME", false) then
			MiniMapLFGFrame:ClearAllPoints()
			MiniMapLFGFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			hooksecurefunc(
				MiniMapLFGFrame,
				"SetParent",
				function(sel)
					if sel.ma_set_parent then return end
					sel.ma_set_parent = true
					sel:SetParent(UIParent)
					sel.ma_set_parent = false
				end
			)

			MiniMapLFGFrame:SetParent(UIParent)
			MoveAny:RegisterWidget(
				{
					["name"] = "MiniMapLFGFrame",
					["lstr"] = "LID_MINIMAPLFGFRAME",
				}
			)
		end

		if LFGMinimapFrame and MoveAny:IsEnabled("LFGMINIMAPFRAME", false) then
			LFGMinimapFrame:ClearAllPoints()
			LFGMinimapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			hooksecurefunc(
				LFGMinimapFrame,
				"SetParent",
				function(sel)
					if sel.ma_set_parent then return end
					sel.ma_set_parent = true
					sel:SetParent(UIParent)
					sel.ma_set_parent = false
				end
			)

			LFGMinimapFrame:SetParent(UIParent)
			MoveAny:RegisterWidget(
				{
					["name"] = "LFGMinimapFrame",
					["lstr"] = "LID_LFGMINIMAPFRAME",
				}
			)
		end

		if PlayerCastingBarFrame then
			if MoveAny:IsEnabled("CASTINGBAR", false) then
				MoveAny:RegisterWidget(
					{
						["name"] = "PlayerCastingBarFrame",
						["lstr"] = "LID_CASTINGBAR",
					}
				)
			end

			if MoveAny:IsEnabled("CASTINGBARTIMER", false) then
				PlayerCastingBarFrameT = CreateFrame("FRAME", MoveAny:GetMainPanel())
				PlayerCastingBarFrameT:SetSize(20, 20)
				PlayerCastingBarFrameT:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
				if PlayerCastingBarFrame.timer ~= nil then
					PlayerCastingBarFrame.timer:SetParent(PlayerCastingBarFrameT)
					PlayerCastingBarFrame.timer:ClearAllPoints()
					PlayerCastingBarFrame.timer:SetPoint("CENTER", PlayerCastingBarFrameT, "CENTER", 0, 0)
				end

				MoveAny:RegisterWidget(
					{
						["name"] = "PlayerCastingBarFrameT",
						["lstr"] = "LID_CASTINGBARTIMER",
					}
				)
			end
		else
			if MoveAny:IsEnabled("CASTINGBAR", false) then
				if CastingBarFrame_ApplyAlpha then
					hooksecurefunc(
						"CastingBarFrame_ApplyAlpha",
						function(sel, alpha)
							if sel.ma_setalpha then return end
							sel.ma_setalpha = true
							if alpha == 1 then
								MoveAny:UpdateAlpha(CastingBarFrame, mouseEle)
							end

							sel.ma_setalpha = false
						end
					)
				end

				MoveAny:RegisterWidget(
					{
						["name"] = "CastingBarFrame",
						["lstr"] = "LID_CASTINGBAR"
					}
				)
			end
		end

		if TotemFrame and MoveAny:IsEnabled("TOTEMFRAME", false) then
			TotemFrame:SetParent(MoveAny:GetMainPanel())
			MoveAny:RegisterWidget(
				{
					["name"] = "TotemFrame",
					["lstr"] = "LID_TOTEMFRAME",
					["sw"] = 32 * 4,
					["sh"] = 32,
					["userplaced"] = true,
					["secure"] = true,
				}
			)
		end

		if RuneFrame and MoveAny:IsEnabled("RUNEFRAME", false) and class == "DEATHKNIGHT" then
			RuneFrame:SetParent(MoveAny:GetMainPanel())
			MoveAny:RegisterWidget(
				{
					["name"] = "RuneFrame",
					["lstr"] = "LID_RUNEFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if WarlockPowerFrame and MoveAny:IsEnabled("WARLOCKPOWERFRAME", false) and class == "WARLOCK" then
			MoveAny:RegisterWidget(
				{
					["name"] = "WarlockPowerFrame",
					["lstr"] = "LID_WARLOCKPOWERFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if ShardBarFrame and MoveAny:IsEnabled("SHARDBARFRAME", false) and class == "WARLOCK" then
			MoveAny:RegisterWidget(
				{
					["name"] = "ShardBarFrame",
					["lstr"] = "LID_SHARDBARFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if (MonkHarmonyBar or MonkHarmonyBarFrame) and MoveAny:IsEnabled("MONKHARMONYBARFRAME", false) and class == "MONK" then
			if MonkHarmonyBarFrame == nil and MonkHarmonyBar then
				MonkHarmonyBarFrame = CreateFrame("Frame", "MonkHarmonyBarFrame", UIParent)
				MonkHarmonyBarFrame:SetSize(118, 28)
				MonkHarmonyBarFrame:SetPoint(MonkHarmonyBar:GetPoint())
				MonkHarmonyBar:ClearAllPoints()
				MonkHarmonyBar:SetPoint("CENTER", MonkHarmonyBarFrame, "CENTER", 0, 0)
				MonkHarmonyBar:SetParent(MonkHarmonyBarFrame)
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "MonkHarmonyBarFrame",
					["lstr"] = "LID_MONKHARMONYBARFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["sw"] = 118,
					["sh"] = 28,
					["soft"] = true,
				}
			)
		end

		if MonkStaggerBar and MoveAny:IsEnabled("MONKSTAGGERBAR", false) and class == "MONK" then
			MoveAny:RegisterWidget(
				{
					["name"] = "MonkStaggerBar",
					["lstr"] = "LID_MONKSTAGGERBAR",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if MageArcaneChargesFrame and MoveAny:IsEnabled("MAGEARCANECHARGESFRAME", false) and class == "MAGE" then
			MoveAny:RegisterWidget(
				{
					["name"] = "MageArcaneChargesFrame",
					["lstr"] = "LID_MAGEARCANECHARGESFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if PriestBarFrame and MoveAny:IsEnabled("PRIESTBARFRAME", false) and class == "PRIEST" then
			MoveAny:RegisterWidget(
				{
					["name"] = "PriestBarFrame",
					["lstr"] = "LID_PRIESTBARFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if (RogueComboPointBarFrame or DruidComboPointBarFrame) and MoveAny:IsEnabled("COMBOPOINTPLAYERFRAME", false) then
			if class == "ROGUE" then
				MoveAny:RegisterWidget(
					{
						["name"] = "RogueComboPointBarFrame",
						["lstr"] = "LID_COMBOPOINTPLAYERFRAME",
						["userplaced"] = true,
						["secure"] = true,
						["sw"] = 120,
						["sh"] = 30,
						["soft"] = true,
					}
				)
			elseif class == "DRUID" then
				MoveAny:RegisterWidget(
					{
						["name"] = "DruidComboPointBarFrame",
						["lstr"] = "LID_COMBOPOINTPLAYERFRAME",
						["userplaced"] = true,
						["secure"] = true,
						["sw"] = 116,
						["sh"] = 28,
						["soft"] = true,
					}
				)
			end
		elseif ComboFrame and MoveAny:IsEnabled("COMBOFRAME", false) then
			local cpsw, cpsh = 12, 12
			for i = 1, 5 do
				local cp = _G["ComboPoint" .. i]
				if cp then
					cpsw, cpsh = cp:GetSize()
					cp:ClearAllPoints()
					if i == 1 then
						cp:SetPoint("LEFT", ComboFrame, "LEFT", 0, 0)
					else
						cp:SetPoint("LEFT", _G["ComboPoint" .. (i - 1)], "RIGHT", 0, 0)
					end
				end
			end

			ComboFrame:SetSize(cpsw * 5, cpsh)
			MoveAny:RegisterWidget(
				{
					["name"] = "ComboFrame",
					["lstr"] = "LID_COMBOFRAME",
					["userplaced"] = true,
					["soft"] = true,
				}
			)
		end

		if EclipseBarFrame and MoveAny:IsEnabled("EclipseBarFrame", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "EclipseBarFrame",
					["lstr"] = "LID_EclipseBarFrame",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if EssencePlayerFrame and MoveAny:IsEnabled("ESSENCEPLAYERFRAME", false) and class == "EVOKER" then
			local wasrun = false
			hooksecurefunc(
				EssencePlayerFrame,
				"Setup",
				function()
					MoveAny:RegisterWidget(
						{
							["name"] = "EssencePlayerFrame",
							["lstr"] = "LID_ESSENCEPLAYERFRAME",
							["userplaced"] = true,
							["secure"] = true,
							["soft"] = true,
						}
					)

					wasrun = true
				end
			)

			MoveAny:After(
				4,
				function()
					if not wasrun then
						MoveAny:RegisterWidget(
							{
								["name"] = "EssencePlayerFrame",
								["lstr"] = "LID_ESSENCEPLAYERFRAME",
								["userplaced"] = true,
								["secure"] = true,
								["soft"] = true,
							}
						)
					end
				end, "LoadAddon1"
			)
		end

		if MoveAny:IsValidFrame(PaladinPowerBarFrame) and MoveAny:IsEnabled("PALADINPOWERBARFRAME", false) and class == "PALADIN" then
			MoveAny:RegisterWidget(
				{
					["name"] = "PaladinPowerBarFrame",
					["lstr"] = "LID_PALADINPOWERBARFRAME",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if MoveAny:IsValidFrame(PaladinPowerBar) and MoveAny:IsEnabled("PALADINPOWERBAR", false) and class == "PALADIN" then
			MoveAny:RegisterWidget(
				{
					["name"] = "PaladinPowerBar",
					["lstr"] = "LID_PALADINPOWERBAR",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end

		if PlayerFrameBackground and MoveAny:IsEnabled("PLAYERFRAMEBACKGROUND", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "PlayerFrameBackground",
					["lstr"] = "LID_PLAYERFRAMEBACKGROUND",
					["userplaced"] = true
				}
			)
		end

		if PlayerLevelText and MoveAny:IsEnabled("PLAYERLEVELTEXT", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "PlayerLevelText",
					["lstr"] = "LID_PLAYERLEVELTEXT",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("PLAYERFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "PlayerFrame",
					["lstr"] = "LID_PLAYERFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("TARGETFRAMENAMEBACKGROUND", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "TargetFrameNameBackground",
					["lstr"] = "LID_TARGETFRAMENAMEBACKGROUND",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("TargetFrameNumericalThreat", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "TargetFrameNumericalThreat",
					["lstr"] = "LID_TargetFrameNumericalThreat",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("TARGETFRAMEBUFFMOVER", false) then
			if MoveAny:IsEnabled("TARGETFRAME", false) then
				function MoveAny:UpdateTargetBuffs()
					for i, bb in pairs(MoveAny:UpdateTargetFrameBuffs()) do
						MoveAny:UpdateChildBuffs(bb, "TargetFrameBuffMover")
					end
				end

				local TargetFrameBuffMover = CreateFrame("Frame", "TargetFrameBuffMover", UIParent)
				TargetFrameBuffMover:SetSize(21, 21)
				TargetFrameBuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				MoveAny:RegisterWidget(
					{
						["name"] = "TargetFrameBuffMover",
						["lstr"] = "LID_TARGETFRAMEBUFFMOVER",
						["userplaced"] = true,
						["setup"] = function()
							local frame = TargetFrameBuffMover
							function frame:UpdateScaleAndAlpha()
								local scale = frame:GetScale()
								local alpha = frame:GetAlpha()
								for i, bb in pairs(MoveAny:UpdateTargetFrameBuffs()) do
									if bb then
										bb:SetScale(scale)
										bb:SetAlpha(alpha)
									end
								end
							end

							local added = {}
							function frame:Update()
								if TargetFrame and TargetFrame:GetLeft() then
									local frameCenterX, frameCenterY = frame:GetCenter()
									local frameEffectiveScale = frame:GetScale()
									local frameAbsoluteX = frameCenterX / frameEffectiveScale
									local frameAbsoluteY = frameCenterY / frameEffectiveScale
									local targetCenterX, targetCenterY = TargetFrame:GetCenter()
									local targetEffectiveScale = TargetFrame:GetScale()
									local targetAbsoluteX = targetCenterX / targetEffectiveScale
									local targetAbsoluteY = targetCenterY / targetEffectiveScale
									frame.PX = frameAbsoluteX - targetAbsoluteX
									frame.PY = frameAbsoluteY - targetAbsoluteY
									for i, bb in pairs(MoveAny:UpdateTargetFrameBuffs()) do
										if bb then
											if added[bb] == nil then
												local setPoint = false
												hooksecurefunc(
													bb,
													"SetPoint",
													function(sel, ...)
														if setPoint then return end
														setPoint = true
														local MABUFFMODE = MoveAny:GetEleOption("TargetFrameBuffMover", "MABUFFMODE", 0)
														local MABUFFLIMIT = MoveAny:GetEleOption("TargetFrameBuffMover", "MABUFFLIMIT", 10)
														local MABUFFSPACINGX = MoveAny:GetEleOption("TargetFrameBuffMover", "MABUFFSPACINGX", 4)
														local MABUFFSPACINGY = MoveAny:GetEleOption("TargetFrameBuffMover", "MABUFFSPACINGY", 10)
														local row = math.floor((added[bb] - 1) / MABUFFLIMIT)
														sel:ClearAllPoints()
														if MABUFFMODE == 1 then
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + row * (21 + MABUFFSPACINGY))
														else
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + -(row * (21 + MABUFFSPACINGY)))
														end

														setPoint = false
													end
												)
											end

											if added[bb] ~= i then
												added[bb] = i
												bb:ClearAllPoints()
												bb:SetPoint("LEFT", TargetFrame, "RIGHT", 0, 0)
											end
										end
									end
								end

								MoveAny:After(
									0.1,
									function()
										frame:Update()
									end, "frame:Update LoadAddon"
								)
							end

							frame:Update()
							TargetFrame:HookScript(
								"OnShow",
								function()
									MoveAny:After(
										buffsDelay,
										function()
											MoveAny:UpdateTargetBuffs()
										end, "TargetFrame OnShow"
									)

									frame:UpdateScaleAndAlpha()
								end
							)

							local bbf = CreateFrame("FRAME")
							MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
							MoveAny:OnEvent(
								bbf,
								function()
									MoveAny:UpdateTargetBuffs()
									frame:UpdateScaleAndAlpha()
								end, "bbf 7"
							)

							hooksecurefunc(
								frame,
								"SetPoint",
								function()
									frame:UpdateScaleAndAlpha()
								end
							)

							hooksecurefunc(
								frame,
								"SetScale",
								function(sel)
									if InCombatLockdown() and sel:IsProtected() then return false end
									if sel.ma_bb_set_scale then return end
									sel.ma_bb_set_scale = true
									frame:UpdateScaleAndAlpha()
									sel.ma_bb_set_scale = false
								end
							)

							frame:UpdateScaleAndAlpha()
						end,
					}
				)
			else
				MoveAny:INFO("TARGETFRAME must be enabled in MoveAny, when you have TargetFrameBuffMover enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:MSG("If TARGETFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if MoveAny:IsEnabled("TARGETFRAMEDEBUFFMOVER", false) then
			if MoveAny:IsEnabled("TARGETFRAME", false) then
				function MoveAny:UpdateTargetDebuffs()
					for i, bb in pairs(MoveAny:UpdateTargetFrameDebuffs()) do
						MoveAny:UpdateChildBuffs(bb, "TargetFrameDebuffMover")
					end
				end

				local TargetFrameDebuffMover = CreateFrame("Frame", "TargetFrameDebuffMover", UIParent)
				TargetFrameDebuffMover:SetSize(21, 21)
				TargetFrameDebuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				MoveAny:RegisterWidget(
					{
						["name"] = "TargetFrameDebuffMover",
						["lstr"] = "LID_TARGETFRAMEDEBUFFMOVER",
						["userplaced"] = true,
						["setup"] = function()
							local frame = TargetFrameDebuffMover
							function frame:UpdateScaleAndAlpha()
								local scale = frame:GetScale()
								local alpha = frame:GetAlpha()
								for i, bb in pairs(MoveAny:UpdateTargetFrameDebuffs()) do
									if bb then
										bb:SetScale(scale)
										bb:SetAlpha(alpha)
									end
								end
							end

							local added = {}
							function frame:Update()
								if TargetFrame and TargetFrame:GetLeft() then
									local frameCenterX, frameCenterY = frame:GetCenter()
									local frameEffectiveScale = frame:GetScale()
									local frameAbsoluteX = frameCenterX / frameEffectiveScale
									local frameAbsoluteY = frameCenterY / frameEffectiveScale
									local targetCenterX, targetCenterY = TargetFrame:GetCenter()
									local targetEffectiveScale = TargetFrame:GetScale()
									local targetAbsoluteX = targetCenterX / targetEffectiveScale
									local targetAbsoluteY = targetCenterY / targetEffectiveScale
									frame.PX = frameAbsoluteX - targetAbsoluteX
									frame.PY = frameAbsoluteY - targetAbsoluteY
									for i, bb in pairs(MoveAny:UpdateTargetFrameDebuffs()) do
										if bb then
											if added[bb] == nil then
												local setPoint = false
												hooksecurefunc(
													bb,
													"SetPoint",
													function(sel, ...)
														if setPoint then return end
														setPoint = true
														local MADEBUFFMODE = MoveAny:GetEleOption("TargetFrameDebuffMover", "MADEBUFFMODE", 0)
														local MADEBUFFLIMIT = MoveAny:GetEleOption("TargetFrameDebuffMover", "MADEBUFFLIMIT", 10)
														local MADEBUFFSPACINGX = MoveAny:GetEleOption("TargetFrameDebuffMover", "MADEBUFFSPACINGX", 4)
														local MADEBUFFSPACINGY = MoveAny:GetEleOption("TargetFrameDebuffMover", "MADEBUFFSPACINGY", 10)
														local row = math.floor((added[bb] - 1) / MADEBUFFLIMIT)
														sel:ClearAllPoints()
														if MADEBUFFMODE == 1 then
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + row * (21 + MADEBUFFSPACINGY))
														else
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + -(row * (21 + MADEBUFFSPACINGY)))
														end

														setPoint = false
													end
												)
											end

											if added[bb] ~= i then
												added[bb] = i
												bb:ClearAllPoints()
												bb:SetPoint("LEFT", TargetFrame, "RIGHT", 0, 0)
											end
										end
									end
								end

								MoveAny:After(
									0.1,
									function()
										frame:Update()
									end, "TargetFrame Update"
								)
							end

							frame:Update()
							TargetFrame:HookScript(
								"OnShow",
								function()
									MoveAny:After(
										buffsDelay,
										function()
											MoveAny:UpdateTargetDebuffs()
										end, "TargetFrame OnShow 2"
									)

									frame:UpdateScaleAndAlpha()
								end
							)

							local bbf = CreateFrame("FRAME")
							MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
							MoveAny:OnEvent(
								bbf,
								function()
									MoveAny:UpdateTargetDebuffs()
									frame:UpdateScaleAndAlpha()
								end, "bbf 7"
							)

							hooksecurefunc(
								frame,
								"SetPoint",
								function()
									frame:UpdateScaleAndAlpha()
								end
							)

							hooksecurefunc(
								frame,
								"SetScale",
								function(sel)
									if InCombatLockdown() and sel:IsProtected() then return false end
									if sel.ma_bb_set_scale then return end
									sel.ma_bb_set_scale = true
									frame:UpdateScaleAndAlpha()
									sel.ma_bb_set_scale = false
								end
							)

							frame:UpdateScaleAndAlpha()
						end,
					}
				)
			else
				MoveAny:INFO("TARGETFRAME must be enabled in MoveAny, when you have TARGETFRAMEDEBUFFMOVER enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:INFO("If TARGETFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if MoveAny:IsEnabled("TARGETFRAMETOTDEBUFFMOVER", false) then
			if MoveAny:IsEnabled("TARGETFRAME", false) then
				function MoveAny:UpdateTargetToTDebuffs()
					for i, bb in pairs(MoveAny:UpdateTargetFrameToTDebuffs()) do
						MoveAny:UpdateChildBuffs(bb, "TargetFrameToTDebuffMover")
					end
				end

				local TargetFrameToTDebuffMover = CreateFrame("Frame", "TargetFrameToTDebuffMover", UIParent)
				TargetFrameToTDebuffMover:SetSize(21, 21)
				TargetFrameToTDebuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				MoveAny:RegisterWidget(
					{
						["name"] = "TargetFrameToTDebuffMover",
						["lstr"] = "LID_TARGETFRAMETOTDEBUFFMOVER",
						["userplaced"] = true,
						["setup"] = function()
							local frame = TargetFrameToTDebuffMover
							function frame:UpdateScaleAndAlpha()
								local scale = frame:GetScale()
								local alpha = frame:GetAlpha()
								for i, bb in pairs(MoveAny:UpdateTargetFrameToTDebuffs()) do
									if bb then
										bb:SetScale(scale)
										bb:SetAlpha(alpha)
									end
								end
							end

							local added = {}
							function frame:Update()
								if TargetFrame and TargetFrame:GetLeft() then
									local frameCenterX, frameCenterY = frame:GetCenter()
									local frameEffectiveScale = frame:GetScale()
									local frameAbsoluteX = frameCenterX / frameEffectiveScale
									local frameAbsoluteY = frameCenterY / frameEffectiveScale
									local targetCenterX, targetCenterY = TargetFrame:GetCenter()
									local targetEffectiveScale = TargetFrame:GetScale()
									local targetAbsoluteX = targetCenterX / targetEffectiveScale
									local targetAbsoluteY = targetCenterY / targetEffectiveScale
									frame.PX = frameAbsoluteX - targetAbsoluteX
									frame.PY = frameAbsoluteY - targetAbsoluteY
									for i, bb in pairs(MoveAny:UpdateTargetFrameToTDebuffs()) do
										if bb then
											if added[bb] == nil then
												local setPoint = false
												hooksecurefunc(
													bb,
													"SetPoint",
													function(sel, ...)
														if setPoint then return end
														setPoint = true
														local MADEBUFFMODE = MoveAny:GetEleOption("TargetFrameToTDebuffMover", "MADEBUFFMODE", 0)
														local MADEBUFFLIMIT = MoveAny:GetEleOption("TargetFrameToTDebuffMover", "MADEBUFFLIMIT", 10)
														local MADEBUFFSPACINGX = MoveAny:GetEleOption("TargetFrameToTDebuffMover", "MADEBUFFSPACINGX", 4)
														local MADEBUFFSPACINGY = MoveAny:GetEleOption("TargetFrameToTDebuffMover", "MADEBUFFSPACINGY", 10)
														local row = math.floor((added[bb] - 1) / MADEBUFFLIMIT)
														sel:ClearAllPoints()
														if MADEBUFFMODE == 1 then
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + row * (21 + MADEBUFFSPACINGY))
														else
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + -(row * (21 + MADEBUFFSPACINGY)))
														end

														setPoint = false
													end
												)
											end

											if added[bb] ~= i then
												added[bb] = i
												bb:ClearAllPoints()
												bb:SetPoint("LEFT", TargetFrame, "RIGHT", 0, 0)
											end
										end
									end
								end

								MoveAny:After(
									0.1,
									function()
										frame:Update()
									end, "TargetFrame Update 2"
								)
							end

							frame:Update()
							TargetFrame:HookScript(
								"OnShow",
								function()
									MoveAny:After(
										buffsDelay,
										function()
											MoveAny:UpdateTargetToTDebuffs()
										end, "t123"
									)

									frame:UpdateScaleAndAlpha()
								end
							)

							local bbf = CreateFrame("FRAME")
							MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
							MoveAny:OnEvent(
								bbf,
								function()
									MoveAny:UpdateTargetToTDebuffs()
									frame:UpdateScaleAndAlpha()
								end, "bbf 6"
							)

							hooksecurefunc(
								frame,
								"SetPoint",
								function()
									frame:UpdateScaleAndAlpha()
								end
							)

							hooksecurefunc(
								frame,
								"SetScale",
								function(sel)
									if InCombatLockdown() and sel:IsProtected() then return false end
									if sel.ma_bb_set_scale then return end
									sel.ma_bb_set_scale = true
									frame:UpdateScaleAndAlpha()
									sel.ma_bb_set_scale = false
								end
							)

							frame:UpdateScaleAndAlpha()
						end,
					}
				)
			else
				MoveAny:INFO("TARGETFRAME must be enabled in MoveAny, when you have TARGETFRAMEDEBUFFMOVER enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:INFO("If TARGETFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if MoveAny:IsEnabled("TARGETFRAMETOTBUFFMOVER", false) then
			if MoveAny:IsEnabled("TARGETFRAME", false) then
				function MoveAny:UpdateTargetToTBuffs()
					for i, bb in pairs(MoveAny:UpdateTargetFrameToTBuffs()) do
						MoveAny:UpdateChildBuffs(bb, "TargetFrameToTBuffMover")
					end
				end

				local TargetFrameToTBuffMover = CreateFrame("Frame", "TargetFrameToTBuffMover", UIParent)
				TargetFrameToTBuffMover:SetSize(21, 21)
				TargetFrameToTBuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				MoveAny:RegisterWidget(
					{
						["name"] = "TargetFrameToTBuffMover",
						["lstr"] = "LID_TARGETFRAMETOTBUFFMOVER",
						["userplaced"] = true,
						["setup"] = function()
							local frame = TargetFrameToTBuffMover
							function frame:UpdateScaleAndAlpha()
								local scale = frame:GetScale()
								local alpha = frame:GetAlpha()
								for i, bb in pairs(MoveAny:UpdateTargetFrameToTBuffs()) do
									if bb then
										bb:SetScale(scale)
										bb:SetAlpha(alpha)
									end
								end
							end

							local added = {}
							function frame:Update()
								if TargetFrame and TargetFrame:GetLeft() then
									local frameCenterX, frameCenterY = frame:GetCenter()
									local frameEffectiveScale = frame:GetScale()
									local frameAbsoluteX = frameCenterX / frameEffectiveScale
									local frameAbsoluteY = frameCenterY / frameEffectiveScale
									local targetCenterX, targetCenterY = TargetFrame:GetCenter()
									local targetEffectiveScale = TargetFrame:GetScale()
									local targetAbsoluteX = targetCenterX / targetEffectiveScale
									local targetAbsoluteY = targetCenterY / targetEffectiveScale
									frame.PX = frameAbsoluteX - targetAbsoluteX
									frame.PY = frameAbsoluteY - targetAbsoluteY
									for i, bb in pairs(MoveAny:UpdateTargetFrameToTBuffs()) do
										if bb then
											if added[bb] == nil then
												local setPoint = false
												hooksecurefunc(
													bb,
													"SetPoint",
													function(sel, ...)
														if setPoint then return end
														setPoint = true
														local MABUFFMODE = MoveAny:GetEleOption("TargetFrameToTBuffMover", "MABUFFMODE", 0)
														local MABUFFLIMIT = MoveAny:GetEleOption("TargetFrameToTBuffMover", "MABUFFLIMIT", 10)
														local MABUFFSPACINGX = MoveAny:GetEleOption("TargetFrameToTBuffMover", "MABUFFSPACINGX", 4)
														local MABUFFSPACINGY = MoveAny:GetEleOption("TargetFrameToTBuffMover", "MABUFFSPACINGY", 10)
														local row = math.floor((added[bb] - 1) / MABUFFLIMIT)
														sel:ClearAllPoints()
														if MABUFFMODE == 1 then
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + row * (21 + MABUFFSPACINGY))
														else
															sel:SetPoint("CENTER", TargetFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + -(row * (21 + MABUFFSPACINGY)))
														end

														setPoint = false
													end
												)
											end

											if added[bb] ~= i then
												added[bb] = i
												bb:ClearAllPoints()
												bb:SetPoint("LEFT", TargetFrame, "RIGHT", 0, 0)
											end
										end
									end
								end

								MoveAny:After(
									0.1,
									function()
										frame:Update()
									end, "t234"
								)
							end

							frame:Update()
							TargetFrame:HookScript(
								"OnShow",
								function()
									MoveAny:After(
										buffsDelay,
										function()
											MoveAny:UpdateTargetToTBuffs()
										end, "t345"
									)

									frame:UpdateScaleAndAlpha()
								end
							)

							local bbf = CreateFrame("FRAME")
							MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
							MoveAny:OnEvent(
								bbf,
								function()
									MoveAny:UpdateTargetToTBuffs()
									frame:UpdateScaleAndAlpha()
								end, "bbf 5"
							)

							hooksecurefunc(
								frame,
								"SetPoint",
								function()
									frame:UpdateScaleAndAlpha()
								end
							)

							hooksecurefunc(
								frame,
								"SetScale",
								function(sel)
									if InCombatLockdown() and sel:IsProtected() then return false end
									if sel.ma_bb_set_scale then return end
									sel.ma_bb_set_scale = true
									frame:UpdateScaleAndAlpha()
									sel.ma_bb_set_scale = false
								end
							)

							frame:UpdateScaleAndAlpha()
						end,
					}
				)
			else
				MoveAny:INFO("TARGETFRAME must be enabled in MoveAny, when you have TARGETFRAMEBUFFMOVER enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:INFO("If TARGETFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if MoveAny:IsEnabled("TARGETFRAME", false) then
			if ComboFrame then
				hooksecurefunc(
					TargetFrame,
					"SetScale",
					function(sel, scale)
						if InCombatLockdown() and sel:IsProtected() then return false end
						if scale and type(scale) == "number" then
							ComboFrame:SetScale(scale)
						end
					end
				)

				ComboFrame:SetScale(TargetFrame:GetScale())
				hooksecurefunc(
					TargetFrame,
					"SetAlpha",
					function(sel, alpha)
						ComboFrame:SetAlpha(alpha)
					end
				)

				ComboFrame:SetAlpha(TargetFrame:GetAlpha())
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "TargetFrame",
					["lstr"] = "LID_TARGETFRAME",
					["userplaced"] = true
				}
			)
		end

		if FocusFrame then
			if MoveAny:IsEnabled("FOCUSFRAMEBUFFMOVER", false) then
				if MoveAny:IsEnabled("FOCUSFRAME", false) then
					function MoveAny:UpdateFocusBuffs()
						for i, bb in pairs(MoveAny:UpdateFocusFrameBuffs()) do
							MoveAny:UpdateChildBuffs(bb, "FocusFrameBuffMover")
						end
					end

					local FocusFrameBuffMover = CreateFrame("Frame", "FocusFrameBuffMover", UIParent)
					FocusFrameBuffMover:SetSize(21, 21)
					FocusFrameBuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					MoveAny:RegisterWidget(
						{
							["name"] = "FocusFrameBuffMover",
							["lstr"] = "LID_FOCUSFRAMEBUFFMOVER",
							["userplaced"] = true,
							["setup"] = function()
								local frame = FocusFrameBuffMover
								function frame:UpdateScaleAndAlpha()
									local scale = frame:GetScale()
									local alpha = frame:GetAlpha()
									for i, bb in pairs(MoveAny:UpdateFocusFrameBuffs()) do
										if bb then
											bb:SetScale(scale)
											bb:SetAlpha(alpha)
										end
									end
								end

								local added = {}
								function frame:Update()
									if FocusFrame and FocusFrame:GetLeft() then
										local frameCenterX, frameCenterY = frame:GetCenter()
										local frameEffectiveScale = frame:GetScale()
										local frameAbsoluteX = frameCenterX / frameEffectiveScale
										local frameAbsoluteY = frameCenterY / frameEffectiveScale
										local focusCenterX, focusCenterY = FocusFrame:GetCenter()
										local focusEffectiveScale = FocusFrame:GetScale()
										local focusAbsoluteX = focusCenterX / focusEffectiveScale
										local focusAbsoluteY = focusCenterY / focusEffectiveScale
										frame.PX = frameAbsoluteX - focusAbsoluteX
										frame.PY = frameAbsoluteY - focusAbsoluteY
										for i, bb in pairs(MoveAny:UpdateFocusFrameBuffs()) do
											if bb then
												if added[bb] == nil then
													local setPoint = false
													hooksecurefunc(
														bb,
														"SetPoint",
														function(sel, ...)
															if setPoint then return end
															setPoint = true
															local MABUFFMODE = MoveAny:GetEleOption("FocusFrameBuffMover", "MABUFFMODE", 0)
															local MABUFFLIMIT = MoveAny:GetEleOption("FocusFrameBuffMover", "MABUFFLIMIT", 10)
															local MABUFFSPACINGX = MoveAny:GetEleOption("FocusFrameBuffMover", "MABUFFSPACINGX", 4)
															local MABUFFSPACINGY = MoveAny:GetEleOption("FocusFrameBuffMover", "MABUFFSPACINGY", 10)
															local row = math.floor((added[bb] - 1) / MABUFFLIMIT)
															sel:ClearAllPoints()
															if MABUFFMODE == 1 then
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + row * (21 + MABUFFSPACINGY))
															else
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + -(row * (21 + MABUFFSPACINGY)))
															end

															setPoint = false
														end
													)
												end

												if added[bb] ~= i then
													added[bb] = i
													bb:ClearAllPoints()
													bb:SetPoint("LEFT", FocusFrame, "RIGHT", 0, 0)
												end
											end
										end
									end

									MoveAny:After(
										0.1,
										function()
											frame:Update()
										end, "t456"
									)
								end

								frame:Update()
								FocusFrame:HookScript(
									"OnShow",
									function()
										MoveAny:After(
											buffsDelay,
											function()
												MoveAny:UpdateFocusBuffs()
											end, "t567"
										)

										frame:UpdateScaleAndAlpha()
									end
								)

								local bbf = CreateFrame("FRAME")
								MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
								MoveAny:OnEvent(
									bbf,
									function()
										MoveAny:UpdateFocusBuffs()
										frame:UpdateScaleAndAlpha()
									end, "bbf 4"
								)

								hooksecurefunc(
									frame,
									"SetPoint",
									function()
										frame:UpdateScaleAndAlpha()
									end
								)

								hooksecurefunc(
									frame,
									"SetScale",
									function(sel)
										if InCombatLockdown() and sel:IsProtected() then return false end
										if sel.ma_bb_set_scale then return end
										sel.ma_bb_set_scale = true
										frame:UpdateScaleAndAlpha()
										sel.ma_bb_set_scale = false
									end
								)

								frame:UpdateScaleAndAlpha()
							end,
						}
					)
				else
					MoveAny:INFO("FOCUSFRAME must be enabled in MoveAny, when you have FocusFrameBuffMover enabled in MoveAny.")
					if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
						MoveAny:MSG("If FOCUSFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
					end
				end
			end

			if MoveAny:IsEnabled("FOCUSFRAMEDEBUFFMOVER", false) then
				if MoveAny:IsEnabled("FOCUSFRAME", false) then
					function MoveAny:UpdateFocusDebuffs()
						for i, bb in pairs(MoveAny:UpdateFocusFrameDebuffs()) do
							MoveAny:UpdateChildBuffs(bb, "FocusFrameDebuffMover")
						end
					end

					local FocusFrameDebuffMover = CreateFrame("Frame", "FocusFrameDebuffMover", UIParent)
					FocusFrameDebuffMover:SetSize(21, 21)
					FocusFrameDebuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					MoveAny:RegisterWidget(
						{
							["name"] = "FocusFrameDebuffMover",
							["lstr"] = "LID_FOCUSFRAMEDEBUFFMOVER",
							["userplaced"] = true,
							["setup"] = function()
								local frame = FocusFrameDebuffMover
								function frame:UpdateScaleAndAlpha()
									local scale = frame:GetScale()
									local alpha = frame:GetAlpha()
									for i, bb in pairs(MoveAny:UpdateFocusFrameDebuffs()) do
										if bb then
											bb:SetScale(scale)
											bb:SetAlpha(alpha)
										end
									end
								end

								local added = {}
								function frame:Update()
									if FocusFrame and FocusFrame:GetLeft() then
										local frameCenterX, frameCenterY = frame:GetCenter()
										local frameEffectiveScale = frame:GetScale()
										local frameAbsoluteX = frameCenterX / frameEffectiveScale
										local frameAbsoluteY = frameCenterY / frameEffectiveScale
										local focusCenterX, focusCenterY = FocusFrame:GetCenter()
										local focusEffectiveScale = FocusFrame:GetScale()
										local focusAbsoluteX = focusCenterX / focusEffectiveScale
										local focusAbsoluteY = focusCenterY / focusEffectiveScale
										frame.PX = frameAbsoluteX - focusAbsoluteX
										frame.PY = frameAbsoluteY - focusAbsoluteY
										for i, bb in pairs(MoveAny:UpdateFocusFrameDebuffs()) do
											if bb then
												if added[bb] == nil then
													local setPoint = false
													hooksecurefunc(
														bb,
														"SetPoint",
														function(sel, ...)
															if setPoint then return end
															setPoint = true
															local MADEBUFFMODE = MoveAny:GetEleOption("FocusFrameDebuffMover", "MADEBUFFMODE", 0)
															local MADEBUFFLIMIT = MoveAny:GetEleOption("FocusFrameDebuffMover", "MADEBUFFLIMIT", 10)
															local MADEBUFFSPACINGX = MoveAny:GetEleOption("FocusFrameDebuffMover", "MADEBUFFSPACINGX", 4)
															local MADEBUFFSPACINGY = MoveAny:GetEleOption("FocusFrameDebuffMover", "MADEBUFFSPACINGY", 10)
															local row = math.floor((added[bb] - 1) / MADEBUFFLIMIT)
															sel:ClearAllPoints()
															if MADEBUFFMODE == 1 then
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + row * (21 + MADEBUFFSPACINGY))
															else
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + -(row * (21 + MADEBUFFSPACINGY)))
															end

															setPoint = false
														end
													)
												end

												if added[bb] ~= i then
													added[bb] = i
													bb:ClearAllPoints()
													bb:SetPoint("LEFT", FocusFrame, "RIGHT", 0, 0)
												end
											end
										end
									end

									MoveAny:After(
										0.1,
										function()
											frame:Update()
										end, "t678"
									)
								end

								frame:Update()
								FocusFrame:HookScript(
									"OnShow",
									function()
										MoveAny:After(
											buffsDelay,
											function()
												MoveAny:UpdateFocusDebuffs()
											end, "t789"
										)

										frame:UpdateScaleAndAlpha()
									end
								)

								local bbf = CreateFrame("FRAME")
								MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
								MoveAny:OnEvent(
									bbf,
									function()
										MoveAny:UpdateFocusDebuffs()
										frame:UpdateScaleAndAlpha()
									end, "bbf 3"
								)

								hooksecurefunc(
									frame,
									"SetPoint",
									function()
										frame:UpdateScaleAndAlpha()
									end
								)

								hooksecurefunc(
									frame,
									"SetScale",
									function(sel)
										if InCombatLockdown() and sel:IsProtected() then return false end
										if sel.ma_bb_set_scale then return end
										sel.ma_bb_set_scale = true
										frame:UpdateScaleAndAlpha()
										sel.ma_bb_set_scale = false
									end
								)

								frame:UpdateScaleAndAlpha()
							end,
						}
					)
				else
					MoveAny:INFO("FOCUSFRAME must be enabled in MoveAny, when you have FOCUSFRAMEDEBUFFMOVER enabled in MoveAny.")
					if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
						MoveAny:INFO("If FOCUSFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
					end
				end
			end

			if MoveAny:IsEnabled("FOCUSFRAMETOTDEBUFFMOVER", false) then
				if MoveAny:IsEnabled("FOCUSFRAME", false) then
					function MoveAny:UpdateFocusToTDebuffs()
						for i, bb in pairs(MoveAny:UpdateFocusFrameToTDebuffs()) do
							MoveAny:UpdateChildBuffs(bb, "FocusFrameToTDebuffMover")
						end
					end

					local FocusFrameToTDebuffMover = CreateFrame("Frame", "FocusFrameToTDebuffMover", UIParent)
					FocusFrameToTDebuffMover:SetSize(21, 21)
					FocusFrameToTDebuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					MoveAny:RegisterWidget(
						{
							["name"] = "FocusFrameToTDebuffMover",
							["lstr"] = "LID_FOCUSFRAMETOTDEBUFFMOVER",
							["userplaced"] = true,
							["setup"] = function()
								local frame = FocusFrameToTDebuffMover
								function frame:UpdateScaleAndAlpha()
									local scale = frame:GetScale()
									local alpha = frame:GetAlpha()
									for i, bb in pairs(MoveAny:UpdateFocusFrameToTDebuffs()) do
										if bb then
											bb:SetScale(scale)
											bb:SetAlpha(alpha)
										end
									end
								end

								local added = {}
								function frame:Update()
									if FocusFrame and FocusFrame:GetLeft() then
										local frameCenterX, frameCenterY = frame:GetCenter()
										local frameEffectiveScale = frame:GetScale()
										local frameAbsoluteX = frameCenterX / frameEffectiveScale
										local frameAbsoluteY = frameCenterY / frameEffectiveScale
										local focusCenterX, focusCenterY = FocusFrame:GetCenter()
										local focusEffectiveScale = FocusFrame:GetScale()
										local focusAbsoluteX = focusCenterX / focusEffectiveScale
										local focusAbsoluteY = focusCenterY / focusEffectiveScale
										frame.PX = frameAbsoluteX - focusAbsoluteX
										frame.PY = frameAbsoluteY - focusAbsoluteY
										for i, bb in pairs(MoveAny:UpdateFocusFrameToTDebuffs()) do
											if bb then
												if added[bb] == nil then
													local setPoint = false
													hooksecurefunc(
														bb,
														"SetPoint",
														function(sel, ...)
															if setPoint then return end
															setPoint = true
															local MADEBUFFMODE = MoveAny:GetEleOption("FocusFrameToTDebuffMover", "MADEBUFFMODE", 0)
															local MADEBUFFLIMIT = MoveAny:GetEleOption("FocusFrameToTDebuffMover", "MADEBUFFLIMIT", 10)
															local MADEBUFFSPACINGX = MoveAny:GetEleOption("FocusFrameToTDebuffMover", "MADEBUFFSPACINGX", 4)
															local MADEBUFFSPACINGY = MoveAny:GetEleOption("FocusFrameToTDebuffMover", "MADEBUFFSPACINGY", 10)
															local row = math.floor((added[bb] - 1) / MADEBUFFLIMIT)
															sel:ClearAllPoints()
															if MADEBUFFMODE == 1 then
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + row * (21 + MADEBUFFSPACINGY))
															else
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MADEBUFFLIMIT) * (21 + MADEBUFFSPACINGX), frame.PY + -(row * (21 + MADEBUFFSPACINGY)))
															end

															setPoint = false
														end
													)
												end

												if added[bb] ~= i then
													added[bb] = i
													bb:ClearAllPoints()
													bb:SetPoint("LEFT", FocusFrame, "RIGHT", 0, 0)
												end
											end
										end
									end

									MoveAny:After(
										0.1,
										function()
											frame:Update()
										end, "t890"
									)
								end

								frame:Update()
								FocusFrame:HookScript(
									"OnShow",
									function()
										MoveAny:After(
											buffsDelay,
											function()
												MoveAny:UpdateFocusToTDebuffs()
											end, "t987"
										)

										frame:UpdateScaleAndAlpha()
									end
								)

								local bbf = CreateFrame("FRAME")
								MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
								MoveAny:OnEvent(
									bbf,
									function()
										MoveAny:UpdateFocusToTDebuffs()
										frame:UpdateScaleAndAlpha()
									end, "bbf 2"
								)

								hooksecurefunc(
									frame,
									"SetPoint",
									function()
										frame:UpdateScaleAndAlpha()
									end
								)

								hooksecurefunc(
									frame,
									"SetScale",
									function(sel)
										if InCombatLockdown() and sel:IsProtected() then return false end
										if sel.ma_bb_set_scale then return end
										sel.ma_bb_set_scale = true
										frame:UpdateScaleAndAlpha()
										sel.ma_bb_set_scale = false
									end
								)

								frame:UpdateScaleAndAlpha()
							end,
						}
					)
				else
					MoveAny:INFO("FOCUSFRAME must be enabled in MoveAny, when you have FOCUSFRAMEDEBUFFMOVER enabled in MoveAny.")
					if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
						MoveAny:INFO("If FOCUSFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
					end
				end
			end

			if MoveAny:IsEnabled("FOCUSFRAMETOTBUFFMOVER", false) then
				if MoveAny:IsEnabled("FOCUSFRAME", false) then
					function MoveAny:UpdateFocusToTBuffs()
						for i, bb in pairs(MoveAny:UpdateFocusFrameToTBuffs()) do
							MoveAny:UpdateChildBuffs(bb, "FocusFrameToTBuffMover")
						end
					end

					local FocusFrameToTBuffMover = CreateFrame("Frame", "FocusFrameToTBuffMover", UIParent)
					FocusFrameToTBuffMover:SetSize(21, 21)
					FocusFrameToTBuffMover:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					MoveAny:RegisterWidget(
						{
							["name"] = "FocusFrameToTBuffMover",
							["lstr"] = "LID_FOCUSFRAMETOTBUFFMOVER",
							["userplaced"] = true,
							["setup"] = function()
								local frame = FocusFrameToTBuffMover
								function frame:UpdateScaleAndAlpha()
									local scale = frame:GetScale()
									local alpha = frame:GetAlpha()
									for i, bb in pairs(MoveAny:UpdateFocusFrameToTBuffs()) do
										if bb then
											bb:SetScale(scale)
											bb:SetAlpha(alpha)
										end
									end
								end

								local added = {}
								function frame:Update()
									if FocusFrame and FocusFrame:GetLeft() then
										local frameCenterX, frameCenterY = frame:GetCenter()
										local frameEffectiveScale = frame:GetScale()
										local frameAbsoluteX = frameCenterX / frameEffectiveScale
										local frameAbsoluteY = frameCenterY / frameEffectiveScale
										local focusCenterX, focusCenterY = FocusFrame:GetCenter()
										local focusEffectiveScale = FocusFrame:GetScale()
										local focusAbsoluteX = focusCenterX / focusEffectiveScale
										local focusAbsoluteY = focusCenterY / focusEffectiveScale
										frame.PX = frameAbsoluteX - focusAbsoluteX
										frame.PY = frameAbsoluteY - focusAbsoluteY
										for i, bb in pairs(MoveAny:UpdateFocusFrameToTBuffs()) do
											if bb then
												if added[bb] == nil then
													local setPoint = false
													hooksecurefunc(
														bb,
														"SetPoint",
														function(sel, ...)
															if setPoint then return end
															setPoint = true
															local MABUFFMODE = MoveAny:GetEleOption("FocusFrameToTBuffMover", "MABUFFMODE", 0)
															local MABUFFLIMIT = MoveAny:GetEleOption("FocusFrameToTBuffMover", "MABUFFLIMIT", 10)
															local MABUFFSPACINGX = MoveAny:GetEleOption("FocusFrameToTBuffMover", "MABUFFSPACINGX", 4)
															local MABUFFSPACINGY = MoveAny:GetEleOption("FocusFrameToTBuffMover", "MABUFFSPACINGY", 10)
															local row = math.floor((added[bb] - 1) / MABUFFLIMIT)
															sel:ClearAllPoints()
															if MABUFFMODE == 1 then
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + row * (21 + MABUFFSPACINGY))
															else
																sel:SetPoint("CENTER", FocusFrame, "CENTER", frame.PX + ((added[bb] - 1) % MABUFFLIMIT) * (21 + MABUFFSPACINGX), frame.PY + -(row * (21 + MABUFFSPACINGY)))
															end

															setPoint = false
														end
													)
												end

												if added[bb] ~= i then
													added[bb] = i
													bb:ClearAllPoints()
													bb:SetPoint("LEFT", FocusFrame, "RIGHT", 0, 0)
												end
											end
										end
									end

									MoveAny:After(
										0.1,
										function()
											frame:Update()
										end, "t876"
									)
								end

								frame:Update()
								FocusFrame:HookScript(
									"OnShow",
									function()
										MoveAny:After(
											buffsDelay,
											function()
												MoveAny:UpdateFocusToTBuffs()
											end, "t765"
										)

										frame:UpdateScaleAndAlpha()
									end
								)

								local bbf = CreateFrame("FRAME")
								MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
								MoveAny:OnEvent(
									bbf,
									function()
										MoveAny:UpdateFocusToTBuffs()
										frame:UpdateScaleAndAlpha()
									end, "bbf"
								)

								hooksecurefunc(
									frame,
									"SetPoint",
									function()
										frame:UpdateScaleAndAlpha()
									end
								)

								hooksecurefunc(
									frame,
									"SetScale",
									function(sel)
										if InCombatLockdown() and sel:IsProtected() then return false end
										if sel.ma_bb_set_scale then return end
										sel.ma_bb_set_scale = true
										frame:UpdateScaleAndAlpha()
										sel.ma_bb_set_scale = false
									end
								)

								frame:UpdateScaleAndAlpha()
							end,
						}
					)
				else
					MoveAny:INFO("FOCUSFRAME must be enabled in MoveAny, when you have FOCUSFRAMEBUFFMOVER enabled in MoveAny.")
					if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
						MoveAny:INFO("If FOCUSFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
					end
				end
			end
		end

		if (FocusFrame and MoveAny:IsEnabled("FOCUSFRAME", false)) or (FocusFrame and FocusFrameSpellBar and MoveAny:IsEnabled("FOCUSFRAMESPELLBAR", false)) then
			MoveAny:RegisterWidget(
				{
					["name"] = "FocusFrame",
					["lstr"] = "LID_FOCUSFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("PETBAR", false) then
			if PetActionBar then
				MoveAny:RegisterWidget(
					{
						["name"] = "PetActionBar",
						["lstr"] = "LID_PETBAR"
					}
				)
			else
				MoveAny:RegisterWidget(
					{
						["name"] = "MAPetBar",
						["lstr"] = "LID_PETBAR"
					}
				)
			end
		end

		if MoveAny:IsEnabled("STANCEBARANCHOR", false) and StanceBar then
			for i = 1, 12 do
				local btn = _G["StanceButton" .. i]
				if btn then
					function btn:GetMAEle()
						return getglobal("StanceBarAnchor")
					end

					if _G["StanceButton" .. i .. "NormalTexture2"] then
						_G["StanceButton" .. i .. "NormalTexture2"]:ClearAllPoints()
						_G["StanceButton" .. i .. "NormalTexture2"]:SetPoint("CENTER", btn, "CENTER", 0, 0)
					end
				end
			end

			hooksecurefunc(
				StanceBarAnchor,
				"SetParent",
				function(sel, parent)
					if parent == MoveAny:GetHidden() then
						StanceBar:SetParent(MoveAny:GetHidden())
					end
				end
			)

			MoveAny:RegisterWidget(
				{
					["name"] = "StanceBarAnchor",
					["lstr"] = "LID_STANCEBARANCHOR",
					["secure"] = true
				}
			)
		end

		local PossessBarFrame = getglobal("PossessBarFrame")
		if PossessActionBar then
			if MoveAny:IsEnabled("POSSESSBAR", false) then
				MoveAny:RegisterWidget(
					{
						["name"] = "PossessActionBar",
						["lstr"] = "LID_POSSESSBAR"
					}
				)
			end
		elseif PossessBarFrame then
			if MoveAny:IsEnabled("POSSESSBAR", false) then
				if PossessBarFrame then
					PossessBarFrame:SetParent(MoveAny:GetMainPanel())
				end

				MoveAny:RegisterWidget(
					{
						["name"] = "PossessBarFrame",
						["lstr"] = "LID_POSSESSBAR"
					}
				)
			end
		end

		if MoveAny:IsEnabled("LEAVEVEHICLE", false) then
			if MainMenuBar then
				if MainMenuBarVehicleLeaveButton then
					MainMenuBarVehicleLeaveButton:SetParent(MoveAny:GetMainPanel())
				end

				if UnitInVehicle and UnitOnTaxi then
					function MoveAny:UpdateVehicleLeaveButton()
						if UnitInVehicle("player") or UnitOnTaxi("player") then
							MainMenuBarVehicleLeaveButton:SetAlpha(1)
						else
							MainMenuBarVehicleLeaveButton:SetAlpha(0)
						end

						MoveAny:After(0.4, MoveAny.UpdateVehicleLeaveButton, "UpdateVehicleLeaveButton")
					end

					MoveAny:UpdateVehicleLeaveButton()
				end
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "MainMenuBarVehicleLeaveButton",
					["lstr"] = "LID_LEAVEVEHICLE"
				}
			)
		end

		if ExtraAbilityContainer then
			if MoveAny:IsEnabled("EXTRAABILITYCONTAINER", false) then
				if MoveAny:IsEnabledBartender4("ExtraActionBar") then
					MoveAny:WARN("Bartender4 is enabled and you enabled ExtraAbilityContainer, only 1 addon should move the ExtraAbilityContainer!")
				else
					ExtraAbilityContainer:SetSize(180, 100)
					MoveAny:RegisterWidget(
						{
							["name"] = "ExtraAbilityContainer",
							["lstr"] = "LID_EXTRAABILITYCONTAINER",
							["userplaced"] = true
						}
					)
				end
			end
		elseif ExtraActionBarFrame then
			if MoveAny:IsEnabled("ExtraActionBarFrame", true) then
				if MoveAny:IsEnabledBartender4("ExtraActionBar") then
					MoveAny:WARN("Bartender4 is enabled and you enabled ExtraAbilityContainer, only 1 addon should move the ExtraAbilityContainer!")
				else
					ExtraActionBarFrame:SetParent(UIParent)
					MoveAny:RegisterWidget(
						{
							["name"] = "ExtraActionBarFrame",
							["lstr"] = "LID_ExtraActionBarFrame",
							["userplaced"] = true
						}
					)

					MoveAny:SetPoint(ExtraActionBarFrame, "CENTER", MainMenuBar, "CENTER", 0, 0)
				end
			end
		elseif ExtraActionButton1 then
			if MoveAny:IsEnabled("ExtraActionButton1", true) then
				if MoveAny:IsEnabledBartender4("ExtraActionBar") then
					MoveAny:WARN("Bartender4 is enabled and you enabled ExtraAbilityContainer, only 1 addon should move the ExtraAbilityContainer!")
				else
					local setParent = false
					hooksecurefunc(
						ExtraActionButton1,
						"SetParent",
						function(sel, parent)
							if setParent then return end
							setParent = true
							sel:SetParent(UIParent)
							setParent = false
						end
					)

					ExtraActionButton1:SetParent(UIParent)
					MoveAny:RegisterWidget(
						{
							["name"] = "ExtraActionButton1",
							["lstr"] = "LID_ExtraActionButton1",
							["userplaced"] = true
						}
					)
				end
			end
		end

		if MoveAny:IsEnabled("TALKINGHEAD", false) and TalkingHeadFrame then
			MoveAny:RegisterWidget(
				{
					["name"] = "TalkingHeadFrame",
					["lstr"] = "LID_TALKINGHEAD",
					["secure"] = true
				}
			)
		end

		if OverrideActionBar and MoveAny:IsEnabled("OVERRIDEACTIONBAR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "OverrideActionBar",
					["lstr"] = "LID_OVERRIDEACTIONBAR"
				}
			)
		end

		if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
			local ABNames = {}
			if MainActionBar then
				ABNames[1] = "MainActionBar"
			else
				ABNames[1] = "MainMenuBar"
			end

			ABNames[2] = "MultiBarBottomLeft"
			ABNames[3] = "MultiBarBottomRight"
			ABNames[4] = "MultiBarRight"
			ABNames[5] = "MultiBarLeft"
			ABNames[6] = "MultiBar" .. 5
			ABNames[7] = "MultiBar" .. 6
			ABNames[8] = "MultiBar" .. 7
			for i = 1, 8 do
				if ABNames[i] and MoveAny:IsEnabled("ACTIONBAR" .. i, false) then
					local name = ABNames[i]
					local lstr = "LID_ACTIONBAR" .. i
					MoveAny:RegisterWidget(
						{
							["name"] = name,
							["lstr"] = lstr,
							["secure"] = true,
							["userplaced"] = true,
						}
					)

					local ab = _G[name]
					if ab then
						for x = 1, 12 do
							ab.btns = ab.btns or {}
							local abtn = _G[name .. "Button" .. x]
							if i == 1 then
								abtn = _G["ActionButton" .. x]
							end

							if abtn then
								function abtn:GetMAEle()
									return ab
								end

								table.insert(ab.btns, abtn)
							else
								MoveAny:ERR("ACTION BUTTON NOT FOUND " .. name)
							end
						end
					end

					local bar = _G[name]
					if bar then
						hooksecurefunc(
							bar,
							"SetPoint",
							function(sel, ...)
								MoveAny:UpdateActionBar(bar)
							end
						)

						hooksecurefunc(
							bar,
							"SetSize",
							function(sel, ...)
								if InCombatLockdown() and sel:IsProtected() then return false end
								if sel.ma_uab_setsize then return end
								sel.ma_uab_setsize = true
								MoveAny:UpdateActionBar(bar)
								sel.ma_uab_setsize = false
							end
						)

						MoveAny:UpdateActionBar(bar)
					end
				end
			end
		end

		if (MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC") and MoveAny:AnyActionbarEnabled() then
			for i = 1, 10 do
				if i ~= 2 and (((i == 1 or i == 5 or i == 6) and MoveAny:IsEnabled("ACTIONBARS", false)) or MoveAny:IsEnabled("ACTIONBAR" .. i, false)) then
					MoveAny:RegisterWidget(
						{
							["name"] = "MAActionBar" .. i,
							["lstr"] = "LID_ACTIONBAR" .. i
						}
					)
				end
			end

			MoveAny:After(
				1,
				function()
					local maxWidth = VERTICAL_MULTI_BAR_WIDTH * 2 + VERTICAL_MULTI_BAR_HORIZONTAL_SPACING
					local topLimit = MinimapCluster:GetBottom() + 20
					local bottomLimit = UIParent:GetBottom() + 8
					if MultiBarBottomRight and maxWidth and MultiBarBottomRight:IsShown() and MultiBarBottomRight:GetRight() and UIParent:GetRight() and MultiBarBottomRight:GetRight() >= UIParent:GetRight() - maxWidth - 16 then
						bottomLimit = MultiBarBottomRight:GetTop() + 8
					else
						bottomLimit = MainMenuBarArtFrame:GetTop() + 24
					end

					local availableSpace = topLimit - bottomLimit
					local contentHeight = VERTICAL_MULTI_BAR_HEIGHT
					local scale = 1
					if contentHeight > availableSpace then
						scale = availableSpace / contentHeight
					end

					if scale < 0 and SHOW_MULTI_ACTIONBAR_3 == "1" and MoveAny:IsEnabled("ACTIONBAR" .. 4, false) then
						MoveAny:INFO("Please disable Actionbar4 in ESC -> Options -> Actionbar4, to get rid of the error.")
						MoveAny:INFO("Actionbar4 will still be shown.")
					end
				end, "Loadaddon 123"
			)
		end

		if MoveAny:IsEnabled("ENDCAPS", false) then
			local MA_LeftEndCap = CreateFrame("FRAME", "MA_LeftEndCap", MoveAny:GetMainPanel())
			MA_LeftEndCap.tex = MA_LeftEndCap:CreateTexture("MA_LeftEndCap.tex", "OVERLAY")
			MA_LeftEndCap.tex:SetAllPoints(MA_LeftEndCap)
			local MA_RightEndCap = CreateFrame("FRAME", "MA_RightEndCap", MoveAny:GetMainPanel())
			MA_RightEndCap.tex = MA_RightEndCap:CreateTexture("MA_RightEndCap.tex", "OVERLAY")
			MA_RightEndCap.tex:SetAllPoints(MA_RightEndCap)
			local factionGroup = UnitFactionGroup("player")
			if MainActionBar and MainActionBar.EndCaps then
				MA_LeftEndCap:SetSize(MainActionBar.EndCaps.LeftEndCap:GetSize())
				MA_LeftEndCap.tex:SetTexCoord(MainActionBar.EndCaps.LeftEndCap:GetTexCoord())
				MA_RightEndCap:SetSize(MainActionBar.EndCaps.RightEndCap:GetSize())
				MA_RightEndCap.tex:SetTexCoord(MainActionBar.EndCaps.RightEndCap:GetTexCoord())
				if factionGroup and factionGroup ~= "Neutral" then
					if factionGroup == "Alliance" then
						MA_LeftEndCap.tex:SetAtlas("ui-hud-actionbar-gryphon-left")
						MA_RightEndCap.tex:SetAtlas("ui-hud-actionbar-gryphon-right")
					elseif factionGroup == "Horde" then
						MA_LeftEndCap.tex:SetAtlas("ui-hud-actionbar-wyvern-left")
						MA_RightEndCap.tex:SetAtlas("ui-hud-actionbar-wyvern-right")
					end
				end

				MainActionBar.EndCaps:SetParent(MoveAny:GetHidden())
				MainActionBar.BorderArt:SetParent(MoveAny:GetHidden())
			elseif MainMenuBar and MainMenuBar.EndCaps then
				MA_LeftEndCap:SetSize(MainMenuBar.EndCaps.LeftEndCap:GetSize())
				MA_LeftEndCap.tex:SetTexCoord(MainMenuBar.EndCaps.LeftEndCap:GetTexCoord())
				MA_RightEndCap:SetSize(MainMenuBar.EndCaps.RightEndCap:GetSize())
				MA_RightEndCap.tex:SetTexCoord(MainMenuBar.EndCaps.RightEndCap:GetTexCoord())
				if factionGroup and factionGroup ~= "Neutral" then
					if factionGroup == "Alliance" then
						MA_LeftEndCap.tex:SetAtlas("ui-hud-actionbar-gryphon-left")
						MA_RightEndCap.tex:SetAtlas("ui-hud-actionbar-gryphon-right")
					elseif factionGroup == "Horde" then
						MA_LeftEndCap.tex:SetAtlas("ui-hud-actionbar-wyvern-left")
						MA_RightEndCap.tex:SetAtlas("ui-hud-actionbar-wyvern-right")
					end
				end

				MainMenuBar.EndCaps:SetParent(MoveAny:GetHidden())
				MainMenuBar.BorderArt:SetParent(MoveAny:GetHidden())
			elseif MainMenuBar and MainMenuBarLeftEndCap then
				MA_LeftEndCap:SetSize(MainMenuBarLeftEndCap:GetSize())
				MA_LeftEndCap.tex:SetTexture(MainMenuBarLeftEndCap:GetTexture())
				MA_LeftEndCap.tex:SetTexCoord(MainMenuBarLeftEndCap:GetTexCoord())
				MA_RightEndCap:SetSize(MainMenuBarRightEndCap:GetSize())
				MA_RightEndCap.tex:SetTexture(MainMenuBarRightEndCap:GetTexture())
				MA_RightEndCap.tex:SetTexCoord(MainMenuBarRightEndCap:GetTexCoord())
				MainMenuBarLeftEndCap:SetParent(MoveAny:GetHidden())
				MainMenuBarRightEndCap:SetParent(MoveAny:GetHidden())
			end

			MA_LeftEndCap:SetFrameLevel(10)
			MA_RightEndCap:SetFrameLevel(10)
			MA_LeftEndCap.tex:SetDrawLayer("OVERLAY", 2)
			MA_RightEndCap.tex:SetDrawLayer("OVERLAY", 2)
			MA_LeftEndCap:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			MA_RightEndCap:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			MoveAny:RegisterWidget(
				{
					["name"] = "MA_LeftEndCap",
					["lstr"] = "LID_ENDCAPLEFT",
				}
			)

			MoveAny:RegisterWidget(
				{
					["name"] = "MA_RightEndCap",
					["lstr"] = "LID_ENDCAPRIGHT",
				}
			)
		end

		if MoveAny:IsEnabled("BLIZZARDACTIONBUTTONSART", false) and MainMenuBarTexture0 then
			local MA_BlizzArt = CreateFrame("FRAME", "MA_BlizzArt", MoveAny:GetMainPanel())
			for i = 0, 1 do
				local blizzpart = MA_BlizzArt:CreateTexture("MA_BlizzArt.part" .. i, "OVERLAY")
				local art = _G["MainMenuBarTexture" .. i]
				local ssw, ssh = 256, 43
				blizzpart:SetPoint("LEFT", MA_BlizzArt, "LEFT", i * ssw, 0)
				blizzpart:SetSize(ssw, ssh)
				blizzpart:SetTexture(art:GetTexture())
				blizzpart:SetTexCoord(art:GetTexCoord())
				blizzpart:SetDrawLayer("ARTWORK", 0)
				MA_BlizzArt:SetSize(ssw * 2, ssh)
				MA_BlizzArt["part" .. i] = blizzpart
			end

			MA_BlizzArt:SetFrameLevel(0)
			MA_BlizzArt:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			MoveAny:RegisterWidget(
				{
					["name"] = "MA_BlizzArt",
					["lstr"] = "LID_BLIZZARDACTIONBUTTONSART",
				}
			)
		end

		for i = 1, 10 do
			if MoveAny:IsEnabled("CHATBUTTONFRAME" .. i, false) then
				local cbf = _G["ChatFrame" .. i .. "ButtonFrame"]
				cbf:EnableMouse(true)
				MoveAny:RegisterWidget(
					{
						["name"] = "ChatFrame" .. i .. "ButtonFrame",
						["lstr"] = "LID_CHATBUTTONFRAME" .. i,
					}
				)

				if i == 1 then
					if ChatFrameMenuButton then
						ChatFrameMenuButton:SetFrameLevel(10)
						ChatFrameMenuButton:SetParent(cbf)
						function ChatFrameMenuButton:GetMAEle()
							return cbf
						end
					end

					if ChatFrameChannelButton then
						ChatFrameChannelButton:SetFrameLevel(10)
						ChatFrameChannelButton:SetParent(cbf)
						function ChatFrameChannelButton:GetMAEle()
							return cbf
						end
					end
				end
			end
		end

		for i = 1, 12 do
			if MoveAny:IsEnabled("CHATEDITBOX", false) then
				local ceb = _G["ChatFrame" .. i .. "EditBox"]
				if ceb then
					hooksecurefunc(
						ceb,
						"SetClampRectInsets",
						function(sel)
							if sel.setclamprectinsets_ma then return end
							sel.setclamprectinsets_ma = true
							sel:SetClampRectInsets(2, 2, 2, 2)
							sel.setclamprectinsets_ma = false
						end
					)

					ceb:SetClampRectInsets(2, 2, 2, 2)
				end
			end
		end

		for i = 1, 12 do
			if MoveAny:IsEnabled("CHATEDITBOX", false) and _G["ChatFrame" .. i .. "Tab"] and _G["ChatFrame" .. i .. "Tab"]:IsShown() then
				MoveAny:RegisterWidget(
					{
						["name"] = "ChatFrame" .. i .. "EditBox",
						["lstr"] = "LID_CHATEDITBOX",
						["lstri"] = i,
					}
				)
			end

			if MoveAny:IsEnabled("CHATTAB", false) and _G["ChatFrame" .. i .. "Tab"] and _G["ChatFrame" .. i .. "Tab"]:IsShown() then
				MoveAny:RegisterWidget(
					{
						["name"] = "ChatFrame" .. i .. "Tab",
						["lstr"] = "LID_CHATTAB",
						["lstri"] = i,
					}
				)
			end
		end

		if MoveAny:IsEnabled("CHATQUICKJOIN", false) then
			QuickJoinToastButton:SetFrameLevel(10)
			MoveAny:RegisterWidget(
				{
					["name"] = "QuickJoinToastButton",
					["lstr"] = "LID_CHATQUICKJOIN"
				}
			)
		end

		for x = 1, 10 do
			local cf = _G["ChatFrame" .. x]
			if cf then
				local cleft = -34
				local cright = 2
				local ctop = 22
				local cbottom = -34
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					cright = 16
				end

				if MoveAny:IsEnabled("CHATBUTTONFRAME" .. x, false) then
					cleft = -2
				end

				if MoveAny:IsEnabled("CHATEDITBOX", false) then
					cbottom = -4
				end

				if MoveAny:IsEnabled("CHAT" .. x, false) then
					MoveAny:RegisterWidget(
						{
							["name"] = "ChatFrame" .. x,
							["lstr"] = "LID_CHAT",
							["lstri"] = x,
							["cleft"] = cleft,
							["cright"] = cright,
							["ctop"] = ctop,
							["cbottom"] = cbottom,
						}
					)
				elseif cf.SetClampRectInsets and MoveAny:IsEnabled("CHAT" .. 1, false) then
					hooksecurefunc(
						cf,
						"SetClampRectInsets",
						function(sel, ...)
							if sel.scri then return end
							sel.scri = true
							sel:SetClampRectInsets(cleft, cright, ctop, cbottom)
							sel.scri = false
						end
					)

					cf:SetClampRectInsets(cleft, cright, ctop, cbottom)
				end
			end
		end

		if ActionBarUpButton and ActionBarDownButton and MoveAny:IsEnabled("MAPAGES", false) then
			local MAPages = CreateFrame("FRAME", "MAPages", MoveAny:GetMainPanel())
			local asw, ash = 18, 18
			MAPages:SetSize(asw, 2 * ash)
			MAPages:SetPoint("CENTER", 0, 0)
			ActionBarUpButton:SetParent(MAPages)
			ActionBarUpButton:ClearAllPoints()
			ActionBarUpButton:SetPoint("TOP", MAPages, "TOP", 0, 7)
			ActionBarDownButton:SetParent(MAPages)
			ActionBarDownButton:ClearAllPoints()
			ActionBarDownButton:SetPoint("BOTTOM", MAPages, "BOTTOM", 0, -8)
			MainMenuBarPageNumber:SetParent(MAPages)
			MainMenuBarPageNumber:ClearAllPoints()
			MainMenuBarPageNumber:SetPoint("LEFT", MAPages, "RIGHT", 4, 0)
			MoveAny:RegisterWidget(
				{
					["name"] = "MAPages",
					["lstr"] = "LID_MAPAGES",
				}
			)
		end

		if MoveAny:IsEnabled("QUESTTIMERFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "QuestTimerFrame",
					["lstr"] = "LID_QUESTTIMERFRAME",
				}
			)
		end

		if MoveAny:IsEnabled("QUESTTRACKER", false) then
			MoveAny:After(
				1,
				function()
					local name = GetUnitName("player") .. " - " .. GetRealmName()
					if MoveAny:IsAddOnLoaded("Questie") and QuestieConfig and QuestieConfig.profileKeys and QuestieConfig.profiles and QuestieConfig.profiles[QuestieConfig.profileKeys[name]] and QuestieConfig.profiles[QuestieConfig.profileKeys[name]].trackerEnabled then
						local questieHelper = CreateFrame("Frame", "questieHelper", UIParent)
						questieHelper:SetSize(300, 300)
						questieHelper:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						local function appendQuestie()
							if Questie_BaseFrame then
								hooksecurefunc(
									Questie_BaseFrame,
									"SetPoint",
									function(sel, ...)
										if sel.ma_helper_setpoint then return end
										sel.ma_helper_setpoint = true
										Questie_BaseFrame:ClearAllPoints()
										Questie_BaseFrame:SetPoint("TOPLEFT", questieHelper, "TOPLEFT", 0, 0)
										sel.ma_helper_setpoint = false
									end
								)

								Questie_BaseFrame:SetPoint("TOPLEFT", questieHelper, "TOPLEFT", 0, 0)
							else
								MoveAny:After(
									0.1,
									function()
										appendQuestie()
									end, "appendQuestie"
								)
							end
						end

						MoveAny:RegisterWidget(
							{
								["name"] = "questieHelper",
								["lstr"] = "LID_QUESTTRACKER",
								["userplaced"] = true,
								["secure"] = true,
								["sh"] = 300,
								["sw"] = 300,
								["setup"] = function()
									appendQuestie()
								end
							}
						)
					else
						if ObjectiveTrackerFrame == nil then
							ObjectiveTrackerFrame = CreateFrame("Frame", "ObjectiveTrackerFrame", MoveAny:GetMainPanel())
							ObjectiveTrackerFrame:SetSize(240, 600)
							ObjectiveTrackerFrame:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -85, -180)
							local QuestWatchFrame = getglobal("QuestWatchFrame")
							local WatchFrame = getglobal("WatchFrame")
							if QuestWatchFrame then
								hooksecurefunc(
									QuestWatchFrame,
									"SetPoint",
									function(sel, ...)
										if sel.qwfsetpoint then return end
										sel.qwfsetpoint = true
										sel:SetMovable(true)
										if sel.SetUserPlaced and sel:IsMovable() then
											sel:SetUserPlaced(false)
										end

										sel:SetParent(ObjectiveTrackerFrame)
										MoveAny:SetPoint(sel, "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
										sel.qwfsetpoint = false
									end
								)

								QuestWatchFrame:SetMovable(true)
								if QuestWatchFrame.SetUserPlaced and QuestWatchFrame:IsMovable() then
									QuestWatchFrame:SetUserPlaced(false)
								end

								QuestWatchFrame:SetParent(ObjectiveTrackerFrame)
								QuestWatchFrame:ClearAllPoints()
								QuestWatchFrame:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
								QuestWatchFrame:SetSize(ObjectiveTrackerFrame:GetSize())
							end

							if WatchFrame then
								hooksecurefunc(
									WatchFrame,
									"SetPoint",
									function(sel, ...)
										if sel.wfsetpoint then return end
										sel.wfsetpoint = true
										sel:SetMovable(true)
										if sel.SetUserPlaced and sel:IsMovable() then
											sel:SetUserPlaced(false)
										end

										sel:SetParent(ObjectiveTrackerFrame)
										MoveAny:SetPoint(sel, "TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
										sel.wfsetpoint = false
									end
								)

								WatchFrame:SetMovable(true)
								if WatchFrame.SetUserPlaced and WatchFrame:IsMovable() then
									WatchFrame:SetUserPlaced(false)
								end

								WatchFrame:SetParent(ObjectiveTrackerFrame)
								WatchFrame:ClearAllPoints()
								WatchFrame:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
								WatchFrame:SetSize(ObjectiveTrackerFrame:GetSize())
							end
						end

						MoveAny:RegisterWidget(
							{
								["name"] = "ObjectiveTrackerFrame",
								["lstr"] = "LID_QUESTTRACKER",
								["userplaced"] = true,
								["secure"] = true,
							}
						)
					end
				end, "QUESTTRACKER"
			)
		end

		if MoveAny:IsEnabled("QUESTITEMSANCHOR", false) then
			local use = USE_COLON or ITEM_SPELL_TRIGGER_ONUSE
			local spacing = 6
			local btnSize = 45
			local maxButtons = 10
			local found = {}
			local QuestItemsAnchor = CreateFrame("Frame", "QuestItemsAnchor", UIParent)
			QuestItemsAnchor:SetSize(btnSize, btnSize)
			QuestItemsAnchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			QuestItemsAnchor:EnableMouse(false)
			MoveAny:RegisterWidget(
				{
					["name"] = "QuestItemsAnchor",
					["lstr"] = "LID_QUESTITEMSANCHOR",
					["userplaced"] = true,
					["secure"] = true,
				}
			)

			local scanTT = CreateFrame("GameTooltip", "QIB_ScanTooltip", nil, "GameTooltipTemplate")
			local function ItemHasUseEffect(link)
				if not link then return false end
				scanTT:ClearLines()
				scanTT:SetHyperlink(link)
				for i = 2, scanTT:NumLines() do
					local leftLine = _G["QIB_ScanTooltipTextLeft" .. i]
					if leftLine then
						local text = leftLine:GetText()
						if text and text:find(use) then return true end
					end
				end

				return false
			end

			local bar = CreateFrame("Frame", "QIBarFrame", QuestItemsAnchor)
			bar:SetSize(btnSize, btnSize)
			bar:SetPoint("LEFT", QuestItemsAnchor, "LEFT", 0, 0)
			bar:Show()
			bar:EnableMouse(false)
			scanTT:SetOwner(UIParent, "ANCHOR_NONE")
			local QUEST_ITEM_TOKEN = ITEM_BIND_QUEST or ITEM_BIND_QUESTABLE or "Quest Item"
			local function GetItemIDFromLink(link)
				if not link then return nil end
				local id = link:match("item:(%d+):")
				if not id then
					id = link:match("item:(%d+)")
				end

				return tonumber(id)
			end

			local function CreateQuestButton(i)
				local b = CreateFrame("Button", "QIB_QuestButton" .. i, bar, "SecureActionButtonTemplate")
				b:SetSize(btnSize, btnSize)
				b.cooldown = CreateFrame("Cooldown", "$parentCooldown", b, "CooldownFrameTemplate")
				b.cooldown:SetAllPoints(b)
				b:RegisterEvent("BAG_UPDATE_COOLDOWN")
				b:RegisterEvent("PLAYER_ENTERING_WORLD")
				b:SetScript(
					"OnEvent",
					function(sel, event)
						local itemName = sel:GetAttribute("item")
						if itemName == nil then return end
						local itemID = GetItemInfoInstant(itemName)
						if itemID then
							local start, duration, enable = C_Container.GetItemCooldown(itemID)
							if enable == 1 and duration > 0 then
								sel.cooldown:SetCooldown(start, duration)
							else
								sel.cooldown:Clear()
							end
						else
							sel.cooldown:Clear()
						end
					end
				)

				if true then
					b.icon = _G[b:GetName() .. "Icon"] or b:CreateTexture(nil, "ARTWORK")
					b.icon:SetAllPoints(b)
					b.count = _G[b:GetName() .. "Count"] or b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
					b.count:SetPoint("BOTTOMRIGHT", -2, 2)
					b:SetNormalTexture("UI-HUD-ActionBar-IconFrame-AddRow")
					b:GetNormalTexture():SetSize(54, 53)
					b:GetNormalTexture():ClearAllPoints()
					b:GetNormalTexture():SetPoint("TOPLEFT")
					b:SetHighlightTexture("UI-HUD-ActionBar-IconFrame-Mouseover", "ADD")
					b:GetHighlightTexture():SetSize(49, 48)
					b:GetHighlightTexture():ClearAllPoints()
					b:GetHighlightTexture():SetPoint("TOPLEFT")
					b:SetPushedTexture("UI-HUD-ActionBar-IconFrame-Down")
					b:GetPushedTexture():SetSize(49, 48)
					b:GetPushedTexture():ClearAllPoints()
					b:GetPushedTexture():SetPoint("TOPLEFT")
				end

				b:RegisterForClicks("AnyUp", "AnyDown")
				b:SetAttribute("type", "item")
				b:HookScript(
					"OnEnter",
					function(sel)
						if sel.link then
							GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
							GameTooltip:SetHyperlink(sel.link)
							GameTooltip:Show()
						end
					end
				)

				b:HookScript(
					"OnLeave",
					function()
						GameTooltip:Hide()
					end
				)

				return b
			end

			local buttons = {}
			for i = 1, maxButtons do
				buttons[i] = CreateQuestButton(i)
				buttons[i]:SetPoint("LEFT", bar, "LEFT", (i - 1) * (btnSize + spacing), 0)
				buttons[i]:SetAlpha(0)
				buttons[i]:EnableMouse(false)
			end

			local function ClearFound()
				for k in pairs(found) do
					found[k] = nil
				end
			end

			local function TooltipHasQuestToken()
				for i = 1, scanTT:NumLines() do
					local line = _G["QIB_ScanTooltipTextLeft" .. i]
					if not line then break end
					local text = line:GetText()
					if text and text:find(QUEST_ITEM_TOKEN) then return true end
				end

				return false
			end

			local function IsQuestItem(itemInfo)
				local _, _, _, _, _, itemType = C_Item.GetItemInfo(itemInfo)
				if itemType == "Quest" then return true end

				return false
			end

			local function ScanBags()
				ClearFound()
				for bag = 0, NUM_BAG_SLOTS do
					local slots = MoveAny:GetContainerNumSlots(bag)
					if slots and slots > 0 then
						for slot = 1, slots do
							local link = MoveAny:GetContainerItemLink(bag, slot)
							if link and ItemHasUseEffect(link) then
								scanTT:ClearLines()
								scanTT:SetBagItem(bag, slot)
								if TooltipHasQuestToken() or IsQuestItem(link) then
									local key = string.format("%d:%d", bag, slot)
									local _, count = MoveAny:GetContainerItemInfo(bag, slot)
									local itemID = GetItemIDFromLink(link)
									found[key] = {
										link = link,
										bag = bag,
										slot = slot,
										count = count or 1,
										itemID = itemID,
									}
								end
							end
						end
					end
				end
			end

			local function RefreshBar()
				for i = 1, #buttons do
					buttons[i]:SetAlpha(0)
					buttons[i]:SetAttribute("item", nil)
					buttons[i].link = nil
					buttons[i]:EnableMouse(false)
				end

				local i = 1
				for key, info in pairs(found) do
					if i > #buttons then break end
					local b = buttons[i]
					if b.icon then
						b.icon:SetTexture(select(10, GetItemInfo(info.link)) or GetItemIcon(info.link))
					end

					if b.count then
						b.count:SetText(info.count > 1 and tostring(info.count) or "")
					end

					b.link = info.link
					b:SetAttribute("item", info.link)
					b:SetAlpha(1)
					b:EnableMouse(true)
					i = i + 1
				end

				local visible = i - 1
				if visible == 0 then
					bar:SetWidth(0)
					bar:SetHeight(0)
				else
					bar:SetWidth(visible * (btnSize + spacing) - spacing)
					bar:SetHeight(btnSize)
				end
			end

			local inCombat = false
			local function Update()
				if inCombat then return end
				if InCombatLockdown() then
					inCombat = true
					C_Timer.After(
						0.1,
						function()
							inCombat = false
							Update()
						end
					)

					return
				end

				ScanBags()
				RefreshBar()
			end

			local evt = CreateFrame("Frame")
			evt:RegisterEvent("BAG_UPDATE_DELAYED")
			evt:RegisterEvent("PLAYER_ENTERING_WORLD")
			evt:RegisterEvent("BAG_UPDATE")
			evt:RegisterEvent("QUEST_ACCEPTED")
			evt:RegisterEvent("QUEST_COMPLETE")
			evt:SetScript(
				"OnEvent",
				function(sel, event, ...)
					if event == "QUEST_ACCEPTED" then
						C_Timer.After(
							0.3,
							function()
								Update()
							end
						)
					else
						Update()
					end
				end
			)

			C_Timer.After(1, Update)
		end

		if MoveAny:IsEnabled("PARTYFRAME", false) then
			if PartyFrame then
				MoveAny:RegisterWidget(
					{
						["name"] = "PartyFrame",
						["lstr"] = "LID_PARTYFRAME",
						["sw"] = 120,
						["sh"] = 244
					}
				)
			else
				for x = 1, 4 do
					MoveAny:RegisterWidget(
						{
							["name"] = "PartyMemberFrame" .. x,
							["lstr"] = "LID_PARTYMEMBERFRAME",
							["lstri"] = x
						}
					)
				end
			end
		end

		if MoveAny:IsEnabled("COMPACTRAIDFRAMECONTAINER", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "CompactRaidFrameContainer",
					["lstr"] = "LID_COMPACTRAIDFRAMECONTAINER",
					["sw"] = 360,
					["sh"] = 288
				}
			)
		end

		if MoveAny:IsEnabled("MAPETFRAME", false) then
			MAPetFrame = CreateFrame("FRAME", "MAPetFrame", MoveAny:GetMainPanel())
			if PetFrame:GetSize() then
				MAPetFrame:SetSize(PetFrame:GetSize())
			end

			local p1, p2, p3, p4, p5 = PetFrame:GetPoint()
			if p1 and p3 then
				MAPetFrame:SetPoint(p1, p2, p3, p4, p5)
			else
				MAPetFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			end

			hooksecurefunc(
				MAPetFrame,
				"SetAlpha",
				function(sel, alpha)
					PetFrame:SetAlpha(alpha)
				end
			)

			local secureFlagPetFrame = false
			hooksecurefunc(
				PetFrame,
				"SetPoint",
				function(sel, ...)
					if secureFlagPetFrame then return end
					secureFlagPetFrame = true
					MoveAny:SetPoint(sel, "CENTER", MAPetFrame, "CENTER", 0, 0)
					secureFlagPetFrame = false
				end
			)

			MoveAny:SetPoint(PetFrame, "CENTER", MAPetFrame, "CENTER", 0, 0)
			MoveAny:RegisterWidget(
				{
					["name"] = "MAPetFrame",
					["lstr"] = "LID_PETFRAME",
					["userplaced"] = true
				}
			)
		end

		if PetFrameHappiness and MoveAny:IsEnabled("PETFRAMEHAPPINESS", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "PetFrameHappiness",
					["lstr"] = "LID_PETFRAMEHAPPINESS"
				}
			)
		end

		if MoveAny:IsEnabled("TARGETFRAMESPELLBAR", false) then
			if MoveAny:IsEnabled("TARGETFRAME", false) then
				MoveAny:OnEvent(
					TargetFrameSpellBar,
					function(sel, event)
						if event ~= "UNIT_SPELLCAST_INTERRUPTED" and event ~= "UNIT_SPELLCAST_STOP" then
							MoveAny:UpdateAlpha(sel)
						end
					end, "TargetFrameSpellBar"
				)

				MoveAny:RegisterWidget(
					{
						["name"] = "TargetFrameSpellBar",
						["lstr"] = "LID_TARGETFRAMESPELLBAR",
						["userplaced"] = true
					}
				)
			else
				MoveAny:INFO("TARGETFRAME must be enabled in MoveAny, when you have TARGETFRAMESPELLBAR enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:INFO("If TARGETFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if FocusFrame and FocusFrameSpellBar and MoveAny:IsEnabled("FOCUSFRAMESPELLBAR", false) then
			if MoveAny:IsEnabled("FOCUSFRAME", false) then
				MoveAny:OnEvent(
					FocusFrameSpellBar,
					function(sel, event)
						if event ~= "UNIT_SPELLCAST_INTERRUPTED" and event ~= "UNIT_SPELLCAST_STOP" then
							MoveAny:UpdateAlpha(sel)
						end
					end, "FocusFrameSpellBar"
				)

				MoveAny:RegisterWidget(
					{
						["name"] = "FocusFrameSpellBar",
						["lstr"] = "LID_FOCUSFRAMESPELLBAR",
						["userplaced"] = true
					}
				)
			else
				MoveAny:INFO("FOCUSFRAME must be enabled in MoveAny, when you have FOCUSFRAMESPELLBAR enabled in MoveAny.")
				if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
					MoveAny:INFO("If FOCUSFRAME is enabled in Blizzard-Editmode, you need to disable it there in the Blizzard-Editmode")
				end
			end
		end

		if MoveAny:IsEnabled("TARGETOFTARGETFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "TargetFrameToT",
					["lstr"] = "LID_TARGETOFTARGETFRAME",
					["userplaced"] = true
				}
			)
		end

		if FocusFrame and MoveAny:IsEnabled("TARGETOFFOCUSFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "FocusFrameToT",
					["lstr"] = "LID_TARGETOFFOCUSFRAME",
					["userplaced"] = true
				}
			)
		end

		if CompactRaidFrameManager and MoveAny:IsEnabled("COMPACTRAIDFRAMEMANAGER", false) then
			local MACompactRaidFrameManager = CreateFrame("Frame", "MACompactRaidFrameManager", MoveAny:GetMainPanel())
			if CompactRaidFrameManager then
				local _, rsh = CompactRaidFrameManager:GetSize()
				MACompactRaidFrameManager:SetSize(20, rsh)
			end

			local _, h = MACompactRaidFrameManager:GetSize()
			if h < 10 then
				MACompactRaidFrameManager:SetSize(20, 135)
			end

			MACompactRaidFrameManager:SetPoint("TOPLEFT", MoveAny:GetMainPanel(), "TOPLEFT", 0, -250)
			hooksecurefunc(
				CompactRaidFrameManager,
				"SetPoint",
				function(sel, ...)
					if sel.crfmsetpoint then return end
					sel.crfmsetpoint = true
					sel:SetMovable(true)
					if sel.SetUserPlaced and sel:IsMovable() then
						sel:SetUserPlaced(false)
					end

					if not InCombatLockdown() then
						MoveAny:SetPoint(sel, "RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0)
					end

					sel.crfmsetpoint = false
				end
			)

			CompactRaidFrameManager:SetPoint("RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0)
			hooksecurefunc(
				MACompactRaidFrameManager,
				"SetParent",
				function(sel, parent)
					if parent == MoveAny:GetHidden() then
						CompactRaidFrameManager:SetAlpha(0)
						MoveAny:ForeachChildren(
							CompactRaidFrameManager,
							function(child)
								if child ~= CompactRaidFrameManagerBg and child ~= CompactRaidFrameManagerBorderRight and child ~= CompactRaidFrameManagerToggleButton then
									child:SetIgnoreParentAlpha(true)
								end
							end, "MACompactRaidFrameManager"
						)
					end
				end
			)

			hooksecurefunc(
				CompactRaidFrameManager,
				"SetParent",
				function(sel, parent)
					sel:SetFrameStrata("LOW")
				end
			)

			if CompactRaidFrameManagerToggleButton then
				CompactRaidFrameManagerToggleButton:HookScript(
					"OnClick",
					function(sel, ...)
						if not InCombatLockdown() then
							if CompactRaidFrameManager.collapsed then
								MACompactRaidFrameManager:SetSize(20, 135)
							else
								MACompactRaidFrameManager:SetSize(200, 135)
							end
						end
					end
				)
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "MACompactRaidFrameManager",
					["lstr"] = "LID_COMPACTRAIDFRAMEMANAGER"
				}
			)
		end

		if MoveAny:IsAddOnLoaded("!KalielsTracker") and MoveAny:IsEnabled("!KalielsTrackerButtons", false) then
			MoveAny:After(
				2,
				function()
					local ktb = _G["!KalielsTrackerButtons"]
					if ktb then
						local MAKTB = CreateFrame("FRAME", "MAKTB", MoveAny:GetMainPanel())
						local size = 28
						local kbr = 6
						MAKTB:SetSize(size, size * 3 + kbr * 2)
						hooksecurefunc(
							ktb,
							"SetPoint",
							function(sel, ...)
								if sel.ma_ktb_setpoint then return end
								sel.ma_ktb_setpoint = true
								MoveAny:SetPoint(sel, "TOP", MAKTB, "TOP", 0, kbr)
								sel.ma_ktb_setpoint = false
							end
						)

						ktb:SetPoint("TOP", MAKTB, "TOP", 0, kbr)
						MoveAny:RegisterWidget(
							{
								["name"] = "MAKTB",
								["lstr"] = "LID_!KalielsTrackerButtons",
							}
						)
					else
						MoveAny:ERR("FAILED TO ADD !KalielsTrackerButtons, button ís not created")
					end
				end, "KalielsTracker"
			)
		end

		-- TOP
		if MoveAny:IsEnabled("ZONETEXTFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "ZoneTextFrame",
					["lstr"] = "LID_ZONETEXTFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("OBJECTIVETRACKERBONUSBANNERFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "ObjectiveTrackerBonusBannerFrame",
					["lstr"] = "LID_OBJECTIVETRACKERBONUSBANNERFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("RAIDBOSSEMOTEFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "RaidBossEmoteFrame",
					["lstr"] = "LID_RAIDBOSSEMOTEFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("TIMERTRACKER1", false) then
			if TimerTrackerTimer1 == nil and TimerTracker and TimerTracker_StartTimerOfType then
				TimerTracker_StartTimerOfType(TimerTracker, 2, 0, 0)
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "TimerTrackerTimer1",
					["lstr"] = "LID_TIMERTRACKER1",
				}
			)
		end

		if MoveAny:IsEnabled("MIRRORTIMER1", false) then
			if MirrorTimerContainer then
				MirrorTimerContainer:SetSize(206, 32)
				MoveAny:RegisterWidget(
					{
						["name"] = "MirrorTimerContainer",
						["lstr"] = "LID_MIRRORTIMER1",
					}
				)
			else
				MoveAny:RegisterWidget(
					{
						["name"] = "MirrorTimer1",
						["lstr"] = "LID_MIRRORTIMER1",
					}
				)
			end
		end

		if EncounterBar and MoveAny:IsEnabled("ENCOUNTERBAR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "EncounterBar",
					["lstr"] = "LID_ENCOUNTERBAR",
					["sw"] = 36,
					["sh"] = 36
				}
			)
		elseif UIWidgetPowerBarContainerFrame and MoveAny:IsEnabled("UIWIDGETPOWERBAR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "UIWidgetPowerBarContainerFrame",
					["lstr"] = "LID_UIWIDGETPOWERBAR",
					["sw"] = 36,
					["sh"] = 36
				}
			)
		end

		if PlayerPowerBarAlt and MoveAny:IsEnabled("POWERBAR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "PlayerPowerBarAlt",
					["lstr"] = "LID_POWERBAR",
					["userplaced"] = true,
					["sw"] = 36,
					["sh"] = 36,
					["setup"] = function()
						if UIPARENT_MANAGED_FRAME_POSITIONS then
							UIPARENT_MANAGED_FRAME_POSITIONS["PlayerPowerBarAlt"] = nil
							for k, v in next, UIPARENT_MANAGED_FRAME_POSITIONS do
								v.playerPowerBarAlt = nil
							end
						end

						PlayerPowerBarAlt.ignoreFramePositionManager = true
					end
				}
			)

			if BuffTimer1 == nil then
				BuffTimer1 = CreateFrame("Frame", "BuffTimer" .. 1, UIParent, "UnitPowerBarAltTemplate")
				BuffTimer1.unit = "player"
				BuffTimer1:SetScript("OnEvent", nil)
				BuffTimer1:SetScript("OnUpdate", PlayerBuffTimer_OnUpdate)
				BuffTimer1:SetSize(256, 64)
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "BuffTimer1",
					["lstr"] = "LID_BUFFTIMER1",
					["userplaced"] = true,
					["setup"] = function()
						if UIPARENT_MANAGED_FRAME_POSITIONS then
							UIPARENT_MANAGED_FRAME_POSITIONS["BuffTimer1"] = nil
						end

						BuffTimer1.ignoreFramePositionManager = true
					end
				}
			)
		end

		if MoveAny:IsEnabled("MICROMENU", false) then
			if MoveAny:IsEnabled("MICROMENU", false) and MoveAny:IsEnabledBartender4("MicroMenu") then
				MoveAny:WARN("Bartender4 is enabled and you enabled MICROMENU, only 1 addon should move the MICROMENU!")
			end

			if MoveAny:IsEnabled("MICROMENU", false) and MoveAny:IsAddOnLoaded("Dominos") then
				MoveAny:WARN("Dominos is enabled and you enabled MICROMENU, only 1 addon should move the MICROMENU!")
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "MAMenuBar",
					["lstr"] = "LID_MICROMENU"
				}
			)
		end

		if MoveAny:IsEnabled("BAGS", false) then
			if MoveAny:IsEnabled("BAGS", false) and MoveAny:IsEnabledBartender4("BagBar") then
				MoveAny:WARN("Bartender4 is enabled and you enabled BAGS, only 1 addon should move the BAGS!")
			end

			if MoveAny:IsEnabled("BAGS", false) and MoveAny:IsAddOnLoaded("Dominos") then
				MoveAny:WARN("Dominos is enabled and you enabled BAGS, only 1 addon should move the BAGS!")
			end

			MoveAny:After(
				0,
				function()
					MoveAny:RegisterWidget(
						{
							["name"] = "BagsBar",
							["lstr"] = "LID_BAGS"
						}
					)
				end, "BAGS"
			)
		end

		if MoveAny:IsEnabled("BUFFS", false) then
			if (MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC") and BuffFrame then
				MoveAny:RegisterWidget(
					{
						["name"] = "BuffFrame",
						["lstr"] = "LID_BUFFS"
					}
				)
			else
				MoveAny:RegisterWidget(
					{
						["name"] = "MABuffBar",
						["lstr"] = "LID_BUFFS"
					}
				)
			end
		end

		if MoveAny:IsEnabled("DEBUFFS", false) then
			if (MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC") and DebuffFrame then
				MoveAny:RegisterWidget(
					{
						["name"] = "DebuffFrame",
						["lstr"] = "LID_DEBUFFS"
					}
				)
			else
				MoveAny:RegisterWidget(
					{
						["name"] = "MADebuffBar",
						["lstr"] = "LID_DEBUFFS"
					}
				)
			end
		end

		if MoveAny:IsEnabled("GAMETOOLTIP", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "MAGameTooltip",
					["lstr"] = "LID_GAMETOOLTIP"
				}
			)
		end

		if MoveAny:IsEnabled("MAFPSFrame", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "MAFPSFrame",
					["lstr"] = "LID_MAFPSFrame"
				}
			)
		end

		if MoveAny:IsAddOnLoaded("MoveAny") then
			if MoveAny:IsEnabled("MONEYBAR", true) then
				MoveAny:RegisterWidget(
					{
						["name"] = "IAMoneyBar",
						["lstr"] = "LID_MONEYBAR"
					}
				)
			end

			if MoveAny:IsEnabled("TOKENBAR", true) then
				MoveAny:RegisterWidget(
					{
						["name"] = "IATokenBar",
						["lstr"] = "LID_TOKENBAR"
					}
				)
			end

			if MoveAny:IsEnabled("IAILVLBAR", true) then
				MoveAny:RegisterWidget(
					{
						["name"] = "IAILVLBar",
						["lstr"] = "LID_IAILVLBAR"
					}
				)
			end

			if MoveAny:IsEnabled("IAPingFrame", true) then
				MoveAny:RegisterWidget(
					{
						["name"] = "IAPingFrame",
						["lstr"] = "LID_IAPingFrame"
					}
				)
			end

			if MoveAny:IsEnabled("IACoordsFrame", true) then
				MoveAny:RegisterWidget(
					{
						["name"] = "IACoordsFrame",
						["lstr"] = "LID_IACoordsFrame"
					}
				)
			end

			if MoveAny:IsEnabled("IASKILLS", true) and (MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC") then
				MoveAny:RegisterWidget(
					{
						["name"] = "IASkills",
						["lstr"] = "LID_IASKILLS"
					}
				)
			end
		end

		if MoveAny:IsEnabled("UIWIDGETTOPCENTER", false) and UIWidgetTopCenterContainerFrame then
			MoveAny:RegisterWidget(
				{
					["name"] = "UIWidgetTopCenterContainerFrame",
					["lstr"] = "LID_UIWIDGETTOPCENTER",
					["sw"] = 36 * 5,
					["sh"] = 36 * 2,
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("UIWIDGETBELOWMINIMAP", false) and UIWidgetBelowMinimapContainerFrame then
			MoveAny:RegisterWidget(
				{
					["name"] = "UIWidgetBelowMinimapContainerFrame",
					["lstr"] = "LID_UIWIDGETBELOWMINIMAP",
					["sw"] = 36 * 5,
					["sh"] = 36 * 2,
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsValidFrame(QueueStatusButton) and MoveAny:IsEnabled("QUEUESTATUSBUTTON", false) then
			local setParent = false
			hooksecurefunc(
				QueueStatusButton,
				"SetParent",
				function(sel, parent)
					if setParent then return end
					setParent = true
					sel:SetParent(UIParent)
					setParent = false
				end
			)

			QueueStatusButton:SetParent(UIParent)
			MoveAny:RegisterWidget(
				{
					["name"] = "QueueStatusButton",
					["lstr"] = "LID_QUEUESTATUSBUTTON",
					["userplaced"] = true,
					["secure"] = true
				}
			)
		end

		if MoveAny:IsEnabled("QUEUESTATUSFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "QueueStatusFrame",
					["lstr"] = "LID_QUEUESTATUSFRAME"
				}
			)
		end

		if MoveAny:IsEnabled("BNToastFrame", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "BNToastFrame",
					["lstr"] = "LID_BNToastFrame"
				}
			)
		end

		if MoveAny:IsEnabled("VEHICLESEATINDICATOR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "MAVehicleSeatIndicator",
					["lstr"] = "LID_VEHICLESEATINDICATOR"
				}
			)
		end

		if MoveAny:IsEnabled("DURABILITY", false) then
			if DurabilityFrame:GetPoint() == nil then
				DurabilityFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -0, 0)
			end

			if DurabilityFrame.SetAlerts ~= nil then
				DurabilityFrame:SetAlerts()
			elseif DurabilityFrame_SetAlerts ~= nil then
				DurabilityFrame_SetAlerts()
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "DurabilityFrame",
					["lstr"] = "LID_DURABILITY",
					["userplaced"] = true
				}
			)
		end

		if ArenaEnemyFramesContainer then
			if MoveAny:IsEnabled("ARENAENEMYFRAMESCONTAINER", false) then
				if ArenaEnemyFramesContainer:GetPoint() == nil then
					MoveAny:TrySetParent(ArenaEnemyFramesContainer, UIParent)
					MoveAny:SetPoint(ArenaEnemyFramesContainer, "CENTER", UIParent, "CENTER", 0, 0)
				end

				MoveAny:RegisterWidget(
					{
						["name"] = "ArenaEnemyFramesContainer",
						["lstr"] = "LID_ARENAENEMYFRAMESCONTAINER",
						["userplaced"] = true,
						["secure"] = true,
						["sw"] = 245,
						["sh"] = 305,
					}
				)
			end
		else
			if Arena_LoadUI then
				if MoveAny:IsEnabled("ARENAENEMYFRAMES", false) then
					MoveAny:RegisterWidget(
						{
							["name"] = "MAArenaEnemyFrames",
							["lstr"] = "LID_ARENAENEMYFRAMES",
							["userplaced"] = true,
							["secure"] = true
						}
					)
				end

				if MoveAny:IsEnabled("ARENAPREPFRAMES", false) then
					MoveAny:RegisterWidget(
						{
							["name"] = "MAArenaPrepFrames",
							["lstr"] = "LID_ARENAPREPFRAMES",
							["userplaced"] = true,
							["secure"] = true
						}
					)
				end
			end
		end

		if MoveAny:IsEnabled("BOSSTARGETFRAMECONTAINER", false) then
			if BossTargetFrameContainer then
				MoveAny:RegisterWidget(
					{
						["name"] = "BossTargetFrameContainer",
						["lstr"] = "LID_BOSSTARGETFRAMECONTAINER",
						["userplaced"] = true,
						["secure"] = true,
						["sw"] = 282,
						["sh"] = 305,
					}
				)
			else
				for i = 1, 6 do
					local frame = _G["Boss" .. i .. "TargetFrame"]
					if frame then
						frame:SetScale(1)
						if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
							hooksecurefunc(
								frame,
								"Show",
								function(sel)
									sel.ma_show = true
									sel:SetAlpha(1)
								end
							)

							hooksecurefunc(
								frame,
								"Hide",
								function(sel)
									sel.ma_show = false
									sel:SetAlpha(0)
								end
							)

							hooksecurefunc(
								frame,
								"SetAlpha",
								function(sel, alpha)
									if sel.ma_set_alpha then return end
									sel.ma_set_alpha = true
									if UnitExists(frame.unit) or sel.ma_show or alpha > 0 then
										local a = alpha or 1
										sel:SetAlpha(a)
									else
										sel:SetAlpha(1)
									end

									sel.ma_set_alpha = false
								end
							)

							-- So Blizzard dont do shit with them
							function frame:IsShown()
								return false
							end
						end

						MoveAny:RegisterWidget(
							{
								["name"] = "Boss" .. i .. "TargetFrame",
								["lstr"] = "LID_BOSS" .. i,
								["userplaced"] = true,
								["secure"] = true
							}
						)
					end
				end

				function MoveAny:BossCount()
					local count = 0
					for i = 1, 5 do
						local frame = _G["Boss" .. i .. "TargetFrame"]
						if frame and UnitExists("boss" .. i) then
							count = count + 1
						end
					end

					return count
				end

				function MoveAny:HandleBossFrames()
					for i = 1, 6 do
						local frame = _G["Boss" .. i .. "TargetFrame"]
						local unit = "boss" .. i
						if frame then
							if UnitExists(unit) then
								frame.ma_show = true
								frame:SetAlpha(1)
							else
								frame.ma_show = false
								frame:SetAlpha(0)
							end
						end
					end

					MoveAny:After(1, MoveAny.HandleBossFrames, "HandleBossFrames")
				end

				MoveAny:HandleBossFrames()
			end
		end

		if TicketStatusFrame and MoveAny:IsEnabled("TICKETSTATUSFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "TicketStatusFrame",
					["lstr"] = "LID_TICKETSTATUSFRAME",
					["userplaced"] = true,
					["secure"] = true
				}
			)
		end

		if MinimapZoneTextButton and MoveAny:IsEnabled("MINIMAPZONETEXT", false) then
			MinimapZoneTextButton:SetParent(MoveAny:GetMainPanel())
			MoveAny:RegisterWidget(
				{
					["name"] = "MinimapZoneTextButton",
					["lstr"] = "LID_MINIMAPZONETEXT"
				}
			)
		end

		if MoveAny:IsEnabled("MINIMAPFLAG", false) then
			local flags = {"MiniMapInstanceDifficulty", "MiniMapChallengeMode", "GuildInstanceDifficulty"}
			for i, name in pairs(flags) do
				local flag = _G[name]
				if flag then
					flag:SetParent(MoveAny:GetMainPanel())
					MoveAny:RegisterWidget(
						{
							["name"] = name,
							["lstr"] = "LID_" .. name,
						}
					)
				end
			end
		end

		if MoveAny:IsEnabled("MINIMAP", false) then
			MoveAny:After(
				3,
				function()
					local LeaPlusDB = getglobal("LeaPlusDB")
					local ltpEnhancedMinimap = LeaPlusDB and LeaPlusDB["MinimapModder"] and LeaPlusDB["MinimapModder"] == "On"
					if ltpEnhancedMinimap then
						MoveAny:INFO("LeatrixPlus \"EnhancedMinimap\" is enabled, which will block moving the minimap.")
					end
				end, "MINIMAP 123"
			)

			if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
				MoveAny:RegisterWidget(
					{
						["name"] = "MinimapCluster",
						["lstr"] = "LID_MINIMAP",
						["ctop"] = -44,
						["cright"] = -10,
						["cbottom"] = 10,
						["cleft"] = 31
					}
				)
			else
				if MultiBarRight then
					MultiBarRight.OldSetScale = MultiBarRight.OldSetScale or MultiBarRight.SetScale
					MultiBarRight.SetScale = function(sel, scale)
						if scale > 0 then
							MultiBarRight:OldSetScale(scale)
						end
					end
				end

				if MultiBarLeft then
					MultiBarLeft.OldSetScale = MultiBarLeft.OldSetScale or MultiBarLeft.SetScale
					MultiBarLeft.SetScale = function(sel, scale)
						if scale > 0 then
							MultiBarLeft:OldSetScale(scale)
						end
					end
				end

				MoveAny:RegisterWidget(
					{
						["name"] = "MinimapCluster",
						["lstr"] = "LID_MINIMAP",
						["ctop"] = -25,
						["cright"] = -20,
						["cbottom"] = 30,
						["cleft"] = 35
					}
				)
			end
		end

		if ExpansionLandingPageMinimapButton and MoveAny:IsEnabled("ExpansionLandingPageMinimapButton", false) then
			ExpansionLandingPageMinimapButton:SetParent(UIParent)
			hooksecurefunc(
				ExpansionLandingPageMinimapButton,
				"SetParent",
				function(sel)
					if sel.ma_set_parent_elpmb then return end
					sel.ma_set_parent_elpmb = true
					if MoveAny:GetParent(sel) ~= MoveAny:GetHidden() then
						sel:SetParent(UIParent)
					end

					sel.ma_set_parent_elpmb = false
				end
			)

			MoveAny:RegisterWidget(
				{
					["name"] = "ExpansionLandingPageMinimapButton",
					["lstr"] = "LID_ExpansionLandingPageMinimapButton",
				}
			)
		end

		local gtp4 = nil
		local gtp5 = nil
		function MoveAny:NearNumber(num1, num2, near)
			if num1 + near >= num2 and num1 - near <= num2 then return true end

			return false
		end

		function MoveAny:GameTooltipOnDefaultPosition()
			local p1, p2, p3, p4, p5 = GameTooltip:GetPoint()
			if p1 and p2 and p3 and p4 and p5 then
				if p2 == _G["MAGameTooltip"] then
					return true
				elseif p2 == UIParent or p2 == UIParent then
					if gtp4 == nil and gtp5 == nil then
						_, _, _, gtp4, gtp5 = GameTooltip:GetPoint()
						gtp4 = floor(gtp4)
						gtp5 = floor(gtp5)
					end

					if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
						p4 = floor(p4)
						p5 = floor(p5)
						if MoveAny:NearNumber(p4, gtp4, 5) and MoveAny:NearNumber(p5, gtp5, 5) then return true end
					end
				elseif p2 == GameTooltipDefaultContainer then
					if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
						p4 = floor(p4)
						p5 = floor(p5)
						if MoveAny:NearNumber(p4, 0, 5) and MoveAny:NearNumber(p5, 0, 5) then return true end
					end
				end
			end

			return false
		end

		if MoveAny:IsEnabled("GAMETOOLTIP", false) or MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) then
			GameTooltip:SetMovable(true)
			GameTooltip:SetUserPlaced(false)
			hooksecurefunc(
				GameTooltip,
				"FadeOut",
				function(sel)
					sel:SetAlpha(0)
					sel:Hide()
				end
			)

			local MAGameTooltip = CreateFrame("Frame", "MAGameTooltip", MoveAny:GetMainPanel())
			MAGameTooltip:SetSize(100, 100)
			MAGameTooltip:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", -100, 100)
			hooksecurefunc(
				GameTooltip,
				"SetScale",
				function(sel, ...)
					if InCombatLockdown() and sel:IsProtected() then return false end
					if sel.gtsetscale then return end
					sel.gtsetscale = true
					sel:SetScale(MAGameTooltip:GetScale())
					sel.gtsetscale = false
				end
			)

			hooksecurefunc(
				MAGameTooltip,
				"SetScale",
				function(sel, ...)
					if InCombatLockdown() and sel:IsProtected() then return false end
					if sel.gtsetscale2 then return end
					sel.gtsetscale2 = true
					GameTooltip:SetScale(sel:GetScale())
					sel.gtsetscale2 = false
				end
			)

			GameTooltip:SetScale(MAGameTooltip:GetScale())
			function MAGameTooltip:GetMAEle()
				return GameTooltip
			end

			function GameTooltip:GetMAEle()
				return MAGameTooltip
			end

			local texts = {"GameTooltipStatusBar"}
			for i = 1, 12 do
				tinsert(texts, "GameTooltipTextLeft" .. i)
				tinsert(texts, "GameTooltipTextRight" .. i)
			end

			hooksecurefunc(
				GameTooltip,
				"SetAlpha",
				function(sel, alpha)
					if sel.gtsetalpha then return end
					sel.gtsetalpha = true
					sel:SetAlpha(MAGameTooltip:GetAlpha())
					if sel.NineSlice then
						sel.NineSlice:SetAlpha(MAGameTooltip:GetAlpha())
					end

					sel.gtsetalpha = false
				end
			)

			hooksecurefunc(
				MAGameTooltip,
				"SetAlpha",
				function(sel, alpha)
					if sel.gtsetalpha then return end
					sel.gtsetalpha = true
					GameTooltip:SetAlpha(MAGameTooltip:GetAlpha())
					for i, textName in pairs(texts) do
						local text = _G[textName]
						if text then
							text:SetAlpha(MAGameTooltip:GetAlpha())
						end
					end

					sel.gtsetalpha = false
				end
			)

			GameTooltip:SetAlpha(1)
			local gtsetpoint = false
			if not MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) then
				hooksecurefunc(
					GameTooltip,
					"SetPoint",
					function(sel, ...)
						if gtsetpoint then return end
						gtsetpoint = true
						sel:SetMovable(true)
						sel:SetUserPlaced(false)
						if MoveAny:GameTooltipOnDefaultPosition() then
							local p1, _, p3, _, _ = MAGameTooltip:GetPoint()
							MoveAny:SetPoint(sel, p1, MAGameTooltip, p3, 0, 0)
						end

						gtsetpoint = false
					end
				)
			else
				local CURSOR_OFFSET = 22
				hooksecurefunc(
					GameTooltip,
					"SetPoint",
					function(sel, ...)
						if gtsetpoint then return end
						gtsetpoint = true
						sel:SetMovable(true)
						sel:SetUserPlaced(false)
						if C_Widget.IsWidget(EditModeManagerFrame) and EditModeManagerFrame:IsShown() then
							gtsetpoint = false

							return
						end

						if MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) and GameTooltip:IsShown() then
							local owner = GameTooltip:GetOwner()
							if owner == UIParent then
								if InCombatLockdown() and MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR_NOTINCOMBAT", false) then
									local point1, _, point3 = MAGameTooltip:GetPoint()
									MoveAny:SetPoint(GameTooltip, point1, MAGameTooltip, point3, 0, 0)
									gtsetpoint = false

									return
								end

								local uiScale = GameTooltip:GetEffectiveScale()
								local cursorX, cursorY = GetCursorPosition()
								cursorX = cursorX / uiScale
								cursorY = cursorY / uiScale
								MoveAny:SetPoint(GameTooltip, "BOTTOMLEFT", MoveAny:GetMainPanel(), "BOTTOMLEFT", cursorX + CURSOR_OFFSET, cursorY + CURSOR_OFFSET)
							end
						end

						gtsetpoint = false
					end
				)

				function MoveAny:ThinkTooltip()
					if GameTooltip:IsShown() then
						GameTooltip:SetPoint(GameTooltip:GetPoint())
						MoveAny:After(
							0.03,
							function()
								MoveAny:ThinkTooltip()
							end, "ThinkTooltip 1"
						)
					else
						MoveAny:After(
							0.3,
							function()
								MoveAny:ThinkTooltip()
							end, "ThinkTooltip 2"
						)
					end
				end

				MoveAny:ThinkTooltip()
			end
		end

		-- BOTTOM
		if ZoneAbilityFrame and MoveAny:IsEnabled("ZONEABILITYFRAME", false) then
			ZoneAbilityFrame:SetParent(MoveAny:GetMainPanel())
			ZoneAbilityFrame:ClearAllPoints()
			ZoneAbilityFrame:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 200)
			MoveAny:RegisterWidget(
				{
					["name"] = "ZoneAbilityFrame",
					["lstr"] = "LID_ZONEABILITYFRAME",
					["userplaced"] = true
				}
			)
		end

		if MoveAny:IsEnabled("EventToastManagerFrame", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "EventToastManagerFrame",
					["lstr"] = "LID_EventToastManagerFrame",
					["sw"] = 36 * 2,
					["sh"] = 36 * 2
				}
			)
		end

		if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
			MoveAny:LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if MoveAny:IsEnabled("ARCHEOLOGYDIGSITEPROGRESSBAR", false) and ARCHEOLOGYDIGSITEPROGRESSBAR then
			MoveAny:RegisterWidget(
				{
					["name"] = "ArcheologyDigsiteProgressBar",
					["lstr"] = "LID_ARCHEOLOGYDIGSITEPROGRESSBAR",
				}
			)
		end

		if MoveAny:IsEnabled("UIERRORSFRAME", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "UIErrorsFrame",
					["lstr"] = "LID_UIERRORSFRAME",
				}
			)
		end

		if MoveAny:IsEnabled("BOSSBANNER", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "BossBanner",
					["lstr"] = "LID_BOSSBANNER",
				}
			)
		end

		if MoveAny:IsEnabled("GROUPLOOTCONTAINER", false) then
			local glfsw, glfsh = 256, 67
			if GroupLootFrame1 then
				glfsw, glfsh = GroupLootFrame1:GetSize()
			end

			GroupLootContainer:SetSize(glfsw, glfsh)
			if GroupLootContainer:GetPoint() == nil then
				MoveAny:SetPoint(GroupLootContainer, "CENTER", UIParent, "CENTER", 0, 0)
			end

			MoveAny:RegisterWidget(
				{
					["name"] = "GroupLootContainer",
					["lstr"] = "LID_GROUPLOOTCONTAINER",
					["sw"] = glfsw,
					["sh"] = glfsh,
				}
			)

			for x = 1, 10 do
				local glf = _G["GroupLootFrame" .. x]
				if glf then
					hooksecurefunc(
						glf,
						"SetPoint",
						function(sel, ...)
							if sel.glfsetpoint then return end
							sel.glfsetpoint = true
							sel:SetMovable(true)
							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							if x == 1 then
								MoveAny:SetPoint(sel, "CENTER", GroupLootContainer, "CENTER", 0, 4)
							else
								MoveAny:SetPoint(sel, "BOTTOM", _G["GroupLootFrame" .. (x - 1)], "TOP", 0, 14)
							end

							sel.glfsetpoint = false
						end
					)

					hooksecurefunc(
						GroupLootContainer,
						"SetScale",
						function(sel, scale)
							if InCombatLockdown() and sel:IsProtected() then return false end
							if scale and type(scale) == "number" then
								glf:SetScale(scale)
							end
						end
					)

					glf:SetScale(GroupLootContainer:GetScale())
					hooksecurefunc(
						GroupLootContainer,
						"SetAlpha",
						function(sel, alpha)
							glf:SetAlpha(alpha)
						end
					)

					glf:SetAlpha(GroupLootContainer:GetAlpha())
				end
			end

			if false then
				MoveAny:After(
					1,
					function()
						GroupLootContainer.Hide = GroupLootContainer.Show
						GroupLootContainer:Show()
						local rollID = 1
						local rollTime = 60
						for x = 1, 10 do
							local glf = _G["GroupLootFrame" .. x]
							if glf then
								glf.rollID = rollID + 1
								glf.rollTime = rollTime
								glf.Timer:SetMinMaxValues(0, rollTime)
								GroupLootContainer_AddFrame(GroupLootContainer, glf)
								glf.Hide = glf.Show
								glf:Show()
							end
						end
					end, "TEST LOOT"
				)
			end
		end
	elseif MoveAny:IsEnabled("GROUPLOOTFRAME1", false) then
		local glfsw, glfsh = 244, 84
		MoveAny:RegisterWidget(
			{
				["name"] = "GroupLootFrame1",
				["lstr"] = "LID_GROUPLOOTFRAME1",
				["sw"] = glfsw,
				["sh"] = glfsh,
				["px"] = 0,
				["py"] = 200,
				["an"] = "BOTTOM",
				["re"] = "BOTTOM"
			}
		)

		if GroupLootFrame1 then
			glfsw, glfsh = GroupLootFrame1:GetSize()
			for x = 2, 10 do
				local glf = _G["GroupLootFrame" .. x]
				if glf then
					hooksecurefunc(
						glf,
						"SetPoint",
						function(sel, ...)
							if sel.glfsetpoint then return end
							sel.glfsetpoint = true
							sel:SetMovable(true)
							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							MoveAny:SetPoint(sel, "BOTTOM", _G["GroupLootFrame" .. (x - 1)], "TOP", 0, 4)
							sel.glfsetpoint = false
						end
					)

					hooksecurefunc(
						GroupLootFrame1,
						"SetScale",
						function(sel, scale)
							if InCombatLockdown() and sel:IsProtected() then return false end
							if scale and type(scale) == "number" then
								glf:SetScale(scale)
							end
						end
					)

					hooksecurefunc(
						GroupLootFrame1,
						"SetAlpha",
						function(sel, alpha)
							glf:SetAlpha(alpha)
						end
					)
				end
			end
		end
	end

	if MoveAny:IsEnabled("BONUSROLLFRAME", false) and BonusRollFrame then
		if BonusRollFrame:GetPoint() == nil then
			BonusRollFrame:SetPoint("CENTER", 0, 0)
		end

		MoveAny:RegisterWidget(
			{
				["name"] = "BonusRollFrame",
				["lstr"] = "LID_BONUSROLLFRAME",
			}
		)
	end

	if SpellActivationOverlayFrame and MoveAny:IsEnabled("SPELLACTIVATIONOVERLAYFRAME", false) then
		MoveAny:RegisterWidget(
			{
				["name"] = "SpellActivationOverlayFrame",
				["lstr"] = "LID_SPELLACTIVATIONOVERLAYFRAME"
			}
		)
	end

	if MainStatusTrackingBarContainer and MoveAny:IsEnabled("MainStatusTrackingBarContainer", false) then
		MoveAny:After(
			1,
			function()
				MoveAny:RegisterWidget(
					{
						["name"] = "MainStatusTrackingBarContainer",
						["lstr"] = "LID_MainStatusTrackingBarContainer",
					}
				)
			end, "MainStatusTrackingBarContainer"
		)
	end

	if SecondaryStatusTrackingBarContainer and MoveAny:IsEnabled("SecondaryStatusTrackingBarContainer", false) then
		MoveAny:After(
			1,
			function()
				MoveAny:RegisterWidget(
					{
						["name"] = "SecondaryStatusTrackingBarContainer",
						["lstr"] = "LID_SecondaryStatusTrackingBarContainer",
					}
				)
			end, "SecondaryStatusTrackingBarContainer"
		)
	end

	if MainStatusTrackingBarContainer == nil and SecondaryStatusTrackingBarContainer == nil and StatusTrackingBarManager and MoveAny:IsEnabled("STATUSTRACKINGBARMANAGER", false) then
		-- StatusTrackingBarManager:EnableMouse( true ) -- destroys tooltip
		MoveAny:After(
			1,
			function()
				local ssw, ssh = StatusTrackingBarManager:GetSize()
				MoveAny:RegisterWidget(
					{
						["name"] = "StatusTrackingBarManager",
						["lstr"] = "LID_STATUSTRACKINGBARMANAGER",
						["sw"] = ssw - 6,
						["sh"] = ssh - 8,
						["cleft"] = 0,
						["cright"] = 2,
						["ctop"] = 4,
						["cbottom"] = 4,
						["posx"] = 1,
						["posy"] = 4,
					}
				)
			end, "MainStatusTrackingBarContainer"
		)
	end

	if MainMenuExpBar and ReputationWatchBar then
		if MoveAny:IsEnabled("REPUTATIONWATCHBAR", false) then
			local opts = nil
			ReputationWatchBar:SetParent(MoveAny:GetMainPanel())
			function ReputationWatchBar:UpdateSize()
				opts = MoveAny:GetEleOptions("ReputationWatchBar", "RegisterWidget: ReputationWatchBar")
				opts = opts or {}
				opts["WIDTH"] = opts["WIDTH"] or 1024
				opts["HEIGHT"] = opts["HEIGHT"] or 15
				if opts["WIDTH"] and opts["HEIGHT"] then
					if hookedRep == false then
						hookedRep = true
						hooksecurefunc(
							ReputationWatchBar,
							"SetHeight",
							function(sel, nh)
								if sel.ma_setheight then return end
								sel.ma_setheight = true
								sel:SetSize(opts["WIDTH"], opts["HEIGHT"])
								sel.ma_setheight = false
							end
						)
					end

					ReputationWatchBar:SetSize(opts["WIDTH"], opts["HEIGHT"])
					if ReputationWatchBar_MA_DRAG then
						ReputationWatchBar_MA_DRAG:SetSize(opts["WIDTH"], opts["HEIGHT"])
					end

					if ReputationWatchBar.StatusBar then
						if hookedRepStatus == false then
							hookedRepStatus = true
							hooksecurefunc(
								ReputationWatchBar.StatusBar,
								"SetHeight",
								function(sel, nh)
									if sel.ma_setheight then return end
									sel.ma_setheight = true
									sel:SetSize(opts["WIDTH"], opts["HEIGHT"])
									sel.ma_setheight = false
								end
							)
						end

						ReputationWatchBar.StatusBar:SetSize(opts["WIDTH"], opts["HEIGHT"])
						local last = nil
						local id = 0
						MoveAny:ForeachRegions(
							ReputationWatchBar.StatusBar,
							function(region, x)
								if x == 5 or x == 6 or x == 7 or x == 8 or x == 9 or x == 10 or x == 11 or x == 12 then
									if x < 9 then
										region:SetTexCoord(0.01, 1.01, 0.03, 0.17)
									end

									region:ClearAllPoints()
									if x == 5 or x == 9 then
										region:SetPoint("LEFT", ReputationWatchBar.StatusBar, "LEFT", 0, 0)
									else
										region:SetPoint("LEFT", last, "RIGHT", 0, 0)
									end

									region:SetSize(opts["WIDTH"] / 4, opts["HEIGHT"])
									last = region
									id = id + 1
								end
							end, "REPBAR"
						)
					end

					if ReputationWatchBar.OverlayFrame and ReputationWatchBar.OverlayFrame.Text then
						ReputationWatchBar.OverlayFrame.Text:SetText(ReputationWatchBar.OverlayFrame.Text:GetText())
					end
				end
			end

			ReputationWatchBar:UpdateSize()
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 130)
			MoveAny:RegisterWidget(
				{
					["name"] = "ReputationWatchBar",
					["lstr"] = "LID_REPUTATIONWATCHBAR",
					["sw"] = opts and opts["WIDTH"] or nil,
					["sh"] = opts and opts["HEIGHT"] or nil
				}
			)
		end

		if MoveAny:IsEnabled("MAINMENUEXPBAR", false) then
			local opts = nil
			MainMenuExpBar:SetParent(MoveAny:GetMainPanel())
			function MainMenuExpBar:UpdateSize()
				opts = MoveAny:GetEleOptions("MainMenuExpBar", "RegisterWidget: MainMenuExpBar")
				opts = opts or {}
				opts["WIDTH"] = opts["WIDTH"] or 1024
				opts["HEIGHT"] = opts["HEIGHT"] or 15
				if opts["WIDTH"] and opts["HEIGHT"] then
					MainMenuExpBar:SetSize(opts["WIDTH"], opts["HEIGHT"])
					if MainMenuExpBar_MA_DRAG then
						MainMenuExpBar_MA_DRAG:SetSize(opts["WIDTH"], opts["HEIGHT"])
					end

					local last = nil
					MoveAny:ForeachRegions(
						MainMenuExpBar,
						function(region, x)
							if x == 1 then
								region:SetSize(opts["WIDTH"], opts["HEIGHT"])
							end

							if x == 2 or x == 3 or x == 4 or x == 5 then
								region:ClearAllPoints()
								if x == 2 then
									region:SetPoint("LEFT", MainMenuExpBar, "LEFT", 0, 0)
								else
									region:SetPoint("LEFT", last, "RIGHT", 0, 0)
								end

								region:SetSize(opts["WIDTH"] / 4, opts["HEIGHT"])
								last = region
							end
						end, "XPBar"
					)

					local MainMenuBarExpText = getglobal("MainMenuBarExpText")
					if MainMenuBarExpText then
						MainMenuBarExpText:SetText(MainMenuBarExpText:GetText())
					end
				end
			end

			MainMenuExpBar:UpdateSize()
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 140)
			MoveAny:RegisterWidget(
				{
					["name"] = "MainMenuExpBar",
					["lstr"] = "LID_MAINMENUEXPBAR",
					["sw"] = opts and opts["WIDTH"] or nil,
					["sh"] = opts and opts["HEIGHT"] or nil
				}
			)
		end
	end

	if (MoveAny:GetWoWBuild() == "WRATH" or MoveAny:GetWoWBuild() == "CATA") and class == "SHAMAN" then
		if MultiCastActionBarFrame then
			MultiCastActionBarFrame:SetParent(MoveAny:GetMainPanel())
		end

		if MoveAny:IsEnabled("TOTEMBAR", false) then
			MoveAny:RegisterWidget(
				{
					["name"] = "MultiCastActionBarFrame",
					["lstr"] = "LID_TOTEMBAR",
					["userplaced"] = true,
					["secure"] = true,
					["soft"] = true,
				}
			)
		end
	end

	if MoveAny:IsEnabled("ALERTFRAME", false) then
		local afsw, afsh = 276, 68
		MoveAny:RegisterWidget(
			{
				["name"] = "AlertFrame",
				["lstr"] = "LID_ALERTFRAME",
				["sw"] = afsw,
				["sh"] = afsh
			}
		)

		if AlertFrame and AlertFrame.AddAlertFrame then
			hooksecurefunc(
				AlertFrame,
				"AddAlertFrame",
				function(se, frame)
					if frame.ma_setup == nil then
						frame.ma_setup = true
						hooksecurefunc(
							AlertFrame,
							"SetScale",
							function(sel, scale)
								if InCombatLockdown() and sel:IsProtected() then return false end
								if scale and type(scale) == "number" then
									frame:SetScale(scale)
								end
							end
						)

						frame:SetScale(AlertFrame:GetScale())
						hooksecurefunc(
							AlertFrame,
							"SetAlpha",
							function(sel, alpha)
								frame:SetAlpha(alpha)
							end
						)

						frame:SetAlpha(AlertFrame:GetAlpha())
					end
				end
			)
		end
	end

	for i = 1, 10 do
		local cf = _G["ChatFrame" .. i]
		if cf and i > 1 then
			if MoveAny:IsEnabled("CHATBUTTONFRAME" .. i, false) then
				local cbf = _G["ChatFrame" .. i .. "ButtonFrame"]
				if cbf then
					hooksecurefunc(
						cbf,
						"SetPoint",
						function(sel, ...)
							if sel.cbfsetpoint then return end
							sel:SetMovable(true)
							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(true)
							end

							sel.cbfsetpoint = true
							MoveAny:After(
								0.0,
								function()
									local ssw, _ = _G["ChatFrame" .. i .. "ButtonFrame"]:GetSize()
									sel:SetSize(ssw, ssw * 6)
									MoveAny:SetPoint(sel, "BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0)
									sel.cbfsetpoint = false
								end, "cbfsetpoint"
							)
						end
					)

					cbf:SetMovable(true)
					if cbf.SetUserPlaced and cbf:IsMovable() then
						cbf:SetUserPlaced(true)
					end

					cbf:ClearAllPoints()
					cbf:SetPoint("BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0)
				end

				function MoveAny:UpdateActiveTab()
					local selectedId = 1
					if SELECTED_CHAT_FRAME then
						selectedId = SELECTED_CHAT_FRAME:GetID()
					end

					for x = 1, 10 do
						local cbff = _G["ChatFrame" .. x .. "ButtonFrame"]
						if cbff then
							if x == selectedId then
								cbff:Show()
							else
								cbff:Hide()
							end
						end
					end

					MoveAny:After(0.1, MoveAny.UpdateActiveTab, "UpdateActiveTab")
				end

				MoveAny:UpdateActiveTab()
			end

			if MoveAny:IsEnabled("CHATEDITBOX", false) then
				local ceb = _G["ChatFrame" .. i .. "EditBox"]
				if ceb then
					hooksecurefunc(
						ceb,
						"SetPoint",
						function(sel, ...)
							if sel.cebsetpoint then return end
							sel:SetMovable(true)
							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(true)
							end

							sel.cebsetpoint = true
							if _G["ChatFrame" .. 1 .. "EditBox"] then
								sel:SetSize(_G["ChatFrame" .. 1 .. "EditBox"]:GetSize())
								MoveAny:SetPoint(sel, "CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0)
							end

							sel.cebsetpoint = false
						end
					)

					ceb:SetMovable(true)
					if ceb.SetUserPlaced and ceb:IsMovable() then
						ceb:SetUserPlaced(true)
					end

					ceb:ClearAllPoints()
					ceb:SetPoint("CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0)
				end
			end
		end
	end

	if MoveAny:IsEnabled("LOSSOFCONTROLFRAME", false) then
		MoveAny:RegisterWidget(
			{
				["name"] = "LossOfControlFrame",
				["lstr"] = "LID_LOSSOFCONTROLFRAME"
			}
		)
	end

	if MoveAny:IsEnabled("GHOSTFRAME", false) then
		MoveAny:RegisterWidget(
			{
				["name"] = "GhostFrame",
				["lstr"] = "LID_GHOSTFRAME",
				["sw"] = 130,
				["sh"] = 45,
			}
		)
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] and ArenaEnemyFrames then
		ArenaEnemyFrames:SetMovable(true)
		ArenaEnemyFrames:SetUserPlaced(true)
		UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] = nil
	end

	MoveAny:InitMALock()
	if MoveAny.InitMinimap then
		MoveAny:InitMinimap()
	end

	if MoveAny.InitBuffBar then
		MoveAny:InitBuffBar()
	end

	if MoveAny.InitDebuffBar then
		MoveAny:InitDebuffBar()
	end

	if not MoveAny:IsAddOnLoaded("Dominos") then
		if MoveAny.InitMicroMenu then
			MoveAny:InitMicroMenu()
		end

		if MoveAny.InitBags then
			MoveAny:InitBags()
		end
	end

	if MoveAny.InitMAFPSFrame then
		MoveAny:InitMAFPSFrame()
	end

	if MoveAny.InitMultiCastActionBar then
		MoveAny:InitMultiCastActionBar()
	end

	if MoveAny.InitPartyFrame then
		MoveAny:InitPartyFrame()
	end

	if MoveAny.MoveFrames then
		MoveAny:MoveFrames()
	end

	if MoveAny.InitMAVehicleSeatIndicator then
		MoveAny:InitMAVehicleSeatIndicator()
	end

	if WorldMapFrame and not MoveAny:IsAddOnLoaded("Leatrix_Maps") then
		if WorldMapFrame.Minimize then
			hooksecurefunc(
				WorldMapFrame,
				"Minimize",
				function(sel)
					sel:SetScale(1)
				end
			)

			hooksecurefunc(
				WorldMapFrame,
				"Maximize",
				function(sel)
					sel:SetScale(1)
				end
			)
		end

		if WorldMapFrame and (MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC") and WorldMapFrame.ScrollContainer then
			WorldMapFrame.ScrollContainer.GetCursorPosition = function(fr)
				local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(fr)
				local scale = WorldMapFrame:GetScale()
				if not MoveAny:IsAddOnLoaded("Mapster") and not MoveAny:IsAddOnLoaded("GW2_UI") then
					return x / scale, y / scale
				else
					local reverseEffectiveScale = 1 / UIParent:GetEffectiveScale()

					return x / scale * reverseEffectiveScale, y / scale * reverseEffectiveScale
				end
			end
		end
	end

	if MoveAny:IsEnabled("MALOCK", false) then
		MoveAny:ShowMALock()
	end

	if MoveAny:IsEnabled("MAPROFILES", false) then
		MoveAny:ShowProfiles()
	end

	MoveAny:After(
		1,
		function()
			if MoveAny.InitAlphas then
				MoveAny:InitAlphas()
			end
		end, "Init CheckAlphas"
	)

	if MoveAny.UpdateMALock then
		MoveAny:UpdateMALock()
	end
end
