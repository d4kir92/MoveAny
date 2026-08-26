local _, D4 = ...
local UI = D4.UI
local WIDTH = 200
local ITEM = 20

function UI.WindowMixin:AddDropdown(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Dropdown")
    local text = UI:Text(tab.label)
    local choices = tab.choices or {}
    local width = tab.width or WIDTH
    local holder = CreateFrame("Frame", name, win.content)
    holder:SetSize(win.contentWidth - 8, UI.ROW)
    local button = D4:CreateButton(name .. "Button", holder)
    button:SetSize(width, UI.ROW)
    button:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.Label:SetPoint("LEFT", button, "RIGHT", 8, 0)
    holder.Label:SetText(text)
    local list = CreateFrame("Frame", name .. "List", UIParent)
    list:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    list:SetSize(width, math.max(1, #choices * ITEM + 4))
    list:SetFrameStrata("DIALOG")
    list:EnableMouse(true)
    list:Hide()
    local bg = list:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(list)
    UI:SetSolidColor(bg, 0.05, 0.05, 0.05, 0.95)
    local function Apply(newValue)
        for _, choice in ipairs(choices) do
            if choice.value == newValue then
                holder.value = newValue
                button:SetText(UI:Text(choice.label))

                return true
            end
        end

        return false
    end

    local function Choose(newValue)
        UI:CloseDropdowns()
        if Apply(newValue) and tab.func then tab.func(newValue) end
    end

    for index, choice in ipairs(choices) do
        local item = CreateFrame("Button", name .. "Item" .. index, list)
        item:SetSize(width - 4, ITEM)
        item:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2 - (index - 1) * ITEM)
        item.Label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        item.Label:SetPoint("LEFT", item, "LEFT", 4, 0)
        item.Label:SetJustifyH("LEFT")
        item.Label:SetText(UI:Text(choice.label))
        local highlight = item:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(item)
        UI:SetSolidColor(highlight, 1, 1, 1, 0.15)
        item:SetScript("OnClick", function() Choose(choice.value) end)
    end

    button:SetScript(
        "OnClick",
        function()
            local wasShown = list:IsShown()
            UI:CloseDropdowns()
            if not wasShown then
                list:Show()
                UI.openList = list
            end
        end
    )

    holder:SetScript("OnHide", function() UI:CloseDropdowns() end)
    function holder:SetValue(newValue)
        Apply(newValue)
    end

    if not Apply(tab.value) and choices[1] then Apply(choices[1].value) end
    UI:Add(win, holder, UI.ROW, text, true)

    return holder
end
