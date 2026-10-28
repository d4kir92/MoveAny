if _G["D4AtlasViewerRegistry"] then return end
local CreateFrame = _G["CreateFrame"]
local GameTooltip = _G["GameTooltip"]
local registry = {
    cols = 8,
    rows = 8,
    cell = 64,
    gap = 4,
    page = 1,
    filter = "",
}

_G["D4AtlasViewerRegistry"] = registry
function registry.LoadAtlases()
    if registry.all then return registry.all end
    registry.all = {}
    registry.lower = {}
    local keys = {}
    local list = C_Texture and C_Texture.GetAtlasElements and C_Texture.GetAtlasElements()
    if type(list) == "table" then
        for _, name in pairs(list) do
            if type(name) == "string" and not keys[name] then
                keys[name] = string.lower(name)
                tinsert(registry.all, name)
            end
        end
    end

    table.sort(
        registry.all,
        function(a, b)
            local la, lb = keys[a], keys[b]
            if la == lb then return a < b end

            return la < lb
        end
    )

    for i, name in ipairs(registry.all) do
        registry.lower[i] = keys[name]
    end

    return registry.all
end

function registry.ApplyFilter()
    local all = registry.LoadAtlases()
    local filter = string.lower(registry.filter or "")
    if filter == "" then
        registry.shown = all
    else
        registry.shown = {}
        for i, name in ipairs(all) do
            if string.find(registry.lower[i], filter, 1, true) then tinsert(registry.shown, name) end
        end
    end

    registry.page = 1
    registry.Refresh()
end

function registry.GetPageCount()
    local perPage = registry.cols * registry.rows

    return math.max(1, math.ceil(#registry.shown / perPage))
end

function registry.SetPage(page)
    registry.page = math.min(math.max(1, page), registry.GetPageCount())
    registry.Refresh()
end

function registry.FitTexture(btn, name)
    local tex = btn.tex
    tex:SetAtlas(name, false)
    local info = C_Texture.GetAtlasInfo(name)
    local w = info and info.width or 0
    local h = info and info.height or 0
    local box = registry.cell - 4
    if w <= 0 or h <= 0 then
        tex:SetSize(box, box)
    else
        local scale = math.min(box / w, box / h)
        tex:SetSize(math.max(1, w * scale), math.max(1, h * scale))
    end
end

function registry.Refresh()
    local frame = registry.frame
    if not frame or not registry.shown then return end
    local perPage = registry.cols * registry.rows
    local first = (registry.page - 1) * perPage
    for i, btn in ipairs(frame.cells) do
        local name = registry.shown[first + i]
        btn.atlas = name
        if name then
            registry.FitTexture(btn, name)
            btn:Show()
        else
            btn:Hide()
        end
    end

    local pages = registry.GetPageCount()
    frame.pageText:SetText(string.format("%d / %d  (%d)", registry.page, pages, #registry.shown))
    frame.prev:SetEnabled(registry.page > 1)
    frame.next:SetEnabled(registry.page < pages)
    if frame.empty then frame.empty:SetShown(#registry.all == 0) end
    if GameTooltip:GetOwner() and GameTooltip:GetOwner().d4AtlasCell then
        local owner = GameTooltip:GetOwner()
        if owner:IsMouseOver() and owner.atlas then
            owner:GetScript("OnEnter")(owner)
        else
            GameTooltip:Hide()
        end
    end
end

function registry.OnCellEnter(btn)
    if not btn.atlas then return end
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    GameTooltip:SetText(btn.atlas, 1, 1, 1)
    local info = C_Texture.GetAtlasInfo(btn.atlas)
    if info and info.width and info.height then GameTooltip:AddLine(string.format("%d x %d", info.width, info.height), 0.7, 0.7, 0.7) end
    GameTooltip:Show()
end

function registry.CreateCell(parent, index)
    local btn = CreateFrame("Button", nil, parent)
    btn.d4AtlasCell = true
    btn:SetSize(registry.cell, registry.cell)
    local col = (index - 1) % registry.cols
    local row = math.floor((index - 1) / registry.cols)
    local step = registry.cell + registry.gap
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", col * step, -row * step)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.4)
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.15)
    btn.tex = btn:CreateTexture(nil, "ARTWORK")
    btn.tex:SetPoint("CENTER")
    btn:SetScript("OnEnter", registry.OnCellEnter)
    btn:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    return btn
end

function registry.CreateFrame()
    if registry.frame then return registry.frame end
    local step = registry.cell + registry.gap
    local gridW = registry.cols * step - registry.gap
    local gridH = registry.rows * step - registry.gap
    local frame = CreateFrame("Frame", "D4AtlasViewerFrame", UIParent, "BasicFrameTemplateWithInset")
    registry.frame = frame
    frame:SetSize(gridW + 24, gridH + 100)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    local title = frame.TitleText or frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    if not frame.TitleText then title:SetPoint("TOP", frame, "TOP", 0, -5) end
    title:SetText("Atlas Viewer")
    tinsert(UISpecialFrames, "D4AtlasViewerFrame")
    local search = CreateFrame("EditBox", "D4AtlasViewerSearch", frame, "InputBoxTemplate")
    search:SetSize(gridW - 8, 20)
    search:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -30)
    search:SetAutoFocus(false)
    search:SetScript(
        "OnTextChanged",
        function(box, userInput)
            if not userInput then return end
            registry.filter = box:GetText() or ""
            registry.ApplyFilter()
        end
    )

    search:SetScript("OnEscapePressed", search.ClearFocus)
    search:SetScript("OnEnterPressed", search.ClearFocus)
    local hint = search:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    hint:SetPoint("LEFT", search, "LEFT", 2, 0)
    hint:SetText(_G["SEARCH"] or "Search")
    search:HookScript(
        "OnEditFocusGained",
        function()
            hint:Hide()
        end
    )

    search:HookScript(
        "OnEditFocusLost",
        function(box)
            hint:SetShown((box:GetText() or "") == "")
        end
    )

    local grid = CreateFrame("Frame", nil, frame)
    grid:SetSize(gridW, gridH)
    grid:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -58)
    grid:EnableMouseWheel(true)
    grid:SetScript(
        "OnMouseWheel",
        function(_, delta)
            registry.SetPage(registry.page - delta)
        end
    )

    frame.cells = {}
    for i = 1, registry.cols * registry.rows do
        frame.cells[i] = registry.CreateCell(grid, i)
    end

    frame.empty = grid:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.empty:SetPoint("CENTER")
    frame.empty:SetText("C_Texture.GetAtlasElements not available")
    frame.empty:Hide()
    frame.prev = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.prev:SetSize(100, 22)
    frame.prev:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 10)
    frame.prev:SetText(_G["PREV"] or "Prev")
    frame.prev:SetScript(
        "OnClick",
        function()
            registry.SetPage(registry.page - 1)
        end
    )

    frame.next = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.next:SetSize(100, 22)
    frame.next:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 10)
    frame.next:SetText(_G["NEXT"] or "Next")
    frame.next:SetScript(
        "OnClick",
        function()
            registry.SetPage(registry.page + 1)
        end
    )

    frame.pageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.pageText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
    frame:Hide()

    return frame
end

function registry.Toggle()
    local frame = registry.CreateFrame()
    if frame:IsShown() then
        frame:Hide()

        return
    end

    frame:Show()
    if not registry.shown then registry.ApplyFilter() end
end

_G["SLASH_D4ATLASVIEWER1"] = "/atlasviewer"
SlashCmdList["D4ATLASVIEWER"] = registry.Toggle
