local _, D4 = ...
local d4_isMouseDown = {}
local deg, atan2 = math.deg, math.atan2
local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
local floor, ceil = math.floor, math.ceil
local mmShapes = {
    ["ROUND"] = {true, true, true, true},
    ["SQUARE"] = {false, false, false, false},
    ["CORNER-TOPLEFT"] = {false, false, false, true},
    ["CORNER-TOPRIGHT"] = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"] = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
    ["SIDE-LEFT"] = {false, true, false, true},
    ["SIDE-RIGHT"] = {true, false, true, false},
    ["SIDE-TOP"] = {false, false, true, true},
    ["SIDE-BOTTOM"] = {true, true, false, false},
    ["TRICORNER-TOPLEFT"] = {false, true, true, true},
    ["TRICORNER-TOPRIGHT"] = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local BTNPREFIX = "MinimapButton_D4Lib_LibDBIcon_"

local function CollectD4Buttons(skip)
    local list = {}
    D4:ForeachChildren(
        Minimap,
        function(child)
            if child == skip then return end
            local nam = D4:GetName(child)
            if nam and string.find(nam, BTNPREFIX, 1, true) == 1 then tinsert(list, child) end
        end,
        "[D4] CollectD4Buttons"
    )

    return list
end

local function ForceShowD4Buttons(list)
    if list == nil then return end
    for _, child in ipairs(list) do
        if child.fadeOut then child.fadeOut:Stop() end
        if child.fadeIn then child.fadeIn:Stop() end
        child:SetAlpha(1)
    end
end

local function IsOnMinimap(btn)
    if D4:GetParent(btn) ~= Minimap then return false end
    local _, relativeTo = btn:GetPoint(1)

    return relativeTo == nil or relativeTo == Minimap
end

local function ReleaseD4Buttons(list)
    if list == nil then return end
    for _, child in ipairs(list) do
        if child.D4Think then child.D4Think(true) end
    end
end

local BAGNAME = "LeaPlusGlobalMinimapCombinedButtonFrame"
local BAGCELL = 30
local function GetButtonBag()
    return _G[BAGNAME]
end

local function IsExcludedFromButtonBag(btn)
    local db = _G["LeaPlusDB"]
    if type(db) ~= "table" or type(db["MiniExcludeList"]) ~= "string" then return false end
    local nam = D4:GetName(btn)
    if nam == nil then return false end
    local short = strlower(string.sub(nam, #BTNPREFIX + 1))

    return short ~= "" and string.find(strlower(db["MiniExcludeList"]), short, 1, true) ~= nil
end

local function LayoutButtonBag()
    local bag = GetButtonBag()
    if bag == nil or not bag:IsShown() then return end
    local own = {}
    local other = 0
    local otherPerRow = 1
    D4:ForeachChildren(
        bag,
        function(child)
            local nam = D4:GetName(child)
            if nam and string.find(nam, BTNPREFIX, 1, true) == 1 then
                if child:IsShown() then tinsert(own, child) end
            elseif child:IsShown() then
                other = other + 1
                for i = 1, child:GetNumPoints() do
                    local point, relativeTo, _, x = child:GetPoint(i)
                    if point == "TOPLEFT" and relativeTo == bag and type(x) == "number" then otherPerRow = max(otherPerRow, floor(x / BAGCELL + 0.5) + 1) end
                end
            end
        end,
        "[D4] LayoutButtonBag"
    )

    if #own == 0 then return end
    table.sort(own, function(a, b) return strlower(D4:GetName(a)) < strlower(D4:GetName(b)) end)
    local perRow = max(otherPerRow, min(10, ceil((other + #own) / 4)))
    local cols = min(other, otherPerRow)
    local rows = ceil(other / otherPerRow)
    local slot = 0
    for _, child in ipairs(own) do
        local row, col
        repeat
            row, col = floor(slot / perRow), slot % perRow
            slot = slot + 1
        until col >= otherPerRow or row * otherPerRow + col >= other
        child:SetScale(1)
        child:ClearAllPoints()
        child:SetPoint("TOPLEFT", bag, "TOPLEFT", col * BAGCELL, -row * BAGCELL)
        cols = max(cols, col + 1)
        rows = max(rows, row + 1)
    end

    bag:SetSize(cols * BAGCELL, rows * BAGCELL)
end

local function MoveToButtonBag(btn)
    local bag = GetButtonBag()
    if bag == nil or btn.d4NoBag or D4:GetParent(btn) == bag or IsExcludedFromButtonBag(btn) then return end
    if not bag.d4Hooked then
        bag.d4Hooked = true
        bag:HookScript("OnShow", function() D4:After(0, LayoutButtonBag, "[D4] ButtonBagLayout") end)
    end

    btn:SetParent(bag)
    if btn.d4BagBg == nil then
        btn.d4BagBg = btn:CreateTexture(nil, "BACKGROUND")
        btn.d4BagBg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
        btn.d4BagBg:SetPoint("CENTER")
        btn.d4BagBg:SetSize(BAGCELL, BAGCELL)
        btn.d4BagBg:SetVertexColor(0, 0, 0, 0.5)
    end

    LayoutButtonBag()
end

local function IgnoreInButtonBags(btn)
    local ignore = _G["MBB_Ignore"]
    local nam = D4:GetName(btn)
    if not btn.d4NoBag or btn.d4MBBIgnored or type(ignore) ~= "table" or nam == nil then return end
    btn.d4MBBIgnored = true
    tinsert(ignore, "^" .. (string.gsub(nam, "%p", "%%%0")) .. "$")
end

local function UpdateButtonBags(btn)
    IgnoreInButtonBags(btn)
    MoveToButtonBag(btn)
end

local pos = {}
function D4:UpdatePosition(button, position, parent)
    if parent == nil and GetButtonBag() ~= nil and D4:GetParent(button) == GetButtonBag() then return false end
    parent = parent or Minimap
    pos[button] = position or 225
    local angle = rad(pos[button])
    local x, y, q = cos(angle), sin(angle), 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local qt = mmShapes[minimapShape]
    local w = (Minimap:GetWidth() / 2) + button:GetWidth() / 2 - button:GetWidth() / 5
    local h = (Minimap:GetHeight() / 2) + button:GetHeight() / 2 - button:GetHeight() / 5
    w = w / button:GetScale()
    h = h / button:GetScale()
    if qt[q] then
        x, y = x * w, y * h
    else
        local drw = sqrt(2 * w ^ 2) - 10
        local drh = sqrt(2 * h ^ 2) - 10
        x = max(-w, min(x * drw, w))
        y = max(-h, min(y * drh, h))
    end

    if InCombatLockdown() and button:IsProtected() then
        D4:After(0.1, function() D4:UpdatePosition(button, position, parent) end, "UpdatePosition")
        return false
    end

    button:ClearAllPoints()
    button:SetPoint("CENTER", parent, "CENTER", x, y)
    return true
end

function D4:GetMMBtn(name)
    return _G[name]
end

function D4:CreateMinimapButton(params)
    if params.icon == nil and params.atlas == nil then
        D4:MSG("[CreateMinimapButton] Missing Icon/Atlas")
        return
    end

    if params.name == nil then
        D4:MSG("[CreateMinimapButton] Missing Name")
        return
    end

    if params.dbtab == nil then
        D4:MSG("[CreateMinimapButton] Missing Database")
        return
    end

    params.sw = params.sw or 31
    params.sh = params.sh or 31
    if params.border == nil then params.border = true end
    params.dbtab[params.name] = params.dbtab[params.name] or {}
    _G["MinimapButton_D4Lib_LibDBIcon_" .. params.name] = CreateFrame("Button", "MinimapButton_D4Lib_LibDBIcon_" .. params.name, params.parent or Minimap)
    local btn = _G["MinimapButton_D4Lib_LibDBIcon_" .. params.name]
    btn:SetFrameLevel(501)
    btn.d4border = params.border
    btn.d4NoBag = params.nobag == true or params.addoncomp == false
    btn.db = params.dbtab
    btn.db.minimapPos = btn.db.minimapPos or 0
    btn.minimapPos = btn.minimapPos or 0
    btn:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
    btn.icon = btn:CreateTexture()
    btn.icon:SetPoint("CENTER")
    if params.icon ~= nil then
        btn.icon:SetTexture(params.icon)
        --btn.icon:SetMask("Interface\\AddOns\\ImproveAny\\media\\minimap_mask_round")
    elseif params.atlas ~= nil then
        local info = C_Texture.GetAtlasInfo(params.atlas)
        btn.icon:SetTexture(info.file)
        btn.icon:SetTexCoord(info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord)
    end

    btn:SetSize(params.sw, params.sh)
    if params.point ~= nil and params.parent ~= nil then
        btn.d4NoBag = true
        btn:SetPoint(unpack(params.point))
    else
        D4:UpdatePosition(btn, btn.db.minimapPos)
        btn:RegisterForClicks("AnyUp")
        btn:RegisterForDrag("LeftButton")
        btn:SetMovable(true)
        btn:SetScript("OnDragStart", function(sel)
            if not IsOnMinimap(sel) then return end
            d4_isMouseDown[sel] = true
            sel.d4Siblings = CollectD4Buttons(sel)
            ForceShowD4Buttons(sel.d4Siblings)
            if sel.D4Think then sel.D4Think(true) end
            sel:SetScript("OnUpdate", function(se)
                local mx, my = Minimap:GetCenter()
                local px, py = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                px, py = px / scale, py / scale
                local posi = 0
                if se.db then
                    posi = deg(atan2(py - my, px - mx)) % 360
                    se.db.minimapPos = posi
                else
                    posi = deg(atan2(py - my, px - mx)) % 360
                    se.minimapPos = posi
                end

                D4:UpdatePosition(se, posi)
                ForceShowD4Buttons(se.d4Siblings)
            end)

            sel.tooltip:Hide()
        end)

        btn:SetScript("OnDragStop", function(sel)
            sel:SetScript("OnUpdate", nil)
            d4_isMouseDown[sel] = false
            ReleaseD4Buttons(sel.d4Siblings)
            sel.d4Siblings = nil
            if sel.D4Think then sel.D4Think(true) end
        end)
    end

    btn.overlay = btn:CreateTexture(nil, "OVERLAY")
    if D4:GetWoWBuild() == "RETAIL" then
        btn.overlay:SetSize(params.sw * 0.95, params.sh * 0.95)
        btn.overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
        btn.overlay:SetPoint("CENTER", btn, "CENTER", -0.6, -0.2)
        btn.overlay:SetTexCoord(0, 0.6, 0, 0.6)
        btn.icon:SetSize(params.sw * 0.65, params.sh * 0.65)
    else
        btn.overlay:SetSize(params.sw * 0.95, params.sh * 0.95)
        btn.overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
        btn.overlay:SetPoint("CENTER", btn, "CENTER", 0, 0)
        btn.overlay:SetTexCoord(0, 0.6, 0, 0.6)
        btn.icon:SetSize(params.sw * 0.65, params.sh * 0.65)
    end

    if params.border == false then btn.overlay:Hide() end
    btn:SetScript("OnClick", function(sel, btnName)
        if d4_isMouseDown[sel] then return end
        if btnName == "LeftButton" and IsShiftKeyDown() and params.funcSL then
            params:funcSL()
        elseif btnName == "RightButton" and IsShiftKeyDown() and params.funcSR then
            params:funcSR()
        elseif btnName == "LeftButton" and params.funcL then
            params:funcL()
        elseif btnName == "RightButton" and params.funcR then
            params:funcR()
        elseif btnName == "MiddleButton" and params.funcM then
            params:funcM()
        end
    end)

    btn.tooltip = CreateFrame("GameTooltip", params.name .. "_tooltip", UIParent, "GameTooltipTemplate")
    btn:SetScript("OnEnter", function(sel)
        btn.tooltip:SetOwner(sel, "ANCHOR_RIGHT")
        if params.vTT then
            for i, v in pairs(params.vTT) do
                btn.tooltip:AddDoubleLine(v[1], v[2])
            end
        end

        if params.vTTUpdate then params:vTTUpdate(btn.tooltip) end
        btn.tooltip:Show()
    end)

    btn:SetScript("OnLeave", function(sel) btn.tooltip:Hide() end)
    if AddonCompartmentFrame and (params.addoncomp == nil or params.addoncomp == true) then
        AddonCompartmentFrame:RegisterAddon({
            text = params.name,
            icon = params.icon,
            registerForAnyClick = true,
            notCheckable = true,
            func = function(button, menuInputData, menu)
                local btnName = menuInputData.buttonName
                if btnName == "LeftButton" and IsShiftKeyDown() and params.funcSL then
                    params:funcSL()
                elseif btnName == "RightButton" and IsShiftKeyDown() and params.funcSR then
                    params:funcSR()
                elseif btnName == "MiddleButton" and IsShiftKeyDown() and params.funcSM then
                    params:funcSM()
                elseif btnName == "LeftButton" and params.funcL then
                    params:funcL()
                elseif btnName == "RightButton" and params.funcR then
                    params:funcR()
                elseif btnName == "MiddleButton" and params.funcM then
                    params:funcM()
                end
            end,
            funcOnEnter = function(button)
                MenuUtil.ShowTooltip(button, function(tooltip)
                    if not tooltip or not tooltip.AddLine then return end
                    for i, v in pairs(params.vTT) do
                        tooltip:AddDoubleLine(v[1], v[2])
                    end
                end)
            end,
            funcOnLeave = function(button) MenuUtil.HideTooltip(button) end,
        })
    end

    if not params.noalpha then
        btn.fadeOut = btn:CreateAnimationGroup()
        local animOut = btn.fadeOut:CreateAnimation("Alpha")
        animOut:SetOrder(1)
        animOut:SetDuration(0.1)
        if animOut.SetFromAlpha then animOut:SetFromAlpha(1) end
        if animOut.SetToAlpha then animOut:SetToAlpha(0) end
        animOut:SetStartDelay(0.1)
        if btn.fadeOut and btn.fadeOut.SetToFinalAlpha then btn.fadeOut:SetToFinalAlpha(true) end
        btn.fadeIn = btn:CreateAnimationGroup()
        local animIn = btn.fadeIn:CreateAnimation("Alpha")
        animIn:SetOrder(1)
        animIn:SetDuration(0.1)
        if animIn.SetFromAlpha then animIn:SetFromAlpha(0) end
        if animIn.SetToAlpha then animIn:SetToAlpha(1) end
        animIn:SetStartDelay(0.1)
        if btn.fadeIn and btn.fadeIn.SetToFinalAlpha then btn.fadeIn:SetToFinalAlpha(true) end
        local insideBtn = false
        local insideMinimap = false
        local oldState = false
        local function BtnThink(force)
            local onMinimap = IsOnMinimap(btn)
            local shouldShow = not onMinimap or insideBtn or insideMinimap or d4_isMouseDown[btn] == true
            if force then oldState = nil end
            if oldState ~= shouldShow then
                oldState = shouldShow
                if not shouldShow then
                    btn.fadeIn:Stop()
                    btn.fadeOut:Play()
                elseif onMinimap then
                    btn.fadeOut:Stop()
                    btn.fadeIn:Play()
                    btn:SetAlpha(1)
                else
                    btn.fadeOut:Stop()
                    btn.fadeIn:Stop()
                    btn:SetAlpha(1)
                end
            end
        end

        btn.D4Think = BtnThink
        hooksecurefunc(btn, "SetParent", function() BtnThink() end)
        hooksecurefunc(btn, "SetPoint", function() BtnThink() end)
        btn:HookScript("OnEnter", function()
            insideBtn = true
            BtnThink()
        end)

        btn:HookScript("OnLeave", function()
            insideBtn = false
            BtnThink()
        end)

        Minimap:HookScript("OnEnter", function()
            insideMinimap = true
            BtnThink()
        end)

        Minimap:HookScript("OnLeave", function()
            insideMinimap = false
            BtnThink()
        end)

        D4:After(4, function() BtnThink(true) end, "[D4] MinimapInit")
    end

    if params.dbkey and params.dbkey ~= "" then
        if D4.IsEnabled then
            if D4:IsEnabled(params.dbkey, D4:GetWoWBuild() ~= "RETAIL") then
                D4:ShowMMBtn(params.name)
            else
                D4:HideMMBtn(params.name)
            end
        else
            if D4:GV(params.dbtab, params.dbkey, D4:GetWoWBuild() ~= "RETAIL") then
                D4:ShowMMBtn(params.name)
            else
                D4:HideMMBtn(params.name)
            end
        end
    elseif params.dbkey == nil then
        D4:MSG("Missing dbkey in CreateMinimapButton", params.name, params.dbkey)
    end

    UpdateButtonBags(btn)
    return btn
end

function D4:ShowMMBtn(name)
    if name == nil then
        D4:MSG("[ShowMMBtn] Missing Name")
        return
    end

    local btn = D4:GetMMBtn("MinimapButton_D4Lib_LibDBIcon_" .. name)
    if btn then
        btn:Show()
        LayoutButtonBag()
    else
        D4:MSG("[ShowMMBtn] Missing Button", name)
    end
end

function D4:HideMMBtn(name)
    if name == nil then
        D4:MSG("[HideMMBtn] Missing Name")
        return
    end

    local btn = D4:GetMMBtn("MinimapButton_D4Lib_LibDBIcon_" .. name)
    if btn then
        btn:Hide()
        LayoutButtonBag()
    else
        D4:MSG("[HideMMBtn] Missing Button", name)
    end
end

function D4:UpdateLTP()
    local MinimapModder = LeaPlusDB and LeaPlusDB["MinimapModder"] and LeaPlusDB["MinimapModder"] == "On"
    if MinimapModder then
        --local HideMiniAddonButtons = LeaPlusDB["HideMiniAddonButtons"] == "On"
        D4:ForeachChildren(Minimap, function(child)
            local name = D4:GetName(child)
            if name then
                local s1 = string.find(string.lower(name), "libdbicon")
                if s1 and s1 > 1 and child.ltp == nil then
                    child.ltp = true
                    child:SetScale(0.75)
                    D4:UpdatePosition(child, pos[child])
                end
            end
        end, "MMBtns")
    end
end

D4:After(4, function() D4:UpdateLTP() end, "UpdateLTP")
local bagEvents = CreateFrame("Frame")
bagEvents:RegisterEvent("PLAYER_LOGIN")
bagEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
bagEvents:SetScript("OnEvent", function(sel, event)
    sel:UnregisterEvent(event)
    for _, child in ipairs(CollectD4Buttons()) do
        UpdateButtonBags(child)
    end
end)
