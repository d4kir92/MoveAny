local _, MoveAny = ...
local dufloaded = false
local MAAF = {}
local MAAFS = {}
local alphasReady = false
local isresting = nil
local ismounted = nil
local isskyriding = nil
local invehicle = nil
local incombat = nil
local inpetbattle = nil
local isstealthed = nil
local lastEle = nil
local fullHP = false
local enumAlpha = {}
enumAlpha.INIT = "INIT"
enumAlpha.ADDED = "ADDED"
enumAlpha.COMBAT = "COMBAT"
enumAlpha.RESTING = "RESTING"
enumAlpha.FULLHEALTH = "FULLHEALTH"
enumAlpha.AURA = "AURA"
enumAlpha.VEHICLE = "VEHICLE"
enumAlpha.PETBATTLE = "PETBATTLE"
enumAlpha.OLD = "OLD"
function MoveAny:GetEnumAlpha()
    return enumAlpha
end

function MoveAny:GetAlphaFrames()
    return MAAF
end

function MoveAny:AddAlphaFrame(frame)
    tinsert(MAAF, frame)
    MAAFS[frame] = true
    frame:HookScript(
        "OnEnter",
        function()
            if not alphasReady then return end
            frame:SetAlpha(1)
            MoveAny:SetMouseEleAlpha(frame, frame)
        end
    )

    frame:HookScript(
        "OnLeave",
        function()
            if not alphasReady then return end
            local prev = lastEle
            lastEle = nil
            if prev then
                MoveAny:UpdateAlpha(prev, nil)
            end
        end
    )
end

function MoveAny:RegisterChildAlphaFrame(child, parentAlphaFrame)
    if not child or not parentAlphaFrame then return end
    if child.ma_alpha_hooked then return end
    child.ma_alpha_hooked = true
    child:HookScript(
        "OnEnter",
        function()
            if not alphasReady then return end
            parentAlphaFrame:SetAlpha(1)
            MoveAny:SetMouseEleAlpha(parentAlphaFrame, parentAlphaFrame)
        end
    )

    child:HookScript(
        "OnLeave",
        function()
            if not alphasReady then return end
            local prev = lastEle
            lastEle = nil
            if prev then
                MoveAny:UpdateAlpha(prev, nil)
            end
        end
    )
end

function MoveAny:IsAlphaFrame(frame)
    return MAAFS[frame] == true
end

function MoveAny:SetEleAlpha(ele, alpha)
    if ele and ele:GetAlpha() ~= alpha then
        ele:SetAlpha(alpha)
    end
end

function MoveAny:IsInPetBattle()
    local inPetBattle = false
    if C_PetBattles then
        inPetBattle = C_PetBattles.IsInBattle()
    end

    return inPetBattle
end

function MoveAny:IsChatClosed()
    for i = 1, 12 do
        if _G["ChatFrame" .. i .. "EditBox"] and _G["ChatFrame" .. i .. "EditBox"]:HasFocus() then return false end
    end

    return true
end

function MoveAny:CurrentChatTab()
    for i = 1, 12 do
        local ct = _G["ChatFrame" .. i .. "EditBox"]
        if ct and ct:IsShown() then return i end
    end

    return 0
end

function MoveAny:IsDragonriding()
    return GetBonusBarIndex() == 11 and GetBonusBarOffset() == 5
end

function MoveAny:UpdateAlphaCombat(inCom)
    if incombat ~= inCom then
        incombat = inCom
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().COMBAT)
    end
end

function MoveAny:InitAlphaCombat()
    MoveAny:UpdateAlphaCombat(InCombatLockdown())
    local alphaFrameCombat = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFrameCombat, "PLAYER_REGEN_DISABLED")
    MoveAny:RegisterEvent(alphaFrameCombat, "PLAYER_REGEN_ENABLED")
    MoveAny:OnEvent(
        alphaFrameCombat,
        function(sel, event, ...)
            if event == "PLAYER_REGEN_DISABLED" then
                MoveAny:UpdateAlphaCombat(true)
            else
                MoveAny:UpdateAlphaCombat(false)
            end
        end, "alphaFrameCombat"
    )
end

function MoveAny:UpdateAlphaResting()
    if IsResting and isresting ~= IsResting() then
        isresting = IsResting()
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().RESTING)
    end
end

