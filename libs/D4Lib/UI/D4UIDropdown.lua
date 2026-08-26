local _, D4 = ...
local UI = D4.UI
local WIDTH = 200
local ITEM = 20
local MAXVISIBLE = 12
local BARWIDTH = 20
local STEPPERPAD = 70
local STEPPERHEIGHT = 32

local function IndexOf(choices, value)
    for index, choice in ipairs(choices) do
        if choice.value == value then return index end
    end

    return nil
end

local function FindSteppers(control)
    local dec = control.DecrementButton
    local inc = control.IncrementButton
    if dec and inc then return dec, inc end
    local found = {}
    for _, child in ipairs({control:GetChildren()}) do
        if child ~= control.Dropdown and child.SetEnabled and child.GetObjectType and child:GetObjectType() == "Button" then tinsert(found, child) end
    end

    table.sort(found, function(a, b) return (a:GetLeft() or 0) < (b:GetLeft() or 0) end)

    return dec or found[1], inc or found[2]
end

local function CreateStepper(holder, name, tab, choices, width, Pick)
    local control = CreateFrame("Frame", name .. "Control", holder, "SettingsDropdownWithButtonsTemplate")
    control:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    control:SetWidth(width + STEPPERPAD)
    if control.Dropdown then control.Dropdown:SetWidth(width) end
    local index = 1
    local function SetLabel(text)
        local dropdown = control.Dropdown
        if dropdown == nil then return end
        if dropdown.SetDefaultText then dropdown:SetDefaultText(text) end
        if dropdown.Update then dropdown:Update() end
        if dropdown.SetText then dropdown:SetText(text) end
    end

    local dec, inc = FindSteppers(control)
    local setEnabled = {}
    local function Lock(button)
        if button == nil then return end
        setEnabled[button] = button.SetEnabled
        local nop = function() end
        button.SetEnabled = nop
        button.Enable = nop
        button.Disable = nop
    end

    Lock(dec)
    Lock(inc)
    local function UpdateSteppers()
        if dec then setEnabled[dec](dec, index > 1) end
        if inc then setEnabled[inc](inc, index < #choices) end
    end

    local function UpdateSteppersSoon()
        UpdateSteppers()
        if C_Timer then C_Timer.After(0, UpdateSteppers) end
    end

    if dec then
        dec:SetScript(
            "OnClick",
            function()
                if index > 1 then Pick(index - 1) end
            end
        )
    end

    if inc then
        inc:SetScript(
            "OnClick",
            function()
                if index < #choices then Pick(index + 1) end
            end
        )
    end

    control:HookScript("OnShow", UpdateSteppersSoon)
    if control.Dropdown and control.Dropdown.SetupMenu then
        control.Dropdown:SetupMenu(
            function(dropdown, rootDescription)
                UpdateSteppersSoon()
                if tab.label then rootDescription:CreateTitle(UI:Text(tab.label)) end
                for i, choice in ipairs(choices) do
                    rootDescription:CreateButton(UI:Text(choice.label), function() Pick(i) end)
                end
            end
        )
    end

    local function SetIndex(newIndex)
        index = newIndex
        local choice = choices[index]
        if choice then SetLabel(UI:Text(choice.label)) end
        UpdateSteppersSoon()
    end

    return control, SetIndex
end

local function CreateList(name, button, width, count, maxVisible)
    local visible = math.min(count, maxVisible)
    local list = CreateFrame("Frame", name .. "List", UIParent)
    list:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    list:SetSize(width, math.max(1, visible * ITEM + 4))
    list:SetFrameStrata("DIALOG")
    list:EnableMouse(true)
    list:Hide()
    local bg = list:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(list)
    UI:SetSolidColor(bg, 0.05, 0.05, 0.05, 0.95)
    if count <= visible then
        local content = CreateFrame("Frame", name .. "Content", list)
        content:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2)
        content:SetSize(width - 4, math.max(1, count * ITEM))

        return list, content, width - 4
    end

    local template = nil
    if D4:CheckTemplates("UIPanelScrollFrameTemplate") then template = "UIPanelScrollFrameTemplate" end
    local scroll = CreateFrame("ScrollFrame", name .. "Scroll", list, template)
    scroll:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -BARWIDTH, 2)
    local itemWidth = width - 2 - BARWIDTH
    local content = CreateFrame("Frame", name .. "Content", scroll)
    content:SetSize(itemWidth, count * ITEM)
    scroll:SetScrollChild(content)
    if template == nil then
        scroll:EnableMouseWheel(true)
        scroll:SetScript(
            "OnMouseWheel",
            function(sel, delta)
                local range = math.max(0, count * ITEM - visible * ITEM)
                local offset = math.min(range, math.max(0, sel:GetVerticalScroll() - delta * ITEM))
                sel:SetVerticalScroll(offset)
            end
        )
    end

    return list, content, itemWidth
end

local function CreateFallback(holder, name, tab, choices, width, Pick)
    local button = D4:CreateButton(name .. "Button", holder)
    button:SetSize(width, UI.ROW)
    button:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    local list, content, itemWidth = CreateList(name, button, width, #choices, tab.maxVisible or MAXVISIBLE)
    for index, choice in ipairs(choices) do
        local item = CreateFrame("Button", name .. "Item" .. index, content)
        item:SetSize(itemWidth, ITEM)
        item:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(index - 1) * ITEM)
        item.Label = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        item.Label:SetPoint("LEFT", item, "LEFT", 4, 0)
        item.Label:SetJustifyH("LEFT")
        item.Label:SetText(UI:Text(choice.label))
        local highlight = item:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(item)
        UI:SetSolidColor(highlight, 1, 1, 1, 0.15)
        item:SetScript(
            "OnClick",
            function()
                UI:CloseDropdowns()
                Pick(index)
            end
        )
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
    local function SetIndex(newIndex)
        local choice = choices[newIndex]
        if choice then button:SetText(UI:Text(choice.label)) end
    end

    return button, SetIndex
end

function UI.WindowMixin:AddDropdown(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Dropdown")
    local text = UI:Text(tab.label)
    local choices = tab.choices or {}
    local width = tab.width or WIDTH
    local holder = CreateFrame("Frame", name, win.content)
    holder:SetSize(math.max(1, win.contentWidth - 8), UI.ROW)
    local SetIndex = nil
    local function Pick(index)
        local choice = choices[index]
        if choice == nil then return end
        holder.value = choice.value
        SetIndex(index)
        if tab.func then tab.func(choice.value) end
    end

    local anchor = nil
    local height = UI.ROW
    if D4:CheckTemplates("SettingsDropdownWithButtonsTemplate") then
        anchor, SetIndex = CreateStepper(holder, name, tab, choices, width, Pick)
        height = anchor:GetHeight()
        if height == nil or height <= 0 then height = STEPPERHEIGHT end
    else
        anchor, SetIndex = CreateFallback(holder, name, tab, choices, width, Pick)
    end

    holder:SetHeight(height)
    holder.control = anchor
    holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.Label:SetPoint("LEFT", anchor, "RIGHT", 8, 0)
    holder.Label:SetText(text)
    function holder:SetValue(newValue)
        local index = IndexOf(choices, newValue)
        if index == nil then return end
        holder.value = newValue
        SetIndex(index)
    end

    local start = IndexOf(choices, tab.value)
    if start == nil and choices[1] then start = 1 end
    if start then
        holder.value = choices[start].value
        SetIndex(start)
    end

    UI:Add(win, holder, height, text, true, tab.search)

    return holder
end
