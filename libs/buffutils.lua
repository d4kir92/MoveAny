local _, MoveAny = ...
local buffsDelay = 0.1
local ma_bb_set_scale = {}
function MoveAny:CreateTargetFrameMoverSetup(unit, moverName, updateFunction, targetFrameName, configPrefix)
    return function()
        local frame = _G[moverName]
        local targetFrame = _G[targetFrameName]
        function frame:UpdateScaleAndAlpha()
            local scale = frame:GetScale()
            local alpha = frame:GetAlpha()
            for i, bb in pairs(MoveAny[updateFunction]()) do
                if bb then
                    bb:SetScale(scale)
                    bb:SetAlpha(alpha)
                end
            end
        end

        local buffSize = nil
        local added = {}
        function frame:Update(from)
            if targetFrame and targetFrame:GetLeft() then
                for i, bb in pairs(MoveAny[updateFunction]()) do
                    if bb then
                        if added[bb] == nil then
                            local setPoint = false
                            buffSize = buffSize or bb:GetSize()
                            hooksecurefunc(
                                bb,
                                "SetPoint",
                                function(sel, ...)
                                    if setPoint then return end
                                    setPoint = true
                                    if buffSize < 10 then
                                        buffSize = 10
                                    end

                                    bb:SetSize(buffSize, buffSize)
                                    local frameEffScale = frame:GetEffectiveScale()
                                    local targetEffScale = targetFrame:GetEffectiveScale()
                                    local frameCenterX, frameCenterY = frame:GetCenter()
                                    local targetCenterX, targetCenterY = targetFrame:GetCenter()
                                    local frameRealX = frameCenterX * frameEffScale
                                    local frameRealY = frameCenterY * frameEffScale
                                    local targetRealX = targetCenterX * targetEffScale
                                    local targetRealY = targetCenterY * targetEffScale
                                    frame.PX = frameRealX - targetRealX
                                    frame.PY = frameRealY - targetRealY
                                    local mode = MoveAny:GetEleOption(moverName, configPrefix .. "MODE", 0)
                                    local limit = MoveAny:GetEleOption(moverName, configPrefix .. "LIMIT", 10)
                                    local spacingX = MoveAny:GetEleOption(moverName, configPrefix .. "SPACINGX", 4)
                                    local spacingY = MoveAny:GetEleOption(moverName, configPrefix .. "SPACINGY", 10)
                                    local row = math.floor((added[bb] - 1) / limit)
                                    local col = (added[bb] - 1) % limit
                                    local selScale = sel:GetEffectiveScale()
                                    local pixelX = frame.PX + col * (buffSize * selScale + spacingX)
                                    local pixelY
                                    if mode == 1 then
                                        pixelY = frame.PY + row * (buffSize * selScale + spacingY)
                                    else
                                        pixelY = frame.PY - row * (buffSize * selScale + spacingY)
                                    end

                                    sel:ClearAllPoints()
                                    sel:SetPoint("CENTER", targetFrame, "CENTER", pixelX / selScale, pixelY / selScale)
                                    setPoint = false
                                end
                            )
                        end

                        if added[bb] ~= i then
                            added[bb] = i
                        end

                        bb:ClearAllPoints()
                        bb:SetPoint("LEFT", targetFrame, "RIGHT", 0, 0)
                    end
                end
            end
        end

        targetFrame:HookScript(
            "OnShow",
            function()
                C_Timer.After(
                    buffsDelay,
                    function()
                        MoveAny[updateFunction]()
                        frame:UpdateScaleAndAlpha()
                        frame:Update("INIT")
                    end, "OnShow" .. moverName
                )
            end
        )

        local bbf = CreateFrame("FRAME")
        MoveAny:RegisterEvent(bbf, "UNIT_AURA", unit)
        MoveAny:OnEvent(
            bbf,
            function()
                MoveAny[updateFunction]()
                frame:UpdateScaleAndAlpha()
                frame:Update("UNIT_AURA")
            end, moverName .. " 7"
        )

        hooksecurefunc(
            frame,
            "SetPoint",
            function()
                frame:UpdateScaleAndAlpha()
                frame:Update("frame SetPoint")
            end
        )

        hooksecurefunc(
            frame,
            "SetScale",
            function(sel)
                if InCombatLockdown() and sel:IsProtected() then return false end
                if ma_bb_set_scale[sel] then return end
                ma_bb_set_scale[sel] = true
                frame:UpdateScaleAndAlpha()
                frame:Update("SetScale")
                ma_bb_set_scale[sel] = false
            end
        )

        frame:UpdateScaleAndAlpha()
    end
end

function MoveAny:RegisterTargetFrameMover(unit, moverName, lstrKey, updateFunction, targetFrameName, configPrefix)
    local moverFrame = CreateFrame("Frame", moverName, UIParent)
    moverFrame:SetSize(21, 21)
    moverFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    MoveAny:RegisterWidget(
        {
            ["name"] = moverName,
            ["lstr"] = lstrKey,
            ["userplaced"] = true,
            ["setup"] = MoveAny:CreateTargetFrameMoverSetup(unit, moverName, updateFunction, targetFrameName, configPrefix),
        }
    )
end
