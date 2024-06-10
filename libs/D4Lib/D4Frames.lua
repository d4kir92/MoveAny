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

function D4:CreateCheckbox(tab)
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

    cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
    cb.f:SetPoint("LEFT", cb, "RIGHT", 0, 0)
    cb.f:SetText(D4:Trans(tab.name))

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
    tab.sw = tab.sw or 200
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.value = tab.value or nil
    tab.vmin = tab.vmin or 1
    tab.vmax = tab.vmax or 1
    tab.steps = tab.steps or 1
    tab.decimals = tab.decimals or 0
    tab.key = tab.key or tab.name or ""
    local slider = CreateFrame("Slider", tab.name, tab.parent, "OptionsSliderTemplate")
    slider:SetWidth(tab.sw)
    slider:SetPoint(unpack(tab.pTab))
    slider.Low:SetText(tab.vmin)
    slider.High:SetText(tab.vmax)
    slider.Text:SetText(format(D4:Trans(tab.key), tab.value))
    slider:SetMinMaxValues(tab.vmin, tab.vmax)
    slider:SetObeyStepOnDrag(true)
    slider:SetValueStep(tab.steps)
    slider:SetValue(tab.value)
    slider:SetScript(
        "OnValueChanged",
        function(sel, val)
            val = string.format("%." .. tab.decimals .. "f", val)
            if tab.funcV then
                tab:funcV(val)
            end

            if tab.func then
                tab:func()
            end

            slider.Text:SetText(format(D4:Trans(tab.key), val))
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

local Y = 0
local PARENT = nil
local TAB = nil
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

function D4:AppendCategory(name)
    if Y == 0 then
        Y = Y - 5
    else
        Y = Y - 30
    end

    D4:AddCategory(
        {
            ["name"] = name,
            ["parent"] = PARENT,
            ["pTab"] = {"TOPLEFT", 5, Y},
        }
    )

    Y = Y - 20

    return Y
end

function D4:AppendCheckbox(key, value, func)
    value = value or false
    x = x or 5
    local val = TAB[key]
    if val == nil then
        val = value
    end

    D4:CreateCheckbox(
        {
            ["name"] = key,
            ["parent"] = PARENT,
            ["pTab"] = {"TOPLEFT", x, Y},
            ["value"] = val,
            ["funcV"] = function(sel, checked)
                TAB[key] = checked
                if func then
                    func()
                end
            end
        }
    )

    Y = Y - 20

    return Y
end

function D4:AppendSlider(key, value, min, max, steps, decimals, func, lstr)
    Y = Y - 15
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
    slider.pTab = {"TOPLEFT", 10, Y}
    D4:CreateSlider(slider)
    Y = Y - 30
end
