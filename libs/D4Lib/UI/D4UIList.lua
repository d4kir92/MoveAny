local _, D4 = ...
local UI = D4.UI
local ROW_HEIGHT = 20
local CELL_INSET = 3
local ARROW_GAP = 2
local SORT_ATLAS = "auctionhouse-ui-sortarrow"
local SORT_TEXTURE = "Interface\\Buttons\\UI-SortArrow"
UI.ListMixin = {}

local function HasAtlas(atlas)
    if C_Texture == nil or C_Texture.GetAtlasInfo == nil then return false end

    return C_Texture.GetAtlasInfo(atlas) ~= nil
end

local function SetArrowDirection(arrow, ascending)
    if arrow.isAtlas then
        if ascending then
            arrow:SetTexCoord(0, 1, 1, 0)
        else
            arrow:SetTexCoord(0, 1, 0, 1)
        end
    elseif ascending then
        arrow:SetTexCoord(0, 0.5625, 0, 1)
    else
        arrow:SetTexCoord(0, 0.5625, 1, 0)
    end
end

local function GetFontObject(font)
    if type(font) == "string" then return _G[font] end

    return font
end

local function GetHeaderText(list, column)
    local text = UI:Text(column.label)
    if column.icon == nil then return text end
    local size = list:Scaled(column.iconSize or 16)
    local icon = "|T" .. column.icon .. ":" .. size .. ":" .. size .. ":0:0|t"
    if text == "" then return icon end

    return icon .. " " .. text
end

local function GetGroupPath(column)
    if column.group == nil then return {} end
    if type(column.group) == "table" then return column.group end

    return {column.group}
end

local function IsSameGroup(a, b, level)
    for index = 1, level do
        if a[index] == nil or a[index] ~= b[index] then return false end
    end

    return true
end

local function GetCellText(column, data, span)
    if span and span > 1 and column.spanText then return column.spanText(data) or "" end
    if column.text then return column.text(data) or "" end
    local value = data[column.key]
    if value == nil then return "" end

    return tostring(value)
end

local function GetCellSpan(list, index, data)
    local column = list.columns[index]
    if column == nil or column.span == nil or data == nil then return 1 end
    local span = column.span(data)
    if type(span) ~= "number" or span < 1 then return 1 end
    span = math.floor(span)
    local count = #list.columns
    if index + span - 1 > count then span = count - index + 1 end

    return span
end

local function GetSortValue(column, data)
    local value = nil
    if column.value then
        value = column.value(data)
    elseif column.key ~= nil then
        value = data[column.key]
    end

    if value == nil then return nil end
    local kind = type(value)
    if kind == "number" then return value end
    if kind == "boolean" then
        if value then return 1 end

        return 0
    end

    return string.lower(tostring(value))
end

local function IsLess(a, b)
    local kind = type(a)
    if kind ~= type(b) then return kind == "number" end

    return a < b
end

local function CreateHeaderButton(list, index)
    local button = CreateFrame("Button", nil, list.headerRow)
    button.Label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.Label:SetWordWrap(false)
    button.Arrow = button:CreateTexture(nil, "OVERLAY")
    if HasAtlas(SORT_ATLAS) then
        button.Arrow:SetAtlas(SORT_ATLAS, true)
        button.Arrow.isAtlas = true
    else
        button.Arrow:SetTexture(SORT_TEXTURE)
        button.Arrow:SetSize(9, 8)
    end

    button.Arrow:SetPoint("RIGHT", button, "RIGHT", -CELL_INSET, 0)
    button.Arrow:Hide()
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(button)
    UI:SetSolidColor(highlight, 1, 1, 1, 0.08)
    button:SetScript("OnClick", function(sel) list:OnHeaderClick(sel.column) end)
    button:SetScript("OnEnter", function(sel) list:ShowHeaderTooltip(sel) end)
    button:SetScript(
        "OnLeave",
        function(sel)
            if GameTooltip:GetOwner() == sel then GameTooltip:Hide() end
        end
    )

    list.headerButtons[index] = button

    return button
end

