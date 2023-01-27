
local AddOnName, MoveAny = ...

local COL_R = "|cFFFF0000"
local COL_Y = "|cFFFFFF00"

local MADEBUG = false
function MoveAny:DEBUG()
	return MADEBUG
end

function MoveAny:HR()
	print( COL_Y .. "----------------------------------------------------------------------" )
end

function MoveAny:MSG( msg )
	print( "|cff3FC7EB" .. "[MoveAny |T135994:16:16:0:0|t]|r " .. COL_Y .. msg )
end

function MoveAny:MSG_Error( msg )
	print( "|cff3FC7EB" .. "[MoveAny |T135994:16:16:0:0|t]|r " .. COL_R .. "[ERROR] |r" .. msg )
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

function MoveAny:AddProfile( newname, other, noChange )
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	
	local name = MoveAny:GetValidProfileName( newname )

	MATAB["PROFILES"][name] = MATAB["PROFILES"][name] or {}

	if other and MATAB["PROFILES"][other] then
		MATAB["PROFILES"][name] = MATAB["PROFILES"][other]
	else
		MATAB["PROFILES"][name]["FRAMES"] =  MATAB["PROFILES"][name]["FRAMES"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["POINTS"] = MATAB["PROFILES"][name]["FRAMES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["FRAMES"]["SIZES"] = MATAB["PROFILES"][name]["FRAMES"]["SIZES"] or {}

		MATAB["PROFILES"][name]["ELES"] = MATAB["PROFILES"][name]["ELES"] or {}
		MATAB["PROFILES"][name]["ELES"]["POINTS"] = MATAB["PROFILES"][name]["ELES"]["POINTS"] or {}
		MATAB["PROFILES"][name]["ELES"]["SIZES"] = MATAB["PROFILES"][name]["ELES"]["SIZES"] or {}
		MATAB["PROFILES"][name]["ELES"]["OPTIONS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"] or {}

		MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] = MATAB["PROFILES"][name]["ELES"]["OPTIONS"]["ACTIONBARS"] or {}
	end
	if noChange then
		return
	end
	MoveAny:SetCP( name )
end

function MoveAny:RemoveProfile( name )
	MATAB = MATAB or {}
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}

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

function MoveAny:IImportPointValue( profileName, n, t, key, dbKey )
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
		return
	end

	local eleName = nil
	local value = nil
	local s1, e1 = strfind( n, key, 1, true )
	if s1 then
		eleName = strsub( n, 1, s1 - 1 )
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
			return
		end
		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["POINTS"] = MATAB["PROFILES"][profileName]["ELES"]["POINTS"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName] or {}

		MATAB["PROFILES"][profileName]["ELES"]["POINTS"][eleName][dbKey] = value
	end
end

function MoveAny:IImportSizesValue( profileName, n, t, key, dbKey )
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
		return
	end

	local eleName = nil
	local value = nil
	local s1, e1 = strfind( n, key, 1, true )
	if s1 then
		eleName = strsub( n, 1, s1 - 1 )
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
			return
		end
		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["SIZES"] = MATAB["PROFILES"][profileName]["ELES"]["SIZES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName] or {}

		MATAB["PROFILES"][profileName]["ELES"]["SIZES"][eleName][dbKey] = value
	end
end

function MoveAny:IImportOptionValue( profileName, n, t, key, dbKey )
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
		return
	end

	local eleName = nil
	local value = nil
	local s1, e1 = strfind( n, key, 1, true )
	if s1 then
		eleName = strsub( n, 1, s1 - 1 )
		if MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"][eleName] ~= nil then
			value = t
		elseif MATAB["PROFILES"]["DEFAULT"]["ELES"]["POINTS"]["MA" .. eleName] ~= nil then 
			eleName = "MA" .. eleName
			value = t
		end
	end

	if eleName and value then
		if MATAB["PROFILES"][profileName] == nil then
			MoveAny:MSG( "[MAIImportValue] Missing Default Profile" )
			return
		end
		MATAB["PROFILES"][profileName]["ELES"] = MATAB["PROFILES"][profileName]["ELES"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"] = MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"] or {}
		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName] = MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName] or {}

		MATAB["PROFILES"][profileName]["ELES"]["OPTIONS"][eleName][dbKey] = value
	end
end

function MoveAny:GetTab()
	return MATAB["PROFILES"][MoveAny:GetCP()]
end

function MoveAny:GV( key, val )
	return MATAB[key] or val
