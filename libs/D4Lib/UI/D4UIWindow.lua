local _, D4 = ...
local UI = D4.UI
local windows = 0
local TOP_INSET = 32
local BOTTOM_INSET = 4
local LEFT_INSET = 4
local MODERN_LEFT_INSET = 9
local MODERN_TEMPLATE = "ButtonFrameTemplate"
local CONTENT_TRIM = 56
local SCROLL_LEFT = 8
local RIGHT_INSET = 18
local GRIP_INSET = 32
local HEADER_LIFT = 5
local HEADER_GROW = 5
local FOOTER_TRIM = 3

local function KeepWindowOnScreen(win)
    if win.screenBoundsUpdating then return end
    local scale = win:GetEffectiveScale()
    if scale <= 0 then return end
    local parentScale = UIParent:GetEffectiveScale()
    local screenWidth = UIParent:GetWidth() * parentScale / scale
    local screenHeight = UIParent:GetHeight() * parentScale / scale
    if screenWidth <= 0 or screenHeight <= 0 then return end
    win.screenBoundsUpdating = true
    local tab = win.screenBoundsOptions
    if tab and tab.resizable ~= false and tab.resizable ~= "width" then
        local maxWidth = tab.maxWidth or 0
        local maxHeight = tab.maxHeight or 0
        maxWidth = maxWidth > 0 and math.min(maxWidth, screenWidth) or screenWidth
        maxHeight = maxHeight > 0 and math.min(maxHeight, screenHeight) or screenHeight
        local minWidth = math.min(tab.minWidth or 300, maxWidth)
        local minHeight = math.min(tab.minHeight or 200, maxHeight)
        if win.SetResizeBounds then
            win:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
        else
            if win.SetMinResize then win:SetMinResize(minWidth, minHeight) end
            if win.SetMaxResize then win:SetMaxResize(maxWidth, maxHeight) end
        end
    end

    local width = math.min(win:GetWidth(), screenWidth)
    local height = math.min(win:GetHeight(), screenHeight)
    if width ~= win:GetWidth() or height ~= win:GetHeight() then win:SetSize(width, height) end
    local left, top = win:GetLeft(), win:GetTop()
    if left and top then
        local x = math.max(0, math.min(left, screenWidth - width))
        local y = math.max(height, math.min(top, screenHeight))
        if x ~= left or y ~= top then
            win:ClearAllPoints()
            win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
        end
    end

    win.screenBoundsWidth = screenWidth
    win.screenBoundsHeight = screenHeight
    win.screenBoundsScale = scale
    win.screenBoundsUpdating = false
end

local function SetupScreenBounds(win, tab)
    win.screenBoundsOptions = tab
    D4:SetClampedToScreen(win, true)
    win:SetClampRectInsets(0, 0, 0, 0)
    win:HookScript("OnShow", KeepWindowOnScreen)
    win:HookScript("OnSizeChanged", KeepWindowOnScreen)
    win:HookScript("OnUpdate", function(sel)
        local scale = sel:GetEffectiveScale()
        if scale <= 0 then return end
        local parentScale = UIParent:GetEffectiveScale()
        local width = UIParent:GetWidth() * parentScale / scale
        local height = UIParent:GetHeight() * parentScale / scale
        if width ~= sel.screenBoundsWidth or height ~= sel.screenBoundsHeight or scale ~= sel.screenBoundsScale then KeepWindowOnScreen(sel) end
    end)
    KeepWindowOnScreen(win)
end

local function FindInset(win)
    if win.InsetBg then return win.InsetBg end
    if win.Inset then return win.Inset end
    local nam = D4:GetName(win, true)
    if nam ~= "" and _G[nam .. "Inset"] then return _G[nam .. "Inset"] end
    local found = nil
    D4:ForeachRegions(
        win,
        function(region)
            if found then return end
            local regionName = D4:GetName(region)
            if regionName and string.find(regionName, "Inset") then found = region end
        end,
        "[D4UI] FindInset"
    )

    if found then return found end
    D4:ForeachChildren(
        win,
        function(child)
            if found then return end
            local childName = D4:GetName(child)
            if childName and string.find(childName, "Inset") then found = child end
        end,
        "[D4UI] FindInset"
    )

    return found
end

local function CaptureInset(win)
    if win.insetFrame == nil then win.insetFrame = FindInset(win) end
    if win.insetFrame == nil then return end
    if win.insetAnchors then return end
    local anchors = {}
    for i = 1, win.insetFrame:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = win.insetFrame:GetPoint(i)
        tinsert(anchors, {point, relativeTo, relativePoint, x, y})
    end

    if #anchors == 0 then
        anchors = {
            {"TOPLEFT", win, "TOPLEFT", 4, -25},
            {"BOTTOMRIGHT", win, "BOTTOMRIGHT", -6, 4}
        }
    end

    win.insetAnchors = anchors
