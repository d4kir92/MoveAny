local AddonName, MoveAny = ...
local MADEBUG = false
function MoveAny:DEBUG()
	return MADEBUG
end

function MoveAny:CheckDB(from)
	if MoveAny:Loaded() == false then
		MoveAny:INFO("CheckDB", from)
	end

	--[[GLOBAL]]
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	--[[PER CHARACTER]]
	MATABPC = MATABPC or {}
	MATABPC["CURRENTPROFILE"] = MATABPC["CURRENTPROFILE"] or "DEFAULT"
	--[[VERSION OF DB]]
	MATAB["VERSION"] = MATAB["VERSION"] or 1
	if MATAB["VERSION"] < 2 then
		MATAB["VERSION"] = 2
		MATAB["PROFILES"] = MATAB["PROFILES"] or {}
		for pn, pt in pairs(MATAB["PROFILES"]) do
			pt["ELES"] = pt["ELES"] or {}
			pt["ELES"]["SIZES"] = pt["ELES"]["SIZES"] or {}
			pt["ELES"]["OPTIONS"] = pt["ELES"]["OPTIONS"] or {}
			for i, ft in pairs(pt["ELES"]["SIZES"]) do
				if ft.SCALE ~= nil then
					local val = tonumber(string.format("%.1f", ft.SCALE))
					ft.SCALE = val
				end
			end
		end
	end
end

function MoveAny:GetCP()
	MoveAny:CheckDB("GetCP")

	return MATABPC["CURRENTPROFILE"]
end

function MoveAny:SetCP(name)
	MoveAny:CheckDB("SetCP")
	MATABPC["CURRENTPROFILE"] = name
end

function MoveAny:GetValidProfileName(name)
	MoveAny:CheckDB("GetValidProfileName")
	if MATAB["PROFILES"][name] == nil then return name end

	return MoveAny:GetValidProfileName(name .. " NEW")
end

function MoveAny:AddProfile(newname, other, noChange)
	MoveAny:CheckDB("AddProfile")
	local name = MoveAny:GetValidProfileName(newname)
	MATAB["PROFILES"][name] = MATAB["PROFILES"][name] or {}
	if other and MATAB["PROFILES"][other] then
		MATAB["PROFILES"][name] = MATAB["PROFILES"][other]
	else
		MATAB["PROFILES"][name]["FRAMES"] = MATAB["PROFILES"][name]["FRAMES"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["POINTS"] = MATAB["PROFILES"][name]["FRAMES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["SIZES"] = MATAB["PROFILES"][name]["FRAMES"]["SIZES"] or {}
		MATAB["PROFILES"][name]["ELES"] = MATAB["PROFILES"][name]["ELES"] or {}
		MATAB["PROFILES"][name]["ELES"]["POINTS"] = MATAB["PROFILES"][name]["ELES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["ELES"]["SIZES"] = MATAB["PROFILES"][name]["ELES"]["SIZES"] or {}
		MATAB["PROFILES"][name]["ELES"]["OPTIONS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"] or {}
		MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] or {}
	end

	if noChange then return end
	MoveAny:SetCP(name)
end

function MoveAny:RemoveProfile(name)
	MoveAny:CheckDB("RemoveProfile")
	MATAB["PROFILES"][name] = nil
	MoveAny:SetCP("DEFAULT")
end

function MoveAny:ImportProfile(name, eleTab)
	MoveAny:CheckDB("ImportProfile")
	MoveAny:AddProfile(name)
	for i, v in pairs(eleTab) do
		MATAB["PROFILES"][name]["ELES"][i] = v
	end
end

function MoveAny:RenameProfile(oldname, newname)
	MoveAny:CheckDB("RenameProfile")
	if MATAB["PROFILES"][newname] ~= nil then
		MoveAny:MSG("[RenameProfile] can't rename, new Name already exists.")

		return false
	end

	if MATAB["PROFILES"][oldname] == nil then
		MoveAny:MSG("[RenameProfile] can't rename, old Profile don't exists.")

		return false
	end

	local isCurrent = MoveAny:GetCP() == oldname
	MoveAny:AddProfile(newname, oldname)
	MoveAny:RemoveProfile(oldname)
	if isCurrent then
		MoveAny:SetCP(newname)
	end

	C_UI.Reload()

	return true
end

function MoveAny:GetProfiles()
	MoveAny:CheckDB("GetProfiles")

	return MATAB["PROFILES"]
end

function MoveAny:IImportPointValue(profileName, n, t, key, dbKey)
	MoveAny:CheckDB("IImportPointValue")
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG("[MAIImportValue] Missing Default Profile")

		return
	end

	local eleName = nil
	local value = nil
	local s1, _ = strfind(n, key, 1, true)
	if s1 then
		eleName = strsub(n, 1, s1 - 1)
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG("[MAIImportValue] Missing Default Profile")

			return
		end

		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["POINTS"] = MATAB["PROFILES"][profileName]["ELES"]["POINTS"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName] or {}
		MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName][dbKey] = value
	end
end

function MoveAny:IImportSizesValue(profileName, n, t, key, dbKey)
	MoveAny:CheckDB("IImportSizesValue")
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG("[MAIImportValue] Missing Default Profile")

		return
	end

	local eleName = nil
	local value = nil
	local s1, _ = strfind(n, key, 1, true)
	if s1 then
		eleName = strsub(n, 1, s1 - 1)
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG("[MAIImportValue] Missing Default Profile")

			return
		end

		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["SIZES"] = MATAB["PROFILES"][profileName]["ELES"]["SIZES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName] or {}
		MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName][dbKey] = value
	end
end

function MoveAny:IImportOptionValue(profileName, n, t, key, dbKey)
	MoveAny:CheckDB("IImportOptionValue")
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG("[MAIImportValue] Missing Default Profile")

		return
	end

	local eleName = nil
	local value = nil
	local s1, _ = strfind(n, key, 1, true)
	if s1 then
		eleName = strsub(n, 1, s1 - 1)
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		elseif MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"]["MA" .. eleName] ~= nil then
			eleName = "MA" .. eleName
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG("[MAIImportValue] Missing Default Profile")

			return
		end

		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"] = MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName] or {}
		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName][dbKey] = value
	end
