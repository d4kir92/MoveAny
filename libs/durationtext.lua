local _, MoveAny = ...
local PROTOTYPEFONT = "Interface\\AddOns\\MoveAny\\media\\Prototype.ttf"
local origSize = {}
local origSizeSet = {}
local applying = {}
local coloring = {}
local styling = {}
local pending = false
local anchors = {
	["CENTER"] = {"CENTER", 0, 0},
	["TOP"] = {"BOTTOM", 0, 1},
	["BOTTOM"] = {"TOP", 0, -1},
	["LEFT"] = {"RIGHT", -1, 0},
	["RIGHT"] = {"LEFT", 1, 0},
	["TOPLEFT"] = {"BOTTOMRIGHT", -1, 1},
	["TOPRIGHT"] = {"BOTTOMLEFT", 1, 1},
	["BOTTOMLEFT"] = {"TOPRIGHT", -1, -1},
	["BOTTOMRIGHT"] = {"TOPLEFT", 1, -1},
}

MoveAny.DurationAnchors = {
	[0] = "DEFAULT",
	[1] = "CENTER",
	[2] = "TOP",
	[3] = "TOPLEFT",
	[4] = "TOPRIGHT",
	[5] = "LEFT",
	[6] = "RIGHT",
	[7] = "BOTTOM",
	[8] = "BOTTOMLEFT",
	[9] = "BOTTOMRIGHT",
}

MoveAny.DurationFonts = {
	[0] = "DEFAULT",
	[1] = "PROTOTYPE",
}

MoveAny.DurationFormats = {
	[0] = "DEFAULT",
	[1] = "COMPACT",
	[2] = "DIGITAL",
}

local durationHooked = false
local stats = {
	hookOK = 0,
	hookFail = 0,
	fmtCalls = 0,
	txtCalls = 0,
	writes = 0,
	skipType = 0,
	skipSame = 0,
	digitalBase = 0,
	digitalWrites = 0,
	noFactor = 0,
	noTime = 0,
	lastMode = -1,
	lastFmtType = "?",
	lastValueType = "?",
	lastUnknownFmt = "-",
	cFmtCalls = 0,
	cDigitalWrites = 0,
	cNoTime = 0,
	cTicks = 0,
	errors = 0,
	cErrors = 0,
	lastError = "-",
}

local function NoteError(err)
	stats.errors = stats.errors + 1
	if InCombatLockdown() then stats.cErrors = stats.cErrors + 1 end
	if stats.lastError ~= "-" then return end
	local ok, msg = pcall(function() return string.sub(tostring(err), 1, 90) end)
	if ok and type(msg) == "string" then stats.lastError = msg end
end

function MoveAny:CanReadAuraDuration()
	return MoveAny:GetWoWBuild() ~= "RETAIL"
end

local function IsFontString(obj)
	if type(obj) ~= "table" then return false end
	if obj.GetObjectType == nil or obj.SetText == nil then return false end
	local ok, objType = pcall(obj.GetObjectType, obj)
	return ok and objType == "FontString"
end

local function IsTexture(obj)
	if type(obj) ~= "table" then return false end
	if obj.GetObjectType == nil or obj.SetTexture == nil then return false end
	local ok, objType = pcall(obj.GetObjectType, obj)
	return ok and objType == "Texture"
end

local function FindCountFontString(btn)
	if IsFontString(btn.Count) then return btn.Count end
	if IsFontString(btn.count) then return btn.count end
	local btnName = btn.GetName and btn:GetName()
	if btnName then
		local global = _G[btnName .. "Count"]
		if IsFontString(global) then return global end
	end
	return nil
end

local function ScanForDuration(btn)
	if btn.GetRegions == nil or btn.GetNumRegions == nil then return nil end
	local count = FindCountFontString(btn)
	local list = {}
	MoveAny:ForeachRegions(btn, function(region) if region ~= count and IsFontString(region) then table.insert(list, region) end end, "MoveAny ScanForDuration")
	for i, region in ipairs(list) do
		local regionName = MoveAny:GetName(region)
		if regionName and strfind(regionName, "Duration", 1, true) then return region end
	end

	if #list == 1 then return list[1] end
	return nil
