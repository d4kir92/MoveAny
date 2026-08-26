local _, D4 = ...
local UI = D4.UI
local COLLAPSED = "Interface\\Buttons\\UI-PlusButton-Up"
local EXPANDED = "Interface\\Buttons\\UI-MinusButton-Up"

function UI.WindowMixin:AddCategory(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Category")
    local text = UI:Text(tab.label)
    local header = CreateFrame("Button", name, win.content)
    header:SetSize(win.contentWidth - 8, UI.ROW)
    header.Icon = header:CreateTexture(nil, "OVERLAY")
    header.Icon:SetSize(16, 16)
    header.Icon:SetPoint("LEFT", header, "LEFT", 0, 0)
    header.Label = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header.Label:SetPoint("LEFT", header.Icon, "RIGHT", 4, 0)
    header.Label:SetJustifyH("LEFT")
    header.Label:SetText(text)
    local highlight = header:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(header)
    UI:SetSolidColor(highlight, 1, 1, 1, 0.1)
    local level = tab.level
    if level == nil then
        level = 1
        if tab.sub then level = 2 end
    end

    if level < 1 then level = 1 end
    win.categoryStack = win.categoryStack or {}
    win.category = nil
    local parentLevel = level - 1
    while parentLevel >= 1 and win.categoryStack[parentLevel] == nil do
        parentLevel = parentLevel - 1
    end

    if parentLevel >= 1 then win.category = win.categoryStack[parentLevel] end
    local element = UI:Add(win, header, UI.ROW, text, true, tab.search)
    element.isCategory = true
    element.level = level
    element.key = tab.key or tab.search or text
    element.collapsed = tab.collapsed == true
    if win.getCollapsed then
        local stored = win.getCollapsed(element.key)
        if stored ~= nil then element.collapsed = stored == true end
    end

    win.categoryStack[level] = element
    local deeper = level + 1
    while win.categoryStack[deeper] do
        win.categoryStack[deeper] = nil
        deeper = deeper + 1
    end

    win.category = element
    local function UpdateIcon()
        if element.collapsed then
            header.Icon:SetTexture(COLLAPSED)
        else
            header.Icon:SetTexture(EXPANDED)
        end
    end

    header:SetScript(
        "OnClick",
        function()
            element.collapsed = not element.collapsed
            if win.setCollapsed then win.setCollapsed(element.key, element.collapsed) end
            UpdateIcon()
            win:Layout()
        end
    )

    UpdateIcon()
    header.element = element

    return header
end
