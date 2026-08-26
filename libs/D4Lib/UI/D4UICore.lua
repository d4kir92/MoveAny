local _, D4 = ...
D4.UI = D4.UI or {}
local UI = D4.UI
UI.PADDING = 4
UI.SPACING = 5
UI.ROW = 24
UI.INDENT = 16
UI.WindowMixin = {}

function UI:Text(key, ...)
    if key == nil then return "" end
    return D4:TryTrans(key, nil, ...)
end

function UI:NextName(win, kind)
    win.count = win.count + 1

    return D4:GetName(win, true) .. kind .. win.count
end

function UI:SetSolidColor(texture, r, g, b, a)
    if texture == nil then return end
    if texture.SetColorTexture then
        texture:SetColorTexture(r, g, b, a)
    else
        texture:SetTexture(r, g, b, a)
    end
end

function UI:ApplyWindow(win)
    for key, value in pairs(UI.WindowMixin) do
        win[key] = value
    end
end

function UI:Add(win, frame, height, label, stretch, search)
    local element = {
        ["frame"] = frame,
        ["height"] = height or UI.ROW,
        ["label"] = string.lower(label or ""),
        ["keywords"] = string.lower(search or ""),
        ["filter"] = win.search ~= nil,
        ["stretch"] = stretch == true,
        ["category"] = win.category,
        ["depth"] = 0,
        ["isCategory"] = false,
        ["collapsed"] = false,
        ["match"] = true,
        ["selfMatch"] = true,
    }

    if win.category then element.depth = win.category.depth + 1 end

    tinsert(win.elements, element)
    frame.uiElement = element
    win:Layout()

    return element
end

function UI:SetLabel(element, text)
    if element == nil then return end
    element.label = string.lower(text or "")
end

function UI:ChoicesFromMap(map, current)
    local values = {}
    local seen = {}
    for value in pairs(map or {}) do
        tinsert(values, value)
        seen[value] = true
    end

    if current ~= nil and not seen[current] then tinsert(values, current) end
    table.sort(
        values,
        function(a, b)
            if type(a) == type(b) then return a < b end

            return tostring(a) < tostring(b)
        end
    )

    local choices = {}
    for _, value in ipairs(values) do
        tinsert(
            choices,
            {
                ["value"] = value,
                ["label"] = (map and map[value]) or tostring(value)
            }
        )
    end

    return choices
end

function UI:CloseDropdowns()
    if UI.openList then
        UI.openList:Hide()
        UI.openList = nil
    end
end

function UI:HasAncestor(element, category)
    local parent = element.category
    while parent do
        if parent == category then return true end
        parent = parent.category
    end

    return false
end

function UI.WindowMixin:IsElementVisible(element)
    if not element.match then return false end
    if self.searching then return true end
    local parent = element.category
    while parent do
        if parent.collapsed then return false end
        parent = parent.category
    end

    return true
end

function UI.WindowMixin:SuspendLayout()
    self.layoutSuspended = true
end

function UI.WindowMixin:ResumeLayout()
    self.layoutSuspended = false
    self:Layout()
end

function UI.WindowMixin:Layout()
    if self.layoutSuspended then return end
    local y = -UI.PADDING
    for _, element in ipairs(self.elements) do
        if self:IsElementVisible(element) then
            local x = UI.PADDING + element.depth * UI.INDENT
            if element.stretch then element.frame:SetWidth(math.max(1, self.contentWidth - x - UI.PADDING)) end
            element.frame:ClearAllPoints()
            element.frame:SetPoint("TOPLEFT", self.content, "TOPLEFT", x, y)
            element.frame:Show()
            y = y - element.height - UI.SPACING
        else
            element.frame:Hide()
        end
    end

    if self.scroll then self.content:SetWidth(self.contentWidth) end
    self.content:SetHeight(math.max(1, -y + UI.PADDING))
    self:UpdateScroll()
end

function UI.WindowMixin:UpdateScroll()
    if self.scrollBox == nil then return end
    if self.scrollBox.FullUpdate == nil then return end
    if ScrollBoxConstants == nil then return end
    self.scrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
end

function UI.WindowMixin:Filter(text)
    text = string.lower(strtrim(text or ""))
    self.searching = text ~= ""
    for _, element in ipairs(self.elements) do
        if element.filter and self.searching then
            element.selfMatch = string.find(element.label, text, 1, true) ~= nil
            if not element.selfMatch and element.keywords ~= "" then element.selfMatch = string.find(element.keywords, text, 1, true) ~= nil end
        else
            element.selfMatch = true
        end

        element.match = element.selfMatch
    end

    if self.searching then
        for _, category in ipairs(self.elements) do
            if category.isCategory and category.selfMatch then
                for _, child in ipairs(self.elements) do
                    if UI:HasAncestor(child, category) then child.match = true end
                end
            end
        end

        for _, category in ipairs(self.elements) do
            if category.isCategory and not category.match then
                for _, child in ipairs(self.elements) do
                    if child.match and UI:HasAncestor(child, category) then
                        category.match = true
                        break
                    end
                end
            end
        end
    end

    self:Layout()
end