end

local function GetDurationFontString(btn)
	if IsFontString(btn.maDurationFS) then return btn.maDurationFS end
	if btn.maDurationMiss and btn.maDurationMiss > 3 then return nil end
	local fs = nil
	if IsFontString(btn.Duration) then
		fs = btn.Duration
	elseif IsFontString(btn.duration) then
		fs = btn.duration
	else
		local btnName = btn.GetName and btn:GetName()
		if btnName then
			local global = _G[btnName .. "Duration"]
			if IsFontString(global) then fs = global end
		end
	end

	if fs == nil then fs = ScanForDuration(btn) end
	if fs == nil then
		btn.maDurationMiss = (btn.maDurationMiss or 0) + 1
		return nil
	end

	btn.maDurationFS = fs
	return fs
end

local function GetIconRegion(btn)
	if IsTexture(btn.maDurationIcon) then return btn.maDurationIcon end
	if btn.maDurationIconChecked then return nil end
	btn.maDurationIconChecked = true
	local icon = nil
	if IsTexture(btn.Icon) then
		icon = btn.Icon
	elseif IsTexture(btn.icon) then
		icon = btn.icon
	else
		local btnName = btn.GetName and btn:GetName()
		if btnName then
			if IsTexture(_G[btnName .. "Icon"]) then
				icon = _G[btnName .. "Icon"]
			elseif IsTexture(_G[btnName .. "IconTexture"]) then
				icon = _G[btnName .. "IconTexture"]
			end
		end
	end

	btn.maDurationIcon = icon
	return icon
end

local function GetTimeLeft(btn)
	if type(btn.maDurationLeft) == "number" and type(btn.maDurationStamp) == "number" then return btn.maDurationLeft - (GetTime() - btn.maDurationStamp) end
	if type(btn.expirationTime) == "number" and btn.expirationTime > 0 then return btn.expirationTime - GetTime() end
	if type(btn.timeLeft) == "number" then return btn.timeLeft end
	local cd = btn.Cooldown or btn.cooldown
	if cd == nil then
		local btnName = btn.GetName and btn:GetName()
		if btnName then cd = _G[btnName .. "Cooldown"] end
	end

	if type(cd) == "table" and cd.GetCooldownTimes then
		local ok, start, dur = pcall(cd.GetCooldownTimes, cd)
		if ok and type(start) == "number" and type(dur) == "number" and dur > 0 then return (start + dur) / 1000 - GetTime() end
	end
	return nil
end

function MoveAny:GetDigitalDuration(seconds)
	if seconds == nil then return nil end
	if seconds < 0 then seconds = 0 end
	seconds = math.floor(seconds + 0.5)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then return format("%d:%02d:%02d", h, m, s) end
	return format("%d:%02d", m, s)
end

local function GetFormat(fs)
	if fs.maDurationEle == nil or fs.maDurationKey == nil then return 0 end
	return MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "FORMAT", 0)
end

local unitFactors = nil
local function GetUnitFactor(fmt)
	if unitFactors == nil then
		unitFactors = {}
		if type(SECOND_ONELETTER_ABBR) == "string" then unitFactors[SECOND_ONELETTER_ABBR] = 1 end
		if type(MINUTE_ONELETTER_ABBR) == "string" then unitFactors[MINUTE_ONELETTER_ABBR] = 60 end
		if type(HOUR_ONELETTER_ABBR) == "string" then unitFactors[HOUR_ONELETTER_ABBR] = 3600 end
		if type(DAY_ONELETTER_ABBR) == "string" then unitFactors[DAY_ONELETTER_ABBR] = 86400 end
	end

	if type(fmt) ~= "string" then return nil end
	return unitFactors[fmt]
end

local function TrackDigital(btn, fmt, value)
	local factor = GetUnitFactor(fmt)
	if factor == nil then
		stats.noFactor = stats.noFactor + 1
		if type(fmt) == "string" then stats.lastUnknownFmt = fmt end
		return
	end

	if type(value) ~= "number" then return end
	if factor == 1 then
		btn.maDurationLeft = value
		btn.maDurationStamp = GetTime()
	elseif btn.maDurationUnit ~= factor or type(btn.maDurationRaw) ~= "number" or value < btn.maDurationRaw then
		btn.maDurationLeft = value * factor
		btn.maDurationStamp = GetTime()
	end

	btn.maDurationUnit = factor
	btn.maDurationRaw = value
	stats.digitalBase = stats.digitalBase + 1
