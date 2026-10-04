local _, D4 = ...
local UI = D4.UI
local HEIGHT = 46
local BOXWIDTH = 40
local BOXHEIGHT = 20
local BOXGAP = 12
local EPSILON = 1e-9

local function FormatText(text, value)
    if string.find(text, "%%") then return string.format(text, value) end

    return text .. ": " .. value
end

local function Round(value, decimals)
    return tonumber(string.format("%." .. decimals .. "f", value))
end

local function SnapToStep(slider, value, step)
    local vmin, vmax = slider:GetMinMaxValues()
    value = math.max(vmin, math.min(vmax, value))
    if step and step > 0 then
        value = vmin + math.floor((value - vmin) / step + 0.5 + EPSILON) * step
        if value > vmax + EPSILON then value = value - step end
        if value < vmin then value = vmin end
    end

    return value
end

function UI.WindowMixin:AddSlider(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Slider")
    local text = UI:Text(tab.label)
    local vmin = tab.min or 0
    local vmax = tab.max or 100
    local step = tab.step or 1
    local decimals = tab.decimals or 0
    local value = tab.value or vmin
    local width = win.contentWidth - 8
    local holder = CreateFrame("Frame", name, win.content)
    holder:SetSize(width, HEIGHT)
    local template = "OptionsSliderTemplate"
    if D4:CheckTemplates("MinimalSliderTemplate") then
        template = "MinimalSliderTemplate"
    elseif D4:CheckTemplates("UISliderTemplate") then
        template = "UISliderTemplate"
    end

    local slider = CreateFrame("Slider", name .. "Slider", holder, template)
    slider:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -18)
    slider:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -(BOXWIDTH + BOXGAP), -18)
    slider:SetHeight(16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(vmin, vmax)
    slider:SetValueStep(step)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    local label = _G[name .. "SliderText"] or slider.Text
    if label == nil then label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal") end
    label:ClearAllPoints()
    label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    local low = _G[name .. "SliderLow"] or slider.Low
    if low == nil then low = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall") end
    low:ClearAllPoints()
    low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    low:SetText(vmin)
    local high = _G[name .. "SliderHigh"] or slider.High
    if high == nil then high = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall") end
    high:ClearAllPoints()
    high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
    high:SetText(vmax)
    D4:SetFontSize(low, 10, "THINOUTLINE")
    D4:SetFontSize(high, 10, "THINOUTLINE")
    local box = CreateFrame("EditBox", name .. "Box", holder, "InputBoxTemplate")
    box:SetSize(BOXWIDTH, BOXHEIGHT)
    box:SetPoint("LEFT", slider, "RIGHT", BOXGAP, 0)
    box:SetAutoFocus(false)
    box:SetJustifyH("CENTER")
    box:SetMaxLetters(12)
    local function ShowValue()
        box.shown = string.format("%." .. decimals .. "f", holder.value)
        box:SetText(box.shown)
        box:SetCursorPosition(0)
    end

    slider:SetValue(value)
    value = Round(slider:GetValue(), decimals)
    holder.value = value
    label:SetText(FormatText(text, value))
    ShowValue()
    slider:SetScript(
        "OnValueChanged",
        function(sel, newValue)
            newValue = Round(newValue, decimals)
            label:SetText(FormatText(text, newValue))
            holder.value = newValue
            if not box:HasFocus() then ShowValue() end
            if tab.func and not holder.dragging then tab.func(newValue) end
        end
    )

    if tab.commitOnRelease then
        slider:HookScript("OnMouseDown", function() holder.dragging = true end)
        slider:HookScript("OnMouseUp", function()
            if not holder.dragging then return end
            holder.dragging = false
            if tab.func then tab.func(holder.value) end
        end)
        slider:HookScript("OnHide", function() holder.dragging = false end)
    end

    box:SetScript("OnEnterPressed", function(sel) sel:ClearFocus() end)
    box:SetScript(
        "OnEscapePressed",
        function(sel)
            ShowValue()
            sel:ClearFocus()
        end
    )

    box:SetScript(
        "OnEditFocusLost",
        function(sel)
            sel:HighlightText(0, 0)
            local input = sel:GetText()
            if input ~= sel.shown then
                input = string.gsub(input, ",", ".")
                input = tonumber(input)
                if input then slider:SetValue(Round(SnapToStep(slider, input, step), decimals)) end
            end

            ShowValue()
        end
    )

    holder.slider = slider
    holder.Label = label
    holder.Low = low
    holder.High = high
    holder.Box = box
    UI:Add(win, holder, HEIGHT, text, true, tab.search, tab.added)

    return holder
end