end

function MoveAny:GetTab()
	MoveAny:CheckDB("GetTab")

	return MATAB["PROFILES"][MoveAny:GetCP()]
end

function MoveAny:MAGV(key, val)
	MoveAny:CheckDB("MAGV")
	if MATAB[key] ~= nil then return MATAB[key] end

	return val
end

function MoveAny:MASV(key, val)
	local oldVal = MATAB[key]
	MoveAny:CheckDB("MASV")
	MATAB[key] = val
	MoveAny:EnableSave("MASV", key, val, oldVal, true)
end

function MoveAny:FixTable(tab)
	for i, v in pairs(tab) do
		local typ = type(v)
		if typ == "string" then
			if type(tonumber(v)) == "number" then
				tab[i] = tonumber(v)
			end
		elseif typ == "table" then
			MoveAny:FixTable(v)
		elseif typ ~= "number" and typ ~= "boolean" then
			MoveAny:MSG("Missing typ", typ)
		end
	end
end

function MoveAny:SetEnabled(element, value)
	MoveAny:CheckDB("SetEnabled")
	if element == nil then
		MoveAny:MSG_Error("[SetEnabled] Missing Name")

		return false
	end

	if value == nil then
		MoveAny:MSG_Error("[SetEnabled] Missing Value")

		return false
	end

	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	local oldVal = MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"]
	MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] = value
	if element ~= "MALOCK" then
		MoveAny:EnableSave("SetEnabled", element, value, oldVal, false)
	end
end

function MoveAny:IsEnabled(element, value, settings)
	if element == nil then
		MoveAny:MSG_Error("[IsEnabled] Missing Name")

		return false
	end

	MoveAny:CheckDB("IsEnabled")
	local enabled, forced = MoveAny:IsInEditModeEnabled(element)
	if value and enabled and not forced and not settings then
		MoveAny:MSG(format(MoveAny:GT("LID_HELPTEXT"), MoveAny:GT(element)))

		return false
	end

	if MoveAny:GetTab() then
		MoveAny:GetTab()["ELES"] = MoveAny:GetTab()["ELES"] or {}
		MoveAny:GetTab()["ELES"]["OPTIONS"] = MoveAny:GetTab()["ELES"]["OPTIONS"] or {}
		MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
		if MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] == nil and value ~= nil then
			MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] = value
		end

		return MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] or false
	end

	return false
end

function MoveAny:GetEleOptions(key, from)
	if key == nil then
		MoveAny:MSG("GetEleOptions(): key is nil: " .. tostring(from))

		return {}
	end

	MoveAny:CheckDB("GetEleOptions")
	MoveAny:GetTab()["ELES"]["OPTIONS"] = MoveAny:GetTab()["ELES"]["OPTIONS"] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][key] = MoveAny:GetTab()["ELES"]["OPTIONS"][key] or {}

	return MoveAny:GetTab()["ELES"]["OPTIONS"][key]