end

local function GetColor(fs)
	if fs.maDurationEle == nil or fs.maDurationKey == nil then return nil end
	local r = MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "COLOR_R", nil, "GetColor")
	if r == nil then return nil end
	return r, MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "COLOR_G", 1), MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "COLOR_B", 1), MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "COLOR_A", 1)
end

local function ApplyColor(fs)
	if coloring[fs] then return end
	local r, g, b, a = GetColor(fs)
	if r == nil then return end
	coloring[fs] = true
	fs:SetTextColor(r, g, b, a)
	coloring[fs] = false
end

local function ApplyLook(fs)
	if not fs.maDurationCaptured then return end
	if styling[fs] then return end
	styling[fs] = true
	local path = fs.maDurationOrigFont
	if MoveAny.DurationFonts[MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "FONT", 0)] == "PROTOTYPE" then path = PROTOTYPEFONT end
	local size = MoveAny:GetEleOption(fs.maDurationEle, fs.maDurationKey .. "SIZE", fs.maDurationOrigSize)
	if fs:SetFont(path, size, fs.maDurationOrigFlags) == false then fs:SetFont(fs.maDurationOrigFont, size, fs.maDurationOrigFlags) end
	fs:SetShadowColor(0, 0, 0, 1)
	fs:SetShadowOffset(1, -1)
	styling[fs] = false
	ApplyColor(fs)
end

local function TryDigitalFromBase(fs)
	local btn = fs.maDurationBtn
	if btn == nil then return false end
	local ok, text = pcall(function()
		local left = GetTimeLeft(btn)
		if left == nil then return nil end
		return MoveAny:GetDigitalDuration(left)
	end)

	if not ok or type(text) ~= "string" then return false end
	applying[fs] = true
	fs:SetText(text)
	applying[fs] = false
	return true
end

local function WriteDigitalFromFormat(fs, fmt, value)
	local factor = GetUnitFactor(fmt)
	local pattern = nil
	if factor == 1 then
		pattern = "0:%02d"
	elseif factor == 60 then
		pattern = "%d:00"
	elseif factor == 3600 then
		pattern = "%d:00:00"
	else
		return false
	end

	applying[fs] = true
	fs:SetFormattedText(pattern, value)
	applying[fs] = false
	return true
end

local function ApplyFormat(fs)
	local mode = GetFormat(fs)
	if mode == 0 then return end
	if mode == 2 then
		if TryDigitalFromBase(fs) then
			stats.digitalWrites = stats.digitalWrites + 1
			if InCombatLockdown() then stats.cDigitalWrites = stats.cDigitalWrites + 1 end
		else
			stats.noTime = stats.noTime + 1
			if InCombatLockdown() then stats.cNoTime = stats.cNoTime + 1 end
		end

		return
	end

	if not MoveAny:CanReadAuraDuration() then return end
	local txt = fs:GetText()
	if txt == nil or txt == "" then return end
	local new = string.gsub(txt, "%s+", "")
	if new == "" or new == txt then return end
	applying[fs] = true
	fs:SetText(new)
	applying[fs] = false
end

local function SafeApplyFormat(fs)
	local ok, err = pcall(ApplyFormat, fs)
	if ok then return end
	applying[fs] = false
	NoteError(err)
end

local function WriteCompactFormat(fs, fmt, value)
	if type(fmt) ~= "string" then
		stats.skipType = stats.skipType + 1
		return
	end

	local new = string.gsub(fmt, "%s+", "")
	if new == fmt then
		stats.skipSame = stats.skipSame + 1
		return
	end

	applying[fs] = true
	fs:SetFormattedText(new, value)
	applying[fs] = false
	stats.writes = stats.writes + 1
end

local function OnDurationText(fs)
	if applying[fs] then return end
	if fs.maDurationBtn == nil then return end
	stats.txtCalls = stats.txtCalls + 1
	if not pcall(ApplyColor, fs) then coloring[fs] = false end
	SafeApplyFormat(fs)
