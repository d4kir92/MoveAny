local _, D4 = ...
local hooksecurefunc = getglobal("hooksecurefunc")
local GetBuildInfo = getglobal("GetBuildInfo")
local CreateFrame = getglobal("CreateFrame")
local InCombatLockdown = getglobal("InCombatLockdown")
local GetTime = getglobal("GetTime")
local tinsert = getglobal("tinsert")
local tremove = getglobal("tremove")
local CUSTOM_CLASS_COLORS = getglobal("CUSTOM_CLASS_COLORS")
local RAID_CLASS_COLORS = getglobal("RAID_CLASS_COLORS")
local GetAtlasInfo = getglobal("GetAtlasInfo")
--[[ Basics ]]
local buildNr = select(4, GetBuildInfo())
local buildName = "CLASSIC"
if buildNr >= 100000 then
    buildName = "RETAIL"
elseif buildNr >= 50000 then
    buildName = "MISTS"
elseif buildNr >= 40000 then
    buildName = "CATA"
elseif buildNr >= 30000 then
    buildName = "WRATH"
elseif buildNr >= 20000 then
    buildName = "TBC"
end

function D4:GetWoWBuildNr()
    return buildNr
end

function D4:GetWoWBuild()
    return buildName
end

D4.oldWow = D4.oldWow or false
if getglobal("C_Timer") == nil then
    D4:MSG("[D4] ADD MISSING: C_Timer")
    setglobal("C_Timer", {})
    local f = CreateFrame("Frame")
    f.tab = {}
    f:HookScript(
        "OnUpdate",
        function()
            for i, v in pairs(f.tab) do
                if v[1] < GetTime() then
                    local func = v[2]
                    func()
                    tremove(f.tab, i)
                end
            end
        end
    )

    C_Timer.After = function(duration, callback)
        tinsert(f.tab, {GetTime() + duration, callback})
    end

    D4.oldWow = true
end

if getglobal("C_Widget") == nil then
    setglobal("C_Widget", {})
    function C_Widget.IsWidget(frame)
        if frame and frame.GetName then return true end

        return false
    end
end

local countAfter = {}
local countAfterEvents = {}
local debug = false
function D4:SetDebug(bo)
    debug = bo
end

function D4:After(time, callback, from)
    if from == nil then
        D4:INFO("[AFTER] MISSING FROM", time)

        return
    end

    if callback == nil then
        D4:INFO("[AFTER] CALLBACK IS NIL", time, from)

        return
    end

    if debug then
        countAfter[from] = countAfter[from] or 0
        countAfter[from] = countAfter[from] + 1
    end

    C_Timer.After(
        time,
        function()
            callback()
        end
    )
end

function D4:GetCountAfter()
    return countAfter
end

function D4:GetCountAfterEvents()
    return countAfterEvents
end

function D4:GetClassColor(class)
    local colorTab = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
    if CUSTOM_CLASS_COLORS == nil and D4:GetWoWBuild() == "CLASSIC" and class == "SHAMAN" then return 0, 0.44, 0.87, "FF0070DE" end
    if colorTab[class] then return colorTab[class].r, colorTab[class].g, colorTab[class].b, colorTab[class].colorStr end

    return 1, 1, 1, "ffffffff"
end

if GetClassColor == nil then
    D4:MSG("[D4] ADD MISSING: GetClassColor")
    GetClassColor = function(class)
        local color = D4:GetClassColor(class)
        if color then return color.r, color.g, color.b, color.colorStr end

        return 1, 1, 1, "ffffffff"
    end

    D4.oldWow = true
end

function D4:IsOldWow()
    return D4.oldWow
end

function D4:RegisterEvent(frame, event, unit)
    if C_EventUtils == nil then
        frame:RegisterEvent(event)
        D4:MSG("[D4] MISSING C_EventUtils")

        return
    end

    if C_EventUtils.IsEventValid(event) then
        if unit then
            frame:RegisterUnitEvent(event, unit)
        else
            frame:RegisterEvent(event)
        end
    end
end

function D4:UnregisterEvent(frame, event)
    if C_EventUtils == nil then
        frame:UnregisterEvent(event)

        return
    end

    if C_EventUtils.IsEventValid(event) then
        frame:UnregisterEvent(event)
    end
end

