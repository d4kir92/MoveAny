local _, MoveAny = ...
local buffsDelay = 0.1
local ma_bb_set_scale = {}
local gridBusy = {}
local gridHooked = {}
local gridInfo = {}
local gridStats = {
    ["placed"] = 0,
    ["skipped"] = 0,
    ["errors"] = 0,
    ["lastError"] = "",
    ["lastAnchor"] = "?",
    ["lastRoot"] = "?",
    ["lastRootSize"] = "?",
    ["collapse"] = "none",
    ["collapseOn"] = "?",
    ["collapseSizes"] = "?",
    ["insets"] = "?",
}

local GRID_ANCHORS = {
    [0] = "AUTO",
    [3] = "TOPLEFT",
    [4] = "TOPRIGHT",
    [5] = "LEFT",
    [6] = "RIGHT",
    [8] = "BOTTOMLEFT",
    [9] = "BOTTOMRIGHT",
}

function MoveAny:GetAuraGridAnchors()
    return GRID_ANCHORS
end

function MoveAny:HasAuraGrid(ele)
    return ele == "BuffFrame" or ele == "DebuffFrame"
end

local function ResolveGridAnchor(ele, root, value)
    local point = GRID_ANCHORS[value]
    if point and point ~= "AUTO" then return point end
    local p1 = MoveAny:GetElePoint(ele)
    if type(p1) == "string" and p1 ~= "" then return p1 end
    if root and root.GetPoint then
        local ok, rp1 = pcall(root.GetPoint, root)
        if ok and type(rp1) == "string" and rp1 ~= "" then return rp1 end
    end

    return "TOPRIGHT"
end

local function GridOrder(btn, walkIndex)
    local name = MoveAny:GetName(btn)
    if name then
        local num = tonumber(string.match(name, "(%d+)$"))
        if num then return num end
    end

    return walkIndex
end

local function SafeSize(frame)
    if frame == nil or frame.GetSize == nil then return nil end
    local ok, w, h = pcall(function()
        local a, b = frame:GetSize()
        if type(a) ~= "number" or type(b) ~= "number" then return nil end
        if a < 1 then return nil end
        if b < 1 then b = a end

        return a, b
    end)

    if ok and type(w) == "number" then return w, h end

    return nil
end

local function AuraIconRegion(btn)
    if btn == nil then return nil end
    local icon = btn.Icon or btn.icon
    if icon == nil then
        local name = MoveAny:GetName(btn)
        if name and name ~= "" then icon = _G[name .. "Icon"] end
    end

    if icon and icon.GetObjectType and icon.GetHeight then
        local ok, tall = pcall(function() return icon:GetObjectType() == "Texture" and icon:GetHeight() > 1 end)
        if ok and tall == true then return icon end
    end

    return nil
end

local function AuraIconInsets(btn)
    local icon = AuraIconRegion(btn)
    if icon == nil then return 0, 0, 0, 0 end
    local ok, left, right, top, bottom = pcall(function()
        local bl, br, bt, bb = btn:GetLeft(), btn:GetRight(), btn:GetTop(), btn:GetBottom()
        local il, ir, it, ib = icon:GetLeft(), icon:GetRight(), icon:GetTop(), icon:GetBottom()
        if type(bl) ~= "number" or type(br) ~= "number" or type(bt) ~= "number" or type(bb) ~= "number" then return nil end
        if type(il) ~= "number" or type(ir) ~= "number" or type(it) ~= "number" or type(ib) ~= "number" then return nil end

        return math.max(0, il - bl), math.max(0, br - ir), math.max(0, bt - it), math.max(0, ib - bb)
    end)

    if ok and type(left) == "number" then return left, right, top, bottom end

    return 0, 0, 0, 0
end

