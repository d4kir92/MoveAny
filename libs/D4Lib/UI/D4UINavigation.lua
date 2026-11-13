local _, D4 = ...
local UI = D4.UI
local NAV_WIDTH = 150
local NAV_ROW = 20
local NAV_KEY = "D4UI_NAVIGATION"
local ICON_OPEN = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
local ICON_CLOSED = "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up"

function UI.WindowMixin:GetNavWidth()
    if self.nav == nil or self.navCollapsed then return 0 end
    return NAV_WIDTH
end

function UI.WindowMixin:UpdateContentWidth()
    self.contentWidth = self:GetWidth() - self.contentTrim - self:GetNavWidth()
end

local function IsNavEntry(win, element)
    if not element.isCategory then return false end
    if element.hidden or not element.match then return false end
    local parent = element.category
    while parent do
        if parent.hidden then return false end
        if parent.navCollapsed and not win.searching then return false end
        parent = parent.category
    end

    return true
end

local function IsNavCollapsed(win, element)
    if element.navCollapsed == nil then
        element.navCollapsed = false
        if win.getCollapsed then element.navCollapsed = win.getCollapsed("NAV_" .. tostring(element.key)) == true end
    end

    return element.navCollapsed
end

local function CreateNavButton(win, index)
    local nav = win.nav
    local btn = CreateFrame("Button", nil, nav)
    btn:SetHeight(NAV_ROW)
    btn.Selected = btn:CreateTexture(nil, "BACKGROUND")
    btn.Selected:SetAllPoints(btn)
    UI:SetSolidColor(btn.Selected, 1, 0.82, 0, 0.2)
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    UI:SetSolidColor(highlight, 1, 1, 1, 0.1)
    btn.Label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.Label:SetJustifyH("LEFT")
    btn.Label:SetWordWrap(false)
    btn.NewDot = btn:CreateTexture(nil, "OVERLAY")
    btn.NewDot:SetSize(7, 7)
    btn.NewDot:SetPoint("RIGHT", btn, "RIGHT", -3, 0)
    if C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("collections-icon-favorites") then
        btn.NewDot:SetAtlas("collections-icon-favorites")
    else
        btn.NewDot:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
    end

    btn.NewDot:SetDesaturated(true)
    btn.NewDot:SetVertexColor(0.4, 0.8, 1, 1)
    btn:SetScript("OnClick", function(sel) win:SelectNavElement(sel.element) end)
    btn.Toggle = CreateFrame("Button", nil, btn)
    btn.Toggle:SetSize(12, 12)
    btn.Toggle:SetPoint("LEFT", btn, "LEFT", 3, 0)
    btn.Toggle:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
    btn.Toggle:SetScript("OnClick", function()
        local element = btn.element
        if element == nil then return end
        element.navCollapsed = not IsNavCollapsed(win, element)
        if win.setCollapsed then win.setCollapsed("NAV_" .. tostring(element.key), element.navCollapsed) end
        win:ScrollNav(0)
    end)

    nav.buttons[index] = btn

    return btn
end

function UI.WindowMixin:GetScrollOffset()
    if self.scrollBox and self.scrollBox.GetDerivedScrollRange and self.scrollBox.GetScrollPercentage then return self.scrollBox:GetDerivedScrollRange() * (self.scrollBox:GetScrollPercentage() or 0) end
    if self.scroll then return self.scroll:GetVerticalScroll() end
    return 0
end

function UI.WindowMixin:ScrollToOffset(offset)
    offset = math.max(0, offset)
    if self.scrollBox and self.scrollBox.GetDerivedScrollRange and self.scrollBox.SetScrollPercentage then
        local range = self.scrollBox:GetDerivedScrollRange()
        if range > 0 then self.scrollBox:SetScrollPercentage(math.min(1, offset / range)) end
    elseif self.scroll then
        self.scroll:SetVerticalScroll(math.min(offset, self.scroll:GetVerticalScrollRange()))
    end
end

function UI.WindowMixin:SelectNavElement(element)
    if element == nil then return end
    local parent = element
    while parent do
        if parent.collapsed then
            parent.collapsed = false
            if self.setCollapsed then self.setCollapsed(parent.key, false) end
            if parent.frame.UpdateIcon then parent.frame.UpdateIcon() end
        end

        parent = parent.category
    end

    self:Layout()
    self:ScrollToOffset((element.offsetY or 0) - UI.PADDING)
    self.navSelected = element
    self:UpdateNavSelection(true)
end

function UI.WindowMixin:UpdateNavSelection(keep)
    local nav = self.nav
    if nav == nil then return end
    local selected = keep and self.navSelected or nil
    if selected == nil then
        local offset = self:GetScrollOffset() + UI.PADDING + 2
        for i = 1, nav.count or 0 do
            local element = nav.buttons[i].element
            if element.offsetY and element.offsetY <= offset then selected = element end
        end

        if selected == nil and nav.buttons[1] and (nav.count or 0) > 0 then selected = nav.buttons[1].element end
    end

    self.navSelected = selected
    for i = 1, nav.count or 0 do
        local btn = nav.buttons[i]
        btn.Selected:SetShown(btn.element == selected)
    end
end

