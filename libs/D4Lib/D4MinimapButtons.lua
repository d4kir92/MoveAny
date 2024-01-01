local icon = LibStub("LibDBIcon-1.0", true)
function D4:GetLibDBIcon()
    return icon
end

function D4:CreateMinimapButton(tab)
    local mmbtn = LibStub("LibDataBroker-1.1"):NewDataObject(
        tab.name,
        {
            type = "data source",
            text = tab.name,
            icon = tab.icon,
            OnClick = function(sel, btnName)
                if btnName == "LeftButton" and IsShiftKeyDown() and tab.funcSL then
                    tab:funcSL()
                elseif btnName == "RightButton" and IsShiftKeyDown() and tab.funcSR then
                    tab:funcSR()
                elseif btnName == "LeftButton" and tab.funcL then
                    tab:funcL()
                elseif btnName == "RightButton" and tab.funcR then
                    tab:funcR()
                end
            end,
            OnTooltipShow = function(tooltip)
                if not tooltip or not tooltip.AddLine then return end
                for i, v in pairs(tab.vTT) do
                    tooltip:AddLine(v)
                end
            end,
        }
    )

    if mmbtn and D4:GetLibDBIcon() then
        D4:GetLibDBIcon():Register(tab.name, mmbtn, tab.dbtab)
    end
end

function D4:ShowMMBtn(name)
    D4:GetLibDBIcon():Show(name)
end

function D4:HideMMBtn(name)
    D4:GetLibDBIcon():Hide(name)
end