end

function MoveAny:GetEleOption(element, key, value, from)
	if element == nil then
		MoveAny:MSG("GetEleOption(): element is nil: " .. tostring(from))

		return value
	end

	MoveAny:CheckDB("GetEleOption")
	MoveAny:GetTab()["ELES"]["OPTIONS"] = MoveAny:GetTab()["ELES"]["OPTIONS"] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	if MoveAny:GetTab()["ELES"]["OPTIONS"][element][key] ~= nil then return MoveAny:GetTab()["ELES"]["OPTIONS"][element][key] end

	return value
end

function MoveAny:SetEleOption(element, key, value)
	if element == nil then
		MoveAny:MSG("SetEleOption(): element is nil")

		return value
	end

	MoveAny:CheckDB("SetEleOption")
	MoveAny:GetTab()["ELES"]["OPTIONS"] = MoveAny:GetTab()["ELES"]["OPTIONS"] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][element][key] = value
	MoveAny:EnableSave("SetEleOption", key, true, false, false)
end

function MoveAny:GetElePoint(key)
	if key then
		MoveAny:CheckDB("GetElePoint")
		MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}
		local an = MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"]
		--local pa = MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"]
		local re = MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"]
		local px = MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"]
		local py = MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"]

		return an, MoveAny:GetMainPanel(), re, px, py
	else
		MoveAny:MSG_Error("[GetElePoint] KEY not found")

		return "CENTER", MoveAny:GetMainPanel(), "CENTER"
	end
end

function MoveAny:SetElePoint(key, p1, p2, p3, p4, p5)
	MoveAny:CheckDB("SetElePoint")
	MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}
	MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"] = p1
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"] = p2
	MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"] = p3
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"] = p4
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"] = p5
	local frame = _G[key]
	if frame and p1 and p3 then
		local cap = frame.FClearAllPoints or frame.ClearAllPoints
		cap(frame)
		local point = frame.FSetPointBase or frame.FSetPoint or frame.SetPointBase or frame.SetPoint
		point(frame, p1, MoveAny:GetMainPanel(), p3, p4, p5)
		local systemFrame = frame
		local systemInfo = frame.systemInfo
		if frame.GetRealEle then
			systemFrame = MABuffBar:GetRealEle()
			systemInfo = systemFrame.systemInfo
		end

		if systemInfo then
			if systemInfo.anchorInfo then
				systemInfo.anchorInfo.point = p1
				systemInfo.anchorInfo.relativeTo = "UIParent"
				systemInfo.anchorInfo.relativePoint = p3
				systemInfo.anchorInfo.offsetX = p4
				systemInfo.anchorInfo.offsetY = p5
				systemInfo.isInDefaultPosition = false
			end

			if systemInfo.settings and Enum and Enum.EditModeUnitFrameSetting and Enum.EditModeUnitFrameSetting.FrameSize then
				for i, v in pairs(systemInfo.settings) do
					if Enum.EditModeUnitFrameSetting.FrameSize and v.setting == Enum.EditModeUnitFrameSetting.FrameSize then
						v.value = 0 -- = Scale: 1.0
					end
				end
			end

			EditModeSystemMixin.UpdateSystem(systemFrame, systemInfo)
		end

		if frame then
			local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(key)
			if dbp1 and dbp3 then
				frame:ClearAllPoints()
				frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			end
		end
	end

	if key ~= "MALock" then
		MoveAny:EnableSave("SetElePoint", key, true, false, true)
	end
end

function MoveAny:ResetElement(name)
	MoveAny:CheckDB("ResetElement")
	if MoveAny:GetTab() and MoveAny:GetTab()["ELES"] then
		MoveAny:GetTab()["ELES"]["OPTIONS"] = MoveAny:GetTab()["ELES"]["OPTIONS"] or {}
		MoveAny:GetTab()["ELES"]["SIZES"] = MoveAny:GetTab()["ELES"]["SIZES"] or {}
		MoveAny:GetTab()["ELES"]["POINTS"] = MoveAny:GetTab()["ELES"]["POINTS"] or {}
		MoveAny:GetTab()["ELES"]["OPTIONS"][name] = {}
		MoveAny:GetTab()["ELES"]["SIZES"][name] = {}
		MoveAny:GetTab()["ELES"]["POINTS"][name] = {}
	end
end

