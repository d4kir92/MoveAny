local _, D4 = ...
local UI = D4.UI

function UI.WindowMixin:AddSearch(tab)
    tab = tab or {}
    local win = self
    local name = UI:NextName(win, "Search")
    local header = win.header or win:AddHeader({["height"] = 32})
    local box = CreateFrame("EditBox", name, header, "InputBoxTemplate")
    box:SetPoint("LEFT", header, "LEFT", 9 + (tab.leftInset or 0), 1)
    box:SetPoint("RIGHT", header, "RIGHT", -(3 + (tab.rightInset or 0)), 1)
    local height = tab.height or UI.ROW
    box:SetHeight(height)
    for _, region in pairs({box:GetRegions()}) do
        if region:IsObjectType("Texture") then region:SetHeight(height) end
    end
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