end

function UI.WindowMixin:UpdateInset(topExtra, bottomExtra)
    CaptureInset(self)
    if self.insetAnchors == nil then return end
    self.insetFrame:ClearAllPoints()
    for _, anchor in ipairs(self.insetAnchors) do
        local point, relativeTo, relativePoint, x, y = anchor[1], anchor[2], anchor[3], anchor[4], anchor[5]
        if string.find(point, "TOP") then y = y - topExtra end
        if string.find(point, "BOTTOM") then y = y + bottomExtra end
        self.insetFrame:SetPoint(point, relativeTo, relativePoint, x, y)
    end
end

function UI.WindowMixin:UpdateBodyLayout()
    local topExtra = 0
    local bottomExtra = 0
    local headerTop = TOP_INSET - HEADER_LIFT - HEADER_GROW / 2
    if self.headerHeight > 0 then topExtra = headerTop + self.headerHeight + HEADER_GROW + UI.SPACING - TOP_INSET end
    if self.footerHeight > 0 then bottomExtra = self.footerHeight + UI.SPACING - FOOTER_TRIM end
    if self.header then
        self.header:ClearAllPoints()
        self.header:SetPoint("TOPLEFT", self, "TOPLEFT", self.leftInset, -headerTop)
        self.header:SetPoint("TOPRIGHT", self, "TOPRIGHT", -RIGHT_INSET, -headerTop)
        self.header:SetHeight(self.headerHeight + HEADER_GROW)
    end

    if self.footer then
        self.footer:ClearAllPoints()
        self.footer:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.leftInset, BOTTOM_INSET)
        self.footer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -GRIP_INSET, BOTTOM_INSET)
        self.footer:SetHeight(self.footerHeight)
    end

    self:UpdateInset(topExtra, bottomExtra)
    if self.scrollFrame == nil then return end
    if self.scrollInset == nil then return end
    self.scrollFrame:ClearAllPoints()
    self.scrollFrame:SetPoint("TOPLEFT", self, "TOPLEFT", self.scrollInset.left, -(TOP_INSET + topExtra))
    self.scrollFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", self.scrollInset.right, self.scrollInset.bottom + bottomExtra)
    if self.scrollBar == nil or self.grip == nil then return end
    local gripLift = math.max(0, GRIP_INSET - self.scrollInset.bottom - bottomExtra)
    self.scrollBar:ClearAllPoints()
    self.scrollBar:SetPoint("TOPLEFT", self.scrollFrame, "TOPRIGHT", 6, 0)
    self.scrollBar:SetPoint("BOTTOMLEFT", self.scrollFrame, "BOTTOMRIGHT", 6, gripLift)
end

function UI.WindowMixin:GetContentOffset()
    local left = 0
    if self.scrollInset then left = self.scrollInset.left end

    return left - self.leftInset
end

function UI.WindowMixin:AddHeader(tab)
    tab = tab or {}
    if self.header == nil then self.header = CreateFrame("Frame", D4:GetName(self, true) .. "Header", self) end
    self.headerHeight = tab.height or UI.ROW
    self:UpdateBodyLayout()

    return self.header
end

function UI.WindowMixin:AddFooter(tab)
    tab = tab or {}
    if self.footer == nil then self.footer = CreateFrame("Frame", D4:GetName(self, true) .. "Footer", self) end
    self.footerHeight = tab.height or UI.ROW
    self:UpdateBodyLayout()

    return self.footer
end

local function HasModernScroll()
    if ScrollUtil == nil then return false end
    if ScrollUtil.InitScrollBoxWithScrollBar == nil then return false end
    if CreateScrollBoxLinearView == nil then return false end

    return D4:CheckTemplates("WowScrollBox, MinimalScrollBar")
end

local function CreateModernScroll(win, name)
    local scrollBox = CreateFrame("Frame", name .. "ScrollBox", win, "WowScrollBox")
    win.scrollFrame = scrollBox
    win.scrollInset = {
        ["left"] = win.leftInset + SCROLL_LEFT,
        ["right"] = -28,
        ["bottom"] = 7
    }

    win:UpdateBodyLayout()
    local scrollBar = CreateFrame("EventFrame", name .. "ScrollBar", win, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)
    local content = CreateFrame("Frame", name .. "Content", scrollBox)
    content.scrollable = true
    content:SetSize(win.contentWidth, 1)
    local view = CreateScrollBoxLinearView()
    view:SetPanExtent(50)
    ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)
    win.scrollBox = scrollBox
    win.scrollBar = scrollBar

    return content
end

