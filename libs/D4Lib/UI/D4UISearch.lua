local _, D4 = ...
local UI = D4.UI

function UI.WindowMixin:AddSearch(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Search")
    local header = win.header or win:AddHeader({["height"] = UI.ROW})
    local box = CreateFrame("EditBox", name, header, "InputBoxTemplate")
    box:SetPoint("LEFT", header, "LEFT", 6 + (tab.leftInset or 0), 0)
    box:SetPoint("RIGHT", header, "RIGHT", -(tab.rightInset or 0), 0)
    box:SetHeight(UI.ROW)
    box:SetAutoFocus(false)
    box:SetMaxLetters(tab.maxLetters or 50)
    box.Hint = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    box.Hint:SetPoint("LEFT", box, "LEFT", 4, 0)
    box.Hint:SetText(UI:Text(tab.label or "LID_SEARCH"))
    box:SetScript(
        "OnTextChanged",
        function(sel)
            local text = sel:GetText()
            if text == "" then
                box.Hint:Show()
            else
                box.Hint:Hide()
            end

            win:Filter(text)
        end
    )

    box:SetScript(
        "OnEscapePressed",
        function(sel)
            sel:SetText("")
            sel:ClearFocus()
        end
    )

    box:SetScript("OnEnterPressed", function(sel) sel:ClearFocus() end)
    win.search = box

    return box
end