function MoveAny:InitAlphaResting()
    MoveAny:UpdateAlphaResting()
    local alphaFrameResting = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFrameResting, "PLAYER_UPDATE_RESTING")
    MoveAny:OnEvent(
        alphaFrameResting,
        function(sel, event, ...)
            MoveAny:UpdateAlphaResting()
        end, "alphaFrameResting"
    )
end

function MoveAny:UpdateAlphaFullHealth()
    if MoveAny:GetWoWBuildNr() >= 120000 then return end
    if fullHP ~= (UnitHealth("player") >= UnitHealthMax("player")) then
        fullHP = UnitHealth("player") >= UnitHealthMax("player")
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().FULLHEALTH)
    end
end

function MoveAny:InitAlphaFullHealth()
    local alphaFrameHealth = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFrameHealth, "UNIT_HEALTH", "player")
    MoveAny:OnEvent(
        alphaFrameHealth,
        function(sel, event, ...)
            if MoveAny:GetWoWBuildNr() >= 120000 then return end
            MoveAny:UpdateAlphaFullHealth()
        end, "alphaFrameHealth"
    )
end

function MoveAny:UpdateAlphaAura()
    local updateAlpha = false
    if MoveAny.IsDragonriding and isskyriding ~= MoveAny:IsDragonriding() then
        isskyriding = MoveAny:IsDragonriding()
        updateAlpha = true
    end

    if IsMounted and ismounted ~= IsMounted() then
        ismounted = IsMounted()
        updateAlpha = true
    end

    if IsStealthed and isstealthed ~= IsStealthed() then
        isstealthed = IsStealthed()
        updateAlpha = true
    end

    if updateAlpha then
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().AURA)
    end
end

function MoveAny:InitAlphaAura()
    MoveAny:UpdateAlphaAura()
    local alphaFrameAura = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFrameAura, "UNIT_AURA", "player")
    MoveAny:OnEvent(
        alphaFrameAura,
        function(sel, event, ...)
            MoveAny:UpdateAlphaAura()
        end, "alphaFrameAura"
    )
end

function MoveAny:UpdateAlphaVehicle()
    if UnitInVehicle and invehicle ~= UnitInVehicle("player") then
        invehicle = UnitInVehicle("player")
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().VEHICLE)
    end
end

function MoveAny:InitAlphaVehicle()
    MoveAny:UpdateAlphaVehicle()
    local alphaFrameVehicle = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFrameVehicle, "UNIT_ENTERED_VEHICLE")
    MoveAny:RegisterEvent(alphaFrameVehicle, "UNIT_EXITED_VEHICLE")
    MoveAny:OnEvent(
        alphaFrameVehicle,
        function(sel, event, ...)
            MoveAny:UpdateAlphaVehicle()
        end, "alphaFrameVehicle"
    )
end

function MoveAny:UpdateAlphaPetBattle()
    if MoveAny.IsInPetBattle and inpetbattle ~= MoveAny:IsInPetBattle() then
        inpetbattle = MoveAny:IsInPetBattle()
        MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().PETBATTLE)
    end
end

function MoveAny:InitAlphaPetBattle()
    MoveAny:UpdateAlphaPetBattle()
    local alphaFramePetBattle = CreateFrame("Frame")
    MoveAny:RegisterEvent(alphaFramePetBattle, "PET_BATTLE_CLOSE")
    MoveAny:RegisterEvent(alphaFramePetBattle, "PET_BATTLE_OPENING_DONE")
    MoveAny:RegisterEvent(alphaFramePetBattle, "PET_BATTLE_OVER")
    MoveAny:OnEvent(
        alphaFramePetBattle,
        function(sel, event, ...)
            MoveAny:UpdateAlphaPetBattle()
        end, "alphaFramePetBattle"
    )
end

function MoveAny:InitAlphas()
    MoveAny:InitAlphaCombat()
    MoveAny:InitAlphaResting()
    MoveAny:InitAlphaFullHealth()
    MoveAny:InitAlphaAura()
    MoveAny:InitAlphaVehicle()
    MoveAny:InitAlphaPetBattle()
    dufloaded = MoveAny:IsAddOnLoaded("DUnitFrames")
    alphasReady = true
    MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().INIT)
end

function MoveAny:SetMouseEleAlpha(ele, last)
    pcall(
        function()
            MoveAny:UpdateAlphas("SETMOUSEELE", ele, lastEle)
            lastEle = last
        end
    )
end

