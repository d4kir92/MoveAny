local _, D4 = ...
local X = 0
local Y = 0
local PARENT = nil
local TAB = nil
local TABIsNil = false
--[[ INPUTS ]]
function D4:AddCategory(tab)
    tab.sw = tab.sw or 25
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.parent.f = tab.parent:CreateFontString(nil, nil, "GameFontNormal")
    tab.parent.f:SetPoint(unpack(tab.pTab))
    tab.parent.f:SetText(D4:Trans(tab.name))
end

function D4:CreateCheckbox(tab, text)
    if text == nil then
        text = true
    end

    tab.sw = tab.sw or 25
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or nil
    local cb = CreateFrame("CheckButton", tab.name, tab.parent, "UICheckButtonTemplate")
    cb:SetSize(tab.sw, tab.sh)
    cb:SetPoint(unpack(tab.pTab))
    cb:SetChecked(tab.value)
    cb:SetScript(
        "OnClick",
        function(sel)
            tab:funcV(sel:GetChecked())
        end
    )

    if text then
        cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
        cb.f:SetPoint("LEFT", cb, "RIGHT", 0, 0)
        cb.f:SetText(D4:Trans(tab.name))
    end

    return cb
end

function D4:CreateCheckboxForCVAR(tab)
    tab.sw = tab.sw or 25
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or nil
    local cb = D4:CreateCheckbox(tab)
    local cb2 = CreateFrame("CheckButton", tab.name, tab.parent, "UICheckButtonTemplate")
    cb2:SetSize(tab.sw, tab.sh)
    local p1, p2, p3 = unpack(tab.pTab)
    cb2:SetPoint(p1, p2 + 25, p3)
    cb2:SetChecked(tab.value2)
    cb2:SetScript(
        "OnClick",
        function(sel)
            tab:funcV2(sel:GetChecked())
        end
    )

    cb.f:SetPoint("LEFT", cb, "RIGHT", 25, 0)

    return cb
end

function D4:CreateSliderForCVAR(tab)
    tab.sw = tab.sw or 25
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or nil
    local cb = D4:CreateCheckbox(tab, false)
    tab.sw = 460
    tab.value = tab.value2
    tab.key = tab.key or tab.name or ""
    tab.pTab = {tab.pTab[1], tab.pTab[2] + 32, tab.pTab[3] - 18}
    D4:CreateSlider(tab)

    return cb
end

function D4:CreateEditBox(tab)
    tab.sw = tab.sw or 200
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or nil
    local cb = CreateFrame("EditBox", tab.name, tab.parent, "InputBoxTemplate")
    cb:SetSize(tab.sw, tab.sh)
    cb:SetPoint(unpack(tab.pTab))
    cb:SetText(tab.value)
    cb:SetScript(
        "OnTextChanged",
        function(sel)
            tab:funcV(sel:GetText())
        end
    )

    cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
    cb.f:SetPoint("LEFT", cb, "RIGHT", 0, 0)
    cb.f:SetText(D4:Trans(tab.name))

    return cb
end

