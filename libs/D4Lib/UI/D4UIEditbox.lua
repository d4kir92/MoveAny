local _, D4 = ...
local UI = D4.UI
local HEIGHT = 46
local BOXHEIGHT = 22

function UI.WindowMixin:AddEditbox(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Editbox")
    local text = UI:Text(tab.label)
    local holder = CreateFrame("Frame", name, win.content)
    holder:SetSize(math.max(1, win.contentWidth - 8), HEIGHT)
    holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.Label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    holder.Label:SetJustifyH("LEFT")
    holder.Label:SetText(text)
    local box = CreateFrame("EditBox", name .. "Box", holder, "InputBoxTemplate")
    box:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 6, 0)
    box:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -6, 0)
    box:SetHeight(BOXHEIGHT)
    box:SetAutoFocus(false)
    box:SetMaxLetters(tab.maxLetters or 0)
    if tab.numeric then box:SetNumeric(true) end
    box.value = tab.value or ""
    box:SetText(box.value)
    box:SetScript(
        "OnTextChanged",
        function(sel)
            local value = sel:GetText()
            if value == sel.value then return end
            sel.value = value
            holder.value = value
            if tab.func then tab.func(value, sel) end
        end
    )

    box:SetScript(
        "OnEscapePressed",
        function(sel)
            sel:SetText(sel.value or "")
            sel:ClearFocus()
        end
    )

    box:SetScript("OnEnterPressed", function(sel) sel:ClearFocus() end)
    holder.value = box.value
    holder.control = box
    function holder:SetValue(value)
        value = value or ""
        box.value = value
        holder.value = value
        box:SetText(value)
    end

    UI:Add(win, holder, HEIGHT, text, true, tab.search)

    return holder
end
