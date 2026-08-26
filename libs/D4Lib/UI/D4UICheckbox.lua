local _, D4 = ...
local UI = D4.UI

function UI.WindowMixin:AddCheckbox(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Checkbox")
    local holder = CreateFrame("Frame", name .. "Holder", win.content)
    holder:SetSize(math.max(1, win.contentWidth - 8), UI.ROW)
    local cb = D4:CreateCheckButton(name, holder)
    cb:SetSize(UI.ROW, UI.ROW)
    cb:SetHitRectInsets(0, 0, 0, 0)
    cb:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    cb:SetChecked(tab.value == true or tab.value == 1)
    cb.Label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.Label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.holder = holder
    local text = UI:Text(tab.label)
    if tab.textFunc then text = tab.textFunc(cb) or text end
    cb.Label:SetText(text)
    local row = nil
    if tab.onClick then
        row = D4:CreateButton(name .. "Row", holder, true)
        row:SetPoint("TOPLEFT", cb, "TOPRIGHT", 0, 0)
        row:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
        row:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        row:SetScript("OnClick", function(sel, button) tab.onClick(button, cb) end)
        cb.row = row
    end

    local element = UI:Add(win, holder, UI.ROW, text, true, tab.search)
    cb.uiElement = element
    function cb:UpdateLabel()
        if tab.textFunc == nil then return end
        local newText = tab.textFunc(cb) or ""
        cb.Label:SetText(newText)
        UI:SetLabel(element, newText)
    end

    local oldSetEnabled = cb.SetEnabled
    function cb:SetEnabled(value)
        oldSetEnabled(self, value)
        if row == nil then return end
        if value then
            row:Enable()
        else
            row:Disable()
        end
    end

    cb:SetScript(
        "OnClick",
        function(sel)
            local value = false
            if sel:GetChecked() then value = true end
            if tab.func then tab.func(value, sel) end
            cb:UpdateLabel()
        end
    )

    return cb
end