local function CreateGrip(win, name)
    local grip = CreateFrame("Button", name .. "Resize", win)
    grip:SetSize(24, 24)
    grip:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -4, 4)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    win:SetScript(
        "OnSizeChanged",
        function(sel, width)
            sel.contentWidth = width - sel.contentTrim
            sel:Layout()
        end
    )

    win.grip = grip
    win:UpdateBodyLayout()

    return grip
end

local function MakeWidthResizable(win, name, tab)
    local grip = CreateGrip(win, name)
    local minWidth = tab.minWidth or 300
    local maxWidth = tab.maxWidth or 0
    local function StopSizing()
        if grip:GetScript("OnUpdate") == nil then return end
        grip:SetScript("OnUpdate", nil)
        if tab.onResize then tab.onResize(math.floor(win:GetWidth() + 0.5), math.floor(win:GetHeight() + 0.5)) end
    end

    grip:SetScript(
        "OnMouseDown",
        function()
            local scale = win:GetEffectiveScale()
            local startX = GetCursorPosition() / scale
            local startWidth = win:GetWidth()
            grip:SetScript(
                "OnUpdate",
                function()
                    local width = math.max(minWidth, startWidth + GetCursorPosition() / scale - startX)
                    if maxWidth > 0 then width = math.min(maxWidth, width) end
                    win:SetWidth(width)
                end
            )
        end
    )

    grip:SetScript("OnMouseUp", StopSizing)
    grip:SetScript("OnHide", StopSizing)
end

local function MakeResizable(win, name, tab)
    if tab.resizable == "width" then
        MakeWidthResizable(win, name, tab)

        return
    end

    win:SetResizable(true)
    local minWidth = tab.minWidth or 300
    local minHeight = tab.minHeight or 200
    local maxWidth = tab.maxWidth or 0
    local maxHeight = tab.maxHeight or 0
    if win.SetResizeBounds then
        win:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    elseif win.SetMinResize then
        win:SetMinResize(minWidth, minHeight)
        if maxWidth > 0 and maxHeight > 0 and win.SetMaxResize then win:SetMaxResize(maxWidth, maxHeight) end
    end

    local grip = CreateGrip(win, name)
    grip:SetScript(
        "OnMouseDown",
        function()
            local left = win:GetLeft()
            local top = win:GetTop()
            if left and top then
                win:ClearAllPoints()
                win:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
            end

            win:StartSizing("BOTTOMRIGHT")
        end
    )

    grip:SetScript(
        "OnMouseUp",
        function()
            win:StopMovingOrSizing()
            if tab.onResize then tab.onResize(math.floor(win:GetWidth() + 0.5), math.floor(win:GetHeight() + 0.5)) end
            if tab.onMove then
                local p1, _, p3, p4, p5 = win:GetPoint()
                tab.onMove(p1, p3, p4, p5)
            end
        end
    )
end

local function CreateLegacyScroll(win, name)
    local scroll = nil
    if D4:CheckTemplates("UIPanelScrollFrameTemplate") then
        scroll = CreateFrame("ScrollFrame", name .. "Scroll", win, "UIPanelScrollFrameTemplate")
    else
        scroll = CreateFrame("ScrollFrame", name .. "Scroll", win)
    end

    win.scrollFrame = scroll
    win.scrollInset = {
        ["left"] = win.leftInset + SCROLL_LEFT,
        ["right"] = -32,
        ["bottom"] = 22
    }

    win:UpdateBodyLayout()
    local content = CreateFrame("Frame", name .. "Content", scroll)
    content:SetSize(win.contentWidth, 1)
    scroll:SetScrollChild(content)
    win.scroll = scroll

    return content
end

function D4:CreateUIWindowScroll(win, name)
    win.contentWidth = win:GetWidth() - (win.contentTrim or 56)
    if HasModernScroll() then return CreateModernScroll(win, name) end
    return CreateLegacyScroll(win, name)
end

local function UseModernTemplate(tab)
    if tab.modern == false or tab.templates then return false end
    if D4:GetWoWBuild() ~= "RETAIL" then return false end
    if ButtonFrameTemplate_HidePortrait == nil or ButtonFrameTemplate_HideAttic == nil or ButtonFrameTemplate_HideButtonBar == nil then return false end

    return D4:CheckTemplates(MODERN_TEMPLATE)
end

local function ApplyModernTemplate(win)
    ButtonFrameTemplate_HideAttic(win)
    ButtonFrameTemplate_HideButtonBar(win)
    ButtonFrameTemplate_HidePortrait(win)
    if win.TitleText == nil and win.TitleContainer then win.TitleText = win.TitleContainer.TitleText end
    win.leftInset = MODERN_LEFT_INSET
end

