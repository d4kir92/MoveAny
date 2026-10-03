local AddonName, D4 = ...
local fallbackMenu = nil
local function IsChecked(entry)
    if type(entry.checked) == "function" then return entry.checked() == true end

    return entry.checked == true
end

function D4:ShowContextMenu(owner, entries, anchor)
    if entries == nil or #entries == 0 then return false end
    if MenuUtil ~= nil and MenuUtil.CreateContextMenu ~= nil then
        MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
            for _, entry in ipairs(entries) do
                if entry.checked ~= nil then
                    rootDescription:CreateRadio(entry.text, function() return IsChecked(entry) end, entry.func)
                else
                    rootDescription:CreateButton(entry.text, entry.func)
                end
            end
        end)

        return true
    end

    if UIDropDownMenu_Initialize == nil or ToggleDropDownMenu == nil then return false end
    if fallbackMenu == nil then fallbackMenu = CreateFrame("Frame", AddonName .. "D4ContextMenu", UIParent, "UIDropDownMenuTemplate") end
    UIDropDownMenu_Initialize(fallbackMenu, function()
        for _, entry in ipairs(entries) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = entry.text
            info.func = entry.func
            if entry.checked ~= nil then
                info.checked = IsChecked(entry)
            else
                info.notCheckable = true
            end

            UIDropDownMenu_AddButton(info)
        end
    end, "MENU")

    ToggleDropDownMenu(1, nil, fallbackMenu, anchor or owner, 0, 0)

    return true
end

function D4:SetDropdownText(dropdown, text)
    if dropdown == nil then return end
    if dropdown.SetDefaultText then dropdown:SetDefaultText(text) end
    if dropdown.Update then dropdown:Update() end
    if dropdown.SetText then dropdown:SetText(text) end
end

function D4:SetupDropdownSteppers(control, onPrevious, onNext, lock, dropdown)
    dropdown = dropdown or control.Dropdown
    local previous = control.DecrementButton
    local following = control.IncrementButton
    if previous == nil or following == nil then
        local found = {}
        for _, child in ipairs({control:GetChildren()}) do
            if child ~= dropdown and child.SetEnabled and child.GetObjectType and child:GetObjectType() == "Button" then tinsert(found, child) end
        end

        table.sort(found, function(a, b) return (a:GetLeft() or 0) < (b:GetLeft() or 0) end)
        previous = previous or found[1]
        following = following or found[2]
    end

    local setEnabled = {}
    local function Prepare(button, onClick)
        if button == nil then return end
        setEnabled[button] = button.SetEnabled
        if lock then
            local nop = function() end
            button.SetEnabled = nop
            button.Enable = nop
            button.Disable = nop
        end

        if onClick then button:SetScript("OnClick", function() onClick() end) end
    end

    Prepare(previous, onPrevious)
    Prepare(following, onNext)
    local steppers = {
        ["previous"] = previous,
        ["following"] = following,
    }

    function steppers:SetEnabled(previousEnabled, followingEnabled)
        if previous then setEnabled[previous](previous, previousEnabled == true) end
        if following then setEnabled[following](following, followingEnabled == true) end
    end

    return steppers
end
