local _, D4 = ...
local UI = D4.UI

function UI.WindowMixin:AddCheckbox(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Checkbox")
    local text = UI:Text(tab.label)
    local cb = D4:CreateCheckButton(name, win.content)
    cb:SetSize(UI.ROW, UI.ROW)
    cb:SetHitRectInsets(0, 0, 0, 0)
    cb:SetChecked(tab.value == true or tab.value == 1)
    cb.Label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.Label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.Label:SetText(text)
    cb:SetScript(
        "OnClick",
        function(sel)
            local value = false
            if sel:GetChecked() then value = true end
            if tab.func then tab.func(value) end
        end
    )

    UI:Add(win, cb, UI.ROW, text)

    return cb
end
