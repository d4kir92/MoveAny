local _, D4 = ...
local DEFAULT_ART_WIDTH = 1024
local DEFAULT_ART_HEIGHT = 1024
local UPDATE_INTERVAL = 0.05
local OVERLAY_LEVEL = 3000
local LEVEL_BUTTON_WIDTH = 260
local LEVEL_BUTTON_HEIGHT = 22
local LEVEL_BUTTON_OFFSET = 8
local LEVEL_STEPPER_PAD = 70
local NAV_BUTTON_EXTRA = 53
local NAV_BUTTON_PLAIN = 30
local NAV_BUTTON_MIN_TEXT = 60
local PIN_TOGGLE_OFFSET_X = 40
local PIN_TOGGLE_OFFSET_Y = 10
local SIDE_PANEL_BUTTONS = {"OpenButton", "CloseButton"}
local function GetChild()
    if WorldMapFrame == nil or WorldMapFrame.ScrollContainer == nil then return nil end
    return WorldMapFrame.ScrollContainer.Child
end

local function GetPlayerMapID()
    if MapUtil ~= nil and MapUtil.GetDisplayableMapForPlayer ~= nil then return MapUtil.GetDisplayableMapForPlayer() end
    if C_Map ~= nil and C_Map.GetBestMapForUnit ~= nil then return C_Map.GetBestMapForUnit("player") end
    return nil
end

local function GetNavBar()
    if WorldMapFrame == nil then return nil end
    local navBar = WorldMapFrame.NavBar
    if navBar == nil or type(navBar.navList) ~= "table" then return nil end
    if not D4:CheckTemplates("NavButtonTemplate") then return nil end
    return navBar
end

