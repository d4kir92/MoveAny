
local AddOnName, MoveAny = ...

local COL_R = "|cFFFF0000"
local COL_Y = "|cFFFFFF00"

function MoveAny:MSG( msg )
	print( "|cff3FC7EB" .. "[MoveAny]|r " .. COL_Y .. msg )
end

function MoveAny:MSG_Error( msg )
	print( "|cff3FC7EB" .. "[MoveAny]|r " .. COL_R .. "[ERROR] |r" .. msg )
end

function MoveAny:GetCP()
	MATAB = MATAB or {}
	MATABPC = MATABPC or {}
	MATABPC["CURRENTPROFILE"] = MATABPC["CURRENTPROFILE"] or "DEFAULT"

	return MATABPC["CURRENTPROFILE"]
end

function MoveAny:SetCP( name )
	MATAB = MATAB or {}
	MATABPC = MATABPC or {}
	MATABPC["CURRENTPROFILE"] = name
end




function MoveAny:GetValidProfileName( name )
	if MATAB["PROFILES"][name] == nil then
		return name
	end
	return MoveAny:GetValidProfileName( name .. " NEW" )
end

function MoveAny:AddProfile( newname, other )
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	
	local name = MoveAny:GetValidProfileName( newname )
	-- Profile
	MATAB["PROFILES"][name] = MATAB["PROFILES"][name] or {}

	if other and MATAB["PROFILES"][other] then
		MATAB["PROFILES"][name] = MATAB["PROFILES"][other]
	else
		-- Frames
		MATAB["PROFILES"][name]["FRAMES"] =  MATAB["PROFILES"][name]["FRAMES"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["POINTS"] = MATAB["PROFILES"][name]["FRAMES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["SIZES"] = MATAB["PROFILES"][name]["FRAMES"]["SIZES"] or {}

		-- Eles
		MATAB["PROFILES"][name]["ELES"] = MATAB["PROFILES"][name]["ELES"] or {}
		MATAB["PROFILES"][name]["ELES"]["POINTS"] = MATAB["PROFILES"][name]["ELES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["ELES"]["SIZES"] = MATAB["PROFILES"][name]["ELES"]["SIZES"] or {}
		MATAB["PROFILES"][name]["ELES"]["OPTIONS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"] or {}

		MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] or {}
	end

	MoveAny:SetCP( name )
end

function MoveAny:RemoveProfile( name )
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}

	-- Profile
	MATAB["PROFILES"][name] = nil

	MoveAny:SetCP( "DEFAULT" )
end

function MoveAny:ImportProfile( name, eleTab )
	MoveAny:AddProfile( name )
	for i, v in pairs( eleTab ) do
		MATAB["PROFILES"][name]["ELES"][i] = v
	end
end

function MoveAny:RenameProfile( oldname, newname )
	if MATAB["PROFILES"][newname] ~= nil then
		MoveAny:MSG( "[RenameProfile] can't rename, new Name already exists." )
		return false
	end
	if MATAB["PROFILES"][oldname] == nil then
		MoveAny:MSG( "[RenameProfile] can't rename, old Profile don't exists." )
		return false
	end

	local isCurrent = MoveAny:GetCP() == oldname

	MoveAny:AddProfile( newname, oldname )
	MoveAny:RemoveProfile( oldname )

	if isCurrent then
		MoveAny:SetCP( newname )
	end
	
	C_UI.Reload()
	return true
end


function MoveAny:GetProfiles()
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}

	return MATAB["PROFILES"]
end




function MoveAny:InitDB()
	-- DB
	MATAB = MATAB or {}

	-- PROFILES
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	MATABPC = MATABPC or {}
	MATABPC["CURRENTPROFILE"] = MATABPC["CURRENTPROFILE"] or "DEFAULT"

	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:AddProfile( "DEFAULT" )
	end

	if MATAB["PROFILES"][MoveAny:GetCP()] == nil then
		MoveAny:SetCP( "DEFAULT" )
	end
end

function MoveAny:GetTab()
	return MATAB["PROFILES"][MoveAny:GetCP()]
end

function MoveAny:SetEnabled( element, value )
	if element == nil then
		MoveAny:MSG_Error( "[SetEnabled] Missing Name" )
		return false
	end
	if value == nil then
		MoveAny:MSG_Error( "[SetEnabled] Missing Value" )
		return false
	end
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] = value
end

function MoveAny:IsEnabled( element, value )
	if element == nil then
		MoveAny:MSG_Error( "[IsEnabled] Missing Name" )
		return false
	end
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	if MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] == nil then
		return value
	end
	return MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"]
end

function MoveAny:GetEleOptions( key )
	MoveAny:GetTab()["ELES"]["OPTIONS"][key] = MoveAny:GetTab()["ELES"]["OPTIONS"][key] or {}

	return MoveAny:GetTab()["ELES"]["OPTIONS"][key]
end

function MoveAny:GetEleOption( element, key, value )
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	if MoveAny:GetTab()["ELES"]["OPTIONS"][element][key] ~= nil then
		return MoveAny:GetTab()["ELES"]["OPTIONS"][element][key]
	end
	return value
end

function MoveAny:SetEleOption( element, key, value )
	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][element][key] = value
end

function MoveAny:GetElePoint( key )
	if key then
		MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}

		local an = MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"]
		local pa = MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"]
		local re = MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"]
		local px = MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"]
		local py = MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"]
		return an, pa, re, px, py
	else
		MoveAny:MSG_Error( "[GetElePoint] KEY not found" )
		return "CENTER", UIParent, "CENTER"
	end
end

function MoveAny:SetElePoint( key, p1, p2, p3, p4, p5 )
	MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}

	MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"] = p1
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"] = p2
	MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"] = p3
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"] = p4
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"] = p5

	local frame = _G[key]
	if frame then
		frame:ClearAllPoints()
		frame:SetPoint( p1, UIParent, p3, p4, p5 )
	end
end

function MoveAny:GetEleSize( key )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	local sw = MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"]
	local sh = MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"]
	return sw, sh
end

function MoveAny:SetEleSize( key, sw, sh )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"] = sw
	MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"] = sh
end

function MoveAny:GetEleScale( key )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	local scale = MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"]
	return scale
end

function MoveAny:SetEleScale( key, scale )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"] = scale

	local frame = _G[key]
	if frame then
		frame:SetScale( scale )
	end
end

function MoveAny:GetFramePoint( key )
	MoveAny:GetTab()["FRAMES"]["POINTS"][key] = MoveAny:GetTab()["FRAMES"]["POINTS"][key] or {}

	local an = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"]
	local pa = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"]
	local re = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"]
	local px = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"]
	local py = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"]
	return an, pa, re, px, py
end

function MoveAny:SetFramePoint( key, p1, p2, p3, p4, p5 )
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"] = p1
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"] = p1
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"] = p3
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"] = p4
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"] = p5
end

function MoveAny:GetFrameScale( key )
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}

	local scale = MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"]
	return scale
end

function MoveAny:SetFrameScale( key, scale )
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}

	MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"] = scale
end

function MoveAny:GetMinimapTable()
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	
	MoveAny:GetTab()["MMICON"] = MoveAny:GetTab()["MMICON"] or {}

	return MoveAny:GetTab()["MMICON"]
end