end

function MoveAny:SV( key, val )
	MATAB[key] = val

	MoveAny:EnableSave( "SV", key )
end

function MoveAny:FixTable( tab )
	for i, v in pairs( tab ) do
		local typ = type( v )
		if typ == "string" then
			if type( tonumber( v ) ) == "number" then
				tab[i] = tonumber( v )
			end
		elseif typ == "table" then
			MoveAny:FixTable( v )
		elseif typ == "number" then
			
		elseif typ == "boolean" then
			
		else
			MoveAny:MSG( "Missing typ", typ )
		end
	end
end

function MoveAny:InitDB()
	MATAB = MATAB or {}

	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	MATABPC = MATABPC or {}
	MATABPC["CURRENTPROFILE"] = MATABPC["CURRENTPROFILE"] or "DEFAULT"

	if MATAB["PROFILES"]["DEFAULT"] == nil then
		MoveAny:AddProfile( "DEFAULT" )
	end

	if MATAB["PROFILES"][MoveAny:GetCP()] == nil then
		MoveAny:SetCP( "DEFAULT" )
	end

	MoveAny:FixTable( MATAB["PROFILES"] )

	-- FIX, parent had big junk behind
	for x, profil in pairs( MATAB["PROFILES"] ) do
		if profil then
			if profil["ELES"] and profil["ELES"]["POINTS"] then
				for i, v in pairs( profil["ELES"]["POINTS"] ) do
					if v.PA then
						v.PA = nil
					end
				end
			end
			if profil["FRAMES"] and profil["FRAMES"]["POINTS"] then
				for i, v in pairs( profil["FRAMES"]["POINTS"] ) do
					if v.PA then
						v.PA = nil
					end
				end
			end
		end
	end

	if MAITAB then
		MoveAny:HR()
		MoveAny:MSG( "...MoveAndImprove detected, importing Profiles..." )
		for name, tab in pairs( MAITAB["PROFILES"] ) do
			local newName = name .. " by MAI"
			if MATAB["PROFILES"][newName] == nil then
				MoveAny:MSG( "Importing Profile: " .. name )
				MoveAny:AddProfile( newName, nil, true )
				for n, t in pairs( tab ) do
					MoveAny:IImportPointValue( newName, n, t, "point", "AN" )
					MoveAny:IImportPointValue( newName, n, t, "relativePoint", "RE" )
					MoveAny:IImportPointValue( newName, n, t, "ofsx", "PX" )
					MoveAny:IImportPointValue( newName, n, t, "ofsy", "PY" )

					MoveAny:IImportSizesValue( newName, n, t, "scale", "SCALE" )
					MoveAny:IImportOptionValue( newName, n, t, "rows", "ROWS" )
					MoveAny:IImportOptionValue( newName, n, t, "spacing", "SPACING" )
				end
			else
				MoveAny:MSG( "Already Imported Profile: " .. name )
			end
		end
		MoveAny:MSG( "Done Importing Profiles." )
		MoveAny:HR()
	end
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

	if element ~= "MALOCK" then
		MoveAny:EnableSave( "SetEnabled", element )
	end
end

function MoveAny:IsEnabled( element, value, settings )
	if element == nil then
		MoveAny:MSG_Error( "[IsEnabled] Missing Name" )
		return false
	end

	local enabled, forced = MoveAny:IsInEditModeEnabled( element )
	if value and enabled and not forced and not settings then
		MoveAny:MSG( format( MoveAny:GT( "LID_HELPTEXT" ), MoveAny:GT( element ) ) )
		return false
	end

	MoveAny:GetTab()["ELES"]["OPTIONS"][element] = MoveAny:GetTab()["ELES"]["OPTIONS"][element] or {}
	if MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] == nil then
		MoveAny:GetTab()["ELES"]["OPTIONS"][element]["ENABLED"] = value
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

	MoveAny:EnableSave( "SetEleOption", key )
end

function MoveAny:GetElePoint( key )
	if key then
		MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}

		local an = MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"]
		--local pa = MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"]
		MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"] = nil
		local re = MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"]
		local px = MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"]
		local py = MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"]
		return an, _, re, px, py
	else
		MoveAny:MSG_Error( "[GetElePoint] KEY not found" )
		return "CENTER", UIParent, "CENTER"
	end
end