function UI.WindowMixin:ScrollNav(delta)
    local nav = self.nav
    if nav == nil then return end
    local maxOffset = math.max(0, (nav.count or 0) * NAV_ROW - nav:GetHeight())
    nav.offset = math.max(0, math.min(maxOffset, (nav.offset or 0) + delta))
    self:RefreshNav()
end

function UI.WindowMixin:RefreshNav()
    local nav = self.nav
    if nav == nil then return end
    local index = 0
    local hasNew = {}
    local hasChildren = {}
    for _, element in ipairs(self.elements) do
        if element.isCategory and not element.hidden and element.category then hasChildren[element.category] = true end
        if not element.hidden and element.added and UI:IsNew(element.added) then
            local parent = element.isCategory and element or element.category
            while parent do
                hasNew[parent] = true
                parent = parent.category
            end
        end
    end

    for _, element in ipairs(self.elements) do
        if element.isCategory then IsNavCollapsed(self, element) end
        if IsNavEntry(self, element) then
            index = index + 1
            local btn = nav.buttons[index] or CreateNavButton(self, index)
            btn.element = element
            if element.level == 1 then
                btn.Label:SetFontObject("GameFontNormal")
            else
                btn.Label:SetFontObject("GameFontHighlightSmall")
            end

            btn.Label:ClearAllPoints()
            local indent = (element.level - 1) * 8
            btn.Label:SetPoint("LEFT", btn, "LEFT", 18 + indent, 0)
            local canToggle = hasChildren[element] == true
            btn.Toggle:ClearAllPoints()
            btn.Toggle:SetPoint("LEFT", btn, "LEFT", 3 + indent, 0)
            btn.Toggle:SetShown(canToggle)
            if canToggle then
                local icon = element.navCollapsed and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up"
                btn.Toggle:SetNormalTexture(icon)
            end
            btn.Label:SetPoint("RIGHT", btn, "RIGHT", -14, 0)
            btn.NewDot:SetShown(hasNew[element] == true)
            btn.Label:SetText(element.frame.Label and element.frame.Label:GetText() or "")
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", nav, "TOPLEFT", 0, -(index - 1) * NAV_ROW + (nav.offset or 0))
            btn:SetPoint("RIGHT", nav, "RIGHT", -3, 0)
            btn:Show()
        end
    end

    for i = index + 1, #nav.buttons do
        nav.buttons[i]:Hide()
    end

    nav.count = index
    self:UpdateNavSelection()
end

function UI.WindowMixin:UpdateNavToggle()
    if self.navToggle == nil then return end
    local icon = self.navCollapsed and ICON_CLOSED or ICON_OPEN
    self.navToggle:SetNormalTexture(icon)
    self.navToggle:SetPushedTexture(string.gsub(icon, "%-Up$", "-Down"))
end

function UI.WindowMixin:SetNavCollapsed(collapsed)
    self.navCollapsed = collapsed == true
    if self.setCollapsed then self.setCollapsed(NAV_KEY, self.navCollapsed) end
    self:UpdateNavToggle()
    self:UpdateBodyLayout()
    self:UpdateContentWidth()
    self:Layout()
end

function UI.WindowMixin:EnableNavigation()
    if self.nav then return self.nav end
    local win = self
    local name = D4:GetName(win, true)
    local nav = CreateFrame("Frame", name .. "Nav", win)
    if nav.SetClipsChildren then nav:SetClipsChildren(true) end
    nav.Line = nav:CreateTexture(nil, "ARTWORK")
    nav.Line:SetPoint("TOPRIGHT", nav, "TOPRIGHT", 0, 0)
    nav.Line:SetPoint("BOTTOMRIGHT", nav, "BOTTOMRIGHT", 0, 0)
    nav.Line:SetWidth(1)
    UI:SetSolidColor(nav.Line, 1, 0.82, 0, 0.35)
    nav.buttons = {}
    nav.offset = 0
    nav.count = 0
    nav:EnableMouseWheel(true)
    nav:SetScript("OnMouseWheel", function(_, delta) win:ScrollNav(-delta * NAV_ROW * 2) end)
    nav:SetScript("OnSizeChanged", function() win:ScrollNav(0) end)
    win.nav = nav
    if win.getCollapsed then win.navCollapsed = win.getCollapsed(NAV_KEY) == true end
    local header = win.header or win:AddHeader({["height"] = 32})
    local toggle = CreateFrame("Button", name .. "NavToggle", header)
    toggle:SetSize(26, 26)
    toggle:SetPoint("LEFT", header, "LEFT", 2, 1)
    toggle:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    toggle:SetScript("OnClick", function() win:SetNavCollapsed(not win.navCollapsed) end)
    win.navToggle = toggle
    if win.scrollBox and win.scrollBox.RegisterCallback and BaseScrollBoxEvents and BaseScrollBoxEvents.OnScroll then
        win.scrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, function() win:UpdateNavSelection() end, nav)
    elseif win.scroll then
        win.scroll:HookScript("OnVerticalScroll", function() win:UpdateNavSelection() end)
    end

    win:UpdateNavToggle()
    win:UpdateBodyLayout()
    win:UpdateContentWidth()
    win:Layout()

    return nav
end
