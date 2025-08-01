local _, D4 = ...
local X = 0
local Y = 0
local PARENT = nil
local TAB = nil
local TABIsNil = false
function D4:GetName(frame, bStr)
    if frame == nil then
        if bStr then
            return ""
        else
            return nil
        end
    end

    local ok, name = pcall(
        function()
            if type(frame) == "table" and type(frame.GetName) == "function" then return frame:GetName() end
        end
    )

    if ok then
        if name ~= nil then
            return name
        else
            if frame == nil then
                if bStr then
                    return ""
                else
                    return nil
                end
            end
        end
    end

    if bStr then
        return ""
    else
        return nil
    end
end

function D4:GetParent(frame)
    if frame == nil then return nil end
    local ok, parent = pcall(
        function()
            if type(frame) == "table" and type(frame.GetParent) == "function" then return frame:GetParent() end
        end
    )

    if ok then return parent end

    return nil
end

function D4:GetText(frame)
    if frame == nil then return nil end
    local ok, text = pcall(
        function()
            if type(frame) == "table" and type(frame.GetText) == "function" then return frame:GetText() end
        end
    )

    if ok then return text end

    return nil
end

function D4:SetClampedToScreen(frame, value, from)
    if frame == nil then return end
    if value == nil then return end
    local ok = pcall(
        function()
            if frame == nil then return false end
            if InCombatLockdown() and frame:IsProtected() then return false end
            if type(frame) == "table" and type(frame.SetClampedToScreen) == "function" then
                frame:SetClampedToScreen(value)

                return true
            end
        end
    )

    return ok
end

function D4:TrySetParent(frame, parent)
    if frame == nil then
        D4:INFO("[D4] Missing Frame for TrySetParent", frame)

        return false
    end

    if parent == nil then
        D4:INFO("[D4] Missing Parent for TrySetParent", parent)

        return false
    end

    if frame:IsProtected() and InCombatLockdown() then return false end
    local ok = pcall(
        function()
            if type(frame) == "table" and type(frame.SetParent) == "function" then
                frame:SetParent(parent)
            end
        end
    )

    if ok then return true end

    return false
end

function D4:TrySetScale(frame, scale)
    if frame == nil then
        D4:INFO("[D4] Missing Frame for TrySetScale", frame)

        return false
    end

    if scale == nil then
        D4:INFO("[D4] Missing Scale for TrySetScale", scale)

        return false
    end

    if frame:IsProtected() and InCombatLockdown() then return false end
    local ok = pcall(
        function()
            if type(frame) == "table" and type(frame.SetScale) == "function" then
                frame:SetScale(scale)
            end
        end
    )

    if ok then return true end

    return false
end

function D4:TryRun(callback, ...)
    if callback == nil then return end
    local ok, ret = pcall(function(...) return callback(...) end, ...)
    if ok then return ret end

    return nil
end

function D4:TrySec(callback, ...)
    if callback == nil then return end
    local ok, ret = securecall(function(...) return callback(...) end, ...)
    if ok then return ret end

    return nil
end

function D4:SetFontSize(element, fontSize, newFontFlags)
    if not element then return end
    if element.GetFont == nil then return end
    if not fontSize then return end
    local fontType, _, fontFlags = element:GetFont()
    if fontType == nil then
        D4:MSG("SetFontSize FAILED #1:", D4:GetName(element))

        return
    end

    element:SetFont(fontType, fontSize, newFontFlags or fontFlags)
end

--[[ INPUTS ]]
function D4:AddCategory(tab)
    tab.sw = tab.sw or 25
    tab.sh = tab.sh or 25
    tab.parent = tab.parent or UIParent
    tab.pTab = tab.pTab or "CENTER"
    tab.parent.f = tab.parent:CreateFontString(nil, nil, "GameFontNormal")
    tab.parent.f:SetPoint(unpack(tab.pTab))
    if tab.key and tab.name and tab.name == "" then
        D4:INFO("[D4][AddCategory] " .. tab.key .. " has no name")
    end

    tab.parent.f:SetText(D4:Trans("LID_" .. tab.name))
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
    if tab.value == true or tab.value == 1 then
        cb:SetChecked(true)
    else
        cb:SetChecked(false)
    end

    cb:SetScript(
        "OnClick",
        function(sel)
            tab:funcV(sel:GetChecked())
        end
    )

    if text then
        cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
        cb.f:SetPoint("LEFT", cb, "RIGHT", 0, 0)
        if tab.key and tab.name and tab.name == "" then
            D4:INFO("[D4][CreateCheckbox] " .. tab.key .. " has no name")
        end

        cb.f:SetText(D4:Trans("LID_" .. tab.name))
    end

    return cb
end