local function ApplyAuraGrid(btn)
    if btn == nil or gridBusy[btn] then return false end
    local info = gridInfo[btn]
    if info == nil then return false end
    if btn.IsProtected and InCombatLockdown() and btn:IsProtected() then
        gridStats.skipped = gridStats.skipped + 1

        return false
    end

    local limit = MoveAny:GetEleOption(info.ele, info.prefix .. "LIMIT", 10)
    if type(limit) ~= "number" or limit < 1 then limit = 1 end
    local spacingX = MoveAny:GetEleOption(info.ele, info.prefix .. "SPACINGX", 4)
    local spacingY = MoveAny:GetEleOption(info.ele, info.prefix .. "SPACINGY", 10)
    if type(spacingX) ~= "number" then spacingX = 4 end
    if type(spacingY) ~= "number" then spacingY = 10 end
    local sw, sh = SafeSize(btn)
    if sw == nil then return false end
    local anchor = ResolveGridAnchor(info.ele, info.root, MoveAny:GetEleOption(info.ele, info.prefix .. "ANCHOR", 0))
    if info.index == 1 then
        gridStats.lastAnchor = anchor
        gridStats.lastRoot = tostring(MoveAny:GetName(info.root))
        local rw, rh = SafeSize(info.root)
        gridStats.lastRootSize = string.format("%.0fx%.0f", rw or 0, rh or 0)
    end

    local row = math.floor((info.index - 1) / limit)
    local col = (info.index - 1) % limit
    local x = col * (sw + spacingX)
    local y = row * (sh + spacingY)
    if string.find(anchor, "RIGHT", 1, true) then x = -x end
    if not string.find(anchor, "BOTTOM", 1, true) then y = -y end
    local inLeft, inRight, inTop, inBottom = AuraIconInsets(btn)
    if string.find(anchor, "LEFT", 1, true) then
        x = x - inLeft
    elseif string.find(anchor, "RIGHT", 1, true) then
        x = x + inRight
    else
        x = x + (inRight - inLeft) / 2
    end

    if string.find(anchor, "TOP", 1, true) then
        y = y + inTop
    elseif string.find(anchor, "BOTTOM", 1, true) then
        y = y - inBottom
    else
        y = y - (inBottom - inTop) / 2
    end

    if info.index == 1 then gridStats.insets = string.format("l %.0f r %.0f t %.0f b %.0f", inLeft, inRight, inTop, inBottom) end
    local same = false
    pcall(function()
        local cp1, cp2, cp3, cp4, cp5 = btn:GetPoint()
        same = cp1 == anchor and cp2 == info.root and cp3 == anchor and cp4 == x and cp5 == y
    end)

    if same then return true end
    gridBusy[btn] = true
    local ok, err = pcall(function()
        btn:ClearAllPoints()
        btn:SetPoint(anchor, info.root, anchor, x, y)
    end)

    gridBusy[btn] = false
    if ok then
        gridStats.placed = gridStats.placed + 1
    else
        gridStats.errors = gridStats.errors + 1
        gridStats.lastError = string.sub(tostring(err), 1, 120)
    end

    return ok
end

local function UsableAuraButton(btn)
    if btn == nil or type(btn) ~= "table" then return false end
    if btn.IsShown == nil or not btn:IsShown() then return false end
    if btn.SetPoint == nil or btn.GetSize == nil then return false end

    return true
end