function D4:OnEvent(frame, callback, from)
    if from == nil then
        D4:INFO("[D4][OnEvent] Missing from")

        return
    end

    frame:HookScript(
        "OnEvent",
        function(sel, event, ...)
            if debug then
                countAfterEvents[from] = countAfterEvents[from] or 0
                countAfterEvents[from] = countAfterEvents[from] + 1
            end

            callback(sel, event, ...)
        end
    )
end

function D4:ForeachChildren(frame, callback, from)
    if frame == nil then
        D4:MSG("[ForeachChildren] frame == nil", from)

        return
    end

    if frame.GetNumChildren == nil or frame.GetChildren == nil then
        D4:MSG("[ForeachChildren] frame.GetNumChildren == nil or  frame.GetChildren == nil", from)

        return
    end

    if callback == nil then
        D4:MSG("[ForeachChildren] Missing Callback", from)

        return
    end

    for x = 1, frame:GetNumChildren() do
        local child = select(x, frame:GetChildren())
        if child then
            local ret = callback(child, x)
            if ret then return ret end
        else
            return
        end
    end
end

function D4:ForeachRegions(frame, callback, from)
    if frame == nil then
        D4:MSG("[ForeachRegions] frame == nil", from)

        return
    end

    if frame.GetNumRegions == nil or frame.GetRegions == nil then
        D4:MSG("[ForeachRegions] frame.GetNumRegions == nil or  frame.GetRegions == nil", from)

        return
    end

    if callback == nil then
        D4:MSG("[ForeachRegions] Missing Callback", from)

        return
    end

    for x = 1, frame:GetNumRegions() do
        local region = select(x, frame:GetRegions())
        if region then
            local ret = callback(region, x)
            if ret then return ret end
        else
            return
        end
    end
end

--[[ QOL ]]
local callbacks = {}
local fSecure = CreateFrame("Frame")
D4:RegisterEvent(fSecure, "PLAYER_REGEN_ENABLED")
D4:OnEvent(
    fSecure,
    function()
        for i, func in pairs(callbacks) do
            func()
        end

        callbacks = {}
    end, "fSecure"
)

function D4:SafeExec(sel, func, from)
    if sel == nil then
        D4:MSG("[D4][SafeExec] MISSING FRAME", from)

        return
    end

    if from == nil then
        D4:MSG("[D4][SafeExec] MISSING FROM", D4:GetName(sel))

        return
    end

    if InCombatLockdown() and sel:IsProtected() then
        callbacks[from] = func

        return
    end

    func()
end

function D4:GetCVar(name)
    if C_CVar and C_CVar.GetCVar then return C_CVar.GetCVar(name) end
    if GetCVar then return GetCVar(name) end
    D4:MSG("[D4][GetCVar] FAILED")

    return nil
end

function D4:GetItemInfo(itemID)
    if itemID == nil then return nil end
    if C_Item and C_Item.GetItemInfo then return C_Item.GetItemInfo(itemID) end
    local GetItemInfo = getglobal("GetItemInfo")
    if GetItemInfo then return GetItemInfo(itemID) end
    D4:MSG("[D4][GetItemInfo] FAILED")

    return nil
end

function D4:GetItemCount(itemID)
    if itemID == nil then return nil end
    if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(itemID) end
    local GetItemCount = getglobal("GetItemCount")
    if GetItemCount then return GetItemCount(itemID) end
    D4:MSG("[D4][GetItemCount] FAILED")

    return nil
end

function D4:GetSpellPowerCost(spellId)
    if spellId == nil then return nil end
    if C_Spell and C_Spell.GetSpellPowerCost then return C_Spell.GetSpellPowerCost(spellId) end
    local GetSpellPowerCost = getglobal("GetSpellPowerCost")
    if GetSpellPowerCost then return GetSpellPowerCost(spellId) end
    D4:MSG("[D4][GetSpellPowerCost] FAILED")

    return nil
end

function D4:GetSpellInfo(spellID)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local tab = C_Spell.GetSpellInfo(spellID)
        if tab then return tab.name, nil, tab.iconID, tab.castTime, tab.minRange, tab.maxRange, tab.spellID end

        return tab
    end

    local GetSpellInfo = getglobal("GetSpellInfo")
    if GetSpellInfo then return GetSpellInfo(spellID) end
    D4:MSG("[D4][GetSpellInfo] FAILED")

    return nil
end

