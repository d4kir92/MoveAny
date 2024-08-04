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
                        tooltip:AddDoubleLine(v[1], v[2])
                    end
                end,
            }
        )

        if mmbtn and D4:GetLibDBIcon() then
            D4:GetLibDBIcon():Register(tab.name, mmbtn, tab.dbtab)
        end

        if AddonCompartmentFrame and (tab.addoncomp == nil or tab.addoncomp == true) then
            AddonCompartmentFrame:RegisterAddon(
                {
                    text = tab.name,
                    icon = tab.icon,
                    registerForAnyClick = true,
                    notCheckable = true,
                    func = function(button, menuInputData, menu)
                        local btnName = menuInputData.buttonName
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
                    funcOnEnter = function(button)
                        MenuUtil.ShowTooltip(
                            button,
                            function(tooltip)
                                if not tooltip or not tooltip.AddLine then return end
                                for i, v in pairs(tab.vTT) do
                                    tooltip:AddDoubleLine(v[1], v[2])
                                end
                            end
                        )
                    end,
                    funcOnLeave = function(button)
                        MenuUtil.HideTooltip(button)
                    end,
                }
            )
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