function D4:CreateCheckboxForCVAR(tab)
    if tab.name == nil then
        D4:MSG("[D4] Missing name for [CreateCheckboxForCVAR]")

        return
    end

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
    if tab.name == nil then
        D4:MSG("[D4] Missing name for [CreateSliderForCVAR]")

        return
    end

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
    tab.prefix = tab.prefix or ""
    tab.suffix = tab.suffix or ""
    tab.numeric = tab.numeric or false
    local cb = CreateFrame("EditBox", tab.name, tab.parent, "InputBoxTemplate")
    cb:SetSize(tab.sw, tab.sh)
    cb:SetPoint(unpack(tab.pTab))
    cb:SetText(tab.value)
    cb:SetAutoFocus(false)
    cb:SetNumeric(tab.numeric)
    cb:SetScript(
        "OnTextChanged",
        function(sel)
            tab:funcV(sel:GetText())
        end
    )

    cb.f = cb:CreateFontString(nil, nil, "GameFontNormal")
    cb.f:SetPoint("LEFT", cb, "RIGHT", 10, 0)
    if tab.key and tab.name and tab.name == "" then
        D4:INFO("[D4][CreateEditBox] " .. tab.key .. " has no name")
    end

    cb.f:SetText(tab.prefix .. D4:Trans("LID_" .. tab.name) .. tab.suffix)

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
        slider.Low:SetTextColor(1, 1, 1)
    end

    if slider.High == nil then
        slider.High = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.High:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, -12)
        slider.High:SetTextColor(1, 1, 1)
    end

    if slider.Text == nil then
        slider.Text = slider:CreateFontString(nil, nil, "GameFontNormal")
        slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
        slider.Text:SetTextColor(1, 1, 1)
    end

    slider.Low:SetText(tab.vmin)
    slider.High:SetText(tab.vmax)
    if tab.name and tab.key and tab.key == "" then
        D4:INFO("[D4][CreateSlider] " .. tab.name .. " has no key")
    end

    local struct = D4:Trans("LID_" .. tab.key)
    if struct and tab.value then
        slider.Text:SetText(string.format(struct, tab.value))
    end

    D4:SetFontSize(slider.Low, 10, "THINOUTLINE")
    D4:SetFontSize(slider.High, 10, "THINOUTLINE")
    D4:SetFontSize(slider.Text, 10, "THINOUTLINE")
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
                tab:func(val)
            end

            local struct2 = D4:Trans("LID_" .. tab.key)
            if struct2 then
                slider.Text:SetText(string.format(struct2, val))
            else
                D4:MSG("[D4][CreateSlider][OnValueChanged] Missing format string:", tab.key)
            end
        end
    )

    return slider
end

function D4:GetColor(name, from)
    if TAB == nil then
        D4:MSG("[GetColor] Missing TAB", from)

        return 0, 0, 0, 0
    end

    local r = TAB[name .. "_R"] or 0
    local g = TAB[name .. "_G"] or 0
    local b = TAB[name .. "_B"] or 0
    local a = TAB[name .. "_A"] or 0

    return r, g, b, a
end

function D4:SetColor(name, r, g, b, a)
    if TAB == nil then
        D4:MSG("[SetColor] Missing TAB")

        return
    end

    TAB[name .. "_R"] = r or 0
    TAB[name .. "_G"] = g or 0
    TAB[name .. "_B"] = b or 0
    TAB[name .. "_A"] = a or 0
end

function D4:ShowColorPicker(r, g, b, a, changedCallback, revertCallback)
    if ColorPickerFrame.SetupColorPickerAndShow then
        local info = {}
        info.swatchFunc = changedCallback
        info.hasOpacity = true
        info.opacityFunc = changedCallback
        info.cancelFunc = function() end
        info.extraInfo = "TEST"
        info.r = r
        info.g = g
        info.b = b
        info.opacity = a
        ColorPickerFrame:SetupColorPickerAndShow(info)
    else
        D4:MSG("[ShowColorPicker] Missing ColorPicker")
    end
end