function D4:CreateInstanceMap(provider)
    local map = {}
    local overlay = nil
    local levelButton = nil
    local hiddenFor = nil
    local forced = nil
    local forcedMapID = nil
    local forcedIndex = 1
    local selected = {}
    local shownLevels = nil
    local shownIndex = nil
    local shownInstance = nil
    local lastKey = nil
    local mapPinSet = nil
    local mapPinKey = nil
    local cache = {}
    local Refresh = nil
    local function GetLevels(instanceMapID)
        if instanceMapID == nil then return nil end
        if cache[instanceMapID] == nil then cache[instanceMapID] = provider.getLevels(instanceMapID) or false end
        return cache[instanceMapID] or nil
    end

    local function GetInstanceArt()
        if provider.isDisabled ~= nil and provider.isDisabled() then return nil end
        local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
        return GetLevels(instanceMapID), instanceMapID
    end

    local function GetLabel(levels, level)
        return provider.getLabel(levels, level) or ""
    end

    local function ClearForced()
        forced = nil
        forcedMapID = nil
        forcedIndex = 1
    end

    local function SelectLevel(index)
        if forced ~= nil then
            forcedIndex = index
        elseif shownInstance ~= nil then
            selected[shownInstance] = index
        end

        Refresh()
    end

    local function StepLevel(delta)
        if shownLevels == nil or shownIndex == nil then return end
        local index = shownIndex + delta
        if index < 1 or index > #shownLevels then return end
        SelectLevel(index)
    end

    local function SetupLevelMenu(dropdown)
        if dropdown == nil or dropdown.SetupMenu == nil then return end
        dropdown:SetupMenu(function(_, root)
            local levels = shownLevels
            if levels == nil then return end
            for i, level in ipairs(levels) do
                root:CreateRadio(GetLabel(levels, level), function() return shownIndex == i end, function() SelectLevel(i) end)
            end
        end)
    end

    local function OpenLevelMenu(owner)
        local levels = shownLevels
        if levels == nil then return end
        local entries = {}
        for i, level in ipairs(levels) do
            tinsert(entries, {
                ["text"] = GetLabel(levels, level),
                ["checked"] = function() return shownIndex == i end,
                ["func"] = function() SelectLevel(i) end,
            })
        end

        D4:ShowContextMenu(owner, entries)
    end

    local function CreateStepperControl(container)
        local control = CreateFrame("Frame", nil, container, "SettingsDropdownWithButtonsTemplate")
        control:SetWidth(LEVEL_BUTTON_WIDTH + LEVEL_STEPPER_PAD)
        if control.Dropdown then control.Dropdown:SetWidth(LEVEL_BUTTON_WIDTH) end
        local steppers = D4:SetupDropdownSteppers(control, function() StepLevel(-1) end, function() StepLevel(1) end, true)
        local function UpdateSteppers()
            local count = shownLevels and #shownLevels or 0
            local index = shownIndex or 1
            steppers:SetEnabled(index > 1, index < count)
        end

        SetupLevelMenu(control.Dropdown)
        function control:SetLabel(text)
            D4:SetDropdownText(self.Dropdown, text)
            UpdateSteppers()
            if C_Timer then C_Timer.After(0, UpdateSteppers) end
        end

        control:HookScript("OnShow", UpdateSteppers)
        return control
    end

    local function CreateNavButton(navBar)
        local button = CreateFrame("Button", nil, navBar, "NavButtonTemplate")
        button.listFunc = function() return nil end
        local arrow = button.MenuArrowButton
        button:RegisterForClicks("LeftButtonUp")
        button:SetScript("OnClick", function(sel)
            if arrow ~= nil and arrow.OpenMenu ~= nil then
                arrow:OpenMenu()
            else
                OpenLevelMenu(sel)
            end
        end)

        if NavBar_ButtonOnEnter ~= nil then button:SetScript("OnEnter", NavBar_ButtonOnEnter) end
        if NavBar_ButtonOnLeave ~= nil then button:SetScript("OnLeave", NavBar_ButtonOnLeave) end
        button:HookScript("OnShow", function() SetupLevelMenu(arrow) end)
        SetupLevelMenu(arrow)
        if button.selected ~= nil then button.selected:Show() end
        function button:Reanchor()
            local list = navBar.navList
            local last = list[#list]
            if last == nil then return end
            local hasMenu = shownLevels ~= nil and #shownLevels > 1
            local extra = hasMenu and NAV_BUTTON_EXTRA or NAV_BUTTON_PLAIN
            if arrow ~= nil then arrow:SetShown(hasMenu) end
            if self:IsEnabled() ~= hasMenu then self:SetEnabled(hasMenu) end
            local space = (navBar:GetRight() or 0) - (last:GetRight() or 0) - extra
            local width = min(self.textWidth or 0, max(space, NAV_BUTTON_MIN_TEXT))
            self.text:SetWidth(width)
            self:SetWidth(width + extra)
            if self.anchor ~= last then
                self.anchor = last
                self:ClearAllPoints()
                self:SetPoint("LEFT", last, "RIGHT", 0, 0)
            end

            self:SetFrameLevel(max(navBar:GetFrameLevel(), last:GetFrameLevel() - 1))
        end

        function button:SetLabel(text)
            self.text:SetWidth(0)
            self:SetText(text)
            self.textWidth = self.text:GetStringWidth()
            self:Reanchor()
        end

        button:Hide()
        return button
    end

    local function ToggleOverlay()
        if overlay ~= nil and overlay:IsShown() and provider.getReturnMapID ~= nil then
            local info = shownLevels ~= nil and shownLevels[shownIndex] or nil
            local mapID = provider.getReturnMapID(info)
            if mapID ~= nil and WorldMapFrame.SetMapID ~= nil then
                hiddenFor = shownInstance
                ClearForced()
                overlay:Hide()
                levelButton:Hide()
                if mapPinSet ~= nil then mapPinSet:Hide() end
                WorldMapFrame:SetMapID(mapID)
                Refresh()
                return
            end
        end

        if forced ~= nil then
            ClearForced()
            Refresh()
            return
        end

        local levels, instanceMapID = GetInstanceArt()
        if levels == nil then return end
        if hiddenFor == instanceMapID then
            hiddenFor = nil
        else
            hiddenFor = instanceMapID
        end

        Refresh()
    end

    local function OnCanvasMouseUp(_, button)
        if button ~= "RightButton" then return end
        ToggleOverlay()
    end

    local function FindLevelIndex(levels, key)
        for index, level in ipairs(levels or {}) do
            if level.key == key then return index end
        end

        return nil
    end

    local function OnMapPinEnter(pin)
        local row = pin.row
        if row == nil then return end
        GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
        if row[1] == "boss" then
            GameTooltip:SetText(provider.getBossName and provider.getBossName(row) or row[5] or "")
            if row[6] then GameTooltip:AddLine(format("%s %d", LEVEL or "Level", row[6]), 1, 1, 1) end
            local hint = provider.getBossHint and provider.getBossHint(row)
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        elseif row[1] == "item" then
            if GameTooltip.SetItemByID ~= nil then
                GameTooltip:SetItemByID(row[4])
            else
                GameTooltip:SetHyperlink("item:" .. row[4])
            end
        elseif row[1] == "level" then
            GameTooltip:SetText(GetLabel(shownLevels, shownLevels[pin.level]))
            local hint = provider.getLevelHint and provider.getLevelHint()
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        else
            GameTooltip:SetText(provider.getEntranceText and provider.getEntranceText(row) or "")
            local hint = provider.getEntranceHint and provider.getEntranceHint(row)
            if hint then GameTooltip:AddLine(hint, 0.6, 0.6, 0.6) end
        end

        GameTooltip:Show()
    end

    local function OnMapPinLeave(pin)
        if GameTooltip:IsOwned(pin) then GameTooltip:Hide() end
    end

    local function OnMapPinMouseUp(pin, button)
        if not pin:IsMouseOver() then return end
        if button == "RightButton" then
            ToggleOverlay()
            return
        end

        local row = pin.row
        if button ~= "LeftButton" or row == nil then return end
        if row[1] == "level" then
            OnMapPinLeave(pin)
            SelectLevel(pin.level)
        elseif row[1] == "boss" and provider.onBossClick ~= nil then
            local info = shownLevels ~= nil and shownLevels[shownIndex] or nil
            if info == nil then return end
            OnMapPinLeave(pin)
            provider.onBossClick(info, row)
        end
    end

    local function HideMapPins()
        if mapPinKey == nil then return end
        mapPinKey = nil
        if mapPinSet ~= nil then mapPinSet:Hide() end
    end

    local function UpdateMapPins(info)
        local scale = GetChild():GetScale()
        local rows = provider.getPins and provider.getPins(info) or nil
        if rows == nil or scale == nil or scale <= 0 then
            HideMapPins()
            return
        end

        local key = format("%s|%.4f|%.1f|%.1f|%d", info.key, scale, overlay.art:GetWidth(), overlay.art:GetHeight(), #rows)
        if key == mapPinKey then return end
        mapPinKey = key
        if mapPinSet == nil then
            mapPinSet = D4:CreateInstancePins(overlay, {
                ["media"] = provider.media,
                ["onEnter"] = OnMapPinEnter,
                ["onLeave"] = OnMapPinLeave,
                ["onMouseUp"] = OnMapPinMouseUp,
                ["getLevel"] = function(row) return FindLevelIndex(shownLevels, row[4]) end,
                ["isEnabled"] = provider.isPinEnabled,
                ["setEnabled"] = function(kind, enabled)
                    if provider.setPinEnabled then provider.setPinEnabled(kind, enabled) end
                    mapPinKey = nil
                    Refresh()
                end,
                ["getToggleText"] = provider.getToggleText,
            })

            local container = WorldMapFrame.ScrollContainer
            local toggles = mapPinSet:CreateToggles(container)
            toggles:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -PIN_TOGGLE_OFFSET_X, PIN_TOGGLE_OFFSET_Y)
            toggles:SetFrameLevel(overlay:GetFrameLevel() + 1000)
        end

        mapPinSet:Update(rows, overlay.art, scale)
        mapPinSet:UpdateToggles()
        mapPinSet.toggles:Show()
    end

    local function CreateOverlay()
        if overlay ~= nil then return overlay end
        local child = GetChild()
        if child == nil then return nil end
        overlay = CreateFrame("FRAME", nil, child)
        overlay:SetFrameLevel(child:GetFrameLevel() + OVERLAY_LEVEL)
        overlay:EnableMouse(true)
        overlay:SetScript("OnMouseUp", OnCanvasMouseUp)
        overlay:SetAllPoints(child)
        overlay.bg = overlay:CreateTexture(nil, "BACKGROUND")
        overlay.bg:SetAllPoints(overlay)
        overlay.bg:SetColorTexture(0, 0, 0, 1)
        overlay.art = overlay:CreateTexture(nil, "ARTWORK")
        overlay.art:SetPoint("CENTER", overlay, "CENTER", 0, 0)
        overlay:Hide()
        local container = WorldMapFrame.ScrollContainer
        local navBar = GetNavBar()
        if navBar ~= nil then
            levelButton = CreateNavButton(navBar)
        elseif D4:CheckTemplates("SettingsDropdownWithButtonsTemplate") then
            levelButton = CreateStepperControl(container)
        else
            levelButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
            levelButton:SetSize(LEVEL_BUTTON_WIDTH, LEVEL_BUTTON_HEIGHT)
            levelButton:SetScript("OnClick", OpenLevelMenu)
            levelButton.SetLabel = levelButton.SetText
        end

        if navBar == nil then
            levelButton:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", LEVEL_BUTTON_OFFSET, LEVEL_BUTTON_OFFSET)
            levelButton:SetFrameLevel(overlay:GetFrameLevel() + 1000)
        end

        levelButton:Hide()
        container:HookScript("OnMouseUp", OnCanvasMouseUp)
        WorldMapFrame:HookScript("OnShow", function()
            hiddenFor = nil
            ClearForced()
        end)

        return overlay
    end

    local function Layout(info)
        local child = GetChild()
        if child == nil then return end
        local w = child:GetWidth()
        local h = child:GetHeight()
        if w == nil or h == nil or w <= 0 or h <= 0 then return end
        local ratio = (info.height or DEFAULT_ART_HEIGHT) / (info.width or DEFAULT_ART_WIDTH)
        local width = w
        local height = w * ratio
        if height > h then
            height = h
            width = h / ratio
        end

        local zoom = info.zoom or 1
        overlay.art:SetSize(width * zoom, height * zoom)
    end

    local function GetVisibleLevels()
        if WorldMapFrame == nil or WorldMapFrame.GetMapID == nil then return nil end
        if forced ~= nil then
            if WorldMapFrame:GetMapID() == forcedMapID then return forced, forcedIndex, nil end
            ClearForced()
        end

        local levels, instanceMapID = GetInstanceArt()
        if levels == nil then return nil end
        if hiddenFor == instanceMapID then return nil end
        local playerMapID = GetPlayerMapID()
        if playerMapID ~= nil and WorldMapFrame:GetMapID() ~= playerMapID then return nil end
        return levels, selected[instanceMapID] or 1, instanceMapID
    end

    Refresh = function()
        local levels, index, instanceMapID = GetVisibleLevels()
        if levels == nil then
            lastKey = nil
            shownLevels = nil
            shownIndex = nil
            shownInstance = nil
            HideMapPins()
            if overlay ~= nil then
                overlay:Hide()
                levelButton:Hide()
            end

            return
        end

        if CreateOverlay() == nil then return end
        if levels[index] == nil then index = 1 end
        local info = levels[index]
        shownLevels = levels
        shownIndex = index
        shownInstance = instanceMapID
        local child = GetChild()
        local key = format("%s|%.1f|%.1f", info.file, child:GetWidth() or 0, child:GetHeight() or 0)
        if key ~= lastKey then
            lastKey = key
            overlay.art:SetTexture(info.file)
            local width = info.width or DEFAULT_ART_WIDTH
            local height = info.height or DEFAULT_ART_HEIGHT
            overlay.art:SetTexCoord(0, width / (info.fileWidth or width), 0, height / (info.fileHeight or height))
            Layout(info)
            levelButton:SetLabel(GetLabel(levels, info))
        end

        UpdateMapPins(info)
        if levelButton.Reanchor ~= nil then
            levelButton:Reanchor()
            if not levelButton:IsShown() then levelButton:Show() end
        elseif #levels > 1 then
            if not levelButton:IsShown() then levelButton:Show() end
        elseif levelButton:IsShown() then
            levelButton:Hide()
        end

        local toggle = WorldMapFrame.SidePanelToggle
        if toggle ~= nil and toggle.SetFrameLevel ~= nil then
            local level = overlay:GetFrameLevel() + 2001
            if toggle:GetFrameLevel() < level then toggle:SetFrameLevel(level) end
            for _, name in ipairs(SIDE_PANEL_BUTTONS) do
                local button = toggle[name]
                if button ~= nil and button.SetFrameLevel ~= nil and button:GetFrameLevel() <= level then button:SetFrameLevel(level + 1) end
            end
        end

        if not overlay:IsShown() then overlay:Show() end
    end

    function map:Show(instances, level)
        if instances == nil then return false end
        if type(instances) ~= "table" then instances = {instances} end
        local levels = {}
        for _, instanceMapID in ipairs(instances) do
            for _, info in ipairs(GetLevels(instanceMapID) or {}) do
                tinsert(levels, info)
            end
        end

        if #levels == 0 then return false end
        if WorldMapFrame == nil or WorldMapFrame.GetMapID == nil then return false end
        if WorldMapFrame:IsShown() ~= true then return false end
        forced = levels
        forcedMapID = WorldMapFrame:GetMapID()
        forcedIndex = level or 1
        hiddenFor = nil
        lastKey = nil
        Refresh()
        return true
    end

    function map:IsShown()
        return overlay ~= nil and overlay:IsShown()
    end

    function map:HasArt()
        return forced ~= nil or GetInstanceArt() ~= nil
    end

    function map:Toggle()
        if not map:HasArt() then return false end
        ToggleOverlay()
        return true
    end

    function map:Invalidate()
        mapPinKey = nil
        lastKey = nil
        if overlay ~= nil and overlay:IsShown() then Refresh() end
    end

    if WorldMapFrame ~= nil then
        local updater = CreateFrame("FRAME", nil, WorldMapFrame)
        updater.elapsed = 0
        updater:SetScript("OnUpdate", function(sel, elapsed)
            sel.elapsed = sel.elapsed + elapsed
            if sel.elapsed < UPDATE_INTERVAL then return end
            sel.elapsed = 0
            Refresh()
        end)
    end

    return map
end