end

local function OnDurationFormatted(fs, fmt, value)
	if applying[fs] then return end
	if fs.maDurationBtn == nil then return end
	stats.fmtCalls = stats.fmtCalls + 1
	if InCombatLockdown() then stats.cFmtCalls = stats.cFmtCalls + 1 end
	if stats.lastFmtType == "?" then
		local okType, fmtType = pcall(type, fmt)
		stats.lastFmtType = okType and fmtType or "secret"
		local okValue, valueType = pcall(type, value)
		stats.lastValueType = okValue and valueType or "secret"
	end

	fs.maDurationBtn.maDurationSeen = GetTime()
	pcall(TrackDigital, fs.maDurationBtn, fmt, value)
	if not pcall(ApplyColor, fs) then coloring[fs] = false end
	local mode = GetFormat(fs)
	stats.lastMode = mode
	if mode == 1 then
		if not pcall(WriteCompactFormat, fs, fmt, value) then applying[fs] = false end
	elseif mode == 2 then
		if not TryDigitalFromBase(fs) then
			applying[fs] = false
			local ok, written = pcall(WriteDigitalFromFormat, fs, fmt, value)
			if not ok then
				applying[fs] = false
				NoteError(written)
			elseif written then
				stats.digitalWrites = stats.digitalWrites + 1
				if InCombatLockdown() then stats.cDigitalWrites = stats.cDigitalWrites + 1 end
			else
				stats.noTime = stats.noTime + 1
				if InCombatLockdown() then stats.cNoTime = stats.cNoTime + 1 end
			end
		else
			stats.digitalWrites = stats.digitalWrites + 1
			if InCombatLockdown() then stats.cDigitalWrites = stats.cDigitalWrites + 1 end
		end
	end
end

local function OnDurationColor(fs)
	if fs.maDurationBtn == nil then return end
	if not pcall(ApplyColor, fs) then coloring[fs] = false end
end

local function OnDurationFontObject(fs)
	if fs.maDurationBtn == nil then return end
	if not pcall(ApplyLook, fs) then
		styling[fs] = false
		coloring[fs] = false
	end
end

local function OnUpdateDuration(btn, elapsed)
	local fs = btn.maDurationFS
	if fs == nil then return end
	btn.maDurationElapsed = (btn.maDurationElapsed or 0) + elapsed
	if btn.maDurationElapsed < 0.2 then return end
	btn.maDurationElapsed = 0
	if type(btn.maDurationSeen) ~= "number" or GetTime() - btn.maDurationSeen > 3 then return end
	if GetFormat(fs) ~= 2 then return end
	if InCombatLockdown() then stats.cTicks = stats.cTicks + 1 end
	SafeApplyFormat(fs)
end

local function CaptureOriginals(fs)
	local font, size, flags = fs:GetFont()
	local jh = fs:GetJustifyH()
	local jv = fs:GetJustifyV()
	local p1, p2, p3, p4, p5 = fs:GetPoint()
	fs.maDurationOrigFont = font
	fs.maDurationOrigSize = size
	fs.maDurationOrigFlags = flags
	fs.maDurationOrigJH = jh
	fs.maDurationOrigJV = jv
	fs.maDurationOrigP1 = p1
	fs.maDurationOrigP2 = p2
	fs.maDurationOrigP3 = p3
	fs.maDurationOrigP4 = p4
	fs.maDurationOrigP5 = p5
end

local function FallbackOriginals(fs, btn)
	fs.maDurationOrigFont = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
	fs.maDurationOrigSize = 10
	fs.maDurationOrigFlags = ""
	fs.maDurationOrigJH = "CENTER"
	fs.maDurationOrigJV = "MIDDLE"
	fs.maDurationOrigP1 = "CENTER"
	fs.maDurationOrigP2 = btn
	fs.maDurationOrigP3 = "CENTER"
	fs.maDurationOrigP4 = 0
	fs.maDurationOrigP5 = 0
end