local COLLAPSE_GAP = 2
local collapseBusy = {}
local collapseHooked = {}
local collapseInfo = {}
local function ApplyCollapseButton(cb)
    if cb == nil or collapseBusy[cb] then return false end
    local info = collapseInfo[cb]
    if info == nil or info.first == nil then return false end
    if cb.IsProtected and InCombatLockdown() and cb:IsProtected() then return false end
    local target = AuraIconRegion(info.first) or info.first
    local _, bh = SafeSize(info.first)
    local _, th = SafeSize(target)
    local _, ah = SafeSize(cb)
    gridStats.collapseSizes = string.format("btn %.0f target %.0f arrow %.0f", bh or 0, th or 0, ah or 0)
    local p1, p3, p4 = "RIGHT", "LEFT", -COLLAPSE_GAP
    if string.find(info.anchor, "RIGHT", 1, true) then p1, p3, p4 = "LEFT", "RIGHT", COLLAPSE_GAP end
    local same = false
    pcall(function()
        local cp1, cp2, cp3, cp4, cp5 = cb:GetPoint()
        same = cp1 == p1 and cp2 == target and cp3 == p3 and cp4 == p4 and cp5 == 0
    end)

    if same then return true end
    collapseBusy[cb] = true
    local ok = pcall(function()
        cb:ClearAllPoints()
        cb:SetPoint(p1, target, p3, p4, 0)
    end)

    collapseBusy[cb] = false
    if ok then
        gridStats.collapse = p1
        if target == info.first then
            gridStats.collapseOn = "button"
        else
            gridStats.collapseOn = "icon"
        end
    else
        gridStats.collapse = "failed"
    end

    return ok
end

function MoveAny:LayoutAuraGrid(root, ele, prefix, globalPrefix)
    if root == nil or ele == nil then return 0 end
    local container = root.AuraContainer or root
    if container == nil or container.GetChildren == nil then return 0 end
    local list = {}
    local walk = 0
    local seen = {}
    local function collect(child)
        if seen[child] or not UsableAuraButton(child) then return end
        seen[child] = true
        walk = walk + 1
        tinsert(
            list,
            {
                ["btn"] = child,
                ["order"] = GridOrder(child, walk),
                ["walk"] = walk
            }
        )
    end

    MoveAny:ForeachChildren(container, collect, "MoveAny LayoutAuraGrid")
    if #list == 0 and globalPrefix then
        for i = 1, 40 do
            collect(_G[globalPrefix .. i])
        end
    end

    table.sort(
        list,
        function(a, b)
            if a.order ~= b.order then return a.order < b.order end

            return a.walk < b.walk
        end
    )

    for index, entry in ipairs(list) do
        local btn = entry.btn
        gridInfo[btn] = {
            ["ele"] = ele,
            ["prefix"] = prefix,
            ["root"] = root,
            ["index"] = index
        }

        if gridHooked[btn] == nil then
            gridHooked[btn] = true
            hooksecurefunc(btn, "SetPoint", function(sel) ApplyAuraGrid(sel) end)
        end

        ApplyAuraGrid(btn)
    end

    local cb = root.CollapseAndExpandButton
    if cb and cb.SetPoint and list[1] then
        collapseInfo[cb] = {
            ["first"] = list[1].btn,
            ["anchor"] = ResolveGridAnchor(ele, root, MoveAny:GetEleOption(ele, prefix .. "ANCHOR", 0))
        }

        if collapseHooked[cb] == nil then
            collapseHooked[cb] = true
            hooksecurefunc(cb, "SetPoint", function(sel) ApplyCollapseButton(sel) end)
        end

        ApplyCollapseButton(cb)
    end

    return #list
end

function MoveAny:GetAuraGridStats()
    return gridStats
end

