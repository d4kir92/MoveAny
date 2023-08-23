local _, MoveAny = ...

local BAGS = {"CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot", "CharacterBag0Slot"}

function MoveAny:BAGSTryAdd(fra, index)
	if _G[fra] == nil then return end

	if fra and not tContains(BAGS, fra) then
		if index then
			tinsert(BAGS, index, tostring(fra))
		else
			tinsert(BAGS, tostring(fra))
		end
	end
end

function MoveAny:UpdateBags()
	MoveAny:BAGSTryAdd("CharacterReagentBag0Slot", 1)
	MoveAny:BAGSTryAdd("KeyRingButton", 1)
	MoveAny:BAGSTryAdd("BagBarExpandToggle", #BAGS + 1)
	MoveAny:BAGSTryAdd("BagToggle", #BAGS)
	MoveAny:BAGSTryAdd("MainMenuBarBackpackButton")
	local sw, sh = 0, 0

	for i, mbname in pairs(BAGS) do
		local bb = _G[mbname]

		if bb ~= nil and bb:IsShown() then
			local w, h = bb:GetSize()
			sw = sw + w

			if h > sh then
				sh = h
			end
		end
	end

	if BagsBar then
		BagsBar:SetSize(sw, sh)

		if BagsBar_DRAG then
			if BagsBar_DRAG.hooksetsize == nil then
				BagsBar_DRAG.hooksetsize = true

				hooksecurefunc(BagsBar_DRAG, "SetSize", function(sel, w, h)
					if sel.ma_bags_setsize then return end
					sel.ma_bags_setsize = true
					MoveAny:UpdateBags()
					sel.ma_bags_setsize = false
				end)
			end

			BagsBar_DRAG:SetSize(sw, sh)
		end

		local x = 0

		for i, mbname in pairs(BAGS) do
			local bb = _G[mbname]

			if bb ~= nil and bb:IsShown() then
				local w, h = bb:GetSize()
				bb:SetParent(BagsBar)

				if bb.setup == nil then
					bb.setup = true

					hooksecurefunc(bb, "SetPoint", function(sel, ...)
						if sel.ma_bags_setpoint then return end
						sel.ma_bags_setpoint = true
						sel:ClearAllPoints()
						sel:SetPoint("TOPLEFT", BagsBar, "TOPLEFT", sel.px, -(sel.psh / 2 - sel.ph / 2))
						sel.ma_bags_setpoint = false
					end)

					function bb:GetMAEle()
						return BagsBar
					end
				end

				bb.px = x
				bb.psh = sh
				bb.ph = h
				bb:ClearAllPoints()
				bb:SetPoint("TOPLEFT", BagsBar, "TOPLEFT", x, -(sh / 2 - h / 2))
				x = x + w
			end
		end
	end
end

function MoveAny:InitBags()
	if not BagsBar then
		BagsBar = CreateFrame("Frame", "BagsBar", MoveAny:GetMainPanel())
		BagsBar:SetSize(100, 100)
	end

	if MoveAny:IsEnabled("BAGS", false) and BagsBar then
		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		hooksecurefunc(BagsBar, "SetSize", function(sel, w, h)
			if sel.ma_bags_setsize then return end
			sel.ma_bags_setsize = true
			MoveAny:UpdateBags()
			sel.ma_bags_setsize = false
		end)

		if MicroButtonAndBagsBar then
			BagsBar:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", 0, 36)
		elseif MoveAny:GetWoWBuild() ~= "RETAIL" then
			BagsBar:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", 0, 36)
		else
			BagsBar:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
		end

		for i, mbname in pairs(BAGS) do
			local bb = _G[mbname]

			if bb and MoveAny:GetWoWBuild() ~= "RETAIL" then
				hooksecurefunc(bb, "Hide", function(sel)
					if sel.mashow then return end
					sel.mashow = true
					sel:Show()
					sel.mashow = false
				end)

				bb:Show()
			end
		end

		MoveAny:UpdateBags()
	end

	C_Timer.After(1, function()
		for i, v in pairs(BAGS) do
			local bagF = _G[v]
			local NT = _G[v .. "NormalTexture"]

			if NT and bagF and NT.scalesetup == nil then
				NT.scalesetup = true
				local sw, sh = bagF:GetSize()
				local scale = 1.67
				NT:SetSize(sw * scale, sh * scale)
			end
		end
	end)
end