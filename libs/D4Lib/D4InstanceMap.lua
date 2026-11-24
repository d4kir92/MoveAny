local _, D4 = ...
local DEFAULT_ART_WIDTH = 1024
local DEFAULT_ART_HEIGHT = 1024
local UPDATE_INTERVAL = 0.05
local OVERLAY_LEVEL = 3000
local LEVEL_BUTTON_OFFSET = 8
local PIN_TOGGLE_OFFSET_X = 40
local PIN_TOGGLE_OFFSET_Y = 10
local FRAME_STRATA = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}
local BOSS_SCALE = {
    ["min"] = 0.5,
    ["max"] = 1.5,
    ["step"] = 0.05,
    ["width"] = 120,
    ["gap"] = 16,
}
local VIEW_MAX_ZOOM = 4
local VIEW_WHEEL_FACTOR = 1.25
local function GetChild()
    if WorldMapFrame == nil or WorldMapFrame.ScrollContainer == nil then return nil end
    return WorldMapFrame.ScrollContainer.Child
end

local function GetContainer()
    if WorldMapFrame == nil then return nil end
    return WorldMapFrame.ScrollContainer
end

local function GetPlayerMapID()
    if MapUtil ~= nil and MapUtil.GetDisplayableMapForPlayer ~= nil then return MapUtil.GetDisplayableMapForPlayer() end
    if C_Map ~= nil and C_Map.GetBestMapForUnit ~= nil then return C_Map.GetBestMapForUnit("player") end
    return nil
end

local function IsWorldMap(mapID)
    if mapID == nil or C_Map == nil or C_Map.GetMapInfo == nil or Enum == nil or Enum.UIMapType == nil then return false end
    local info = C_Map.GetMapInfo(mapID)
    return info ~= nil and info.mapType ~= nil and info.mapType <= Enum.UIMapType.World
end

