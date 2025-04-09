local _, MoveAny = ...
local btnsize = 36
local once = true
local bar = nil
function MoveAny:UpdatePetBar()
	if bar then
		-- Masque
		if LibStub then
			local MSQ = LibStub("Masque", true)
			if MSQ then
				local MAMasqueGroups = {}
				MAMasqueGroups.Groups = {}
				if once then
					once = false
					MSQ:Register("MoveAny Blizzard Action Bars", function() end, {})
				end

				for y, btn in pairs(bar.btns) do
					if btn then
						local btnName = MoveAny:GetName(btn)
						if _G[btnName .. "FloatingBG"] then
							_G[btnName .. "FloatingBG"]:SetParent(MAHIDDEN)
						end

						local parent = "MAPetBar"
						local group = nil
						if MAMasqueGroups.Groups["MA " .. parent] == nil then
							MAMasqueGroups.Groups["MA " .. parent] = MSQ:Group("MA Blizzard Action Bars", "MA " .. parent)
						end

						group = MAMasqueGroups.Groups["MA " .. parent]
						if not btn.MasqueButtonData then
							btn.MasqueButtonData = {
								Button = btn,
								Icon = _G[btnName .. "IconTexture"],
							}

							group:AddButton(btn, btn.MasqueButtonData, "Item")
						end
					end
				end
			end
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(bar, "MAPetBar")
			MoveAny:UpdateActionBar(bar)
		end
	end

	C_Timer.After(0.4, MoveAny.UpdatePetBar)
end

function MoveAny:InitPetBar()
	if not PetActionBar and MoveAny:IsEnabled("PETBAR", false) then
		bar = CreateFrame("Frame", "MAPetBar", MoveAny:GetMainPanel())
		bar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 110)
		bar.btns = {}
		if _G["PetActionButton" .. 1] then
			btnsize = _G["PetActionButton" .. 1]:GetSize()
		end

		for i = 1, 10 do
			local bb = _G["PetActionButton" .. i]
			if bb then
				bb:SetSize(btnsize, btnsize)
				hooksecurefunc(
					bb,
					"SetParent",
					function(sel, ...)
						if sel.ma_setparent then return end
						sel.ma_setparent = true
						bb:SetParent(bar)
						sel.ma_setparent = false
					end
				)

				hooksecurefunc(
					bar,
					"SetPoint",
					function(sel, ...)
						bb:SetParent(bar)
						bb:SetMovable(true)
						if bb.SetUserPlaced and bb:IsMovable() then
							bb:SetUserPlaced(false)
						end

						MoveAny:SetPoint(bb, "TOPLEFT", bar, "TOPLEFT", (i - 1) * btnsize, 0)
					end
				)

				bb:ClearAllPoints()
				bb:SetPoint("TOPLEFT", bar, "TOPLEFT", (i - 1) * btnsize, 0)
				tinsert(bar.btns, bb)
			end
		end

		bar:SetSize(10 * btnsize, btnsize)
		if ShowPetActionBar then
			hooksecurefunc(
				"ShowPetActionBar",
				function()
					bar:SetAlpha(1)
					bar.ma_show = true
				end
			)

			hooksecurefunc(
				"HidePetActionBar",
				function()
					if UnitExists("pet") then
						bar:SetAlpha(1)
						bar.ma_show = true
					else
						bar:SetAlpha(0)
						bar.ma_show = false
					end
				end
			)
		else
			MoveAny:MSG("MISSING ShowPetActionBar")
		end

		MoveAny:UpdatePetBar()
	elseif PetActionBar then
		PetActionBar.btns = {}
		for i = 1, 12 do
			local btn = _G["PetActionButton" .. i]
			if btn then
				tinsert(PetActionBar.btns, btn)
			end
		end

		MoveAny:UpdatePetBar()
	elseif PetActionBarFrame then
		PetActionBarFrame.btns = {}
		for i = 1, 12 do
			local btn = _G["PetActionButton" .. i]
			if btn then
				tinsert(PetActionBarFrame.btns, btn)
			end
		end

		MoveAny:UpdatePetBar()
	end
end
