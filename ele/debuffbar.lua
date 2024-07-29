local _, MoveAny = ...
local btnsize = 36
local debuffs = {}
function MoveAny:GetDebuffPosition(p1, p3)
	MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] = MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] or 0
	if MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 0 then
		if p1 == "TOPLEFT" or p1 == "LEFT" then
			return "TOPLEFT", "TOPLEFT"
		elseif p1 == "TOPRIGHT" or p1 == "RIGHT" or p1 == "TOP" or p1 == "CENTER" then
			return "TOPRIGHT", "TOPRIGHT"
		elseif p1 == "BOTTOMLEFT" then
			return "BOTTOMLEFT", "BOTTOMLEFT"
		elseif p1 == "BOTTOMRIGHT" or p1 == "BOTTOM" then
			return "BOTTOMRIGHT", "BOTTOMRIGHT"
		end
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 1 then
		return "TOPRIGHT", "TOPRIGHT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 2 then
		return "TOPLEFT", "TOPLEFT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 3 then
		return "BOTTOMRIGHT", "BOTTOMRIGHT"
	elseif MoveAny:GetEleOptions("MADebuffBar", "GetBuffPosition")["MADEBUFFMODE"] == 4 then
		return "BOTTOMLEFT", "BOTTOMLEFT"
	end

	return "TOPRIGHT", "TOPRIGHT"
end