function D4:CreateInstanceLevelPanel(parent, options)
    options = options or {}
    local panel = CreateFrame("Frame", nil, parent)
    panel.acoKeepLight = true
    panel:EnableMouse(true)
    panel:EnableMouseWheel(true)
    panel.bg = panel:CreateTexture(nil, "BACKGROUND")
    panel.bg:SetAllPoints(panel)
    panel.bg:SetColorTexture(0.05, 0.05, 0.07, 0.84)
    panel.borders = {}
    for edge = 1, 4 do
        local tex = panel:CreateTexture(nil, "BORDER")
        tex:SetColorTexture(0.45, 0.4, 0.28, 0.85)
        panel.borders[edge] = tex
    end

    panel.borders[1]:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    panel.borders[1]:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    panel.borders[1]:SetHeight(1)
    panel.borders[2]:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    panel.borders[2]:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    panel.borders[2]:SetHeight(1)
    panel.borders[3]:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    panel.borders[3]:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
    panel.borders[3]:SetWidth(1)
    panel.borders[4]:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    panel.borders[4]:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)
    panel.borders[4]:SetWidth(1)
    panel.pad = 5
    panel.headerH = 20
    panel.btnH = 22
    panel.gap = 2
    panel.margin = 8
    local header = CreateFrame("Frame", nil, panel)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -1, -1)
    header:SetHeight(panel.headerH)
    header:EnableMouse(true)
    header.bg = header:CreateTexture(nil, "BACKGROUND")
    header.bg:SetAllPoints(header)
    header.bg:SetColorTexture(0.1, 0.1, 0.13, 0.92)
    header.divider = header:CreateTexture(nil, "BORDER")
    header.divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    header.divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    header.divider:SetHeight(1)
    header.divider:SetColorTexture(0.45, 0.4, 0.28, 0.65)
    header.dots = {}
    for col = 0, 1 do
        for row = -1, 1 do
            local dot = header:CreateTexture(nil, "ARTWORK")
            dot:SetSize(2, 2)
            dot:SetPoint("LEFT", header, "LEFT", 6 + col * 4, row * 4)
            dot:SetColorTexture(0.72, 0.66, 0.52, 0.9)
            tinsert(header.dots, dot)
        end
    end

    header.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.title:SetPoint("LEFT", header, "LEFT", 17, 0)
    header.title:SetPoint("RIGHT", header, "RIGHT", -22, 0)
    header.title:SetJustifyH("LEFT")
    header.title:SetWordWrap(false)
    header.title:SetTextColor(1, 0.82, 0)
    local toggle = CreateFrame("Button", nil, header)
    toggle:SetSize(16, 16)
    toggle:SetPoint("RIGHT", header, "RIGHT", -2, 0)
    toggle.bg = toggle:CreateTexture(nil, "BACKGROUND")
    toggle.bg:SetAllPoints(toggle)
    toggle.bg:SetColorTexture(1, 1, 1, 0)
    toggle.hBar = toggle:CreateTexture(nil, "ARTWORK")
    toggle.hBar:SetSize(8, 2)
    toggle.hBar:SetPoint("CENTER", toggle, "CENTER", 0, 0)
    toggle.hBar:SetColorTexture(0.72, 0.66, 0.52, 0.95)
    toggle.vBar = toggle:CreateTexture(nil, "ARTWORK")
    toggle.vBar:SetSize(2, 8)
    toggle.vBar:SetPoint("CENTER", toggle, "CENTER", 0, 0)
    toggle.vBar:SetColorTexture(0.72, 0.66, 0.52, 0.95)
    toggle.vBar:Hide()
    toggle:SetScript("OnEnter", function(sel)
        sel.bg:SetColorTexture(1, 1, 1, 0.14)
        sel.hBar:SetColorTexture(1, 0.88, 0.35, 1)
        sel.vBar:SetColorTexture(1, 0.88, 0.35, 1)
        panel:ShowCollapsedTooltip(sel)
    end)

    toggle:SetScript("OnLeave", function(sel)
        sel.bg:SetColorTexture(1, 1, 1, 0)
        sel.hBar:SetColorTexture(0.72, 0.66, 0.52, 0.95)
        sel.vBar:SetColorTexture(0.72, 0.66, 0.52, 0.95)
        if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end
    end)

    toggle:SetScript("OnClick", function() panel:ToggleCollapsed() end)
    header.toggle = toggle
    header:SetScript("OnEnter", function(sel)
        sel.bg:SetColorTexture(0.16, 0.15, 0.18, 0.95)
        for _, dot in ipairs(sel.dots) do
            dot:SetColorTexture(1, 0.88, 0.35, 1)
        end

        panel:ShowCollapsedTooltip(sel)
    end)

    header:SetScript("OnLeave", function(sel)
        sel.bg:SetColorTexture(0.1, 0.1, 0.13, 0.92)
        for _, dot in ipairs(sel.dots) do
            dot:SetColorTexture(0.72, 0.66, 0.52, 0.9)
        end

        if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end
    end)

    header:SetScript("OnMouseDown", function(_, button) panel:StartDrag(button) end)
    header:SetScript("OnMouseUp", function(_, button)
        local moved = panel.dragMoved
        panel:StopDrag()
        if button == "LeftButton" and not moved then panel:ToggleCollapsed() end
    end)

    panel.header = header
    local scroll = CreateFrame("ScrollFrame", nil, panel)
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", panel.pad, -(panel.headerH + panel.pad))
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -panel.pad, panel.pad)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    panel.scroll = scroll
    panel.content = content
    panel.measure = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.measure:Hide()
    panel.buttons = {}
    local function ClampScroll(value)
        local maxScroll = max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))

        return max(0, min(maxScroll, value or 0))
    end

    function panel:GetBounds()
        local viewW = parent:GetWidth() or 0
        local viewH = parent:GetHeight() or 0
        local boxW = self:GetWidth() or 0
        local boxH = self:GetHeight() or 0
        local m = self.margin
        local maxX = max(m, viewW - boxW - m)
        local maxY = max(m, viewH - boxH - m)

        return m, maxX, m, maxY
    end

    function panel:LoadPosition()
        if self.posRX ~= nil and self.posRY ~= nil then return end
        local saved = options.getPos and options.getPos() or nil
        if type(saved) == "table" and type(saved.rx) == "number" and type(saved.ry) == "number" then
            self.posRX = max(0, min(1, saved.rx))
            self.posRY = max(0, min(1, saved.ry))
        else
            self.posRX = 0
            self.posRY = 0.5
        end
    end

    function panel:SavePosition()
        if self.posRX == nil or self.posRY == nil or options.setPos == nil then return end
        options.setPos({
            rx = self.posRX,
            ry = self.posRY,
        })
    end

    function panel:ApplyPixelPosition(x, y, updateRatios)
        local minX, maxX, minY, maxY = self:GetBounds()
        local cx = max(minX, min(maxX, x))
        local cy = max(minY, min(maxY, y))
        self.posX = cx
        self.posY = cy
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", parent, "TOPLEFT", cx, -cy)
        if updateRatios then
            if maxX > minX then self.posRX = (cx - minX) / (maxX - minX) end
            if maxY > minY then self.posRY = (cy - minY) / (maxY - minY) end
        end
    end

    function panel:ApplyRatioPosition()
        self:LoadPosition()
        local minX, maxX, minY, maxY = self:GetBounds()
        local x = minX + self.posRX * (maxX - minX)
        local y = minY + self.posRY * (maxY - minY)
        self:ApplyPixelPosition(x, y, false)
    end

    function panel:OnDragUpdate()
        if not self.dragging or not IsMouseButtonDown("LeftButton") then
            self:StopDrag()

            return
        end

        local cx, cy = GetCursorPosition()
        local scale = parent:GetEffectiveScale()
        if scale == nil or scale <= 0 then scale = 1 end
        local dx = (cx - self.dragStartX) / scale
        local dy = (cy - self.dragStartY) / scale
        if not self.dragMoved and abs(dx) < 4 and abs(dy) < 4 then return end
        self.dragMoved = true
        self:ApplyPixelPosition(self.dragOriginX + dx, self.dragOriginY - dy, true)
    end

    function panel:StartDrag(button)
        if button ~= "LeftButton" then return end
        self:LoadPosition()
        if self.posX == nil or self.posY == nil then self:ApplyRatioPosition() end
        local cx, cy = GetCursorPosition()
        self.dragging = true
        self.dragMoved = false
        self.dragStartX = cx
        self.dragStartY = cy
        self.dragOriginX = self.posX or self.margin
        self.dragOriginY = self.posY or self.margin
        self:SetScript("OnUpdate", self.OnDragUpdate)
    end

    function panel:StopDrag()
        if not self.dragging then return end
        self.dragging = false
        self:SetScript("OnUpdate", nil)
        if self.dragMoved then self:SavePosition() end
    end

    panel:SetScript("OnMouseDown", function(sel, button) sel:StartDrag(button) end)
    panel:SetScript("OnMouseUp", function(sel) sel:StopDrag() end)
    panel:SetScript("OnHide", function(sel) sel:StopDrag() end)
    panel:SetScript("OnMouseWheel", function(_, delta)
        local step = panel.btnH + panel.gap
        scroll:SetVerticalScroll(ClampScroll(scroll:GetVerticalScroll() - delta * step))
    end)

    function panel:GetButton(index)
        local btn = self.buttons[index]
        if btn ~= nil then return btn end
        btn = CreateFrame("Button", nil, self.content)
        btn:SetHeight(self.btnH)
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints(btn)
        btn.accent = btn:CreateTexture(nil, "ARTWORK")
        btn.accent:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.accent:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        btn.accent:SetWidth(2)
        btn.accent:SetColorTexture(1, 0.82, 0, 1)
        btn.accent:Hide()
        btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.highlight:SetAllPoints(btn)
        btn.highlight:SetColorTexture(1, 1, 1, 0.14)
        btn.highlight:SetBlendMode("ADD")
        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.label:SetPoint("LEFT", btn, "LEFT", 8, 0)
        btn.label:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
        btn.label:SetJustifyH("LEFT")
        btn.label:SetWordWrap(false)
        btn:SetScript("OnClick", function(sel)
            if sel.levelIndex and options.onSelect then options.onSelect(sel.levelIndex) end
        end)

        btn:SetScript("OnEnter", function(sel)
            if sel.fullLabel and sel.label.IsTruncated and sel.label:IsTruncated() then
                GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
                GameTooltip:SetText(sel.fullLabel, 1, 0.82, 0)
                GameTooltip:Show()
            end
        end)

        btn:SetScript("OnLeave", function(sel) if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end end)
        self.buttons[index] = btn

        return btn
    end

    function panel:ShowCollapsedTooltip(owner)
        if not self.collapsed or not self.activeLabel or self.activeLabel == "" then return end
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.activeLabel, 1, 0.82, 0)
        GameTooltip:Show()
    end

    function panel:LoadCollapsed()
        if self.collapsed ~= nil then return end
        self.collapsed = options.getCollapsed and options.getCollapsed() == true or false
    end

    function panel:SaveCollapsed()
        if options.setCollapsed ~= nil then options.setCollapsed(self.collapsed == true) end
    end

    function panel:UpdateCollapsedVisuals()
        local collapsed = self.collapsed == true
        self.header.divider:SetShown(not collapsed)
        self.header.toggle.vBar:SetShown(collapsed)
        self.scroll:SetShown(not collapsed)
        self:EnableMouseWheel(not collapsed)
    end

    function panel:SetCollapsed(collapsed)
        self.collapsed = collapsed == true
        self:SaveCollapsed()
        self:UpdateCollapsedVisuals()
        if not self.collapsed and GameTooltip and (GameTooltip:IsOwned(self.header) or GameTooltip:IsOwned(self.header.toggle)) then GameTooltip:Hide() end
        self:Layout()
    end

    function panel:ToggleCollapsed()
        self:LoadCollapsed()
        self:SetCollapsed(not self.collapsed)
    end

    function panel:Layout()
        local count = self.count or 0
        if count <= 0 then return end
        self:LoadCollapsed()
        self:UpdateCollapsedVisuals()
        local viewW = parent:GetWidth() or 400
        local viewH = parent:GetHeight() or 300
        local maxInnerW = max(60, viewW - self.margin * 2 - self.pad * 2)
        if self.collapsed then
            local boxW = min(self.collapsedWidth or 96, maxInnerW + self.pad * 2)
            self:SetSize(boxW, self.headerH + 2)
            self:ApplyRatioPosition()
            if options.getFrameLevel ~= nil then self:SetFrameLevel(options.getFrameLevel()) end

            return
        end

        local step = self.btnH + self.gap
        local contentH = count * self.btnH + max(0, count - 1) * self.gap
        local maxScrollH = max(self.btnH, viewH - self.margin * 2 - self.pad * 2 - self.headerH)
        local visibleH = min(contentH, maxScrollH)
        local innerW = min(self.innerWidth or 140, maxInnerW)
        self:SetSize(innerW + self.pad * 2, visibleH + self.pad * 2 + self.headerH)
        self.content:SetSize(innerW, contentH)
        for i = 1, count do
            local btn = self.buttons[i]
            if btn then
                btn:SetWidth(innerW)
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -(i - 1) * step)
            end
        end

        local active = self.activeIndex or 1
        local activeTop = (active - 1) * step
        local activeBottom = activeTop + self.btnH
        local cur = self.scroll:GetVerticalScroll() or 0
        if activeTop < cur then
            cur = activeTop
        elseif activeBottom > cur + visibleH then
            cur = activeBottom - visibleH
        end

        self.scroll:SetVerticalScroll(ClampScroll(cur))
        self:ApplyRatioPosition()
        if options.getFrameLevel ~= nil then self:SetFrameLevel(options.getFrameLevel()) end
    end

    function panel:Refresh(levels, activeIndex)
        local count = levels and #levels or 0
        self.count = count
        self.activeIndex = activeIndex or 1
        self.activeLabel = nil
        local title = options.getTitle and options.getTitle() or "Floors"
        self.header.title:SetText(title)
        local maxW = 0
        for i = 1, count do
            local btn = self:GetButton(i)
            local text = options.getLabel and options.getLabel(levels, levels[i], i) or levels[i].name or tostring(i)
            btn.levelIndex = i
            btn.fullLabel = text
            btn.label:SetText(text)
            self.measure:SetText(text)
            local textW = self.measure:GetStringWidth() or 0
            if textW > maxW then maxW = textW end
            local active = i == self.activeIndex
            if active then
                self.activeLabel = text
                btn.bg:SetColorTexture(0.85, 0.68, 0.2, 0.28)
                btn.accent:Show()
                btn.label:SetTextColor(1, 0.88, 0.35)
            else
                btn.bg:SetColorTexture(0.14, 0.14, 0.17, 0.65)
                btn.accent:Hide()
                btn.label:SetTextColor(0.88, 0.88, 0.9)
            end

            btn:Show()
        end

        for i = count + 1, #self.buttons do
            self.buttons[i]:Hide()
        end

        self.measure:SetText(title)
        local titleW = self.measure:GetStringWidth() or 0
        local headerW = titleW + 34
        if headerW > maxW then maxW = headerW end
        self.collapsedWidth = max(84, min(200, ceil(titleW) + 46))
        self.innerWidth = max(110, min(200, ceil(maxW) + 20))
        self:Layout()
    end

    panel:Hide()

    return panel
