local _, D4 = ...
D4.UI = D4.UI or {}
local UI = D4.UI
UI.PADDING = 4
UI.SPACING = 5
UI.ROW = 24
UI.INDENT = 16
UI.WindowMixin = {}
local NEW_DAYS = 7
local NEW_SECONDS = NEW_DAYS * 24 * 60 * 60

function UI:Text(key, ...)
    if key == nil then return "" end
    return D4:TryTrans(key, nil, ...)
end

local function DateToDays(year, month, day)
    if month <= 2 then
        year = year - 1
        month = month + 12
    end

    return 365 * year + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400) + math.floor((153 * (month - 3) + 2) / 5) + day
end

local function DaysInMonth(year, month)
    if month == 2 then
        if year % 400 == 0 or year % 4 == 0 and year % 100 ~= 0 then return 29 end
        return 28
    end

    if month == 4 or month == 6 or month == 9 or month == 11 then return 30 end
    return 31
end

local function CurrentDate()
    local dateAndTime = _G["C_DateAndTime"]
    if type(dateAndTime) == "table" and type(dateAndTime.GetCurrentCalendarTime) == "function" then
        local ok, current = pcall(dateAndTime.GetCurrentCalendarTime)
        if ok and type(current) == "table" and current.year and current.month and current.monthDay then return current.year, current.month, current.monthDay end
    end

    local getDate = _G["date"]
    if type(getDate) ~= "function" then return nil end
    local ok, current = pcall(getDate, "*t")
    if not ok or type(current) ~= "table" then return nil end
    return current.year, current.month, current.day
end

function UI:IsNew(added)
    if type(added) == "number" then
        local getTime = _G["time"]
        if type(getTime) ~= "function" then return false end
        local ok, now = pcall(getTime)
        if not ok or type(now) ~= "number" then return false end
        local age = now - added
        return age >= 0 and age <= NEW_SECONDS
    end

    if type(added) ~= "string" then return false end
    local year, month, day = string.match(added, "^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    if not year or not month or not day or month < 1 or month > 12 or day < 1 or day > DaysInMonth(year, month) then return false end
    local currentYear, currentMonth, currentDay = CurrentDate()
    if not currentYear or not currentMonth or not currentDay then return false end
    local age = DateToDays(currentYear, currentMonth, currentDay) - DateToDays(year, month, day)
    return age >= -1 and age <= NEW_DAYS
end

function UI:AddNewBadge(frame, added)
    if not UI:IsNew(added) then return nil end
    if frame == nil or frame.Label == nil or type(frame.CreateFontString) ~= "function" or type(frame.Label.GetPoint) ~= "function" then return nil end
    local point, relativeTo, relativePoint, xOffset, yOffset = frame.Label:GetPoint(1)
    if point == nil then return nil end
    local badge = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.Label:ClearAllPoints()
    badge:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    frame.Label:SetPoint("LEFT", badge, "RIGHT", 4, 0)
    badge:SetWordWrap(false)
    badge:SetText("|cff66ccff[" .. tostring(_G["NEW_CAPS"] or UI:Text("LID_NEW")) .. "]|r")
    frame.NewBadge = badge
    return badge
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

function UI:Add(win, frame, height, label, stretch, search, added)
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
        ["added"] = added,
    }

    if win.category then element.depth = win.category.depth + 1 end

    tinsert(win.elements, element)
    frame.uiElement = element
    UI:AddNewBadge(frame, added)
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
    if not element.match or element.hidden then return false end
    local parent = element.category
    while parent do
        if parent.hidden then return false end
        if parent.collapsed and not self.searching then return false end
        parent = parent.category
    end

    return true
end

function UI.WindowMixin:SetElementShown(frame, shown)
    local element = frame and (frame.uiElement or frame.element)
    if element == nil then return end
    local hidden = not shown
    if (element.hidden == true) == hidden then return end
    element.hidden = hidden
    self:Layout()
end

function UI.WindowMixin:AddRequirement(frame, requiredFrame)
    local element = frame and (frame.uiElement or frame.element)
    local required = requiredFrame and (requiredFrame.uiElement or requiredFrame.element)
    if element == nil or required == nil or element == required then return end
    element.requires = element.requires or {}
    tinsert(element.requires, required)
end

function UI:MatchRequirements(element)
    if element.requires == nil then return end
    for _, required in ipairs(element.requires) do
        if not required.match then
            required.match = true
            UI:MatchRequirements(required)
        end
    end
end

function UI.WindowMixin:SetCategoryOrder(keys)
    local elements = {}
    local blocks = {}
    local blocksByKey = {}
    local block = nil
    for _, element in ipairs(self.elements) do
        if element.isCategory and element.level == 1 then
            block = {element}
            tinsert(blocks, block)
            if blocksByKey[element.key] == nil then blocksByKey[element.key] = block end
        elseif block then
            tinsert(block, element)
        else
            tinsert(elements, element)
        end
    end

    local used = {}
    local ordered = {}
    for _, key in ipairs(keys or {}) do
        local found = blocksByKey[key]
        if found and not used[found] then
            used[found] = true
            tinsert(ordered, found)
        end
    end

    for _, remaining in ipairs(blocks) do
        if not used[remaining] then tinsert(ordered, remaining) end
    end

    for _, entry in ipairs(ordered) do
        for _, element in ipairs(entry) do
            tinsert(elements, element)
        end
    end

    self.elements = elements
    self:Layout()
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

        for _, element in ipairs(self.elements) do
            if element.match and not element.hidden then UI:MatchRequirements(element) end
        end

        for _, category in ipairs(self.elements) do
            if category.isCategory and not category.match then
                for _, child in ipairs(self.elements) do
                    if child.match and not child.hidden and UI:HasAncestor(child, category) then
                        category.match = true
                        break
                    end
                end
            end
        end
    end

    self:Layout()
end
