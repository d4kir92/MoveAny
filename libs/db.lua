
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
	MATAB["CURRENTPROFILE"] = MATAB["CURRENTPROFILE"] or "DEFAULT"

	return MATAB["CURRENTPROFILE"]
end

function MoveAny:AddProfile( name )
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}

	-- Profile
	MATAB["PROFILES"][name] = MATAB["PROFILES"][name] or {}

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

function MoveAny:InitDB()
	-- DB
	MATAB = MATAB or {}

	-- PROFILES
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	MATAB["CURRENTPROFILE"] = MATAB["CURRENTPROFILE"] or "DEFAULT"

	MoveAny:AddProfile( "DEFAULT" )
end

function MoveAny:GetTab()
	return MATAB["PROFILES"][MoveAny:GetCP()]
end

function MoveAny:SetEnabled( name, value )
	MoveAny:GetTab()["ELES"]["OPTIONS"][name] = MoveAny:GetTab()["ELES"]["OPTIONS"][name] or {}
	MoveAny:GetTab()["ELES"]["OPTIONS"][name]["ENABLED"] = value
end

function MoveAny:IsEnabled( name, value )
	if name == nil then
		MoveAny:MSG_Error( "[IsEnabled] Missing Name" )
		return false
	end
	if value == nil then
		MoveAny:MSG_Error( "[IsEnabled] Missing Value" )
		return false
	end
	MoveAny:GetTab()["ELES"]["OPTIONS"][name] = MoveAny:GetTab()["ELES"]["OPTIONS"][name] or {}
	if MoveAny:GetTab()["ELES"]["OPTIONS"][name]["ENABLED"] == nil then
		MoveAny:GetTab()["ELES"]["OPTIONS"][name]["ENABLED"] = value
	end
	return MoveAny:GetTab()["ELES"]["OPTIONS"][name]["ENABLED"]
end

function MoveAny:GetEleOptions( key )
	MoveAny:GetTab()["ELES"]["OPTIONS"][key] = MoveAny:GetTab()["ELES"]["OPTIONS"][key] or {}

	return MoveAny:GetTab()["ELES"]["OPTIONS"][key]
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

	return MoveAny:GetTab()["MMICON"]
end