local function CreateGroupLabel(list, index)
    local group = CreateFrame("Frame", nil, list.headerRow)
    group.Label = group:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    group.Label:SetPoint("LEFT", group, "LEFT", CELL_INSET, 0)
    group.Label:SetPoint("RIGHT", group, "RIGHT", -CELL_INSET, 0)
    group.Label:SetWordWrap(false)
    group.Line = group:CreateTexture(nil, "ARTWORK")
    group.Line:SetHeight(1)
    group.Line:SetPoint("BOTTOMLEFT", group, "BOTTOMLEFT", CELL_INSET, 1)
    group.Line:SetPoint("BOTTOMRIGHT", group, "BOTTOMRIGHT", -CELL_INSET, 1)
    UI:SetSolidColor(group.Line, 1, 1, 1, 0.25)
    list.groupLabels[index] = group

    return group
end

local function CreateRow(list, index)
    local row = CreateFrame("Button", nil, list)
    row.cells = {}
    row.Background = row:CreateTexture(nil, "BACKGROUND")
    row.Background:SetAllPoints(row)
    if index % 2 == 0 then
        UI:SetSolidColor(row.Background, 1, 1, 1, 0.04)
    else
        UI:SetSolidColor(row.Background, 0, 0, 0, 0)
    end

    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(row)
    UI:SetSolidColor(highlight, 1, 1, 1, 0.1)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript(
        "OnClick",
        function(sel, button)
            if list.onClick and sel.data then list.onClick(sel.data, button) end
        end
    )

    row:SetScript(
        "OnEnter",
        function(sel)
            sel.hoverColumn = nil
            sel:SetScript("OnUpdate", function(se) list:UpdateRowTooltip(se) end)
            list:UpdateRowTooltip(sel)
        end
    )

    row:SetScript(
        "OnLeave",
        function(sel)
            sel:SetScript("OnUpdate", nil)
            sel.hoverColumn = nil
            if GameTooltip:GetOwner() == sel then GameTooltip:Hide() end
        end
    )

    list.rowFrames[index] = row
    list:LayoutRow(row)

    return row
end

function UI.ListMixin:GetScale()
    if self.fontSize == nil then return 1 end
    local base = 10
    local fontObject = GetFontObject(self.font)
    if fontObject and fontObject.GetFont then
        local _, size = fontObject:GetFont()
        if size and size > 0 then base = size end
    end

    return self.fontSize / base
end

function UI.ListMixin:Scaled(value)
    return math.floor(value * self:GetScale() + 0.5)
end

function UI.ListMixin:ApplyFont(fontString, font)
    fontString:SetFontObject(font)
    if self.fontSize == nil then return end
    local path, _, flags = fontString:GetFont()
    if path then fontString:SetFont(path, self.fontSize, flags or "") end
end

function UI.ListMixin:UpdateMetrics()
    self.rowHeight = self:Scaled(self.baseRowHeight)
    self.headerHeight = self:Scaled(self.baseHeaderHeight)
end

function UI.ListMixin:SetFontSize(size)
    self.fontSize = size
    self:UpdateMetrics()
    self:LayoutColumns()
    self:Refresh()
end

function UI.ListMixin:GetFontSize()
    return self.fontSize
end

function UI.ListMixin:GetHeaderHeight()
    return self.headerHeight * (self.groupDepth + 1)
end

function UI.ListMixin:GetRowsTop()
    if self.sticky then return 0 end

    return self:GetHeaderHeight()
end

function UI.ListMixin:GetColumnsWidth()
    local width = 0
    for _, column in ipairs(self.columns) do
        width = width + self:Scaled(column.width)
    end

    return width
end