function D4:IsSpellInRange(spellID, spellType, unit)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.IsSpellInRange then return C_Spell.IsSpellInRange(spellID, unit) end
    local IsSpellInRange = getglobal("IsSpellInRange")
    if IsSpellInRange then return IsSpellInRange(spellID, spellType, unit) end
    D4:MSG("[D4][IsSpellInRange] FAILED")

    return nil
end

function D4:GetSpellCharges(spellID)
    if spellID == nil then return nil end
    if C_Spell and C_Spell.GetSpellCharges then return C_Spell.GetSpellCharges(spellID) end
    local GetSpellCharges = getglobal("GetSpellCharges")
    if GetSpellCharges then return GetSpellCharges(spellID) end
    D4:MSG("[D4][GetSpellCharges] FAILED")

    return nil
end

function D4:GetSpellCastCount(...)
    if C_Spell and C_Spell.GetSpellCastCount then return C_Spell.GetSpellCastCount(...) end
    local GetSpellCastCount = getglobal("GetSpellCastCount")
    if GetSpellCastCount then return GetSpellCastCount(...) end
    D4:MSG("[D4][GetSpellCastCount] FAILED")

    return nil
end

function D4:GetMouseFocus()
    if GetMouseFoci then return GetMouseFoci()[1] end
    local GetMouseFocus = getglobal("GetMouseFocus")
    if GetMouseFocus then return GetMouseFocus() end
    D4:MSG("[D4][GetMouseFocus] FAILED")

    return nil
end

function D4:GetItemGem(hyperLink, index)
    if C_Item and C_Item.GetItemGem then return C_Item.GetItemGem(hyperLink, index) end
    local GetItemGem = getglobal("GetItemGem")
    if GetItemGem then return GetItemGem(hyperLink, index) end

    return nil, nil
end

function D4:GetDetailedItemLevelInfo(itemInfo)
    if C_Item and C_Item.GetDetailedItemLevelInfo then return C_Item.GetDetailedItemLevelInfo(itemInfo) end
    local GetDetailedItemLevelInfo = getglobal("GetDetailedItemLevelInfo")
    if GetDetailedItemLevelInfo then return GetDetailedItemLevelInfo(itemInfo) end

    return nil, nil, nil
end

function D4:GetContainerItemLink(bagID, slotID)
    if slotID < 0 then return nil end
    if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bagID, slotID) end
    local GetContainerItemLink = getglobal("GetContainerItemLink")
    if GetContainerItemLink then return GetContainerItemLink(bagID, slotID) end

    return nil
end

local function D4GetContainerNumSlots(bagID)
    if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bagID) end
    local GetContainerNumSlots = getglobal("GetContainerNumSlots")
    if GetContainerNumSlots then return GetContainerNumSlots(bagID) end

    return nil
end

function D4:GetContainerNumSlots(bagID)
    local cur = D4GetContainerNumSlots(bagID)
    local max = cur
    if bagID == 0 and IsAccountSecured and not IsAccountSecured() then
        max = cur + 4
    end

    return max, cur
end

function D4:UnitAura(...)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then return C_UnitAuras.GetAuraDataByIndex(...) end
    local UnitAura = getglobal("UnitAura")
    if UnitAura then return UnitAura(...) end
    D4:MSG("[D4][UnitAura] FAILED")

    return nil
end

function D4:LoadAddOn(name)
    if C_AddOns and C_AddOns.LoadAddOn then return C_AddOns.LoadAddOn(name) end
    local LoadAddOn = getglobal("LoadAddOn")
    if LoadAddOn then return LoadAddOn(name) end
    D4:MSG("[D4][LoadAddOn] FAILED")

    return nil
end

function D4:IsAddOnLoaded(name, from)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local loaded, _ = C_AddOns.IsAddOnLoaded(name)

        return loaded
    end

    local IsAddOnLoaded = getglobal("IsAddOnLoaded")
    if IsAddOnLoaded then return IsAddOnLoaded(name) end
    D4:MSG("[D4][IsAddOnLoaded] FAILED")

    return nil
end

function D4:IsAddonLoaded(name, from)
    return D4:IsAddOnLoaded(name, from)
end

function D4:AtlasExists(atlas)
    if atlas == nil then return false end
    if C_Texture and C_Texture.GetAtlasInfo(atlas) then
        return true
    elseif GetAtlasInfo and GetAtlasInfo(atlas) then
        return true
    end

    return false
