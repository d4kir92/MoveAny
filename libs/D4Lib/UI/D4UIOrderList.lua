local _, D4 = ...
local UI = D4.UI
local ARROW_SIZE = 18
local ARROW_GAP = 2
local ARROW_TEXTURES = {
    ["Up"] = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-",
    ["Down"] = "Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-",
}

UI.OrderListMixin = {}

local function SetEnabled(frame, enabled)
    if enabled then
        frame:Enable()
    else
        frame:Disable()
    end
end

local function CreateArrow(parent, direction, onClick)
    local prefix = ARROW_TEXTURES[direction]
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(ARROW_SIZE, ARROW_SIZE)
    button:SetNormalTexture(prefix .. "Up")
    button:SetPushedTexture(prefix .. "Down")
    button:SetDisabledTexture(prefix .. "Disabled")
    button:SetHighlightTexture(prefix .. "Highlight", "ADD")
    local textures = {button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(), button:GetHighlightTexture()}
    for index = 1, 4 do
        if textures[index] then textures[index]:SetTexCoord(0.2, 0.8, 0.25, 0.75) end
    end

    button:SetScript("OnClick", onClick)

    return button
end

local function CreateRow(list, index)
    local name = list:GetName() .. "Row" .. index
    local row = CreateFrame("Frame", name, list)
    row:SetHeight(UI.ROW)
    row.Check = D4:CreateCheckButton(name .. "Check", row)
    row.Check:SetSize(UI.ROW, UI.ROW)
    row.Check:SetHitRectInsets(0, 0, 0, 0)
    row.Check:SetScript("OnClick", function(sel) list:OnCheck(row.entry, sel:GetChecked() == true) end)
    row.Label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.Label:SetJustifyH("LEFT")
    row.Label:SetWordWrap(false)
    row.Down = CreateArrow(row, "Down", function() list:Move(row.entry, 1) end)
    row.Down:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.Up = CreateArrow(row, "Up", function() list:Move(row.entry, -1) end)
    row.Up:SetPoint("RIGHT", row.Down, "LEFT", -ARROW_GAP, 0)
    list.rowFrames[index] = row

    return row
end

local function Flatten(nodes, depth, enabled, entries)
    for index, node in ipairs(nodes) do
        tinsert(
            entries,
            {
                ["node"] = node,
                ["depth"] = depth,
                ["siblings"] = nodes,
                ["index"] = index,
                ["enabled"] = enabled
            }
        )

        if node.children then Flatten(node.children, depth + 1, enabled and node.checked ~= false, entries) end
    end

    return entries
end

local function CollectLabels(nodes, labels)
    for _, node in ipairs(nodes) do
        tinsert(labels, UI:Text(node.label))
        if node.children then CollectLabels(node.children, labels) end
    end

    return labels
end

function UI.OrderListMixin:Refresh()
    local entries = Flatten(self.items, 0, true, {})
    for index, entry in ipairs(entries) do
        local row = self.rowFrames[index] or CreateRow(self, index)
        local node = entry.node
        local x = entry.depth * UI.INDENT
        row.entry = entry
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(index - 1) * UI.ROW)
        row:SetPoint("RIGHT", self, "RIGHT", 0, 0)
        row.Check:ClearAllPoints()
        row.Check:SetPoint("LEFT", row, "LEFT", x, 0)
        row.Check:SetChecked(node.checked ~= false)
        row.Check:SetShown(node.checkable ~= false)
        SetEnabled(row.Check, entry.enabled)
        row.Label:ClearAllPoints()
        row.Label:SetPoint("LEFT", row, "LEFT", x + UI.ROW + 4, 0)
        row.Label:SetPoint("RIGHT", row.Up, "LEFT", -4, 0)
        row.Label:SetText(UI:Text(node.label))
        if entry.enabled then
            row.Label:SetFontObject("GameFontNormal")
        else
            row.Label:SetFontObject("GameFontDisable")
        end

        local movable = node.movable ~= false and #entry.siblings > 1
        row.Up:SetShown(movable)
        row.Down:SetShown(movable)
        SetEnabled(row.Up, entry.enabled and entry.index > 1)
        SetEnabled(row.Down, entry.enabled and entry.index < #entry.siblings)
        row:Show()
    end

    for index = #entries + 1, #self.rowFrames do
        self.rowFrames[index].entry = nil
        self.rowFrames[index]:Hide()
    end

    local height = math.max(1, #entries) * UI.ROW
    self:SetHeight(height)
    if self.uiElement == nil or self.uiElement.height == height then return end
    self.uiElement.height = height
    self.win:Layout()
end

function UI.OrderListMixin:SetItems(items)
    self.items = items or {}
    self:Refresh()
    if self.uiElement then self.uiElement.keywords = string.lower((self.search or "") .. " " .. table.concat(CollectLabels(self.items, {}), " ")) end
end

function UI.OrderListMixin:GetItems()
    return self.items
end

function UI.OrderListMixin:Move(entry, delta)
    if entry == nil then return end
    local siblings = entry.siblings
    local target = entry.index + delta
    if siblings[target] == nil then return end
    siblings[entry.index], siblings[target] = siblings[target], siblings[entry.index]
    self:Refresh()
    if self.func then self.func(self.items, entry.node) end
end

function UI.OrderListMixin:OnCheck(entry, checked)
    if entry == nil then return end
    entry.node.checked = checked
    self:Refresh()
    if self.func then self.func(self.items, entry.node) end
end

function UI.WindowMixin:AddOrderList(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "OrderList")
    local list = CreateFrame("Frame", name, win.content)
    for key, value in pairs(UI.OrderListMixin) do
        list[key] = value
    end

    list.win = win
    list.func = tab.func
    list.search = tab.search
    list.items = tab.items or {}
    list.rowFrames = {}
    list:SetSize(math.max(1, win.contentWidth - 8), UI.ROW)
    list:Refresh()
    list.uiElement = UI:Add(win, list, list:GetHeight(), UI:Text(tab.label), true, tab.search)
    list:SetItems(list.items)

    return list
end
