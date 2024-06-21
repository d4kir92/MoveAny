local _, D4 = ...
local icon = null
function D4:GetLibDBIcon()
    if not D4:IsOldWow() then
        icon = icon or LibStub("LibDBIcon-1.0", true)
    end

    return icon
end

function D4:CreateMinimapButton(tab)
    if not D4:IsOldWow() then
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
end

function D4:ShowMMBtn(name)
    if not D4:IsOldWow() then
        D4:GetLibDBIcon():Show(name)
    end
end

function D4:HideMMBtn(name)
    if not D4:IsOldWow() then
        D4:GetLibDBIcon():Hide(name)
    end
end