end

local ICON_TAG_LIST_EN = {
    ["star"] = 1,
    ["yellow"] = 1,
    ["cirlce"] = 2,
    ["orange"] = 2,
    ["diamond"] = 3,
    ["triangle"] = 4,
    ["moon"] = 5,
    ["square"] = 6,
    ["blue"] = 6,
    ["cross"] = 7,
    ["red"] = 7,
    ["skull"] = 8,
}

local function FixIconChat(sel, event, message, author, ...)
    if ICON_LIST then
        for tag in string.gmatch(message, "%b{}") do
            local term = strlower(string.gsub(tag, "[{}]", ""))
            if ICON_TAG_LIST_EN[term] and ICON_LIST[ICON_TAG_LIST_EN[term]] then
                message = string.gsub(message, tag, ICON_LIST[ICON_TAG_LIST_EN[term]] .. "0|t")
            end
        end
    end

    return false, message, author, ...
end

D4:After(
    2,
    function()
        local chatChannels = {}
        for i, v in pairs(_G) do
            if string.find(i, "CHAT_MSG_", 1, true) and not tContains(chatChannels, i) then
                tinsert(chatChannels, i)
            end
        end

        for id, channelName in pairs(chatChannels) do
            ChatFrame_AddMessageEventFilter(channelName, FixIconChat)
        end

        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FixIconChat)
    end, "D4 1"
)