function MoveAny:GetEleSize(key)
	MoveAny:CheckDB("GetEleSize")
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}
	local sw = MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"]
	local sh = MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"]
	sw = MoveAny:MathR(sw)
	sh = MoveAny:MathR(sh)

	return sw, sh
end

function MoveAny:SetEleSize(key, sw, sh)
	MoveAny:CheckDB("SetEleSize")
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}
	MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"] = MoveAny:MathR(sw)
	MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"] = MoveAny:MathR(sh)
end

function MoveAny:GetEleScale(key)
	MoveAny:CheckDB("GetEleScale")
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}
	local scale = MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"]
	if scale and type(scale) ~= "number" then
		MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"] = tonumber(scale)
	end

	if scale and tonumber(scale) > 0 then
		return tonumber(scale)
	elseif scale then
		MoveAny:MSG("[GetEleScale] SCALE <= 0, key: " .. tostring(key))

		return 1
	end

	return 1
end

function MoveAny:SetEleScale(key, scale)
	MoveAny:CheckDB("SetEleScale")
	if scale == nil then
		MoveAny:MSG("[SetEleScale] NO SCALE, key: " .. tostring(key))

		return
	end

	if scale > 0 then
		MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}
		MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"] = scale
		local frame = _G[key]
		if frame then
			frame:SetScale(scale)
		end
	else
		MoveAny:MSG("[SetEleScale] SCALE <= 0, key: " .. tostring(key))
	end

	if key ~= "MALock" then
		MoveAny:EnableSave("SetEleScale", key, true, false, true)
	end
end

function MoveAny:GetFramePoint(key)
	MoveAny:CheckDB("GetFramePoint")
	MoveAny:GetTab()["FRAMES"]["POINTS"][key] = MoveAny:GetTab()["FRAMES"]["POINTS"][key] or {}
	if MoveAny:IsEnabled("SAVEFRAMEPOSITION", true) then
		local an = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"]
		--local pa = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"]
		local re = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"]
		local px = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"]
		local py = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"]

		return an, _, re, px, py
	end

	return nil, nil, nil, nil, nil
end

function MoveAny:SaveFramePointToDB(key, p1, p2, p3, p4, p5)
	MoveAny:CheckDB("SaveFramePointToDB")
	MoveAny:GetTab()["FRAMES"]["POINTS"][key] = MoveAny:GetTab()["FRAMES"]["POINTS"][key] or {}
	if MoveAny:IsEnabled("SAVEFRAMEPOSITION", true) then
		MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"] = p1
		MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"] = p2
		MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"] = p3
		MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"] = p4
		MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"] = p5
	end
end

function MoveAny:GetFrameScale(key)
	MoveAny:CheckDB("GetFrameScale")
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}
	if MoveAny:IsEnabled("SAVEFRAMESCALE", true) then
		local scale = MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"]

		return scale
	end

	return nil
end

function MoveAny:SetFrameScale(key, scale)
	MoveAny:CheckDB("SetFrameScale")
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}
	if MoveAny:IsEnabled("SAVEFRAMESCALE", true) then
		MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"] = scale
	end
end

function MoveAny:GetMinimapTable()
	MoveAny:CheckDB("GetMinimapTable")
	MoveAny:GetTab()["MMICON"] = MoveAny:GetTab()["MMICON"] or {}

	return MoveAny:GetTab()["MMICON"]
end

function MoveAny:GetGridSize()
	return MoveAny:MAGV("GRIDSIZE", 10)
end

function MoveAny:GetSnapSize()
	return MoveAny:MAGV("GRIDSIZE", 10)
end

function MoveAny:GetSnapWindowSize()
	return MoveAny:MAGV("SNAPWINDOWSIZE", 1)
end

