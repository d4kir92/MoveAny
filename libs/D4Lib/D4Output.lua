local AddonName, D4 = ...
function D4:GetAddonMeta(key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then return C_AddOns.GetAddOnMetadata(AddonName, key) end
    if GetAddOnMetadata then return GetAddOnMetadata(AddonName, key) end

    return nil
end

function D4:GetAddonVersion()
    return D4:GetAddonMeta("Version")
end

function D4:GetAddonIcon()
    local icon = D4:GetAddonMeta("IconTexture")

    return tonumber(icon) or icon
end

local nam = AddonName
local ico = D4:GetAddonIcon() or ""
function D4:SetAddonOutput(name, icon)
    nam = name or AddonName
    ico = icon or D4:GetAddonIcon() or ""
end

function D4:MSG(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFA0A0FF", nam, ico), ...)
end

function D4:INFO(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFFFF00", nam, ico), ...)
end

function D4:WARN(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFF0000", nam, ico), ...)
end

function D4:ERR(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFFF0000", nam, ico), ...)
end

function D4:DEB(...)
    print(string.format("|cFFFFFF00[|r|cFFA0A0FF%s|r |T%s:0:0:0:0|t|cFFFFFF00]|cFFAAAA00", nam, ico), ...)
end