if D4:GetWoWBuild() == "CLASSIC" then
    D4:After(
        2,
        function()
            -- FIX HEALTH
            D4.fixedHealth = D4.fixedHealth or false
            if D4.fixedHealth == false then
                D4.fixedHealth = true
                local foundText = false
                local HealthBarTexts = {_G["TargetFrameHealthBar"].RightText, _G["TargetFrameHealthBar"].LeftText, _G["TargetFrameHealthBar"].TextString, _G["TargetFrameTextureFrameDeadText"]}
                for _, healthBar in pairs(HealthBarTexts) do
                    if _G["TargetFrameHealthBar"].TextString ~= nil then
                        foundText = true
                    end
                end

                if foundText == false then
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarText", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarTextLeft", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameHealthBarTextRight", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarText", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarTextLeft", "BORDER", "TextStatusBarText")
                    _G["TargetFrameTextureFrame"]:CreateFontString("TargetFrameManaBarTextRight", "BORDER", "TextStatusBarText")
                    _G["TargetFrameHealthBarText"]:ClearAllPoints()
                    _G["TargetFrameHealthBarTextLeft"]:ClearAllPoints()
                    _G["TargetFrameHealthBarTextRight"]:ClearAllPoints()
                    _G["TargetFrameManaBarText"]:ClearAllPoints()
                    _G["TargetFrameManaBarTextLeft"]:ClearAllPoints()
                    _G["TargetFrameManaBarTextRight"]:ClearAllPoints()
                    _G["TargetFrameHealthBarText"]:SetPoint("CENTER", _G["TargetFrameHealthBar"], "CENTER", 0, 0)
                    _G["TargetFrameHealthBarTextLeft"]:SetPoint("LEFT", _G["TargetFrameHealthBar"], "LEFT", 0, 0)
                    _G["TargetFrameHealthBarTextRight"]:SetPoint("RIGHT", _G["TargetFrameHealthBar"], "RIGHT", 0, 0)
                    _G["TargetFrameManaBarText"]:SetPoint("CENTER", _G["TargetFrameManaBar"], "CENTER", 0, 0)
                    _G["TargetFrameManaBarTextLeft"]:SetPoint("LEFT", _G["TargetFrameManaBar"], "LEFT", 2, 0)
                    _G["TargetFrameManaBarTextRight"]:SetPoint("RIGHT", _G["TargetFrameManaBar"], "RIGHT", -2, 0)
                    _G["TargetFrameHealthBar"].LeftText = _G["TargetFrameHealthBarTextLeft"]
                    _G["TargetFrameHealthBar"].RightText = _G["TargetFrameHealthBarTextRight"]
                    _G["TargetFrameManaBar"].LeftText = _G["TargetFrameManaBarTextLeft"]
                    _G["TargetFrameManaBar"].RightText = _G["TargetFrameManaBarTextRight"]
                    UnitFrameHealthBar_Initialize("target", _G["TargetFrameHealthBar"], _G["TargetFrameHealthBarText"], true)
                    UnitFrameManaBar_Initialize("target", _G["TargetFrameManaBar"], _G["TargetFrameManaBarText"], true)
                    if FocusFrame then
                        UnitFrameHealthBar_Initialize("focus", _G["FocusFrameHealthBar"], _G["FocusFrameHealthBarText"], true)
                        UnitFrameManaBar_Initialize("focus", _G["FocusFrameManaBar"], _G["FocusFrameManaBarText"], true)
                    end

                    local function TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
                        if statusFrame.LeftText and statusFrame.RightText then
                            statusFrame.LeftText:SetText("")
                            statusFrame.RightText:SetText("")
                            statusFrame.LeftText:Hide()
                            statusFrame.RightText:Hide()
                        end

                        if (tonumber(valueMax) ~= valueMax or valueMax > 0) and not statusFrame.pauseUpdates then
                            statusFrame:Show()
                            if (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) or statusFrame.forceShow then
                                textString:Show()
                            elseif statusFrame.lockShow > 0 and (not statusFrame.forceHideText) then
                                textString:Show()
                            else
                                textString:SetText("")
                                textString:Hide()

                                return
                            end

                            if value == 0 and statusFrame.zeroText then
                                textString:SetText(statusFrame.zeroText)
                                statusFrame.isZero = 1
                                textString:Show()

                                return
                            end

                            statusFrame.isZero = nil
                            local valueDisplay = value
                            local valueMaxDisplay = valueMax
                            if statusFrame.numericDisplayTransformFunc then
                                valueDisplay, valueMaxDisplay = statusFrame.numericDisplayTransformFunc(value, valueMax)
                            else
                                valueDisplay = AbbreviateLargeNumbers(value)
                                valueMaxDisplay = AbbreviateLargeNumbers(valueMax)
                            end

                            local shouldUsePrefix = statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable))
                            local displayMode = GetCVar("statusTextDisplay")
                            if statusFrame.showNumeric then
                                displayMode = "NUMERIC"
                            end

                            if statusFrame.disablePercentages and displayMode == "PERCENT" then
                                displayMode = "NUMERIC"
                            end

                            if valueMax <= 0 or displayMode == "NUMERIC" or displayMode == "NONE" then
                                if shouldUsePrefix then
                                    textString:SetText(statusFrame.prefix .. " " .. valueDisplay .. " / " .. valueMaxDisplay)
                                else
                                    textString:SetText(valueDisplay .. " / " .. valueMaxDisplay)
                                end
                            elseif displayMode == "BOTH" then
                                if statusFrame.LeftText and statusFrame.RightText then
                                    if not statusFrame.disablePercentages and (not statusFrame.powerToken or statusFrame.powerToken == "MANA") then
                                        statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%")
                                        statusFrame.LeftText:Show()
                                    end

                                    statusFrame.RightText:SetText(valueDisplay)
                                    statusFrame.RightText:Show()
                                    textString:Hide()
                                else
                                    valueDisplay = valueDisplay .. " / " .. valueMaxDisplay
                                    if not statusFrame.disablePercentages then
                                        valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay
                                    end
                                end

                                textString:SetText(valueDisplay)
                            elseif displayMode == "PERCENT" then
                                valueDisplay = math.ceil((value / valueMax) * 100) .. "%"
                                if shouldUsePrefix then
                                    textString:SetText(statusFrame.prefix .. " " .. valueDisplay)
                                else
                                    textString:SetText(valueDisplay)
                                end
                            end
                        else
                            textString:Hide()
                            textString:SetText("")
                            if not statusFrame.alwaysShow then
                                statusFrame:Hide()
                            else
                                statusFrame:SetValue(0)
                            end
                        end
                    end

                    hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", TextStatusBar_UpdateTextStringWithValues)
                end
            end
        end, "FixHealth"
    )
end

function D4:ReplaceStr(text, old, new)
    if text == nil then return "" end
    local b, e = text:find(old, 1, true)
    if b == nil then
        return text
    else
        return text:sub(1, b - 1) .. new .. text:sub(e + 1)
    end
end

local genderNames = {"", "Male", "Female"}
function D4:GetClassAtlas(class)
    return ("classicon-%s"):format(class)
end