function UI.ListMixin:SetColumns(columns)
    self.columns = {}
    self.columnsByKey = {}
    self.groupDepth = 0
    self.hasSpans = false
    for _, source in ipairs(columns or {}) do
        local column = {}
        for key, value in pairs(source) do
            column[key] = value
        end

        column.width = column.width or 60
        column.align = column.align or "LEFT"
        column.groupPath = GetGroupPath(column)
        self.groupDepth = math.max(self.groupDepth, #column.groupPath)
        if column.span ~= nil then self.hasSpans = true end
        if column.key ~= nil then self.columnsByKey[column.key] = column end
        tinsert(self.columns, column)
    end

    if self.sortKey ~= nil and self.columnsByKey[self.sortKey] == nil then self.sortKey = nil end
    self:LayoutColumns()
    self:SortRows()
    self:Refresh()
end

function UI.ListMixin:LayoutColumns()
    local fixed = self:GetColumnsWidth()
    local flexCount = 0
    for _, column in ipairs(self.columns) do
        if column.flex then flexCount = flexCount + 1 end
    end

    local extra = 0
    local available = self:GetWidth() or 0
    if flexCount > 0 and available > fixed then extra = math.floor((available - fixed) / flexCount) end
    local x = 0
    for _, column in ipairs(self.columns) do
        column.x = x
        column.actualWidth = self:Scaled(column.width)
        if column.flex then column.actualWidth = column.actualWidth + extra end
        x = x + column.actualWidth
    end

    self.totalWidth = x
    self:LayoutHeader()
    for _, row in ipairs(self.rowFrames) do
        self:LayoutRow(row)
    end

    self:ApplyFont(self.Empty, "GameFontDisableSmall")
    self.Empty:ClearAllPoints()
    self.Empty:SetPoint("TOPLEFT", self, "TOPLEFT", CELL_INSET, -self:GetRowsTop())
    self.Empty:SetSize(math.max(1, self.totalWidth - CELL_INSET * 2), self.rowHeight)
end

function UI.ListMixin:LayoutHeader()
    local headerHeight = self:GetHeaderHeight()
    if self.sticky and self.win.headerHeight ~= headerHeight then self.win:AddHeader({["height"] = headerHeight}) end
    local groupHeight = headerHeight - self.headerHeight
    self.headerRow:SetSize(math.max(1, self.totalWidth), headerHeight)
    for index, column in ipairs(self.columns) do
        local button = self.headerButtons[index] or CreateHeaderButton(self, index)
        button.column = column
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", self.headerRow, "TOPLEFT", column.x, -groupHeight)
        button:SetSize(math.max(1, column.actualWidth), self.headerHeight)
        button.Label:SetJustifyH(column.align)
        button.Label:SetText(GetHeaderText(self, column))
        button:Show()
    end

    for index = #self.columns + 1, #self.headerButtons do
        self.headerButtons[index]:Hide()
    end

    local groupCount = 0
    for level = 1, self.groupDepth do
        local index = 1
        while index <= #self.columns do
            local column = self.columns[index]
            local path = column.groupPath
            local last = index
            if path[level] ~= nil then
                while self.columns[last + 1] and IsSameGroup(path, self.columns[last + 1].groupPath, level) do
                    last = last + 1
                end

                groupCount = groupCount + 1
                local group = self.groupLabels[groupCount] or CreateGroupLabel(self, groupCount)
                local lastColumn = self.columns[last]
                group:ClearAllPoints()
                group:SetPoint("TOPLEFT", self.headerRow, "TOPLEFT", column.x, -(level - 1) * self.headerHeight)
                group:SetSize(math.max(1, lastColumn.x + lastColumn.actualWidth - column.x), self.headerHeight)
                self:ApplyFont(group.Label, "GameFontNormalSmall")
                group.Label:SetText(UI:Text(path[level]))
                group:Show()
            end

            index = last + 1
        end
    end

    for groupIndex = groupCount + 1, #self.groupLabels do
        self.groupLabels[groupIndex]:Hide()
    end

    self:UpdateHeaderPosition()
    self:UpdateArrows()
end

function UI.ListMixin:UpdateHeaderPosition()
    self.headerRow:ClearAllPoints()
    if not self.sticky then
        self.headerRow:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

        return
    end

    local depth = 0
    if self.uiElement then depth = self.uiElement.depth end
    self.headerRow:SetPoint("LEFT", self.win.header, "LEFT", self.win:GetContentOffset() + UI.PADDING + depth * UI.INDENT, 0)
end

function UI.ListMixin:UpdateArrows()
    for index, column in ipairs(self.columns) do
        local button = self.headerButtons[index]
        if button then
            local right = CELL_INSET
            button.Label:ClearAllPoints()
            if column.key ~= nil and column.key == self.sortKey then
                right = CELL_INSET + button.Arrow:GetWidth() + ARROW_GAP
                SetArrowDirection(button.Arrow, self.ascending)
                button.Arrow:Show()
                self:ApplyFont(button.Label, "GameFontHighlightSmall")
            else
                button.Arrow:Hide()
                self:ApplyFont(button.Label, "GameFontNormalSmall")
            end

            button.Label:SetPoint("LEFT", button, "LEFT", CELL_INSET, 0)
            button.Label:SetPoint("RIGHT", button, "RIGHT", -right, 0)
        end
    end
end

function UI.ListMixin:PlaceRowCells(row)
    local count = #self.columns
    local index = 1
    while index <= count do
        local column = self.columns[index]
        local span = GetCellSpan(self, index, row.data)
        local last = self.columns[index + span - 1]
        local cell = row.cells[index]
        cell:ClearAllPoints()
        cell:SetPoint("LEFT", row, "LEFT", column.x + CELL_INSET, 0)
        cell:SetSize(math.max(1, last.x + last.actualWidth - column.x - CELL_INSET * 2), self.rowHeight)
        if span > 1 then
            cell:SetJustifyH(column.spanAlign or column.align)
        else
            cell:SetJustifyH(column.align)
        end

        cell:Show()
        for hidden = index + 1, index + span - 1 do
            row.cells[hidden]:Hide()
        end

        index = index + span
    end
end

function UI.ListMixin:LayoutRow(row)
    row:SetSize(math.max(1, self.totalWidth), self.rowHeight)
    for index in ipairs(self.columns) do
        local cell = row.cells[index]
        if cell == nil then
            cell = row:CreateFontString(nil, "OVERLAY", self.font)
            cell:SetWordWrap(false)
            row.cells[index] = cell
        end

        self:ApplyFont(cell, self.font)
    end

    for index = #self.columns + 1, #row.cells do
        row.cells[index]:Hide()
    end

    self:PlaceRowCells(row)
end

function UI.ListMixin:SortRows()
    local order = self.order
    local column = nil
    if self.sortKey ~= nil then column = self.columnsByKey[self.sortKey] end
    if column == nil or column.sortable == false then
        table.sort(self.rows, function(a, b) return order[a] < order[b] end)

        return
    end

    local ascending = self.ascending
    local values = {}
    for _, data in ipairs(self.rows) do
        values[data] = GetSortValue(column, data)
    end

    table.sort(
        self.rows,
        function(a, b)
            local va = values[a]
            local vb = values[b]
            if va == vb then return order[a] < order[b] end
            if va == nil then return false end
            if vb == nil then return true end
            if IsLess(va, vb) then return ascending end
            if IsLess(vb, va) then return not ascending end

            return order[a] < order[b]
        end
    )
end

function UI.ListMixin:SetRows(rows)
    self.rows = {}
    self.order = {}
    for index, data in ipairs(rows or {}) do
        self.rows[index] = data
        self.order[data] = index
    end

    self:SortRows()
    self:Refresh()
end

function UI.ListMixin:GetRows()
    return self.rows
end

function UI.ListMixin:SetSort(key, ascending)
    local column = nil
    if key ~= nil then column = self.columnsByKey[key] end
    if column == nil then key = nil end
    if ascending == nil then ascending = not (column and column.descending) end
    self.sortKey = key
    self.ascending = ascending == true
    self:UpdateArrows()
    self:SortRows()
    self:Refresh()
end

function UI.ListMixin:GetSort()
    return self.sortKey, self.ascending
end

function UI.ListMixin:OnHeaderClick(column)
    if column == nil or column.key == nil or column.sortable == false then return end
    local ascending = not column.descending
    if self.sortKey == column.key then ascending = not self.ascending end
    self:SetSort(column.key, ascending)
    if self.onSort then self.onSort(self.sortKey, self.ascending) end
end

function UI.ListMixin:ShowHeaderTooltip(button)
    local column = button.column
    if column == nil then return end
    local tooltip = column.headerTooltip
    if tooltip == nil and button.Label.IsTruncated and button.Label:IsTruncated() then tooltip = column.label end
    if tooltip == nil then return end
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
    if type(tooltip) == "function" then
        tooltip(GameTooltip)
    else
        GameTooltip:SetText(UI:Text(tooltip), 1, 1, 1)
    end

    if GameTooltip:NumLines() > 0 then
        GameTooltip:Show()
    else
        GameTooltip:Hide()
    end
end

function UI.ListMixin:GetColumnAt(frame)
    local left = frame:GetLeft()
    if left == nil then return nil end
    local x = GetCursorPosition() / frame:GetEffectiveScale() - left
    for _, column in ipairs(self.columns) do
        if x >= column.x and x < column.x + column.actualWidth then return column end
    end

    return nil
end

function UI.ListMixin:GetSpanColumn(row, column)
    if not self.hasSpans or column == nil or row.data == nil then return column end
    local count = #self.columns
    local index = 1
    while index <= count do
        local span = GetCellSpan(self, index, row.data)
        for offset = 0, span - 1 do
            if self.columns[index + offset] == column then return self.columns[index] end
        end

        index = index + span
    end

    return column
end

function UI.ListMixin:UpdateRowTooltip(row)
    local column = self:GetSpanColumn(row, self:GetColumnAt(row))
    if column == row.hoverColumn then return end
    row.hoverColumn = column
    if column == nil or column.tooltip == nil or row.data == nil then
        if GameTooltip:GetOwner() == row then GameTooltip:Hide() end

        return
    end

    GameTooltip:SetOwner(row, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMLEFT", row, "TOPLEFT", column.x, 0)
    column.tooltip(GameTooltip, row.data)
    if GameTooltip:NumLines() > 0 then
        GameTooltip:Show()
    else
        GameTooltip:Hide()
    end
end

function UI.ListMixin:Refresh()
    local top = self:GetRowsTop()
    for index, data in ipairs(self.rows) do
        local row = self.rowFrames[index] or CreateRow(self, index)
        row.data = data
        row.hoverColumn = nil
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(top + (index - 1) * self.rowHeight))
        if self.hasSpans then self:PlaceRowCells(row) end
        local columnIndex = 1
        local columnCount = #self.columns
        while columnIndex <= columnCount do
            local column = self.columns[columnIndex]
            local span = GetCellSpan(self, columnIndex, data)
            row.cells[columnIndex]:SetText(GetCellText(column, data, span))
            columnIndex = columnIndex + span
        end

        row:Show()
    end

    for index = #self.rows + 1, #self.rowFrames do
        self.rowFrames[index].data = nil
        self.rowFrames[index]:Hide()
    end

    if #self.rows == 0 and self.emptyText then
        self.Empty:SetText(UI:Text(self.emptyText))
        self.Empty:Show()
    else
        self.Empty:Hide()
    end

    local height = top + math.max(1, #self.rows) * self.rowHeight
    self:SetHeight(height)
    if self.uiElement == nil or self.uiElement.height == height then return end
    self.uiElement.height = height
    self.win:Layout()
end

function UI.WindowMixin:AddList(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "List")
    local list = CreateFrame("Frame", name, win.content)
    for key, value in pairs(UI.ListMixin) do
        list[key] = value
    end

    list.win = win
    list.baseRowHeight = tab.rowHeight or ROW_HEIGHT
    list.baseHeaderHeight = tab.headerHeight or ROW_HEIGHT
    list.font = tab.font or "GameFontHighlightSmall"
    list.fontSize = tab.fontSize
    list:UpdateMetrics()
    list.sticky = tab.stickyHeader ~= false
    list.onSort = tab.onSort
    list.onClick = tab.onClick
    list.emptyText = tab.emptyText
    list.columns = {}
    list.columnsByKey = {}
    list.rows = {}
    list.order = {}
    list.rowFrames = {}
    list.headerButtons = {}
    list.groupLabels = {}
    list.totalWidth = 0
    list.groupDepth = 0
    list:SetSize(math.max(1, win.contentWidth - 8), list.rowHeight)
    if list.sticky then
        local header = win.header or win:AddHeader({["height"] = list.headerHeight})
        list.headerRow = CreateFrame("Frame", name .. "Header", header)
        list:HookScript("OnShow", function(sel) sel.headerRow:Show() end)
        list:HookScript("OnHide", function(sel) sel.headerRow:Hide() end)
    else
        list.headerRow = CreateFrame("Frame", name .. "Header", list)
    end

    list.Empty = list:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    list.Empty:SetJustifyH("LEFT")
    list.Empty:Hide()
    list:SetColumns(tab.columns)
    list:SetRows(tab.rows)
    list:SetSort(tab.sortKey, tab.ascending)
    list.uiElement = UI:Add(win, list, list:GetHeight(), tab.label, true, tab.search)
    list:UpdateHeaderPosition()
    list.lastWidth = list:GetWidth()
    list:SetScript(
        "OnSizeChanged",
        function(sel, width)
            if sel.lastWidth == width then return end
            sel.lastWidth = width
            sel:LayoutColumns()
        end
    )

    list:LayoutColumns()

    return list
end