function MoveAny:SetElePoint( key, p1, p2, p3, p4, p5 )
	MoveAny:GetTab()["ELES"]["POINTS"][key] = MoveAny:GetTab()["ELES"]["POINTS"][key] or {}

	MoveAny:GetTab()["ELES"]["POINTS"][key]["AN"] = p1
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PA"] = nil
	MoveAny:GetTab()["ELES"]["POINTS"][key]["RE"] = p3
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PX"] = p4
	MoveAny:GetTab()["ELES"]["POINTS"][key]["PY"] = p5

	local frame = _G[key]
	if frame then
		frame:ClearAllPoints()
		frame:SetPoint( p1, UIParent, p3, p4, p5 )

		if frame.systemInfo and frame.systemInfo.anchorInfo then
			frame.systemInfo.anchorInfo.point = p1
			frame.systemInfo.anchorInfo.relativeTo = "UIParent"
			frame.systemInfo.anchorInfo.relativePoint = p3
			frame.systemInfo.anchorInfo.offsetX = p4
			frame.systemInfo.anchorInfo.offsetY = p5
			frame.systemInfo.isInDefaultPosition = false

			EditModeSystemMixin.UpdateSystem( frame, frame.systemInfo )
		end
	end

	MoveAny:EnableSave( "SetElePoint", key )
end

function MoveAny:GetEleSize( key )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	local sw = MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"]
	local sh = MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"]
	return sw, sh
end

function MoveAny:SetEleSize( key, sw, sh )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	MoveAny:GetTab()["ELES"]["SIZES"][key]["SW"] = math.floor( sw )
	MoveAny:GetTab()["ELES"]["SIZES"][key]["SH"] = math.floor( sh )

	MoveAny:EnableSave( "SetEleSize", key )
end

function MoveAny:GetEleScale( key )
	MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

	local scale = MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"]
	if scale and type( scale ) ~= "number" then
		MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"] = tonumber( scale )
	end
	if scale and tonumber( scale ) > 0 then
		return tonumber( scale )
	elseif scale then
		MoveAny:MSG( "[GetEleScale] SCALE <= 0, key: " .. tostring( key ) )
		return 1
	end
end

function MoveAny:SetEleScale( key, scale )
	if scale == nil then
		MoveAny:MSG( "[SetEleScale] NO SCALE, key: " .. tostring( key ) )
		return
	end
	if scale > 0 then
		MoveAny:GetTab()["ELES"]["SIZES"][key] = MoveAny:GetTab()["ELES"]["SIZES"][key] or {}

		MoveAny:GetTab()["ELES"]["SIZES"][key]["SCALE"] = scale

		local frame = _G[key]
		if frame then
			frame:SetScale( scale )
		end
	else
		MoveAny:MSG( "[SetEleScale] SCALE <= 0, key: " .. tostring( key ) )
	end

	MoveAny:EnableSave( "SetEleScale", key )
end

function MoveAny:GetFramePoint( key )
	MoveAny:GetTab()["FRAMES"]["POINTS"][key] = MoveAny:GetTab()["FRAMES"]["POINTS"][key] or {}

	local an = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"]
	--local pa = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"]
	local re = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"]
	local px = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"]
	local py = MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"]
	return an, _, re, px, py
end

function MoveAny:SetFramePoint( key, p1, p2, p3, p4, p5 )
	MoveAny:GetTab()["FRAMES"]["POINTS"][key] = MoveAny:GetTab()["FRAMES"]["POINTS"][key] or {}
	
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["AN"] = p1
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PA"] = nil
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["RE"] = p3
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PX"] = p4
	MoveAny:GetTab()["FRAMES"]["POINTS"][key]["PY"] = p5

	MoveAny:EnableSave( "SetFramePoint", key )
end

function MoveAny:GetFrameScale( key )
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}

	local scale = MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"]
	return scale
end

function MoveAny:SetFrameScale( key, scale )
	MoveAny:GetTab()["FRAMES"]["SIZES"][key] = MoveAny:GetTab()["FRAMES"]["SIZES"][key] or {}

	MoveAny:GetTab()["FRAMES"]["SIZES"][key]["SCALE"] = scale

	MoveAny:EnableSave( "SetFrameScale", key )
end

function MoveAny:GetMinimapTable()
	MATAB["PROFILES"] = MATAB["PROFILES"] or {}
	
	MoveAny:GetTab()["MMICON"] = MoveAny:GetTab()["MMICON"] or {}

	return MoveAny:GetTab()["MMICON"]
end

function MoveAny:GetGridSize()
	return MoveAny:GV( "GRIDSIZE", 10 )
end
