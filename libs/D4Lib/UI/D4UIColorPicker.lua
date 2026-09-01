local _, D4 = ...
local UI = D4.UI
local SWATCH = 20

local function Clamp(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback end
    if value < 0 then return 0 end
    if value > 1 then return 1 end

    return value
end

local function ReadColor(value)
    if type(value) ~= "table" then return 1, 1, 1, 1 end
    local r = Clamp(value.r or value.R or value[1], 1)
    local g = Clamp(value.g or value.G or value[2], 1)
    local b = Clamp(value.b or value.B or value[3], 1)
    local a = Clamp(value.a or value.A or value[4], 1)

    return r, g, b, a
end

function UI.WindowMixin:AddColorPicker(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "ColorPicker")
    local text = UI:Text(tab.label)
    local hasOpacity = tab.hasOpacity ~= false
    local holder = CreateFrame("Frame", name, win.content)
    holder:SetSize(math.max(1, win.contentWidth - 8), UI.ROW)
    local swatch = CreateFrame("Button", name .. "Swatch", holder)
    swatch:SetSize(SWATCH, SWATCH)
    swatch:SetPoint("LEFT", holder, "LEFT", 0, 0)
    swatch.SwatchBg = swatch:CreateTexture(nil, "BACKGROUND")
    swatch.SwatchBg:SetSize(SWATCH - 2, SWATCH - 2)
    swatch.SwatchBg:SetPoint("CENTER", swatch, "CENTER", 0, 0)
    UI:SetSolidColor(swatch.SwatchBg, 1, 1, 1, 1)
    swatch.InnerBorder = swatch:CreateTexture(nil, "BORDER")
    swatch.InnerBorder:SetSize(SWATCH - 4, SWATCH - 4)
    swatch.InnerBorder:SetPoint("CENTER", swatch, "CENTER", 0, 0)
    UI:SetSolidColor(swatch.InnerBorder, 0, 0, 0, 1)
    swatch.Color = swatch:CreateTexture(nil, "ARTWORK")
    swatch.Color:SetSize(SWATCH - 6, SWATCH - 6)
    swatch.Color:SetPoint("CENTER", swatch, "CENTER", 0, 0)
    local highlight = swatch:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(swatch)
    UI:SetSolidColor(highlight, 1, 1, 1, 0.2)
    holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.Label:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
    holder.Label:SetJustifyH("LEFT")
    holder.Label:SetText(text)
    holder.control = swatch
    swatch.holder = holder
    local function Refresh()
        UI:SetSolidColor(swatch.Color, holder.r, holder.g, holder.b, holder.a)
    end

    function holder:SetValue(r, g, b, a)
        self.r = Clamp(r, 1)
        self.g = Clamp(g, 1)
        self.b = Clamp(b, 1)
        self.a = Clamp(a, 1)
        if not hasOpacity then self.a = 1 end
        Refresh()
    end

    holder:SetValue(ReadColor(tab.value))
    local function Commit(r, g, b, a)
        holder:SetValue(r, g, b, a)
        if tab.func then tab.func(holder.r, holder.g, holder.b, holder.a) end
    end

    swatch:SetScript(
        "OnClick",
        function()
            if ColorPickerFrame == nil then
                D4:MSG("[D4UI][AddColorPicker] Missing ColorPicker")

                return
            end

            local legacy = D4:GetWoWBuild() ~= "RETAIL"
            local opacity = holder.a
            if legacy then opacity = 1 - opacity end
            D4:ShowColorPicker(
                holder.r,
                holder.g,
                holder.b,
                opacity,
                function(restore)
                    if restore then
                        Commit(unpack(restore))

                        return
                    end

                    local alpha = 1
                    if ColorPickerFrame.GetColorAlpha then
                        alpha = ColorPickerFrame:GetColorAlpha()
                    elseif OpacitySliderFrame then
                        alpha = OpacitySliderFrame:GetValue()
                    end

                    if legacy then alpha = 1 - alpha end
                    if not hasOpacity then alpha = 1 end
                    local r, g, b = ColorPickerFrame:GetColorRGB()
                    Commit(r, g, b, alpha)
                end
            )
        end
    )

    UI:Add(win, holder, UI.ROW, text, true, tab.search)

    return holder
end