function D4:CreateSlider(tab)
    if tab.key == nil then
        D4:MSG("[D4][CreateSlider] Missing format string:", tab.key, tab.value)

        return
    elseif tab.value == nil or type(tonumber(tab.value)) ~= "number" then
        D4:MSG("[D4][CreateSlider] Missing value:", tab.key, tab.value)

        return
    end

    tab.sw = tab.sw or 200
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or 1
    tab.vmin = tab.vmin or 1
    tab.vmax = tab.vmax or 1
    tab.steps = tab.steps or 1
    tab.decimals = tab.decimals or 0
    tab.key = tab.key or tab.name or ""
    local slider = CreateFrame("Slider", tab.key, tab.parent, "UISliderTemplate")
    slider:SetSize(tab.sw, 16)
    slider:SetPoint(unpack(tab.pTab))
    if slider.Low == nil then
        slider.Low = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.Low:SetPoint("BOTTOMLEFT", slider, "BOTTOMLEFT", 0, -12)
        slider.Low:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        slider.Low:SetTextColor(1, 1, 1)
    end

    if slider.High == nil then
        slider.High = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.High:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, -12)
        slider.High:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        slider.High:SetTextColor(1, 1, 1)
    end

    if slider.Text == nil then
        slider.Text = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
        slider.Text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
        slider.Text:SetTextColor(1, 1, 1)
    end

    slider.Low:SetText(tab.vmin)
    slider.High:SetText(tab.vmax)
    local struct = D4:Trans(tab.key)
    if struct and tab.value then
        slider.Text:SetText(string.format(struct, tab.value))
    end

    slider:SetMinMaxValues(tab.vmin, tab.vmax)
    slider:SetObeyStepOnDrag(true)
    slider:SetValueStep(tab.steps)
    if tab.value then
        slider:SetValue(tab.value)
    end

    slider:SetScript(
        "OnValueChanged",
        function(sel, val)
            val = string.format("%." .. tab.decimals .. "f", val)
            val = tonumber(val)
            if TAB then
                TAB[tab.key] = val
            end

            if tab.funcV2 then
                tab:funcV2(val)
            elseif tab.funcV then
                tab:funcV(val)
            end

            if tab.func then
                tab:func()
            end

            local struct2 = D4:Trans(tab.key)
            if struct2 then
                slider.Text:SetText(string.format(struct2, val))
            else
                D4:MSG("[D4][CreateSlider][OnValueChanged] Missing format string:", tab.key)
            end
        end
    )

    return slider
end

--[[ FRAMES ]]
function D4:CreateFrame(tab)
    tab.sw = tab.sw or 100
    tab.sh = tab.sh or 100
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.title = tab.title or ""
    local fra = nil
    if not D4:IsOldWow() then
        tab.templates = tab.templates or "BasicFrameTemplateWithInset"
        fra = CreateFrame("FRAME", tab.name, tab.parent, tab.templates)
    else
        fra = CreateFrame("Frame", tab.name, tab.parent)
        fra.TitleText = fra:CreateFontString(nil, nil, "GameFontNormal")
        fra.TitleText:SetPoint("TOP", fra, "TOP", 0, 0)
        fra.CloseButton = CreateFrame("Button", tab.name .. ".CloseButton", fra, "UIPanelButtonTemplate")
        fra.CloseButton:SetPoint("TOPRIGHT", fra, "TOPRIGHT", 0, 0)
        fra.CloseButton:SetSize(25, 25)
        fra.CloseButton:SetText("X")
        fra.bg = fra:CreateTexture(tab.name .. ".bg", "ARTWORK")
        fra.bg:SetAllPoints(fra)
        if fra.bg.SetColorTexture then
            fra.bg:SetColorTexture(0.03, 0.03, 0.03, 0.5)
        else
            fra.bg:SetTexture(0.03, 0.03, 0.03, 0.5)
        end
    end

    fra:SetSize(tab.sw, tab.sh)
    fra:SetPoint(unpack(tab.pTab))
    fra:SetClampedToScreen(true)
    fra:SetMovable(true)
    fra:EnableMouse(true)
    fra:RegisterForDrag("LeftButton")
    fra:SetScript("OnDragStart", fra.StartMoving)
    fra:SetScript("OnDragStop", fra.StopMovingOrSizing)
    fra:Hide()
    if fra.TitleText then
        fra.TitleText:SetText(tab.title)
    end

    return fra
end

function D4:SetAppendX(newX)
    X = newX
end

function D4:GetAppendX()
    return X
end

function D4:SetAppendY(newY)
    Y = newY
end

function D4:GetAppendY()
    return Y
end

function D4:SetAppendParent(newParent)
    PARENT = newParent
end

function D4:GetAppendParent()
    return PARENT
end

function D4:SetAppendTab(newTab)
    TAB = newTab
end

function D4:AppendCategory(name, x, y)
    if Y == 0 then
        Y = Y - 5
    else
        Y = Y - 30
    end

    D4:AddCategory(
        {
            ["name"] = name,
            ["parent"] = PARENT,
            ["pTab"] = {"TOPLEFT", x or X, y or Y},
        }
    )

    Y = Y - 20

    return Y
