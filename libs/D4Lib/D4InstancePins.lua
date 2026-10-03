local _, D4 = ...
local PIN_SIZE = 26
local BOSS_PIN_SIZE = 34
local PIN_RING_SCALE = 1.55
local PIN_RING_TEXTURE = "Interface\\Minimap\\MiniMap-TrackingBorder"
local PIN_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local BOSS_PORTRAIT_FALLBACK = "Interface\\Icons\\INV_Misc_QuestionMark"
local ITEM_ICON_FALLBACK = 134400
local LEVEL_SKULL_MIN = 63
local PIN_ICONS = {
    ["entrance"] = {{"Dungeon", "DungeonSkull", "Dungeon-Normal"}, "Interface\\Icons\\INV_Misc_Bone_Skull_02"},
    ["raid"] = {{"Raid", "Dungeon", "DungeonSkull", "Dungeon-Normal"}, "Interface\\Icons\\INV_Misc_Bone_Skull_02"},
    ["down"] = {{"CaveUnderground-Down", "CaveUnderground-Up"}, "Interface\\Icons\\INV_Misc_Map_01"},
    ["up"] = {{"CaveUnderground-Up", "CaveUnderground-Down"}, "Interface\\Icons\\INV_Misc_Map_01"},
}

local BADGE_STYLES = {
    [0] = {
        ["ring"] = {0.55, 0.5, 0.4},
    },
    [1] = {
        ["ring"] = {0.95, 0.75, 0.25},
        ["dragon"] = "BossDragon-Elite",
    },
    [2] = {
        ["ring"] = {0.85, 0.87, 0.95},
        ["dragon"] = "BossDragon-Rare-Elite",
    },
    [3] = {
        ["ring"] = {0.95, 0.75, 0.25},
        ["dragon"] = "BossDragon-Elite",
    },
    [4] = {
        ["ring"] = {0.85, 0.87, 0.95},
        ["dragon"] = "BossDragon-Rare",
    },
}

local function ApplyIcon(texture, def)
    if def.resolved == nil then def.resolved = D4:FindAtlas(def[1]) or def[2] end
    D4:SetIconTexture(texture, def.resolved)
end

local function GetItemTexture(itemID)
    if C_Item ~= nil and C_Item.GetItemIconByID ~= nil then return C_Item.GetItemIconByID(itemID) or ITEM_ICON_FALLBACK end
    if GetItemIcon ~= nil then return GetItemIcon(itemID) or ITEM_ICON_FALLBACK end

    return ITEM_ICON_FALLBACK
end