function D4:GetClassIcon(class)
    return "|A:" .. D4:GetClassAtlas(class) .. ":16:16:0:0|a"
end

function D4:GetRaceAtlas(race, gender)
    return ("raceicon-%s-%s"):format(race:lower(), gender:lower())
end

function D4:GetRaceIcon(race, gender)
    if race:lower() == "scourge" and C_Texture.GetAtlasInfo(D4:GetRaceAtlas(race, genderNames[gender])) == nil then
        race = "Undead"
    end

    local atlas = "|A:" .. D4:GetRaceAtlas(race, genderNames[gender]) .. ":16:16:0:0|a"
    if C_Texture.GetAtlasInfo(D4:GetRaceAtlas(race, genderNames[gender])) == nil then
        D4:INFO("[D4][GetRaceIcon] INVALID ATLAS", race, gender)
    end

    return atlas
end

local units = {"player"}
for i = 1, 4 do
    table.insert(units, "party" .. i)
end

for i = 1, 40 do
    table.insert(units, "raid" .. i)
end

local specIcons = {
    ["DEATHKNIGHT"] = {
        [1] = 135770,
        [2] = 135773,
        [3] = 135775,
    },
    ["DEMONHUNTER"] = {
        [1] = 1247264,
        [2] = 1247265,
    },
    ["DRUID"] = {
        [1] = 136096,
        [2] = 132115,
        [3] = 132276,
        [4] = 136041,
    },
    ["EVOKER"] = {
        [1] = 4511811,
        [2] = 4511812,
        [3] = 5198700,
    },
    ["HUNTER"] = {
        [1] = 132164,
        [2] = 132222,
        [3] = 132215,
    },
    ["MAGE"] = {
        [1] = 135932,
        [2] = 135812,
        [3] = 135846,
    },
    ["MONK"] = {
        [1] = 608951,
        [2] = 608952,
        [3] = 608953,
    },
    ["PALADIN"] = {
        [1] = 135920,
        [2] = 135893,
        [3] = 135873,
    },
    ["PRIEST"] = {
        [1] = 135940,
        [2] = 135920,
        [3] = 136207,
    },
    ["ROGUE"] = {
        [1] = 136189,
        [2] = 132282,
        [3] = 132320,
    },
    ["SHAMAN"] = {
        [1] = 136048,
        [2] = 132314,
        [3] = 136043,
    },
    ["WARLOCK"] = {
        [1] = 136145,
        [2] = 136172,
        [3] = 136186,
    },
    ["WARRIOR"] = {
        [1] = 132292,
        [2] = 132347,
        [3] = 134952,
    },
}

local classIds = {
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 3,
    ["ROGUE"] = 4,
    ["PRIEST"] = 5,
    ["DEATHKNIGHT"] = 6,
    ["SHAMAN"] = 7,
    ["MAGE"] = 8,
    ["WARLOCK"] = 9,
    ["MONK"] = 10,
    ["DRUID"] = 11,
    ["DEMONHUNTER"] = 12,
    ["EVOKER"] = 13,
}

