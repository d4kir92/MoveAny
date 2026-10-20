local _, MoveAny = ...
function MoveAny:InitPartyFrame()
end

function MoveAny:IsRaidStylePartyFrames()
	if EditModeManagerFrame == nil or EditModeManagerFrame.UseRaidStylePartyFrames == nil then return false end
	local ok, res = pcall(EditModeManagerFrame.UseRaidStylePartyFrames, EditModeManagerFrame)
	return ok and res == true
end

function MoveAny:CanMovePartyMembers()
	return PartyFrame ~= nil and PartyFrame.PartyMemberFramePool ~= nil
end

function MoveAny:InitPartyMemberMovers()
	if not MoveAny:CanMovePartyMembers() then return false end
	if not MoveAny:IsEnabled("PARTYMEMBERFRAMES", false) then return false end
	if MoveAny:IsRaidStylePartyFrames() then return false end
	local proxies = {}
	local spacing = PartyFrame.spacing or 10
	for i = 1, 4 do
		local proxy = CreateFrame("Frame", "MAPartyMemberFrame" .. i, MoveAny:GetMainPanel())
		proxy:SetSize(120, 53)
		proxy:SetPoint("TOPLEFT", PartyFrame, "TOPLEFT", 0, -(i - 1) * (53 + spacing))
		proxies[i] = proxy
	end

	local busy = false
	local pending = false
	local function Apply()
		if busy then return end
		if InCombatLockdown() then
			pending = true
			return
		end

		pending = false
		busy = true
		for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
			local proxy = proxies[memberFrame.layoutIndex]
			if proxy then
				memberFrame:SetScale(proxy:GetScale())
				memberFrame:SetAlpha(proxy:GetAlpha())
				memberFrame:ClearAllPoints()
				memberFrame:SetPoint("TOPLEFT", proxy, "TOPLEFT", 0, 0)
				local ratio = memberFrame:GetEffectiveScale() / proxy:GetEffectiveScale()
				local w = memberFrame:GetWidth() * ratio
				local h = memberFrame:GetHeight() * ratio
				if w > 0 and h > 0 and (math.abs(proxy:GetWidth() - w) > 0.5 or math.abs(proxy:GetHeight() - h) > 0.5) then proxy:SetSize(w, h) end
			end
		end

		busy = false
	end

	for i, proxy in ipairs(proxies) do
		hooksecurefunc(proxy, "SetAlpha", function(sel, alpha)
			for memberFrame in PartyFrame.PartyMemberFramePool:EnumerateActive() do
				if memberFrame.layoutIndex == i then memberFrame:SetAlpha(alpha) end
			end
		end)

		hooksecurefunc(proxy, "SetScale", Apply)
	end

	hooksecurefunc(PartyFrame, "Layout", Apply)
	hooksecurefunc(PartyFrame, "InitializePartyMemberFrames", Apply)
	hooksecurefunc(PartyFrame, "UpdatePartyFrames", Apply)
	local combatFrame = CreateFrame("Frame")
	MoveAny:RegisterEvent(combatFrame, "PLAYER_REGEN_ENABLED")
	MoveAny:OnEvent(combatFrame, function() if pending then Apply() end end, "PartyMemberMovers")
	Apply()
	for i = 1, 4 do
		MoveAny:RegisterWidget({
			["name"] = "MAPartyMemberFrame" .. i,
			["lstr"] = "LID_PARTYMEMBERFRAME",
			["lstri"] = i,
			["userplaced"] = true
		})
	end
	return true
end

function MoveAny:ShowPartyMembersTooltip(owner)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	GameTooltip:AddLine(MoveAny:Trans("LID_PARTYMEMBERFRAMES"))
	if MoveAny:IsRaidStylePartyFrames() then
		local partyLabel = HUD_EDIT_MODE_PARTY_FRAMES_LABEL or MoveAny:Trans("LID_PARTYFRAME")
		local raidStyleLabel = HUD_EDIT_MODE_SETTING_UNIT_FRAME_RAID_STYLE_PARTY_FRAMES or "Use Raid-Style Party Frames"
		GameTooltip:AddLine(format(MoveAny:Trans("LID_PARTYMEMBERFRAMESRAIDSTYLE"), partyLabel, raidStyleLabel), 1, 0.3, 0.3, true)
	else
		GameTooltip:AddLine(MoveAny:Trans("LID_PARTYMEMBERFRAMESDESC"), 1, 1, 1, true)
	end

	GameTooltip:Show()
end

function MoveAny:SetupPartyMembersCheckBox(cb)
	if cb == nil then return end
	local function Update()
		local raidStyle = MoveAny:IsRaidStylePartyFrames()
		cb:SetEnabled(not raidStyle)
		if cb.Label then
			if raidStyle then
				cb.Label:SetAlpha(0.5)
			else
				cb.Label:SetAlpha(1)
			end
		end
	end

	local function OnEnter(sel)
		MoveAny:ShowPartyMembersTooltip(sel)
	end

	cb:SetMotionScriptsWhileDisabled(true)
	cb:SetScript("OnEnter", OnEnter)
	cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if cb.row then
		cb.row:SetMotionScriptsWhileDisabled(true)
		cb.row:SetScript("OnEnter", OnEnter)
	end

	if cb.holder then cb.holder:HookScript("OnShow", Update) end
	if EventRegistry and EventRegistry.RegisterCallback then EventRegistry:RegisterCallback("EditMode.Exit", Update, cb) end
	Update()
end
--PartyFrame:SetSize(120, 244)