local function AddMask(owner, texture)
    if owner.CreateMaskTexture == nil or texture.AddMaskTexture == nil then return end
    local mask = owner:CreateMaskTexture()
    mask:SetAllPoints(texture)
    mask:SetTexture(PIN_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    texture:AddMaskTexture(mask)
end

local function CreatePin(parent, options)
    local pin = CreateFrame("Button", nil, parent)
    pin.icon = pin:CreateTexture(nil, "ARTWORK")
    pin.icon:SetAllPoints(pin)
    pin.highlight = pin:CreateTexture(nil, "HIGHLIGHT")
    pin.highlight:SetAllPoints(pin)
    pin.highlight:SetBlendMode("ADD")
    pin.highlight:SetAlpha(0.5)
    pin.portrait = pin:CreateTexture(nil, "ARTWORK")
    pin.portrait:SetPoint("TOPLEFT", pin, "TOPLEFT", 2, -2)
    pin.portrait:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", -2, 2)
    pin.ring = pin:CreateTexture(nil, "OVERLAY", nil, 1)
    pin.ring:SetTexture(PIN_RING_TEXTURE)
    pin.ring:SetTexCoord(0, 0.6, 0, 0.6)
    pin.ring:SetPoint("CENTER", pin.portrait, "CENTER", 0, 0)
    local scale = (BOSS_PIN_SIZE - 4) / 64
    local badgeSize = 16 * (BOSS_PIN_SIZE - 4) / 34
    pin.dragon = pin:CreateTexture(nil, "OVERLAY", nil, 2)
    pin.dragon:SetSize(256 * scale, 128 * scale)
    pin.dragon:SetPoint("CENTER", pin, "CENTER", -54 * scale, -20 * scale)
    pin.badge = CreateFrame("Frame", nil, pin)
    pin.badge:SetSize(badgeSize, badgeSize)
    pin.badge:SetPoint("CENTER", pin, "CENTER", 19.5 * scale, -22 * scale)
    pin.badgeRing = pin.badge:CreateTexture(nil, "BORDER")
    pin.badgeRing:SetAllPoints(pin.badge)
    pin.badgeFill = pin.badge:CreateTexture(nil, "ARTWORK")
    pin.badgeFill:SetPoint("TOPLEFT", pin.badge, "TOPLEFT", 1.5, -1.5)
    pin.badgeFill:SetPoint("BOTTOMRIGHT", pin.badge, "BOTTOMRIGHT", -1.5, 1.5)
    pin.badgeFill:SetColorTexture(0.05, 0.04, 0.03, 0.95)
    pin.badgeText = pin.badge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pin.badgeText:SetPoint("CENTER", pin.badge, "CENTER", 0.5, 0)
    local fontFile, _, fontFlags = pin.badgeText:GetFont()
    if fontFile then pin.badgeText:SetFont(fontFile, 8, fontFlags) end
    pin.badgeSkull = pin.badge:CreateTexture(nil, "OVERLAY")
    pin.badgeSkull:SetSize(badgeSize - 5, badgeSize - 5)
    pin.badgeSkull:SetPoint("CENTER", pin.badge, "CENTER", 0, 0)
    pin.badgeSkull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    AddMask(pin, pin.portrait)
    AddMask(pin.badge, pin.badgeRing)
    AddMask(pin.badge, pin.badgeFill)
    if options.onEnter then pin:SetScript("OnEnter", options.onEnter) end
    if options.onLeave then pin:SetScript("OnLeave", options.onLeave) end
    if options.onMouseUp then pin:SetScript("OnMouseUp", options.onMouseUp) end

    return pin
end

local function StylePin(pin, row, media)
    local isBoss = row[1] == "boss"
    local isItem = row[1] == "item"
    local size = isBoss and BOSS_PIN_SIZE or PIN_SIZE
    pin:SetSize(size, size)
    pin.portrait:SetShown(isBoss or isItem)
    pin.icon:SetShown(not isBoss and not isItem)
    pin.ring:SetSize((size - 4) * PIN_RING_SCALE, (size - 4) * PIN_RING_SCALE)
    pin.ring:SetShown(isBoss or isItem)
    pin.dragon:Hide()
    pin.badge:Hide()
    pin.highlight:SetTexture(nil)
    if isBoss then
        pcall(pin.portrait.SetTexCoord, pin.portrait, 0, 1, 0, 1)
        if not row[7] or SetPortraitTextureFromCreatureDisplayID == nil or not pcall(SetPortraitTextureFromCreatureDisplayID, pin.portrait, row[7]) then pin.portrait:SetTexture(BOSS_PORTRAIT_FALLBACK) end
        local style = BADGE_STYLES[row[8]] or BADGE_STYLES[0]
        if style.dragon and media then
            pin.dragon:SetTexture(media .. style.dragon)
            pin.dragon:Show()
        end

        local level = row[6] or nil
        local isSkull = row[8] == 3 or (level ~= nil and level >= LEVEL_SKULL_MIN)
        if level == nil and not isSkull then return end
        pin.badgeRing:SetColorTexture(style.ring[1], style.ring[2], style.ring[3], 1)
        pin.badgeText:SetShown(not isSkull)
        pin.badgeSkull:SetShown(isSkull)
        if not isSkull then
            pin.badgeText:SetText(level)
            pin.badgeText:SetTextColor(D4:GetLevelDifficultyColor(level))
        end

        pin.badge:Show()
    elseif isItem then
        pin.portrait:SetTexture(GetItemTexture(row[4]))
        pcall(pin.portrait.SetTexCoord, pin.portrait, 0.07, 0.93, 0.07, 0.93)
    else
        local def = row[1] == "entrance" and PIN_ICONS[row[4] == "raid" and "raid" or "entrance"] or row[5] and PIN_ICONS["up"] or PIN_ICONS["down"]
        ApplyIcon(pin.icon, def)
        ApplyIcon(pin.highlight, def)
    end
end

local TOGGLES = {{"boss", {{}, "Interface\\TargetingFrame\\UI-RaidTargetingIcons"}, {0.75, 1, 0.25, 0.5}}, {"item", {{}, "Interface\\Icons\\INV_Misc_Bag_10"}}, {"entrance", PIN_ICONS["entrance"]}, {"level", PIN_ICONS["up"]}}
local InstancePins = {}
InstancePins.__index = InstancePins
function InstancePins:IsKindEnabled(kind)
    return self.options.isEnabled == nil or self.options.isEnabled(kind) ~= false
end

function InstancePins:UpdateToggles()
    if self.toggles == nil then return end
    for _, button in ipairs(self.toggles.buttons) do
        local enabled = self:IsKindEnabled(button.kind)
        if enabled then
            button.ring:SetVertexColor(0.2, 1, 0.2)
        else
            button.ring:SetVertexColor(1, 0.2, 0.2)
        end

        button.icon:SetDesaturated(not enabled)
        button.icon:SetAlpha(enabled and 1 or 0.5)
    end
end

function InstancePins:CreateToggles(parent)
    if self.toggles ~= nil then return self.toggles end
    local set = self
    local options = self.options
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(#TOGGLES * 30 - 10, 20)
    bar.buttons = {}
    for index, def in ipairs(TOGGLES) do
        local button = CreateFrame("Button", nil, bar)
        button.kind = def[1]
        button:SetSize(20, 20)
        button:SetPoint("RIGHT", bar, "RIGHT", -(index - 1) * 30, 0)
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetAllPoints(button)
        button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
        button.highlight:SetAllPoints(button)
        ApplyIcon(button.icon, def[2])
        ApplyIcon(button.highlight, def[2])
        if def[3] then
            button.icon:SetTexCoord(unpack(def[3]))
            button.highlight:SetTexCoord(unpack(def[3]))
        end

        button.highlight:SetBlendMode("ADD")
        button.highlight:SetAlpha(0.4)
        button.ring = button:CreateTexture(nil, "OVERLAY", nil, 1)
        button.ring:SetTexture(PIN_RING_TEXTURE)
        button.ring:SetTexCoord(0, 0.6, 0, 0.6)
        button.ring:SetSize(20 * PIN_RING_SCALE, 20 * PIN_RING_SCALE)
        button.ring:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.ring:SetDesaturated(true)
        if button.CreateMaskTexture ~= nil and button.icon.AddMaskTexture ~= nil then
            local mask = button:CreateMaskTexture()
            mask:SetAllPoints(button)
            mask:SetTexture(PIN_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            button.icon:AddMaskTexture(mask)
            button.highlight:AddMaskTexture(mask)
        end

        local function ShowTooltip(sel)
            if options.getToggleText == nil then return end
            GameTooltip:SetOwner(sel, "ANCHOR_RIGHT")
            GameTooltip:SetText(options.getToggleText(sel.kind, set:IsKindEnabled(sel.kind)))
            GameTooltip:Show()
        end

        button:SetScript("OnClick", function(sel)
            if options.setEnabled == nil then return end
            options.setEnabled(sel.kind, not set:IsKindEnabled(sel.kind))
            set:UpdateToggles()
            if GameTooltip:IsOwned(sel) then ShowTooltip(sel) end
        end)

        button:SetScript("OnEnter", ShowTooltip)
        button:SetScript("OnLeave", function(sel) if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end end)
        bar.buttons[index] = button
    end

    self.toggles = bar
    self:UpdateToggles()

    return bar
end

function InstancePins:Update(rows, art, scale)
    scale = scale or 1
    local options = self.options
    local w = art:GetWidth()
    local h = art:GetHeight()
    local baseLevel = self.parent:GetFrameLevel()
    local count = 0
    for _, row in ipairs(rows or {}) do
        local level = nil
        if row[1] == "level" and options.getLevel then level = options.getLevel(row) end
        if self:IsKindEnabled(row[1]) and (row[1] ~= "level" or level ~= nil) then
            count = count + 1
            local pin = self.pins[count]
            if pin == nil then
                pin = CreatePin(self.parent, options)
                self.pins[count] = pin
            end

            local frameLevel = baseLevel + 2 + count * 3
            if row[1] == "boss" then frameLevel = frameLevel + #rows * 3 end
            pin:SetFrameLevel(frameLevel)
            pin.badge:SetFrameLevel(frameLevel + 2)
            pin.row = row
            pin.level = level
            pin:SetScale(1 / scale)
            StylePin(pin, row, options.media)
            pin:ClearAllPoints()
            pin:SetPoint("CENTER", art, "TOPLEFT", w * row[2] * scale, -h * row[3] * scale)
            pin:Show()
        end
    end

    for i = count + 1, #self.pins do
        self.pins[i]:Hide()
    end
end

function InstancePins:Hide()
    for _, pin in ipairs(self.pins) do
        pin:Hide()
    end

    if self.toggles ~= nil then self.toggles:Hide() end
end

function D4:CreateInstancePins(parent, options)
    local set = setmetatable({}, InstancePins)
    set.parent = parent
    set.options = options or {}
    set.pins = {}

    return set
end