local specRoless = {
    ["DEATHKNIGHT"] = {
        [1] = "TANK",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["DEMONHUNTER"] = {
        [1] = "DAMAGER",
        [2] = "TANK",
    },
    ["EVOKER"] = {
        [1] = "DAMAGER",
        [2] = "HEALER",
        [3] = "HEALER",
    },
    ["HUNTER"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["MAGE"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["MONK"] = {
        [1] = "TANK",
        [2] = "HEALER",
        [3] = "DAMAGER",
    },
    ["PALADIN"] = {
        [1] = "HEALER",
        [2] = "TANK",
        [3] = "DAMAGER",
    },
    ["PRIEST"] = {
        [1] = "HEALER",
        [2] = "HEALER",
        [3] = "DAMAGER",
    },
    ["ROGUE"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["SHAMAN"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "HEALER",
    },
    ["WARLOCK"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "DAMAGER",
    },
    ["WARRIOR"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "TANK",
    },
}

if D4:GetWoWBuild() == "RETAIL" then
    specRoless["DRUID"] = {
        [1] = "DAMAGER",
        [2] = "DAMAGER",
        [3] = "TANK",
        [4] = "HEALER",
    }
else
    specRoless["DRUID"] = {
        [1] = "DAMAGER",
        [2] = "TANK",
        [3] = "HEALER",
    }
end

function D4:GetRole(className, specId)
    return specRoless[className][specId]
end

function D4:GetSpecIcon(className, specId)
    if GetSpecializationInfoForClassID then
        local classId = classIds[className]
        if classId then
            local _, _, _, icon = GetSpecializationInfoForClassID(classId, specId)
            if icon then return icon end
        end
    end

    return specIcons[className][specId]
end

local icons = {}
local searchIcons = true
function D4:GetTalentIcons()
    local GetPrimaryTalentTree = getglobal("GetPrimaryTalentTree")
    local GetTalentTabInfo = getglobal("GetTalentTabInfo")
    if searchIcons then
        if GetSpecialization and GetSpecialization() then
            if GetSpecializationInfo then
                for i = 1, 4 do
                    local name, _, _, icon = GetSpecializationInfo(i)
                    if name and icon then
                        searchIcons = false
                        icons[name] = icon
                    end
                end
            end
        elseif GetPrimaryTalentTree and GetPrimaryTalentTree() then
            if GetTalentTabInfo then
                for i = 1, 4 do
                    local name, _, _, icon = GetTalentTabInfo(i)
                    if name and icon then
                        searchIcons = false
                        icons[name] = icon
                    end
                end
            end
        elseif GetTalentTabInfo then
            for i = 1, 4 do
                local name, _, _, icon = GetTalentTabInfo(i)
                if name and icon then
                    searchIcons = false
                    icons[name] = icon
                end
            end
        end
    end

    return icons
end

function D4:GetTalentInfo()
    local specid, icon
    local GetPrimaryTalentTree = getglobal("GetPrimaryTalentTree")
    local GetTalentTabInfo = getglobal("GetTalentTabInfo")
    local GetActiveTalentGroup = getglobal("GetActiveTalentGroup")
    local GetTalentGroupRole = getglobal("GetTalentGroupRole")
    if GetSpecialization and GetSpecialization() then
        specid = GetSpecialization()
        if GetSpecializationInfo then
            _, _, _, icon = GetSpecializationInfo(specid)
        end

        return specid, icon
    elseif GetPrimaryTalentTree and GetPrimaryTalentTree() then
        specid = GetPrimaryTalentTree()
        if specid and GetTalentTabInfo then
            _, _, _, icon = GetTalentTabInfo(specid)
        end

        return specid, icon
    elseif GetTalentTabInfo then
        local ps = 0
        for i = 1, 4 do
            local _, _, _, iconTexture, pointsSpent = GetTalentTabInfo(i)
            if pointsSpent ~= nil and pointsSpent > ps then
                ps = pointsSpent
                specid = i
                icon = iconTexture
                local _, class = UnitClass("PLAYER")
                if GetActiveTalentGroup and class == "DRUID" and D4:GetWoWBuild() ~= "CATA" then
                    local group = GetActiveTalentGroup()
                    local role = GetTalentGroupRole(group)
                    if role == "DAMAGER" then
                        specid = 2
                        icon = 132115
                    elseif role == "TANK" then
                        specid = 3
                    end
                end
            end

            if icon == nil then
                local _, class = UnitClass("PLAYER")
                icon = D4:GetSpecIcon(class, specid)
                if icon == nil then
                    if class == "DRUID" then
                        icon = 625999
                    elseif class == "HUNTER" then
                        icon = 626000
                    elseif class == "MAGE" then
                        icon = 626001
                    elseif class == "PALADIN" then
                        if specid == 1 then
                            icon = 135920
                        elseif specid == 2 then
                            icon = 135893
                        elseif specid == 3 then
                            icon = 135873
                        end
                    elseif class == "PRIEST" then
                        icon = 626004
                    elseif class == "ROGUE" then
                        icon = 626005
                    elseif class == "SHAMAN" then
                        icon = 626006
                    elseif class == "WARLOCK" then
                        icon = 626007
                    elseif class == "WARRIOR" then
                        icon = 626008
                    end
                end
            end
        end

        return specid, icon
    end

    return nil, nil
end

function D4:GetRoleByGuid(guid)
    if UnitGroupRolesAssigned == nil then return "NONE" end
    for i, unit in pairs(units) do
        if UnitGUID(unit) == guid then return UnitGroupRolesAssigned(unit) end
    end

    return "NONE"
end

function D4:GetRoleIcon(role)
    if role == "" then return "" end
    if role == "NONE" then return "" end
    if role == "DAMAGER" then
        return "UI-LFG-RoleIcon-DPS"
    elseif role == "HEALER" then
        return "UI-LFG-RoleIcon-HEALER"
    elseif role == "TANK" then
        return "UI-LFG-RoleIcon-TANK"
    end

    return ""
end

function D4:GetHeroSpecId()
    local heroSpecID = nil
    if C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec then
        heroSpecID = C_ClassTalents.GetActiveHeroTalentSpec()
    end

    return heroSpecID
end

function D4:GetFrameByName(name)
    local frame = _G[name]
    if type(frame) == "table" then return frame end
    if name:find("%.") then
        local parts = {strsplit(".", name)}
        frame = _G[parts[1]]
        for i = 2, #parts do
            if type(frame) ~= "table" then return nil end
            frame = frame[parts[i]]
        end

        return type(frame) == "table" and frame or nil
    end

    local baseName, index = name:match("([^%[]+)%[(%d+)%]")
    if baseName and index and index ~= nil then
        if type(index) == "string" then
            index = tonumber(index)
        end

        if type(index) ~= "number" then return nil end
        local f = _G[baseName]

        return f and select(index, f:GetRegions()) or nil
    end

    return nil
end

local f = CreateFrame("Frame")
D4:RegisterEvent(f, "PLAYER_LOGIN")
D4:OnEvent(
    f,
    function(self, event, ...)
        local GetTrackingTexture = getglobal("GetTrackingTexture")
        local MiniMapTracking = getglobal("MiniMapTracking")
        local MiniMapTrackingIcon = getglobal("MiniMapTrackingIcon")
        if GetTrackingTexture then
            local trackingTexture = GetTrackingTexture()
            if trackingTexture and MiniMapTracking and MiniMapTrackingIcon and not MiniMapTrackingIcon:GetTexture() then
                MiniMapTrackingIcon:SetTexture(trackingTexture)
                MiniMapTracking:Show()
            end
        end
    end, "MiniMapTracking"
)

function D4:DrawDebug(name, callback, fontSize, sw, sh, p1, p2, p3, p4, p5)
    sw = sw or 100
    sh = sh or 50
    p1 = p1 or "CENTER"
    p2 = p2 or UIParent
    p3 = p3 or "CENTER"
    p4 = p4 or 0
    p5 = p5 or 0
    local fDebug = CreateFrame("Frame", name)
    fDebug:SetSize(sw, sh)
    fDebug:SetPoint(p1, p2, p3, p4, p5)
    fDebug.header = fDebug:CreateFontString(nil, nil, "GameFontNormal")
    fDebug.header:SetPoint("CENTER", fDebug, "CENTER", 0, 200)
    fDebug.header:SetSize(sw, sh)
    fDebug.header:SetJustifyH("LEFT")
    --fDebug.header:SetText(name)
    if fontSize then
        D4:SetFontSize(fDebug.header, fontSize)
    end

    fDebug.text = fDebug:CreateFontString(nil, nil, "GameFontNormal")
    fDebug.text:SetPoint("CENTER", fDebug, "CENTER", 0, 0)
    fDebug.text:SetSize(sw, sh)
    fDebug.text:SetJustifyH("LEFT")
    if fontSize then
        D4:SetFontSize(fDebug.text, fontSize)
    end

    local function Think()
        local text = callback()
        fDebug.text:SetText(text)
        D4:After(
            0.2,
            function()
                Think()
            end, "D4:DD " .. name
        )
    end

    Think()

    return fDebug
end

function D4:FindInGlobal(name, exact, ...)
    local args = {...}
    D4:After(
        0.1,
        function()
            for i, v in pairs(_G) do
                if exact then
                    if v and type(v) == "string" and v == name then
                        print("i", i, "v", v)
                    end
                else
                    if v and type(v) == "string" and string.find(v, name, 1, true) then
                        if #args > 0 then
                            local all = true
                            for x, w in pairs(args) do
                                if string.find(v, w, 1, true) == nil then
                                    all = false
                                    break
                                end
                            end

                            if all then
                                print("v", v, "i", i)
                            end
                        else
                            print("v", v, "i", i)
                        end
                    end
                end
            end
        end, "FindInGlobal"
    )
end