function MoveAny:UpdateAlpha(ele, mouseEle)
    if ele == nil then
        MoveAny:MSG("UpdateAlphas: ele is nil")
    else
        local name = MoveAny:GetFrameName(ele)
        if name ~= nil then
            local opts = MoveAny:GetCachedAlphaOptions(name)
            if not dufloaded or (dufloaded and ele ~= PlayerFrame and ele ~= TargetFrame) then
                if ele.ma_show ~= nil and ele.ma_show == false then
                    MoveAny:SetEleAlpha(ele, 0)
                elseif MoveAny.IsInPetBattle and MoveAny:IsInPetBattle() then
                    MoveAny:SetEleAlpha(ele, opts.petBattle)
                elseif ele == mouseEle then
                    MoveAny:SetEleAlpha(ele, 1)
                elseif incombat then
                    MoveAny:SetEleAlpha(ele, opts.inCombat)
                elseif opts.fullHPEnabled and UnitHealth("player") >= UnitHealthMax("player") then
                    MoveAny:SetEleAlpha(ele, opts.fullHealth)
                elseif UnitInVehicle and invehicle then
                    MoveAny:SetEleAlpha(ele, opts.inVehicle)
                elseif isskyriding then
                    MoveAny:SetEleAlpha(ele, opts.skyriding)
                elseif IsMounted and ismounted then
                    MoveAny:SetEleAlpha(ele, opts.mounted)
                elseif IsResting and isresting then
                    MoveAny:SetEleAlpha(ele, opts.resting)
                elseif IsStealthed and isstealthed then
                    MoveAny:SetEleAlpha(ele, opts.stealthed)
                elseif not incombat then
                    MoveAny:SetEleAlpha(ele, opts.notInCombat)
                end
            end
        end
    end
end

local alphaOptionsCache = {}
function MoveAny:InvalidateAlphaOptionsCache(name)
    if name then
        alphaOptionsCache[name] = nil
    else
        alphaOptionsCache = {}
    end
end

function MoveAny:GetCachedAlphaOptions(name)
    if alphaOptionsCache[name] then return alphaOptionsCache[name] end
    local opts = {
        inCombat = MoveAny:GetEleOption(name, "ALPHAINCOMBAT", 1, "Alpha1"),
        fullHealth = MoveAny:GetEleOption(name, "ALPHAISFULLHEALTH", 1, "Alpha2"),
        inVehicle = MoveAny:GetEleOption(name, "ALPHAINVEHICLE", 1, "Alpha3"),
        mounted = MoveAny:GetEleOption(name, "ALPHAISMOUNTED", 1, "Alpha4"),
        resting = MoveAny:GetEleOption(name, "ALPHAINRESTEDAREA", 1, "Alpha5"),
        stealthed = MoveAny:GetEleOption(name, "ALPHAISSTEALTHED", 1, "Alpha6"),
        petBattle = MoveAny:GetEleOption(name, "ALPHAISINPETBATTLE", 1, "Alpha7"),
        notInCombat = MoveAny:GetEleOption(name, "ALPHANOTINCOMBAT", 1, "Alpha8"),
        skyriding = MoveAny:GetEleOption(name, "ALPHAISSKYRIDING", 1, "Alpha9"),
        fullHPEnabled = MoveAny:GetEleOption(name, "FULLHPENABLED", false, "fullhp2"),
    }

    alphaOptionsCache[name] = opts

    return opts
end

local timeStampAlpha = 0
local retryAlpha = false
local delayAlpha = 0.08
function MoveAny:SafeUpdateAlphas(from, mouseEle, lastMouseEle)
    if timeStampAlpha >= GetTime() then
        retryAlpha = true

        return
    end

    retryAlpha = false
    timeStampAlpha = GetTime() + delayAlpha
    MoveAny:UpdateAlphas(from, mouseEle, lastMouseEle)
    MoveAny:After(
        delayAlpha + 0.02,
        function()
            if retryAlpha then
                retryAlpha = false
                MoveAny:SafeUpdateAlphas(from, mouseEle, lastMouseEle)
            end
        end, "retryAlpha"
    )
end

function MoveAny:UpdateAlphas(from, mouseEle, lastMouseEle)
    if not alphasReady then return end
    if mouseEle or lastMouseEle then
        if mouseEle then
            MoveAny:UpdateAlpha(mouseEle, mouseEle)
        end

        if lastMouseEle then
            MoveAny:UpdateAlpha(lastMouseEle, mouseEle)
        end
    else
        for i, ele in pairs(MoveAny:GetAlphaFrames()) do
            MoveAny:UpdateAlpha(ele, mouseEle)
        end
    end
end
