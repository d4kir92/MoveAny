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
    if tab.sub and win.rootCategory then
        win.category = win.rootCategory
    else
        win.category = nil
    end

    local element = UI:Add(win, header, UI.ROW, text, true)
    element.isCategory = true
    element.collapsed = tab.collapsed == true
    if element.category == nil then win.rootCategory = element end
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
            UpdateIcon()
            win:Layout()
        end
    )

    UpdateIcon()
    header.element = element

    return header
end
