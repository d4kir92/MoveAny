local _, D4 = ...
local UI = D4.UI
local HEIGHT = 46

local function FormatText(text, value)
    if string.find(text, "%%") then return string.format(text, value) end

    return text .. ": " .. value
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
    slider:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -18)
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
    slider:SetValue(value)
    value = tonumber(string.format("%." .. decimals .. "f", slider:GetValue()))
    holder.value = value
    label:SetText(FormatText(text, value))
    slider:SetScript(
        "OnValueChanged",
        function(sel, newValue)
            newValue = tonumber(string.format("%." .. decimals .. "f", newValue))
            label:SetText(FormatText(text, newValue))
            holder.value = newValue
            if tab.func then tab.func(newValue) end
        end
    )

    holder.slider = slider
    holder.Label = label
    UI:Add(win, holder, HEIGHT, text, true, tab.search)

    return holder
end