end

function D4:CreateInstanceMap(provider)
    local map = {}
    local overlay = nil
    local levelButton = nil
    local hiddenFor = nil
    local leftPlayerMap = false
    local forced = nil
    local forcedMapID = nil
    local forcedIndex = 1
    local selected = {}
    local shownLevels = nil
    local shownIndex = nil
    local shownInstance = nil
    local lastKey = nil
    local mapPinSet = nil
    local mapPinKey = nil
    local cache = {}
    local view = {
        ["zoom"] = 1,
        ["x"] = 0,
        ["y"] = 0,
        ["baseWidth"] = 0,
        ["baseHeight"] = 0,
    }

    local Refresh = nil
    local function ApplyView()
        if overlay == nil then return end
        local width = view.baseWidth * view.zoom
        local height = view.baseHeight * view.zoom
        local maxX = max(0, (width - (overlay:GetWidth() or 0)) / 2)
        local maxY = max(0, (height - (overlay:GetHeight() or 0)) / 2)
        view.x = min(maxX, max(-maxX, view.x))
        view.y = min(maxY, max(-maxY, view.y))
        overlay.art:SetSize(width, height)
        overlay.art:ClearAllPoints()
        overlay.art:SetPoint("CENTER", overlay, "CENTER", view.x, view.y)
    end

    local function ResetView()
        view.zoom = 1
        view.x = 0
        view.y = 0
        view.drag = nil
    end

    local function GetCursorOffset()
        local scale = overlay:GetEffectiveScale()
        local centerX, centerY = overlay:GetCenter()
        if scale == nil or scale <= 0 or centerX == nil then return nil end
        local cursorX, cursorY = GetCursorPosition()
        return cursorX / scale - centerX, cursorY / scale - centerY
    end

    local function OnOverlayWheel(_, delta)
        local zoom = min(VIEW_MAX_ZOOM, max(1, view.zoom * VIEW_WHEEL_FACTOR ^ delta))
        if zoom == view.zoom then return end
        local dx, dy = GetCursorOffset()
        if dx ~= nil then
            local factor = zoom / view.zoom
            view.x = dx - (dx - view.x) * factor
            view.y = dy - (dy - view.y) * factor
        end

        view.zoom = zoom
        ApplyView()
    end

    local function OnOverlayMouseDown(_, button)
        if button ~= "LeftButton" or view.zoom <= 1 then return end
        local dx, dy = GetCursorOffset()
        if dx == nil then return end
        view.drag = {dx, dy, view.x, view.y}
    end

    local function OnOverlayUpdate()
        local drag = view.drag
        if drag == nil then return end
        if not IsMouseButtonDown("LeftButton") then
            view.drag = nil
            return
        end

        local dx, dy = GetCursorOffset()
        if dx == nil then return end
        view.x = drag[3] + dx - drag[1]
        view.y = drag[4] + dy - drag[2]
        ApplyView()
    end
    local function GetLevels(instanceMapID)
        if instanceMapID == nil then return nil end
        if cache[instanceMapID] == nil then cache[instanceMapID] = provider.getLevels(instanceMapID) or false end
        return cache[instanceMapID] or nil
    end

    local function GetInstanceArt()
        if provider.isDisabled ~= nil and provider.isDisabled() then return nil end
        local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
        return GetLevels(instanceMapID), instanceMapID
    end

    local function GetLabel(levels, level)
        return provider.getLabel(levels, level) or ""
    end

    local function ClearForced()
        forced = nil
        forcedMapID = nil
        forcedIndex = 1
    end

    local function SelectLevel(index)
        if forced ~= nil then
            forcedIndex = index
        elseif shownInstance ~= nil then
            selected[shownInstance] = index
        end

        Refresh()
    end

    local function ToggleOverlay()
        if overlay ~= nil and overlay:IsShown() and provider.getReturnMapID ~= nil then
            local info = shownLevels ~= nil and shownLevels[shownIndex] or nil
            local mapID = provider.getReturnMapID(info)
            if mapID ~= nil and WorldMapFrame.SetMapID ~= nil then
                hiddenFor = shownInstance or select(2, GetInstanceArt())
                ClearForced()
                overlay:Hide()
                levelButton:Hide()
                mapPinKey = nil
                if mapPinSet ~= nil then mapPinSet:Hide() end
                if not (InCombatLockdown ~= nil and InCombatLockdown()) and (WorldMapFrame.GetMapID == nil or WorldMapFrame:GetMapID() ~= mapID) then
                    WorldMapFrame:SetMapID(mapID)
                end
                Refresh()
                if provider.onReturn ~= nil then provider.onReturn(info) end
                return
            end
        end

        if forced ~= nil then
            ClearForced()
            Refresh()
            return
        end

        local levels, instanceMapID = GetInstanceArt()
        if levels == nil then return end
        if hiddenFor == instanceMapID then
            if provider.keepShown ~= nil and provider.keepShown() then return end
            hiddenFor = nil
        else
            hiddenFor = instanceMapID
        end

        Refresh()
    end

    local function OnCanvasMouseUp(_, button)
        if button == "LeftButton" then view.drag = nil end
        if button ~= "RightButton" then return end
        ToggleOverlay()
    end

    local function FindLevelIndex(levels, key)
        for index, level in ipairs(levels or {}) do
            if level.key == key then return index end
        end

        return nil
    end

    local function OnMapPinEnter(pin)
        local row = pin.row
        if row == nil then return end
        GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
        if row[1] == "boss" then
            GameTooltip:SetText(provider.getBossName and provider.getBossName(row) or row[5] or "")
            if row[6] then GameTooltip:AddLine(format("%s %d", LEVEL or "Level", row[6]), 1, 1, 1) end
            local hint = provider.getBossHint and provider.getBossHint(row)
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        elseif row[1] == "item" then
            if GameTooltip.SetItemByID ~= nil then
                GameTooltip:SetItemByID(row[4])
            else
                GameTooltip:SetHyperlink("item:" .. row[4])
            end
        elseif row[1] == "queststart" or row[1] == "questend" then
            GameTooltip:SetText(provider.getQuestName and provider.getQuestName(row) or row[5] or "")
            local text = provider.getQuestKindText and provider.getQuestKindText(row)
            if text then GameTooltip:AddLine(text, 1, 0.82, 0) end
        elseif row[1] == "level" then
            GameTooltip:SetText(GetLabel(shownLevels, shownLevels[pin.level]))
            local hint = provider.getLevelHint and provider.getLevelHint()
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        else
            GameTooltip:SetText(provider.getEntranceText and provider.getEntranceText(row) or "")
            local hint = provider.getEntranceHint and provider.getEntranceHint(row)
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        end

        GameTooltip:Show()
    end

    local function OnMapPinLeave(pin)
        if GameTooltip:IsOwned(pin) then GameTooltip:Hide() end
    end

    local function OnMapPinMouseUp(pin, button)
        if not pin:IsMouseOver() then return end
        if button == "RightButton" then
            ToggleOverlay()
            return
        end

        local row = pin.row
        if button ~= "LeftButton" or row == nil then return end
        if row[1] == "level" then
            OnMapPinLeave(pin)
            SelectLevel(pin.level)
        elseif row[1] == "boss" and provider.onBossClick ~= nil then
            local info = shownLevels ~= nil and shownLevels[shownIndex] or nil
            if info == nil then return end
            OnMapPinLeave(pin)
            provider.onBossClick(info, row)
        end
    end

    local function HideMapPins()
        if mapPinKey == nil then return end
        mapPinKey = nil
        if mapPinSet ~= nil then mapPinSet:Hide() end
    end

    local function UpdateMapPins(info)
        local scale = 1
        local rows = provider.getPins and provider.getPins(info) or nil
        if rows == nil then
            HideMapPins()
            return
        end

        local questKey = {}
        local killedKey = {}
        for _, row in ipairs(rows) do
            if row[1] == "queststart" or row[1] == "questend" then
                local visible = provider.isQuestPinVisible ~= nil and provider.isQuestPinVisible(row) or provider.isQuestPinVisible == nil and D4:IsInstanceQuestPinVisible(row)
                tinsert(questKey, visible and "1" or "0")
            elseif row[1] == "boss" and provider.isBossKilled ~= nil then
                tinsert(killedKey, provider.isBossKilled(row) and "1" or "0")
            end
        end

        local key = format("%s|%.4f|%.1f|%.1f|%d|%s|%s", info.key, scale, overlay.art:GetWidth(), overlay.art:GetHeight(), #rows, table.concat(questKey), table.concat(killedKey))
        if key == mapPinKey then return end
        mapPinKey = key
        if mapPinSet == nil then
            mapPinSet = D4:CreateInstancePins(overlay, {
                ["media"] = provider.media,
                ["onEnter"] = OnMapPinEnter,
                ["onLeave"] = OnMapPinLeave,
                ["onMouseUp"] = OnMapPinMouseUp,
                ["getLevel"] = function(row) return FindLevelIndex(shownLevels, row[4]) end,
                ["isEnabled"] = provider.isPinEnabled,
                ["isQuestVisible"] = provider.isQuestPinVisible,
                ["isBossKilled"] = provider.isBossKilled,
                ["setEnabled"] = function(kind, enabled)
                    if provider.setPinEnabled then provider.setPinEnabled(kind, enabled) end
                    mapPinKey = nil
                    Refresh()
                end,
                ["getToggleText"] = provider.getToggleText,
                ["getBossScale"] = provider.getBossScale,
            })

            local container = WorldMapFrame.ScrollContainer
            local toggles = mapPinSet:CreateToggles(container)
            toggles:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PIN_TOGGLE_OFFSET_X, PIN_TOGGLE_OFFSET_Y)
            toggles:SetFrameLevel(overlay:GetFrameLevel() + 1000)
            if provider.getBossScale ~= nil and provider.setBossScale ~= nil then
                local template = DoesTemplateExist ~= nil and (DoesTemplateExist("MinimalSliderTemplate") and "MinimalSliderTemplate" or DoesTemplateExist("UISliderTemplate") and "UISliderTemplate") or "OptionsSliderTemplate"
                local slider = CreateFrame("Slider", nil, toggles, template)
                slider:SetSize(BOSS_SCALE.width, 16)
                slider:SetPoint("RIGHT", toggles, "LEFT", -BOSS_SCALE.gap, 0)
                slider:SetMinMaxValues(BOSS_SCALE.min, BOSS_SCALE.max)
                slider:SetValueStep(BOSS_SCALE.step)
                if slider.SetObeyStepOnDrag ~= nil then slider:SetObeyStepOnDrag(true) end
                for _, region in ipairs({slider:GetRegions()}) do
                    if region.GetObjectType ~= nil and region:GetObjectType() == "FontString" then region:SetText("") end
                end

                slider.label = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                slider.label:SetPoint("BOTTOM", slider, "TOP", 0, 1)
                local function UpdateLabel(value)
                    local percent = floor(value * 100 + 0.5)
                    slider.label:SetText(provider.getBossScaleText ~= nil and provider.getBossScaleText(percent) or format("%d%%", percent))
                end

                slider:SetValue(provider.getBossScale() or 1)
                UpdateLabel(slider:GetValue())
                slider:SetScript("OnValueChanged", function(_, value)
                    value = floor(value / BOSS_SCALE.step + 0.5) * BOSS_SCALE.step
                    UpdateLabel(value)
                    if abs(value - (provider.getBossScale() or 1)) < 0.001 then return end
                    provider.setBossScale(value)
                    mapPinKey = nil
                    Refresh()
                end)

                toggles.bossScale = slider
            end
        end

        mapPinSet:Update(rows, overlay.art, scale)
        mapPinSet:UpdateToggles()
        mapPinSet.toggles:Show()
    end

    local function CreateOverlay()
        if overlay ~= nil then return overlay end
        local child = GetChild()
        local container = GetContainer()
        if child == nil or container == nil then return nil end
        overlay = CreateFrame("FRAME", nil, container)
        overlay:SetFrameLevel(child:GetFrameLevel() + OVERLAY_LEVEL)
        overlay:EnableMouse(true)
        overlay:EnableMouseWheel(true)
        overlay:SetScript("OnMouseUp", OnCanvasMouseUp)
        overlay:SetScript("OnMouseDown", OnOverlayMouseDown)
        overlay:SetScript("OnMouseWheel", OnOverlayWheel)
        overlay:SetScript("OnUpdate", OnOverlayUpdate)
        local toggle = WorldMapFrame.SidePanelToggle
        if toggle ~= nil then
            local originalStrata, raisedStrata
            overlay:HookScript("OnShow", function()
                local overlayStrata = overlay:GetFrameStrata()
                local toggleStrata = toggle:GetFrameStrata()
                local overlayIndex, toggleIndex
                for index, strata in ipairs(FRAME_STRATA) do
                    if strata == overlayStrata then overlayIndex = index end
                    if strata == toggleStrata then toggleIndex = index end
                end

                if overlayIndex ~= nil and toggleIndex ~= nil and toggleIndex <= overlayIndex then
                    raisedStrata = FRAME_STRATA[overlayIndex + 1]
                    if raisedStrata ~= nil then
                        originalStrata = toggleStrata
                        toggle:SetFrameStrata(raisedStrata)
                    end
                end
            end)
            overlay:HookScript("OnHide", function()
                if originalStrata ~= nil and toggle:GetFrameStrata() == raisedStrata then toggle:SetFrameStrata(originalStrata) end
                originalStrata, raisedStrata = nil, nil
            end)
        end
        overlay:SetAllPoints(container)
        if overlay.SetClipsChildren ~= nil then overlay:SetClipsChildren(true) end
        overlay.bg = overlay:CreateTexture(nil, "BACKGROUND")
        overlay.bg:SetAllPoints(overlay)
        overlay.bg:SetColorTexture(0, 0, 0, 1)
        overlay.art = overlay:CreateTexture(nil, "ARTWORK")
        overlay.art:SetPoint("CENTER", overlay, "CENTER", 0, 0)
        overlay.credit = overlay:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        overlay.credit:SetPoint("BOTTOM", overlay, "BOTTOM", 0, LEVEL_BUTTON_OFFSET)
        overlay.credit:Hide()
        overlay:Hide()
        levelButton = D4:CreateInstanceLevelPanel(overlay, {
            ["getTitle"] = provider.getLevelsTitle,
            ["getLabel"] = function(levels, level) return GetLabel(levels, level) end,
            ["onSelect"] = SelectLevel,
            ["getPos"] = provider.getLevelPanelPos,
            ["setPos"] = provider.setLevelPanelPos,
            ["getCollapsed"] = provider.getLevelPanelCollapsed,
            ["setCollapsed"] = provider.setLevelPanelCollapsed,
            ["getFrameLevel"] = function() return overlay:GetFrameLevel() + 1000 end,
        })

        overlay:HookScript("OnSizeChanged", function()
            if levelButton ~= nil and levelButton:IsShown() then levelButton:Layout() end
        end)

        levelButton:Hide()
        container:HookScript("OnMouseUp", OnCanvasMouseUp)
        WorldMapFrame:HookScript("OnShow", function()
            hiddenFor = nil
            leftPlayerMap = false
            view.file = nil
            lastKey = nil
            ClearForced()
        end)

        return overlay
    end

    local function Layout(info)
        local w = overlay:GetWidth()
        local h = overlay:GetHeight()
        if w == nil or h == nil or w <= 0 or h <= 0 then return end
        local ratio = (info.height or DEFAULT_ART_HEIGHT) / (info.width or DEFAULT_ART_WIDTH)
        local width = w
        local height = w * ratio
        if height > h then
            height = h
            width = h / ratio
        end

        local zoom = info.zoom or 1
        view.baseWidth = width * zoom
        view.baseHeight = height * zoom
        ApplyView()
    end

    local function GetVisibleLevels()
        if WorldMapFrame == nil or WorldMapFrame.GetMapID == nil then return nil end
        if forced ~= nil then
            if WorldMapFrame:GetMapID() == forcedMapID or provider.keepShown ~= nil and provider.keepShown() then return forced, forcedIndex, nil end
            ClearForced()
        end

        local levels, instanceMapID = GetInstanceArt()
        if levels == nil then return nil end
        if hiddenFor == instanceMapID then return nil end
        if provider.keepShown ~= nil and provider.keepShown() then return levels, selected[instanceMapID] or 1, instanceMapID end
        local playerMapID = GetPlayerMapID()
        if playerMapID ~= nil and WorldMapFrame:GetMapID() ~= playerMapID then
            leftPlayerMap = true
            return nil
        end

        if leftPlayerMap and IsWorldMap(playerMapID) then return nil end
        return levels, selected[instanceMapID] or 1, instanceMapID
    end

    Refresh = function()
        local levels, index, instanceMapID = GetVisibleLevels()
        if levels == nil then
            lastKey = nil
            shownLevels = nil
            shownIndex = nil
            shownInstance = nil
            view.file = nil
            HideMapPins()
            if overlay ~= nil then
                overlay:Hide()
                levelButton:Hide()
            end

            return
        end

        if CreateOverlay() == nil then return end
        if levels[index] == nil then index = 1 end
        local info = levels[index]
        shownLevels = levels
        shownIndex = index
        shownInstance = instanceMapID
        local key = format("%s|%.1f|%.1f", info.file, overlay:GetWidth() or 0, overlay:GetHeight() or 0)
        if key ~= lastKey then
            lastKey = key
            if view.file ~= info.file then
                view.file = info.file
                ResetView()
            end

            overlay.art:SetTexture(info.file)
            local width = info.width or DEFAULT_ART_WIDTH
            local height = info.height or DEFAULT_ART_HEIGHT
            overlay.art:SetTexCoord(0, width / (info.fileWidth or width), 0, height / (info.fileHeight or height))
            Layout(info)
            local credit = provider.getCredit and provider.getCredit(info)
            overlay.credit:SetText(credit or "")
            overlay.credit:SetShown(credit ~= nil)
            if #levels > 1 then levelButton:Refresh(levels, index) end
        end

        UpdateMapPins(info)
        if #levels > 1 then
            if not levelButton:IsShown() then
                levelButton:Refresh(levels, index)
                levelButton:Show()
            end
        elseif levelButton:IsShown() then
            levelButton:Hide()
        end

        if not overlay:IsShown() then overlay:Show() end
    end

    function map:Show(instances, level)
        if instances == nil then return false end
        if type(instances) ~= "table" then instances = {instances} end
        local levels = {}
        for _, instanceMapID in ipairs(instances) do
            for _, info in ipairs(GetLevels(instanceMapID) or {}) do
                tinsert(levels, info)
            end
        end

        if #levels == 0 then return false end
        if WorldMapFrame == nil or WorldMapFrame.GetMapID == nil then return false end
        if WorldMapFrame:IsShown() ~= true then return false end
        forced = levels
        forcedMapID = WorldMapFrame:GetMapID()
        forcedIndex = level or 1
        hiddenFor = nil
        lastKey = nil
        view.file = nil
        Refresh()
        return true
    end

    function map:IsShown()
        return overlay ~= nil and overlay:IsShown()
    end

    function map:HasArt()
        return forced ~= nil or GetInstanceArt() ~= nil
    end

    function map:Toggle()
        if not map:HasArt() then return false end
        if leftPlayerMap and forced == nil and not map:IsShown() then
            leftPlayerMap = false
            hiddenFor = nil
            Refresh()
            return true
        end

        ToggleOverlay()
        return true
    end

    function map:Invalidate()
        mapPinKey = nil
        lastKey = nil
        if overlay ~= nil and overlay:IsShown() then Refresh() end
    end

    if WorldMapFrame ~= nil then
        local updater = CreateFrame("FRAME", nil, WorldMapFrame)
        updater.elapsed = 0
        updater:SetScript("OnUpdate", function(sel, elapsed)
            sel.elapsed = sel.elapsed + elapsed
            if sel.elapsed < UPDATE_INTERVAL then return end
            sel.elapsed = 0
            Refresh()
        end)
    end

    return map
end