local function RestoreOriginals(fs)
	fs:SetJustifyH(fs.maDurationOrigJH)
	fs:SetJustifyV(fs.maDurationOrigJV)
	fs:ClearAllPoints()
	fs:SetPoint(fs.maDurationOrigP1, fs.maDurationOrigP2, fs.maDurationOrigP3, fs.maDurationOrigP4, fs.maDurationOrigP5)
end

function MoveAny:GetDurationDefaultSize(ele)
	local ok, res = pcall(function()
		local size = origSize[ele] or 10
		if size < 4 then size = 4 end
		if size > 12 then size = 12 end
		return math.floor(size + 0.5)
	end)

	if ok and type(res) == "number" then return res end
	return 10
end

function MoveAny:StyleAuraDuration(btn, ele, prefix, onlyNew)
	if btn == nil or ele == nil or type(btn) ~= "table" then return false end
	local fs = GetDurationFontString(btn)
	if fs == nil then return false end
	if onlyNew and fs.maDurationHooked then return true end
	prefix = prefix or "MABUFFDURATION"
	if not fs.maDurationCaptured then
		fs.maDurationCaptured = true
		if not pcall(CaptureOriginals, fs) then FallbackOriginals(fs, btn) end
	end

	if origSizeSet[ele] == nil then
		origSizeSet[ele] = true
		origSize[ele] = fs.maDurationOrigSize
	end

	fs.maDurationBtn = btn
	fs.maDurationEle = ele
	fs.maDurationKey = prefix
	if not fs.maDurationHooked then
		fs.maDurationHooked = true
		pcall(hooksecurefunc, fs, "SetText", OnDurationText)
		if pcall(hooksecurefunc, fs, "SetFormattedText", OnDurationFormatted) then
			stats.hookOK = stats.hookOK + 1
		else
			stats.hookFail = stats.hookFail + 1
		end

		pcall(hooksecurefunc, fs, "SetTextColor", OnDurationColor)
		pcall(hooksecurefunc, fs, "SetVertexColor", OnDurationColor)
		pcall(hooksecurefunc, fs, "SetFontObject", OnDurationFontObject)
	end

	if not pcall(ApplyLook, fs) then
		styling[fs] = false
		coloring[fs] = false
	end

	local point = MoveAny.DurationAnchors[MoveAny:GetEleOption(ele, prefix .. "ANCHOR", 0)]
	local anchor = anchors[point]
	if anchor then
		local spacing = MoveAny:GetEleOption(ele, prefix .. "SPACING", 0)
		pcall(function()
			fs:SetJustifyH("CENTER")
			fs:SetJustifyV("MIDDLE")
			fs:ClearAllPoints()
			fs:SetPoint(anchor[1], GetIconRegion(btn) or btn, point, anchor[2] * spacing, anchor[3] * spacing)
		end)
	else
		pcall(RestoreOriginals, fs)
	end

	if GetFormat(fs) == 2 and not btn.maDurationOnUpdate and btn.HookScript then
		btn.maDurationOnUpdate = true
		pcall(btn.HookScript, btn, "OnUpdate", OnUpdateDuration)
	end

	SafeApplyFormat(fs)
	return true
end

local function ForeachAuraButton(root, globalPrefix, callback)
	local seen = {}
	local function add(btn)
		if btn == nil or type(btn) ~= "table" or seen[btn] then return end
		seen[btn] = true
		callback(btn)
	end

	if root then
		if root.AuraContainer then
			MoveAny:ForeachChildren(root.AuraContainer, function(child) add(child) end, "MoveAny AuraDurations container")
		elseif root.GetChildren then
			MoveAny:ForeachChildren(root, function(child)
				local childName = MoveAny:GetName(child)
				if childName and (strfind(childName, "Buff", 1, true) or strfind(childName, "Aura", 1, true)) then add(child) end
			end, "MoveAny AuraDurations root")
		end
	end

	if globalPrefix then
		for i = 1, 40 do
			add(_G[globalPrefix .. i])
		end
	end
end

local function GetBuffEle()
	if not MoveAny:IsEnabled("BUFFS", false) then return nil end
	local build = MoveAny:GetWoWBuild()
	if (build == "RETAIL" or build == "CLASSIC" or build == "TBC") and BuffFrame then return "BuffFrame" end
	return "MABuffBar"