function MoveAny:InitDB()
	MoveAny:CheckDB("InitDB")
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:AddProfile("DEFAULT")
	end

	if MATAB["PROFILES"][MoveAny:GetCP()] == nil then
		MoveAny:SetCP("DEFAULT")
	end

	MoveAny:FixTable(MATAB["PROFILES"])
	-- FIX, parent had big junk behind
	for x, profil in pairs(MATAB["PROFILES"]) do
		if profil then
			if profil["ELES"] and profil["ELES"]["POINTS"] then
				for i, v in pairs(profil["ELES"]["POINTS"]) do
					if v.PA then
						v.PA = nil
					end
				end
			end

			if profil["FRAMES"] and profil["FRAMES"]["POINTS"] then
				for i, v in pairs(profil["FRAMES"]["POINTS"]) do
					if v.PA then
						v.PA = nil
					end
				end
			end
		end
	end

	if MAITAB then
		MoveAny:HR()
		MoveAny:MSG("...MoveAndImprove detected, importing Profiles...")
		for name, tab in pairs(MAITAB["PROFILES"]) do
			local newName = name .. " by MAI"
			if MATAB["PROFILES"][newName] == nil then
				MoveAny:MSG("Importing Profile: " .. name)
				MoveAny:AddProfile(newName, nil, true)
				for n, t in pairs(tab) do
					MoveAny:IImportPointValue(newName, n, t, "point", "AN")
					MoveAny:IImportPointValue(newName, n, t, "relativePoint", "RE")
					MoveAny:IImportPointValue(newName, n, t, "ofsx", "PX")
					MoveAny:IImportPointValue(newName, n, t, "ofsy", "PY")
					MoveAny:IImportSizesValue(newName, n, t, "scale", "SCALE")
					MoveAny:IImportOptionValue(newName, n, t, "rows", "ROWS")
					MoveAny:IImportOptionValue(newName, n, t, "spacing", "SPACING")
				end
			else
				MoveAny:MSG("Already Imported Profile: " .. name)
			end
		end

		MoveAny:MSG("Done Importing Profiles.")
		MoveAny:HR()
	end
end

local mf = CreateFrame("FRAME")
mf:RegisterEvent("PLAYER_LOGIN")
mf:RegisterEvent("ADDON_LOADED")
local loaded = false
function MoveAny:Loaded()
	return loaded
end

function MoveAny:AddonLoaded(event, ...)
	if event == "ADDON_LOADED" then
		if select(1, ...) == AddonName then
			loaded = true
			MoveAny:LoadAddon()
			mf:UnregisterEvent(event)
		end
	elseif event == "PLAYER_LOGIN" then
		MoveAny:PlayerLogin()
		mf:UnregisterEvent(event)
	end
end

mf:SetScript("OnEvent", MoveAny.AddonLoaded)
--[[ FIX ]]
function MoveAny:TrySaveEditMode()
	local layoutCount = 0
	if EditModeManagerFrame and EditModeManagerFrame.numLayouts and EditModeManagerFrame.numLayouts[Enum.EditModeLayoutType.Account] and EditModeManagerFrame.numLayouts[Enum.EditModeLayoutType.Character] then
		layoutCount = layoutCount + EditModeManagerFrame.numLayouts[Enum.EditModeLayoutType.Account]
		layoutCount = layoutCount + EditModeManagerFrame.numLayouts[Enum.EditModeLayoutType.Character]
	end

	if layoutCount > 0 and EditModeManagerFrame and EditModeManagerFrame.SaveChangesButton and EditModeManagerFrame.CloseButton then
		EditModeManagerFrame.SaveChangesButton:SetEnabled(true)
		EditModeManagerFrame.SaveChangesButton:Click()
		EditModeManagerFrame.CloseButton:Click()
	end
end

MoveAny:TrySaveEditMode()
local foundProblem = false
function MoveAny:HasProblem()
	return foundProblem
end

function string.startswith(str, prefix)
	return str:sub(1, #prefix) == prefix
end

local function is_full_caps(text)
	for character in text:gmatch("%S") do
		if character:upper() ~= character then return false end
	end

	return true
end

function MoveAny:FixEditMode()
	local rig = 0
	local wro = 0
	for i, v in pairs(_G) do
		if v ~= nil and i ~= "L" and i ~= "G" and C_Widget.IsWidget(v) and v.GetPoint ~= nil and v.systemInfo ~= nil and type(v.systemInfo) == "table" and v.systemInfo.anchorInfo ~= nil and type(v.systemInfo.anchorInfo) == "table" and v.systemInfo.anchorInfo.relativeTo ~= nil and not is_full_caps(i) then
			if string.startswith(v.systemInfo.anchorInfo.relativeTo, "MA") then
				_G[i]["systemInfo"]["anchorInfo"]["relativeTo"] = "UIParent"
				EditModeSystemMixin.UpdateSystem(_G[i], _G[i]["systemInfo"])
				foundProblem = true
				wro = wro + 1
			else
				rig = rig + 1
			end
		end
	end

	if foundProblem then
		MoveAny:MSG("FOUND A PROBLEM, please relog your character.")
		C_Timer.After(0, MoveAny.TrySaveEditMode)
	end
end

C_Timer.After(0, MoveAny.FixEditMode)
--[[ FIX ]]
function MoveAny:AddProfileData(name, tab)
	--if MATAB["PROFILES"][name] == nil then
	MATAB["PROFILES"][name] = tab
	--end
end