function MoveAny:CreateTargetFrameMoverSetup(unit, moverName, updateFunction, targetFrameName, configPrefix)
    return function()
        local frame = _G[moverName]
        local targetFrame = _G[targetFrameName]
        function frame:UpdateScaleAndAlpha()
            local scale = frame:GetScale()
            local alpha = frame:GetAlpha()
            for i, bb in pairs(MoveAny[updateFunction]()) do
                if bb then
                    bb:SetScale(scale)
                    bb:SetAlpha(alpha)
                end
            end
        end

        local buffSize = nil
        local added = {}
        function frame:Update(from)
            if targetFrame and targetFrame:GetLeft() then
                for i, bb in pairs(MoveAny[updateFunction]()) do
                    if bb then
                        if added[bb] == nil then
                            local setPoint = false
                            buffSize = buffSize or bb:GetSize()
                            hooksecurefunc(bb, "SetPoint", function(sel, ...)
                                if setPoint then return end
                                setPoint = true
                                if buffSize < 10 then buffSize = 10 end
                                bb:SetSize(buffSize, buffSize)
                                local frameEffScale = frame:GetEffectiveScale()
                                local targetEffScale = targetFrame:GetEffectiveScale()
                                local frameCenterX, frameCenterY = frame:GetCenter()
                                local targetCenterX, targetCenterY = targetFrame:GetCenter()
                                local frameRealX = frameCenterX * frameEffScale
                                local frameRealY = frameCenterY * frameEffScale
                                local targetRealX = targetCenterX * targetEffScale
                                local targetRealY = targetCenterY * targetEffScale
                                frame.PX = frameRealX - targetRealX
                                frame.PY = frameRealY - targetRealY
                                local mode = MoveAny:GetEleOption(moverName, configPrefix .. "MODE", 0)
                                local limit = MoveAny:GetEleOption(moverName, configPrefix .. "LIMIT", 10)
                                local spacingX = MoveAny:GetEleOption(moverName, configPrefix .. "SPACINGX", 4)
                                local spacingY = MoveAny:GetEleOption(moverName, configPrefix .. "SPACINGY", 10)
                                local row = math.floor((added[bb] - 1) / limit)
                                local col = (added[bb] - 1) % limit
                                local selScale = sel:GetEffectiveScale()
                                local pixelX = frame.PX + col * (buffSize * selScale + spacingX)
                                local pixelY
                                if mode == 1 then
                                    pixelY = frame.PY + row * (buffSize * selScale + spacingY)
                                else
                                    pixelY = frame.PY - row * (buffSize * selScale + spacingY)
                                end

                                sel:ClearAllPoints()
                                sel:SetPoint("CENTER", targetFrame, "CENTER", pixelX / selScale, pixelY / selScale)
                                setPoint = false
                            end)
                        end

                        if added[bb] ~= i then added[bb] = i end
                        bb:ClearAllPoints()
                        bb:SetPoint("LEFT", targetFrame, "RIGHT", 0, 0)
                    end
                end
            end
        end

        targetFrame:HookScript("OnShow", function()
            C_Timer.After(buffsDelay, function()
                MoveAny[updateFunction]()
                frame:UpdateScaleAndAlpha()
                frame:Update("INIT")
            end, "OnShow" .. moverName)
        end)

        local bbf = CreateFrame("FRAME")
        MoveAny:RegisterEvent(bbf, "UNIT_AURA", unit)
        MoveAny:OnEvent(bbf, function()
            MoveAny[updateFunction]()
            frame:UpdateScaleAndAlpha()
            frame:Update("UNIT_AURA")
        end, moverName .. " 7")

        hooksecurefunc(frame, "SetPoint", function()
            frame:UpdateScaleAndAlpha()
            frame:Update("frame SetPoint")
        end)

        hooksecurefunc(frame, "SetScale", function(sel)
            if InCombatLockdown() and sel:IsProtected() then return false end
            if ma_bb_set_scale[sel] then return end
            ma_bb_set_scale[sel] = true
            frame:UpdateScaleAndAlpha()
            frame:Update("SetScale")
            ma_bb_set_scale[sel] = false
        end)

        frame:UpdateScaleAndAlpha()
    end
end

function MoveAny:RegisterTargetFrameMover(unit, moverName, lstrKey, updateFunction, targetFrameName, configPrefix)
    local moverFrame = CreateFrame("Frame", moverName, UIParent)
    moverFrame:SetSize(21, 21)
    moverFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    MoveAny:RegisterWidget({
        ["name"] = moverName,
        ["lstr"] = lstrKey,
        ["userplaced"] = true,
        ["setup"] = MoveAny:CreateTargetFrameMoverSetup(unit, moverName, updateFunction, targetFrameName, configPrefix),
    })
end