end

local function GetDebuffEle()
	if MoveAny:IsEnabled("DEBUFFS", false) then
		local build = MoveAny:GetWoWBuild()
		if (build == "RETAIL" or build == "CLASSIC" or build == "TBC" or build == "MISTS") and DebuffFrame then return "DebuffFrame", "MADEBUFFDURATION" end
		return "MADebuffBar", "MADEBUFFDURATION"
	end

	local buffEle = GetBuffEle()
	if buffEle then return buffEle, "MABUFFDURATION" end
	return nil
end

local function GetFormatTarget(btn)
	if btn.maDurationEle then return btn.maDurationEle, btn.maDurationKey end
	local btnName = MoveAny:GetName(btn)
	if btnName and strfind(btnName, "Debuff", 1, true) then return GetDebuffEle() end
	local buffEle = GetBuffEle()
	if buffEle then return buffEle, "MABUFFDURATION" end
	return nil
end

local function OnAuraButtonUpdateDuration(btn, timeLeft)
	if not timeLeft then return end
	if type(btn) ~= "table" then return end
	local fs = GetDurationFontString(btn)
	if fs == nil then return end
	btn.maDurationLeft = timeLeft
	btn.maDurationStamp = GetTime()
	local ele, prefix = GetFormatTarget(btn)
	if ele == nil then return end
	local mode = MoveAny:GetEleOption(ele, prefix .. "FORMAT", 0)
	if mode == 0 then return end
	if mode == 1 then
		local formatString, value = SecondsToTimeAbbrev(timeLeft)
		if type(formatString) == "string" then fs:SetFormattedText(string.gsub(formatString, "%s+", ""), value) end
	else
		local new = MoveAny:GetDigitalDuration(timeLeft)
		if new then fs:SetText(new) end
	end
end

function MoveAny:TryHookAuraDuration()
	if durationHooked then return true end
	if type(AuraButton_UpdateDuration) ~= "function" then return false end
	durationHooked = true
	pcall(hooksecurefunc, "AuraButton_UpdateDuration", function(btn, timeLeft) pcall(OnAuraButtonUpdateDuration, btn, timeLeft) end)
	return true
end

function MoveAny:UpdateAuraDurations(from, onlyNew)
	MoveAny:TryHookAuraDuration()
	local styled, total = 0, 0
	local buffEle = GetBuffEle()
	if buffEle then
		ForeachAuraButton(BuffFrame, "BuffButton", function(btn)
			total = total + 1
			if MoveAny:StyleAuraDuration(btn, buffEle, "MABUFFDURATION", onlyNew) then styled = styled + 1 end
		end)

		for i = 1, 3 do
			local te = _G["TempEnchant" .. i]
			if te then
				total = total + 1
				if MoveAny:StyleAuraDuration(te, buffEle, "MABUFFDURATION", onlyNew) then styled = styled + 1 end
			end
		end
	end

	local debuffEle, debuffPrefix = GetDebuffEle()
	if debuffEle then
		ForeachAuraButton(DebuffFrame, "DebuffButton", function(btn)
			total = total + 1
			if MoveAny:StyleAuraDuration(btn, debuffEle, debuffPrefix, onlyNew) then styled = styled + 1 end
		end)
	end

	if MoveAny.LayoutAuraGrid then
		if buffEle == "BuffFrame" and BuffFrame then MoveAny:LayoutAuraGrid(BuffFrame, buffEle, "MABUFF", "BuffButton") end
		if debuffEle == "DebuffFrame" and DebuffFrame then MoveAny:LayoutAuraGrid(DebuffFrame, debuffEle, "MADEBUFF", "DebuffButton") end
	end

	if MoveAny:DEBUG() and from ~= "tick" then MoveAny:MSG("[UpdateAuraDurations]", tostring(from), "styled", styled, "of", total) end
	return styled, total
end

local function ScheduleAuraDurations(from)
	if pending then return end
	pending = true
	MoveAny:After(0, function()
		pending = false
		MoveAny:UpdateAuraDurations(from)
	end, "UpdateAuraDurations")
end