local once = true
function MoveAny:InitDebuffBar()
	if MoveAny:IsEnabled("DEBUFFS", false) then
		MADebuffBar = CreateFrame("Frame", nil, MoveAny:GetMainPanel())
		MADebuffBar:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -165, -132)
		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			MADebuffBar:SetSize(btnsize * 10, btnsize * 3)
		else
			local sw1, sh1 = BuffFrame:GetSize()
			MADebuffBar:SetSize(sw1, sh1)
		end

		function MALoadDebuff()
			for i = 1, 32 do
				local debuffBtn = _G["DebuffButton" .. i]
				if debuffBtn and not tContains(debuffs, debuffBtn) then
					table.insert(debuffs, debuffBtn)
					function debuffBtn:GetMAEle()
						return MABuffBar
					end

					if i == 1 then
						hooksecurefunc(
							debuffBtn,
							"SetPoint",
							function(sel, ...)
								if sel.debuffsetpoint then return end
								sel.debuffsetpoint = true
								sel:SetMovable(true)
								if sel.SetUserPlaced and sel:IsMovable() then
									sel:SetUserPlaced(false)
								end

								sel:SetParent(MADebuffBar)
								MoveAny:SetPoint(sel, "TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0)
								sel.debuffsetpoint = false
							end
						)

						debuffBtn:ClearAllPoints()
						debuffBtn:SetPoint("TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0)
					else
						local op1, op2, op3, op4, op5 = debuffBtn:GetPoint()
						hooksecurefunc(
							debuffBtn,
							"SetPoint",
							function(sel, ...)
								if sel.debuffsetpoint then return end
								sel.debuffsetpoint = true
								local p1, p2, p3, p4, p5 = ...
								sel:SetMovable(true)
								if sel.SetUserPlaced and sel:IsMovable() then
									sel:SetUserPlaced(false)
								end

								sel:SetParent(MADebuffBar)
								MoveAny:SetPoint(sel, p1, p2, p3, p4, p5)
								sel.debuffsetpoint = false
							end
						)

						debuffBtn:ClearAllPoints()
						debuffBtn:SetPoint(op1, op2, op3, op4, op5)
					end
				end
			end

			C_Timer.After(0.3, MALoadDebuff)
		end

		MALoadDebuff()
		if MoveAny:DEBUG() then
			DebuffButton1.t = DebuffButton1:CreateTexture()
			DebuffButton1.t:SetAllPoints(DebuffButton1)
			DebuffButton1.t:SetColorTexture(0, 1, 1, 1)
			MADebuffBar.t = MADebuffBar:CreateTexture()
			MADebuffBar.t:SetAllPoints(MADebuffBar)
			MADebuffBar.t:SetColorTexture(1, 0, 0, 0.2)
		end

		local rel = "RIGHT"
		local dirH = "LEFT"
		local dirV = "BOTTOM"
		function MoveAny:UpdateDebuffDirections()
			local p1, _, p3, _, _ = MADebuffBar:GetPoint()
			local bp1, bp3 = MoveAny:GetDebuffPosition(p1, p3)
			rel = "RIGHT"
			if bp1 == "TOPLEFT" then
				rel = "LEFT"
			elseif bp1 == "LEFT" then
				rel = "LEFT"
			elseif bp1 == "BOTTOMLEFT" then
				rel = "LEFT"
			end

			dirH = "LEFT"
			if rel == "LEFT" then
				dirH = "RIGHT"
			end

			dirV = "BOTTOM"
			if bp3 == "BOTTOMLEFT" then
				dirV = "TOP"
			elseif bp3 == "BOTTOM" then
				dirV = "TOP"
			elseif bp3 == "BOTTOMRIGHT" then
				dirV = "TOP"
			end
		end

		MoveAny:UpdateDebuffDirections()
		function MoveAny:UpdateDebuffs()
			MoveAny:UpdateDebuffDirections()
			for i = 1, 32 do
				local dbtn = _G["DebuffButton" .. i]
				if dbtn then
					if dbtn.masetup == nil then
						dbtn.masetup = true
						hooksecurefunc(
							dbtn,
							"SetPoint",
							function(sel, ...)
								if sel.setpoint_dbtn then return end
								sel.setpoint_dbtn = true
								local p1, _, p3, _, _ = MADebuffBar:GetPoint()
								local bp1, bp3 = MoveAny:GetDebuffPosition(p1, p3)
								local _, sh = sel:GetSize()
								local id = i
								local caly = (id - 0.1) / 10
								local cy = caly - caly % 1
								if i == 1 then
									if rel == "RIGHT" then
										MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, 0)
									else
										MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, 0)
									end
								else
									if id % 10 == 1 then
										if dirV == "BOTTOM" then
											MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, -cy * (sh + 10))
										else
											MoveAny:SetPoint(sel, bp1, MADebuffBar, bp3, 0, cy * (sh + 10))
										end
									else
										if rel == "RIGHT" then
											MoveAny:SetPoint(sel, rel, _G["DebuffButton" .. (i - 1)], dirH, -4, 0)
										else
											MoveAny:SetPoint(sel, rel, _G["DebuffButton" .. (i - 1)], dirH, 4, 0)
										end
									end
								end

								sel.setpoint_dbtn = false
							end
						)
					end

					dbtn:SetPoint("CENTER", 0, 0)
				end
			end

			-- Masque
			local MSQ = LibStub("Masque", true)
			if MSQ then
				if once then
					once = false
					MSQ:Register("Buffs", function() end, {})
					MAMasqueBuffs = MSQ:Group("MA Blizzard Buffs")
				end

				for i = 1, 32 do
					local btn = _G["BuffButton" .. i]
					if btn and not btn.MasqueButtonData then
						btn.MasqueButtonData = {
							Button = btn,
							Icon = _G["BuffButton" .. "IconTexture"],
						}

						MAMasqueBuffs:AddButton(btn, btn.MasqueButtonData, "Item")
					end

					local btn2 = _G["DebuffButton" .. i]
					if btn2 and not btn2.MasqueButtonData then
						btn2.MasqueButtonData = {
							Button = btn2,
							Icon = _G["DebuffButton" .. "IconTexture"],
						}

						MAMasqueBuffs:AddButton(btn2, btn2.MasqueButtonData, "Item")
					end
				end

				for i = 1, 3 do
					local btn = _G["TempEnchant" .. i]
					if btn and not btn.MasqueButtonData then
						btn.MasqueButtonData = {
							Button = btn,
							Icon = _G["TempEnchant" .. i .. "IconTexture"],
						}

						MAMasqueBuffs:AddButton(btn, btn.MasqueButtonData, "Item")
					end
				end
			end
		end

		if MABuffBar then
			hooksecurefunc(
				MABuffBar,
				"SetPoint",
				function(sel, ...)
					MoveAny:UpdateDebuffs()
				end
			)
		end

		hooksecurefunc(
			MADebuffBar,
			"SetPoint",
			function(sel, ...)
				MoveAny:UpdateDebuffs()
			end
		)

		local f = CreateFrame("FRAME")
		f:RegisterEvent("UNIT_AURA")
		f:SetScript(
			"OnEvent",
			function(sel, event, ...)
				if event == "UNIT_AURA" then
					unit = ...
					if unit and unit == "player" then
						MoveAny:UpdateDebuffs()
					end
				end
			end
		)

		C_Timer.After(1, MoveAny.UpdateDebuffs)
	end
end
