local _, D4 = ...
local MAX_FRAME_LEVEL = 10000
local FADE_DEFAULT = 50
local FADE_SPEED = 8
local FADE_SNAP = 0.01
local HOVER_MOVE = 2
local STRATA = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}
local STRATA_INDEX = {}
for i, strata in ipairs(STRATA) do
    STRATA_INDEX[strata] = i
end

local function GetStrataIndex(region, index, skip)
    if region == skip then return index end
    index = max(index, STRATA_INDEX[region:GetFrameStrata()] or 1)
    for _, child in ipairs({region:GetChildren()}) do
        index = GetStrataIndex(child, index, skip)
    end

    return index
end

function D4:CreateSizeGrip(parent, size)
    local sizeGrip = CreateFrame("Button", nil, parent)
    sizeGrip:SetSize(size, size)
    sizeGrip:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
    sizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    sizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    sizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    sizeGrip:Hide()

    return sizeGrip
end

function D4:RaiseSizeGrip(sizeGrip, root)
    local index = GetStrataIndex(root, 1, sizeGrip)
    sizeGrip:SetFrameStrata(STRATA[min(index + 1, #STRATA)])
    sizeGrip:SetFrameLevel(MAX_FRAME_LEVEL)
end

local function IsMoving()
    if IsPlayerMoving ~= nil then return IsPlayerMoving() end

    return (GetUnitSpeed("player") or 0) > 0
end

local function IsMouseLook()
    return IsMouseLooking ~= nil and IsMouseLooking() == true
end

function D4:CreateMoveFader(target, options)
    local fader = {}
    local fadeAlpha = 1
    local baseAlpha = 1
    local settingAlpha = false
    local hoverArmed = true
    local openX = nil
    local openY = nil
    local function Enabled()
        return options.isEnabled ~= nil and options.isEnabled() == true
    end

    local function IsBusy()
        return options.isBusy ~= nil and options.isBusy() == true
    end

    local function IsHovered()
        if IsMouseLook() then
            openX = nil

            return false
        end

        if not hoverArmed then
            local x, y = GetCursorPosition()
            if openX == nil then
                openX, openY = x, y
            end

            if math.abs(x - openX) + math.abs(y - openY) <= HOVER_MOVE then return false end
            hoverArmed = true
        end

        return target:IsMouseOver()
    end

    local function GetTarget()
        if not Enabled() or not IsMoving() or IsBusy() or IsHovered() then return 1 end
        local percent = options.getOpacity ~= nil and tonumber(options.getOpacity()) or FADE_DEFAULT

        return max(0, min(percent, 100)) / 100
    end

    local function SetAlpha()
        settingAlpha = true
        target:SetAlpha(baseAlpha * fadeAlpha)
        settingAlpha = false
    end

    local function OnUpdate(_, elapsed)
        local wanted = GetTarget()
        if wanted ~= fadeAlpha then
            local alpha = fadeAlpha + (wanted - fadeAlpha) * min(1, elapsed * FADE_SPEED)
            if math.abs(wanted - alpha) < FADE_SNAP then alpha = wanted end
            fadeAlpha = alpha
            SetAlpha()
        elseif (Enabled() or fadeAlpha < 1) and math.abs(target:GetAlpha() - baseAlpha * fadeAlpha) > FADE_SNAP then
            SetAlpha()
        end
    end

    function fader:Reset()
        local faded = fadeAlpha < 1
        fadeAlpha = GetTarget()
        if Enabled() or faded then SetAlpha() end
    end

    function fader:OnShow()
        openX = nil
        hoverArmed = false
        self:Reset()
    end

    function fader:Debug(name)
        D4:INFO(format("%s fade enabled=%s moving=%s mouseOver=%s mouseLook=%s armed=%s busy=%s", name, tostring(Enabled()), tostring(IsMoving()), tostring(target:IsMouseOver()), tostring(IsMouseLook()), tostring(hoverArmed), tostring(IsBusy())))
        D4:INFO(format("%s fade target=%.2f fade=%.2f base=%.2f alpha=%.2f", name, GetTarget(), fadeAlpha, baseAlpha, target:GetAlpha()))
    end

    if options.hookSetAlpha then
        hooksecurefunc(target, "SetAlpha", function()
            if settingAlpha then return end
            if PlayerMovementFrameFader == nil then baseAlpha = target:GetAlpha() end
            if Enabled() or fadeAlpha < 1 then SetAlpha() end
        end)
    end

    target:HookScript("OnShow", function() fader:OnShow() end)
    local driver = CreateFrame("FRAME", nil, target)
    driver:SetScript("OnUpdate", OnUpdate)

    return fader
end