local function TickAuraDurations()
	MoveAny:UpdateAuraDurations("tick", true)
	MoveAny:After(0.25, TickAuraDurations, "TickAuraDurations")
end

function MoveAny:InitAuraDurations()
	MoveAny:TryHookAuraDuration()
	MoveAny:After(0.25, TickAuraDurations, "TickAuraDurations")
	local f = CreateFrame("FRAME")
	MoveAny:RegisterEvent(f, "UNIT_AURA", "player")
	MoveAny:RegisterEvent(f, "PLAYER_ENTERING_WORLD")
	MoveAny:OnEvent(f, function(sel, event, ...) ScheduleAuraDurations(event) end, "InitAuraDurations")
	for i, delay in ipairs({0.5, 1, 2, 4, 8}) do
		MoveAny:After(delay, function() MoveAny:UpdateAuraDurations("init " .. delay) end, "InitAuraDurations")
	end

	MoveAny:AddSlash("madur", function()
		local styled, total = MoveAny:UpdateAuraDurations("slash")
		MoveAny:MSG("[MoveAny] Aura duration text:", styled, "of", total, "buttons")
		MoveAny:MSG("[MoveAny] Buff element:", tostring(GetBuffEle()), "Debuff element:", tostring(GetDebuffEle()))
		MoveAny:MSG("[MoveAny] AuraButton_UpdateDuration hooked:", tostring(durationHooked))
		MoveAny:MSG("[MoveAny] SetFormattedText hooks ok/fail:", stats.hookOK, "/", stats.hookFail)
		MoveAny:MSG("[MoveAny] hook calls fmt/txt:", stats.fmtCalls, "/", stats.txtCalls, "lastMode:", tostring(stats.lastMode), "fmtType:", tostring(stats.lastFmtType), "valueType:", tostring(stats.lastValueType))
		MoveAny:MSG("[MoveAny] compact writes:", stats.writes, "skipType:", stats.skipType, "skipSame:", stats.skipSame)
		MoveAny:MSG("[MoveAny] digital bases:", stats.digitalBase, "writes:", stats.digitalWrites, "noTime:", stats.noTime, "noFactor:", stats.noFactor)
		MoveAny:MSG("[MoveAny] unknown format string:", tostring(stats.lastUnknownFmt))
		MoveAny:MSG("[MoveAny] IN COMBAT fmtCalls:", stats.cFmtCalls, "ticks:", stats.cTicks, "writes:", stats.cDigitalWrites, "noTime:", stats.cNoTime)
		MoveAny:MSG("[MoveAny] errors:", stats.errors, "in combat:", stats.cErrors)
		MoveAny:MSG("[MoveAny] first error:", tostring(stats.lastError))
		if MoveAny.GetAuraGridStats then
			local grid = MoveAny:GetAuraGridStats()
			MoveAny:MSG("[MoveAny] aura grid placed:", grid.placed, "skipped:", grid.skipped, "errors:", grid.errors)
			MoveAny:MSG("[MoveAny] aura grid anchor:", tostring(grid.lastAnchor), "on", tostring(grid.lastRoot), tostring(grid.lastRootSize))
			if grid.errors > 0 then MoveAny:MSG("[MoveAny] aura grid error:", tostring(grid.lastError)) end
		end
		local probed = false
		ForeachAuraButton(BuffFrame, "BuffButton", function(btn)
			if probed then return end
			probed = true
			local ok, isNum = pcall(function() return type(GetTimeLeft(btn)) == "number" end)
			MoveAny:MSG("[MoveAny] DIGITAL possible:", tostring(ok and isNum == true))
		end)

		if not MoveAny:CanReadAuraDuration() then return end
		local shown = 0
		ForeachAuraButton(BuffFrame, "BuffButton", function(btn)
			if shown < 3 then
				shown = shown + 1
				local fs = GetDurationFontString(btn)
				local icon = GetIconRegion(btn)
				MoveAny:MSG("[MoveAny]", tostring(MoveAny:GetName(btn)), "duration:", tostring(fs and MoveAny:GetName(fs) or fs), "text:", tostring(fs and fs:GetText()), "icon:", tostring(icon and MoveAny:GetName(icon) or icon))
			end
		end)
	end)
end