function D4:AddColorPicker(key, value, func, x, y)
    if TAB == nil then
        D4:MSG("[D4][AddColorPicker] Missing TAB")

        return
    end

    if key and key == "" then
        D4:INFO("[D4][AddColorPicker] has no key")

        return
    end

    if TAB[key .. "_R"] == nil then
        TAB[key .. "_R"] = value.R
    end

    if TAB[key .. "_G"] == nil then
        TAB[key .. "_G"] = value.G
    end

    if TAB[key .. "_B"] == nil then
        TAB[key .. "_B"] = value.B
    end

    if TAB[key .. "_A"] == nil then
        TAB[key .. "_A"] = value.A
    end

    local btn = CreateFrame("Button", key, PARENT, "UIPanelButtonTemplate")
    btn:SetSize(180, 25)
    btn:SetPoint("TOPLEFT", PARENT, "TOPLEFT", x, Y)
    btn:SetText(D4:Trans("LID_" .. key))
    btn:SetScript(
        "OnClick",
        function()
            local r, g, b, a = D4:GetColor(key)
            if D4:GetWoWBuild() ~= "RETAIL" then
                a = 1 - a
            end

            D4:ShowColorPicker(
                r,
                g,
                b,
                a,
                function(restore)
                    local newR, newG, newB, newA
                    if restore then
                        newR, newG, newB, newA = unpack(restore)
                    else
                        local alpha = 1
                        if ColorPickerFrame.GetColorAlpha then
                            alpha = ColorPickerFrame:GetColorAlpha()
                        else
                            alpha = OpacitySliderFrame:GetValue()
                        end

                        if D4:GetWoWBuild() ~= "RETAIL" then
                            alpha = 1 - alpha
                        end

                        newA, newR, newG, newB = alpha, ColorPickerFrame:GetColorRGB()
                    end

                    D4:SetColor(key, newR, newG, newB, newA)
                    if func then
                        func()
                    end
                end
            )
        end
    )
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
    D4:SetClampedToScreen(fra, true)
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
        Y = Y - 50
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
        TAB[key] = value
        val = TAB[key]
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
    Y = Y - 24
    if key == nil then
        D4:MSG("[D4][AppendSlider] Missing key:", key, value)

        return
    elseif value == nil then
        D4:MSG("[D4][AppendSlider] Missing value:", key, value)

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

    if TAB[key] and not (type(TAB[key]) == "number" or type(TAB[key]) == "string") then
        D4:MSG("[D4][AppendSlider] WRONG TYPE value:", TAB[key])

        return
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

function D4:AppendColorPicker(key, value, func, x)
    D4:AddColorPicker(key, value, func, x)
    Y = Y - 30
end

function D4:AppendEditbox(key, value, func, x, y, numeric, tab, prefix, suffix, lstr)
    value = value or false
    x = x or X
    if tab == nil and TAB == nil then
        if TABIsNil == false then
            TABIsNil = true
            D4:MSG("TAB is nil #1")
        end

        return Y
    end

    local t = tab or TAB
    local val = t[key]
    if val == nil then
        t[key] = value
        val = t[key]
    end

    Y = Y - 4
    local eb = D4:CreateEditBox(
        {
            ["name"] = lstr or key,
            ["parent"] = PARENT,
            ["pTab"] = {"TOPLEFT", x or X, y or Y},
            ["value"] = val,
            ["funcV"] = function(sel, text)
                if numeric then
                    text = tonumber(text)
                end

                t[key] = text
                if func then
                    func(sel, text)
                end
            end,
            ["prefix"] = prefix,
            ["suffix"] = suffix,
            ["numeric"] = numeric
        }
    )

    Y = Y - 20

    return Y, eb
end

function D4:CreateDropdown(key, value, choices, parent, func)
    if TAB[key] == nil then
        TAB[key] = value
    end

    if key and key == "" then
        D4:INFO("[D4][CreateDropdown] has no key")

        return nil
    end

    local text = parent:CreateFontString(nil, nil, "GameFontNormal")
    text:SetPoint("TOPLEFT", X + 5, Y)
    text:SetText(D4:Trans("LID_" .. key))
    Y = Y - 18
    if D4:GetWoWBuild() == "RETAIL" then
        local Dropdown = CreateFrame("DropdownButton", key, parent, "WowStyle1DropdownTemplate")
        Dropdown:SetDefaultText(D4:Trans("LID_" .. choices[TAB[key]]))
        Dropdown:SetPoint("TOPLEFT", X + 5, Y)
        Dropdown:SetWidth(200)
        Dropdown:SetupMenu(
            function(dropdown, rootDescription)
                if key and key == "" then
                    D4:INFO("[D4][CreateDropdown] has no key")
                end

                rootDescription:CreateTitle(D4:Trans("LID_" .. key))
                for data, name in pairs(choices) do
                    if key and name and name == "" then
                        D4:INFO("[D4][CreateDropdown] " .. key .. " has no name")
                    end

                    rootDescription:CreateButton(
                        D4:Trans("LID_" .. name),
                        function()
                            TAB[key] = data
                            Dropdown:SetDefaultText(D4:Trans("LID_" .. name))
                            if func then
                                func(data)
                            end
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
                    if name and name == "" then
                        D4:INFO("[D4][CreateDropdown] has no name")

                        return nil
                    end

                    info.text = D4:Trans("LID_" .. name)
                    info.arg1 = data
                    info.checked = name == choices[TAB[key]]
                    info.func = dropDown.SetValue
                    UIDropDownMenu_AddButton(info)
                end
            end
        end

        UIDropDownMenu_Initialize(dropDown, WPDropDownDemo_Menu)
        UIDropDownMenu_SetText(dropDown, D4:Trans("LID_" .. choices[TAB[key]]))
        function dropDown:SetValue(newValue)
            TAB[key] = newValue
            UIDropDownMenu_SetText(dropDown, newValue)
            CloseDropDownMenus()
            if func then
                func(newValue)
            end
        end
    end
end

function D4:AppendDropdown(key, value, choices, func)
    Y = Y - 10
    D4:CreateDropdown(key, value, choices, PARENT, func)
    Y = Y - 30
end