function D4:CreateUIWindowFrame(name, parent, templates)
    local modern = UseModernTemplate({templates = templates})
    if modern then templates = MODERN_TEMPLATE end
    local win = D4:CreateFrame(name, parent or UIParent, templates)
    if modern then ApplyModernTemplate(win) end
    SetupScreenBounds(win)
    return win
end

local function ApplyWindowTitle(win, tab)
    local title = UI:Text(tab.title) or ""
    local name, version = title:match("^(.-)%s+(v%d[%w%.%-%_+]*)%s*$")
    if name then
        title = name:match("^(.-)%s+by%s+") or name
    end

    if win.TitleText then win.TitleText:Hide() end
    local bar = CreateFrame("Frame", nil, win)
    bar:SetPoint("TOPLEFT", win, "TOPLEFT", 0, 0)
    bar:SetPoint("TOPRIGHT", win, "TOPRIGHT", 0, 0)
    bar:SetHeight(28)
    bar:SetFrameLevel(win:GetFrameLevel() + 510)
    bar:EnableMouse(false)
    win.titleBar = bar
    bar.Title = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.Title:SetPoint("CENTER", bar, "TOP", 0, -12)
    bar.Title:SetJustifyH("CENTER")
    bar.Title:SetText(title)
    bar.Version = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bar.Version:SetTextColor(0.6, 0.6, 0.6)
    bar.Version:SetJustifyH("RIGHT")
    bar.Version:SetText(version or "")
    if win.CloseButton then
        bar.Version:SetPoint("RIGHT", win.CloseButton, "LEFT", -4, 0)
    else
        bar.Version:SetPoint("RIGHT", bar, "RIGHT", -8, 0)
    end

    local function UpdateTitleWidth()
        local reserve = bar.Version:GetStringWidth() + 12
        if win.CloseButton then reserve = reserve + win.CloseButton:GetWidth() end
        bar.Title:SetWidth(math.max(1, win:GetWidth() - reserve * 2))
    end

    win:HookScript("OnSizeChanged", UpdateTitleWidth)
    UpdateTitleWidth()
end

function D4:CreateUIWindow(tab)
    tab = tab or {}
    windows = windows + 1
    local name = tab.name or ("D4UIWindow" .. windows)
    local width = tab.width or 420
    local height = tab.height or 520
    local modern = UseModernTemplate(tab)
    local templates = tab.templates
    if modern then templates = MODERN_TEMPLATE end
    local win = D4:CreateFrame(name, tab.parent or UIParent, templates)
    win.leftInset = LEFT_INSET
    if modern then ApplyModernTemplate(win) end
    win.contentTrim = CONTENT_TRIM + win.leftInset - LEFT_INSET
    win:SetSize(width, height)
    win:SetPoint(unpack(tab.pTab or {"CENTER"}))
    win:SetFrameStrata("HIGH")
    win:SetToplevel(true)
    win:HookScript("OnShow", function(sel) sel:Raise() end)
    win:EnableMouse(true)
    if tab.movable ~= false then
        win:SetMovable(true)
        win:RegisterForDrag("LeftButton")
        win:SetScript("OnDragStart", win.StartMoving)
        win:SetScript(
            "OnDragStop",
            function(sel)
                sel:StopMovingOrSizing()
                if tab.onMove == nil then return end
                local p1, _, p3, p4, p5 = sel:GetPoint()
                tab.onMove(p1, p3, p4, p5)
            end
        )
    end

    D4:SetClampedToScreen(win, true)
    ApplyWindowTitle(win, tab)
    if tab.onClose and win.CloseButton then win.CloseButton:SetScript("OnClick", function() tab.onClose(win) end) end
    UI:ApplyWindow(win)
    win.headerHeight = 0
    win.footerHeight = 0
    win.contentWidth = width - win.contentTrim
    if HasModernScroll() then
        win.content = CreateModernScroll(win, name)
    else
        win.content = CreateLegacyScroll(win, name)
    end

    win.elements = {}
    win.count = 0
    win.search = nil
    win.category = nil
    win.categoryStack = {}
    win.searching = false
    win.layoutSuspended = false
    win.getCollapsed = tab.getCollapsed
    win.setCollapsed = tab.setCollapsed
    if tab.resizable ~= false then MakeResizable(win, name, tab) end
    SetupScreenBounds(win, tab)
    win:HookScript("OnHide", function() UI:CloseDropdowns() end)
    local escClose = tab.escClose
    if escClose == nil then escClose = tab.onClose == nil end
    if escClose and UISpecialFrames and not tContains(UISpecialFrames, name) then tinsert(UISpecialFrames, name) end
    win:Hide()

    return win
end

function UI.WindowMixin:Toggle()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end
