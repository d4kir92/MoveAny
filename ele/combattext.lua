local _, MoveAny = ...
local hooksecurefunc = MoveAny.hooksecurefunc
local hookedCombatText = false
local shiftGroup = nil
local shiftAnim = nil
local shiftX, shiftY = nil, nil
function MoveAny:UpdateMACombatText()
	local frame = MACombatText
	if shiftGroup == nil or frame == nil or CombatText == nil or CombatText.textLocations == nil then return end
	local startX = CombatText.textLocations.startX or 0
	local startY = CombatText.textLocations.startY
	local cx, cy = frame:GetCenter()
	local wcx = WorldFrame:GetCenter()
	local wbottom = WorldFrame:GetBottom()
	if startY == nil or cx == nil or cy == nil or wcx == nil or wbottom == nil then return end
	if issecretvalue and (issecretvalue(cx) or issecretvalue(cy) or issecretvalue(startX) or issecretvalue(startY)) then return end
	local k = CombatText:GetEffectiveScale()
	local mScale = frame:GetEffectiveScale() / k
	local wScale = WorldFrame:GetEffectiveScale() / k
	local dx = cx * mScale - wcx * wScale - startX
	local dy = cy * mScale - wbottom * wScale - startY
	if dx == shiftX and dy == shiftY and shiftGroup:IsPlaying() then return end
	shiftX = dx
	shiftY = dy
	shiftGroup:Stop()
	shiftAnim:SetOffset(dx, dy)
	shiftGroup:Play()
end

function MoveAny:HookMACombatText()
	if hookedCombatText or CombatText == nil or CombatText.UpdateDisplayedMessages == nil then return false end
	hookedCombatText = true
	shiftGroup = CombatText:CreateAnimationGroup()
	shiftAnim = shiftGroup:CreateAnimation("Translation")
	shiftAnim:SetDuration(0.001)
	shiftAnim:SetEndDelay(100000000)
	shiftGroup:SetScript("OnFinished", function() MoveAny:UpdateMACombatText() end)
	CombatText:HookScript("OnShow", function() MoveAny:UpdateMACombatText() end)
	hooksecurefunc(CombatText, "UpdateDisplayedMessages", function() MoveAny:UpdateMACombatText() end)
	MoveAny:UpdateMACombatText()

	return true
end

function MoveAny:InitMACombatText()
	if not MoveAny:IsEnabled("MACombatText", false) or MACombatText then return end
	local frame = CreateFrame("Frame", "MACombatText", MoveAny:GetMainPanel())
	frame:SetSize(50, 50)
	frame:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
	hooksecurefunc(frame, "SetPoint", function() MoveAny:UpdateMACombatText() end)
	hooksecurefunc(frame, "SetScale", function() MoveAny:UpdateMACombatText() end)
	if not MoveAny:HookMACombatText() then
		local f = CreateFrame("Frame")
		MoveAny:RegisterEvent(f, "ADDON_LOADED")
		MoveAny:OnEvent(f, function(sel, event, addonName)
			if addonName == "Blizzard_CombatText" and MoveAny:HookMACombatText() then sel:UnregisterAllEvents() end
		end, "MACombatText ADDON_LOADED")
	end
end
