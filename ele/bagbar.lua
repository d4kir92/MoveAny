local _, MoveAny = ...
local KEYBAG = {"KeyRingButton"}
local SMALLBAGS = {"CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot", "CharacterBag0Slot"}
local BAGS = {"CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot", "CharacterBag0Slot"}
function MoveAny:BAGSTryAdd(fra, index)
	if fra == nil then return end
	if not tContains(BAGS, fra) then
		if index then
			tinsert(BAGS, index, tostring(fra))
		else
			tinsert(BAGS, tostring(fra))
		end
	end
end

local hookedBags = {}
local run = false
local hooksetsize = nil
local ma_bags_setsize = false
local ma_bags_setsize_frame = {}
local ma_bags_setpoint = {}
local ma_setparent = {}
local ma_show_guard = {}
local ma_setup = {}
local ma_px = {}
local ma_psh = {}
local ma_ph = {}
function MoveAny:UpdateBags()
	if run then return end
	run = true
	if MoveAny:GetEleOption("BagsBar", "HideSmallBags", false) then
		for i, v in pairs(SMALLBAGS) do
			local bag = _G[v]
			if bag then
				MoveAny:HideFrame(bag)
			end
		end
	else
		for i, v in pairs(SMALLBAGS) do
			local bag = _G[v]
			if bag then
				MoveAny:ShowFrame(bag)
			end
		end
	end

	if MoveAny:GetEleOption("BagsBar", "HideKeyBag", false) then
		for i, v in pairs(KEYBAG) do
			local bag = _G[v]
			if bag then
				MoveAny:HideFrame(bag)
			end
		end
	else
		for i, v in pairs(KEYBAG) do
			local bag = _G[v]
			if bag then
				MoveAny:ShowFrame(bag)
			end
		end
	end

	MoveAny:BAGSTryAdd("CharacterReagentBag0Slot", 1)
	MoveAny:BAGSTryAdd("KeyRingButton", 1)
	MoveAny:BAGSTryAdd("BagBarExpandToggle", #BAGS + 1)
	MoveAny:BAGSTryAdd("BagToggle", #BAGS)
	MoveAny:BAGSTryAdd("MainMenuBarBackpackButton")
	local sw, sh = 0, 0
	for i, mbname in pairs(BAGS) do
		local bb = _G[mbname]
		if bb ~= nil and bb:IsShown() and MoveAny:GetParent(bb):IsShown() and bb:GetAlpha() > 0 then
			if not tContains(hookedBags, mbname) then
				tinsert(hookedBags, mbname)
				hooksecurefunc(
					bb,
					"SetParent",
					function(sel, parent)
						if run then return end
						if ma_setparent[sel] then return end
						ma_setparent[sel] = true
						MoveAny:UpdateBags()
						ma_setparent[sel] = false
					end
				)
			end

			local w, h = bb:GetSize()
			sw = sw + w
			if h > sh then
				sh = h
			end
		end
	end

	if BagsBar then
		BagsBar:SetSize(sw, sh)
		local BagsBarDrag = MoveAny:GetDragFromName("BagsBar")
		if BagsBarDrag then
			if hooksetsize == nil then
				hooksetsize = true
				hooksecurefunc(
					BagsBarDrag,
					"SetSize",
					function(sel, w, h)
						if InCombatLockdown() and sel:IsProtected() then return false end
						if ma_bags_setsize then return end
						ma_bags_setsize = true
						MoveAny:UpdateBags()
						ma_bags_setsize = false
					end
				)
			end

			BagsBarDrag:SetSize(sw, sh)
		end

		local x = 0
		for i, mbname in pairs(BAGS) do
			local bb = _G[mbname]
			if bb ~= nil and bb:IsShown() and MoveAny:GetParent(bb):IsShown() and bb:GetAlpha() > 0 then
				local w, h = bb:GetSize()
				if MainMenuBarArtFrame and MoveAny:GetParent(bb) == MainMenuBarArtFrame then
					bb:SetParent(BagsBar)
				end

				if ma_setup[bb] == nil then
					ma_setup[bb] = true
					hooksecurefunc(
						bb,
						"SetPoint",
						function(sel, ...)
							if ma_bags_setpoint[sel] then return end
							ma_bags_setpoint[sel] = true
							MoveAny:SetPoint(sel, "TOPLEFT", BagsBar, "TOPLEFT", ma_px[sel], -(ma_psh[sel] / 2 - ma_ph[sel] / 2))
							ma_bags_setpoint[sel] = false
						end
					)

					function bb:GetMAEle()
						return BagsBar
					end

					MoveAny:RegisterChildAlphaFrame(bb, BagsBar)
				end

				ma_px[bb] = x
				ma_psh[bb] = sh
				ma_ph[bb] = h
				bb:ClearAllPoints()
				bb:SetPoint("TOPLEFT", BagsBar, "TOPLEFT", x, -(sh / 2 - h / 2))
				x = x + w
			end
		end
	end

	run = false
end

local once = true
function MoveAny:InitBags()
	if MoveAny:IsEnabled("BAGS", false) then
		if not BagsBar then
			BagsBar = CreateFrame("Frame", "BagsBar", MoveAny:GetMainPanel())
			BagsBar:SetSize(100, 100)
		end

		if BagsBar then
			if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
				MicroButtonAndBagsBar.MicroBagBar:Hide()
			end

			hooksecurefunc(
				BagsBar,
				"SetSize",
				function(sel, w, h)
					if InCombatLockdown() and sel:IsProtected() then return false end
					if ma_bags_setsize_frame[sel] then return end
					ma_bags_setsize_frame[sel] = true
					MoveAny:UpdateBags()
					ma_bags_setsize_frame[sel] = false
				end
			)

			if MicroButtonAndBagsBar then
				BagsBar:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", 0, 36)
			elseif MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
				BagsBar:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", 0, 36)
			else
				BagsBar:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			end

			for i, mbname in pairs(BAGS) do
				local bb = _G[mbname]
				if bb and (MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC") then
					hooksecurefunc(
						bb,
						"Hide",
						function(sel)
							if ma_show_guard[sel] then return end
							ma_show_guard[sel] = true
							sel:Show()
							ma_show_guard[sel] = false
						end
					)

					bb:Show()
				end
			end

			MoveAny:UpdateBags()
		end
	end

	MoveAny:After(
		1,
		function()
			for i, v in pairs(BAGS) do
				local bagF = _G[v]
				local NT = _G[v .. "NormalTexture"]
				if NT and bagF and NT.scalesetup == nil then
					NT.scalesetup = true
					if NT:GetTexture() == 130841 then
						local sw, sh = bagF:GetSize()
						local scale = 1.66
						NT:SetSize(sw * scale, sh * scale)
					end
				end
			end

			-- Masque
			if once then
				once = false
				if LibStub then
					local MSQ = LibStub("Masque", true)
					if MSQ then
						local group = MSQ:Group("MA Blizzard Bags")
						for i, v in pairs(BAGS) do
							if v ~= "KeyRingButton" and v ~= "BagToggle" then
								local btn = _G[v]
								if not btn.MasqueButtonData then
									btn.MasqueButtonData = {
										Button = btn,
										Icon = _G[v .. "IconTexture"],
									}

									group:AddButton(btn, btn.MasqueButtonData, "Item")
								end
							end
						end
					end
				end
			end
		end, "InitBags"
	)
end