end

function D4:AppendCheckbox(key, value, func, x, y)
    value = value or false
    x = x or X
    if TAB == nil then
        if TABIsNil == false then
            TABIsNil = true
            D4:MSG("TAB is nil #1")
        end

        return Y
    end

    local val = TAB[key]
    if val == nil then
        val = value
    end

    D4:CreateCheckbox(
        {
            ["name"] = key,
            ["parent"] = PARENT,
            ["pTab"] = {"TOPLEFT", x or X, y or Y},
            ["value"] = val,
            ["funcV"] = function(sel, checked)
                TAB[key] = checked
                if func then
                    func(sel, checked)
                end
            end
        }
    )

    Y = Y - 20

    return Y
end

function D4:AppendSlider(key, value, min, max, steps, decimals, func, lstr)
    Y = Y - 15
    if key == nil then
        D4:MSG("[D4][AppendSlider] Missing key:", tab.key, tab.value)

        return
    elseif value == nil then
        D4:MSG("[D4][AppendSlider] Missing value:", tab.key, tab.value)

        return
    end

    if TAB == nil then
        if TABIsNil == false then
            TABIsNil = true
            D4:MSG("TAB is nil #2")
        end

        return Y
    end

    if TAB[key] == nil then
        TAB[key] = value
    end

    local slider = {}
    slider.key = key
    slider.parent = PARENT
    slider.value = TAB[key]
    slider.vmin = min
    slider.vmax = max
    slider.sw = 460
    slider.steps = steps
    slider.decimals = decimals
    slider.color = {0, 1, 0, 1}
    slider.func = func
    slider.pTab = {"TOPLEFT", X + 5, Y}
    D4:CreateSlider(slider)
    Y = Y - 30
end

function D4:CreateDropdown(key, value, choices, parent)
    if TAB[key] == nil then
        TAB[key] = value
    end

    local text = parent:CreateFontString(nil, nil, "GameFontNormal")
    text:SetPoint("TOPLEFT", X + 5, Y)
    text:SetText(D4:Trans(key))
    Y = Y - 18
    if D4:GetWoWBuild() == "RETAIL" then
        local Dropdown = CreateFrame("DropdownButton", key, parent, "WowStyle1DropdownTemplate")
        Dropdown:SetDefaultText(D4:Trans(choices[TAB[key]]))
        Dropdown:SetPoint("TOPLEFT", X + 5, Y)
        Dropdown:SetWidth(200)
        Dropdown:SetupMenu(
            function(dropdown, rootDescription)
                rootDescription:CreateTitle(D4:Trans(key))
                for data, name in pairs(choices) do
                    rootDescription:CreateButton(
                        D4:Trans(name),
                        function()
                            TAB[key] = data
                            Dropdown:SetDefaultText(D4:Trans(name))
                        end
                    )
                end
            end
        )
    else
        local dropDown = CreateFrame("Frame", "WPDemoDropDown", PARENT, "UIDropDownMenuTemplate")
        dropDown:SetPoint("TOPLEFT", -10, Y)
        UIDropDownMenu_SetWidth(dropDown, 200)
        function WPDropDownDemo_Menu(frame, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            if level == 1 then
                for data, name in pairs(choices) do
                    info.text = D4:Trans(name)
                    info.arg1 = data
                    info.checked = name == choices[TAB[key]]
                    info.func = dropDown.SetValue
                    UIDropDownMenu_AddButton(info)
                end
            end
        end

        UIDropDownMenu_Initialize(dropDown, WPDropDownDemo_Menu)
        UIDropDownMenu_SetText(dropDown, choices[TAB[key]])
        function dropDown:SetValue(newValue)
            TAB[key] = newValue
            UIDropDownMenu_SetText(dropDown, newValue)
            CloseDropDownMenus()
        end
    end
end

function D4:AppendDropdown(key, value, choices)
    Y = Y - 10
    D4:CreateDropdown(key, value, choices, PARENT)
    Y = Y - 30
end
