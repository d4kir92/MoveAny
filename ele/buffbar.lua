local _, MoveAny = ...
local btnsize = 36
local MABUFFLIMIT = 10
local MABUFFSPACINGX = 4
local MABUFFSPACINGY = 10
local MADEBUFFSPACING = 140
function MoveAny:GetBuffPosition(name, p1, p3)
	MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] = MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] or 0
	if MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 0 then
		if p1 == "TOPLEFT" or p1 == "LEFT" then
			return "TOPLEFT", "TOPLEFT"
		elseif p1 == "TOPRIGHT" or p1 == "RIGHT" or p1 == "TOP" or p1 == "CENTER" then
			return "TOPRIGHT", "TOPRIGHT"
		elseif p1 == "BOTTOMLEFT" then
			return "BOTTOMLEFT", "BOTTOMLEFT"
		elseif p1 == "BOTTOMRIGHT" or p1 == "BOTTOM" then
			return "BOTTOMRIGHT", "BOTTOMRIGHT"
		end
	elseif MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 1 then
		return "TOPRIGHT", "TOPRIGHT"
	elseif MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 2 then
		return "TOPLEFT", "TOPLEFT"
	elseif MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 3 then
		return "BOTTOMRIGHT", "BOTTOMRIGHT"
	elseif MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 4 then
		return "BOTTOMLEFT", "BOTTOMLEFT"
	elseif MoveAny:GetEleOptions(name, "GetBuffPosition")["MABUFFMODE"] == 5 then
		return "CENTER", "CENTER"
	end

	return "TOPRIGHT", "TOPRIGHT"
end

local once = true
function MoveAny:InitBuffBar()
	local dbtab = {}
	if MoveAny:IsEnabled("BUFFS", false) and (MoveAny:GetWoWBuild() ~= "RETAIL" or BuffFrame == nil) then
		local MABuffBar = CreateFrame("Frame", "MABuffBar", MoveAny:GetMainPanel())
		local sw1, sh1 = BuffFrame:GetSize()
		MABuffBar:SetSize(sw1, sh1)
		MABuffBar:SetPoint(BuffFrame:GetPoint())
		function MABuffBar:GetRealEle()
			return BuffFrame
		end

		if BuffFrame then
			MABuffBar:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -165, -32)
		else
			MABuffBar:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			if MoveAny:IsEnabled("DEBUFFS", false) then
				MABuffBar:SetSize(btnsize * 10, btnsize * 3)
			else
				MABuffBar:SetSize(btnsize * 10, btnsize * 6)
			end
		else
			sw1, sh1 = BuffFrame:GetSize()
			MABuffBar:SetSize(sw1, sh1)
		end

		if not MoveAny:IsEnabled("DEBUFFS", false) then
			if DebuffFrame == nil then
				local sw, sh = BuffFrame:GetSize()
				DebuffFrame = CreateFrame("FRAME", "DebuffFrame", MoveAny:GetMainPanel())
				DebuffFrame:SetSize(sw, sh)
				DebuffFrame:SetPoint("CENTER", 0, 0)
			end

			function MoveAny:UpdateDebuffs(from)
				MABUFFLIMIT = MoveAny:GetEleOption("MABuffBar", "MABUFFLIMIT", 10)
				MABUFFSPACINGX = MoveAny:GetEleOption("MABuffBar", "MABUFFSPACINGX", 4)
				MABUFFSPACINGY = MoveAny:GetEleOption("MABuffBar", "MABUFFSPACINGY", 10)
				local p1, _, p3 = MABuffBar:GetPoint()
				local bp1 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
				local left = bp1 == "TOPLEFT" or bp1 == "LEFT" or bp1 == "BOTTOMLEFT"
				local bottom = bp1 == "BOTTOMLEFT" or bp1 == "BOTTOM" or bp1 == "BOTTOMRIGHT"
				if left then
					if bottom then
						DebuffFrame:ClearAllPoints()
						DebuffFrame:SetPoint("BOTTOMLEFT", MABuffBar, "BOTTOMLEFT", 0, MADEBUFFSPACING + 2 * MABUFFSPACINGY)
					else
						DebuffFrame:ClearAllPoints()
						DebuffFrame:SetPoint("TOPLEFT", MABuffBar, "TOPLEFT", 0, -(MADEBUFFSPACING + 2 * MABUFFSPACINGY))
					end
				else
					if bottom then
						DebuffFrame:ClearAllPoints()
						DebuffFrame:SetPoint("BOTTOMRIGHT", MABuffBar, "BOTTOMRIGHT", 0, MADEBUFFSPACING + 2 * MABUFFSPACINGY)
					else
						DebuffFrame:ClearAllPoints()
						DebuffFrame:SetPoint("TOPRIGHT", MABuffBar, "TOPRIGHT", 0, -(MADEBUFFSPACING + 2 * MABUFFSPACINGY))
					end
				end

				local olddb = nil
				for i = 1, 32 do
					local db = _G["DebuffButton" .. i]
					if db then
						if dbtab[i] == nil then
							dbtab[i] = {}
							hooksecurefunc(
								db,
								"SetPoint",
								function(sel, o1, o2, o3, o4, o5)
									if sel.ma_db_setpoint then return end
									sel.ma_db_setpoint = true
									MoveAny:SetPoint(sel, dbtab[i]["p1"], dbtab[i]["p2"], dbtab[i]["p3"], dbtab[i]["p4"], dbtab[i]["p5"])
									sel.ma_db_setpoint = false
								end
							)

							function db:GetMAEle()
								return MABuffBar
							end
						end

						if olddb then
							if left then
								dbtab[i]["p1"] = "LEFT"
								dbtab[i]["p2"] = olddb
								dbtab[i]["p3"] = "RIGHT"
								dbtab[i]["p4"] = MABUFFSPACINGX
								dbtab[i]["p5"] = 0
								db:ClearAllPoints()
								db:SetPoint("LEFT", olddb, "RIGHT", MABUFFSPACINGX, 0)
							else
								dbtab[i]["p1"] = "RIGHT"
								dbtab[i]["p2"] = olddb
								dbtab[i]["p3"] = "LEFT"
								dbtab[i]["p4"] = -MABUFFSPACINGX
								dbtab[i]["p5"] = 0
								db:ClearAllPoints()
								db:SetPoint("RIGHT", olddb, "LEFT", -MABUFFSPACINGX, 0)
							end
						else
							if left then
								dbtab[i]["p1"] = "TOPLEFT"
								dbtab[i]["p2"] = DebuffFrame
								dbtab[i]["p3"] = "TOPLEFT"
								dbtab[i]["p4"] = 0
								dbtab[i]["p5"] = 0
								db:ClearAllPoints()
								db:SetPoint("TOPLEFT", DebuffFrame, "TOPLEFT", 0, 0)
							else
								dbtab[i]["p1"] = "TOPRIGHT"
								dbtab[i]["p2"] = DebuffFrame
								dbtab[i]["p3"] = "TOPRIGHT"
								dbtab[i]["p4"] = 0
								dbtab[i]["p5"] = 0
								db:ClearAllPoints()
								db:SetPoint("TOPRIGHT", DebuffFrame, "TOPRIGHT", 0, 0)
							end
						end

						olddb = db
					else
						break
					end
				end
			end

			hooksecurefunc(
				DebuffFrame,
				"SetPoint",
				function(sel, ...)
					if sel.debuffsetpoint then return end
					sel.debuffsetpoint = true
					if MoveAny.UpdateDebuffs then
						MoveAny:UpdateDebuffs("SetPoint 3")
					end

					sel.debuffsetpoint = false
				end
			)

			hooksecurefunc(
				MABuffBar,
				"SetPoint",
				function(sel, ...)
					if sel.debuffsetpoint then return end
					sel.debuffsetpoint = true
					if MoveAny.UpdateDebuffs then
						MoveAny:UpdateDebuffs("SetPoint 2")
					end

					sel.debuffsetpoint = false
				end
			)

			local f = CreateFrame("FRAME")
			MoveAny:RegisterEvent(f, "UNIT_AURA", "player")
			f:SetScript(
				"OnEvent",
				function(sel, event, ...)
					if event == "UNIT_AURA" and MoveAny.UpdateDebuffs then
						MoveAny:UpdateDebuffs("event 2")
					end
				end
			)

			if not InCombatLockdown() then
				DebuffFrame:ClearAllPoints()
				DebuffFrame:SetPoint("TOPRIGHT", MABuffBar, "TOPRIGHT", 0, -128)
			end
		end

		hooksecurefunc(
			BuffFrame,
			"SetPoint",
			function(sel, ...)
				if sel.buffsetpoint then return end
				sel.buffsetpoint = true
				sel:SetMovable(true)
				if sel.SetUserPlaced and sel:IsMovable() then
					sel:SetUserPlaced(false)
				end

				sel:SetParent(MABuffBar)
				MoveAny:SetPoint(sel, "TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0)
				sel.buffsetpoint = false
			end
		)

		BuffFrame:ClearAllPoints()
		BuffFrame:SetPoint("TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0)
		if MoveAny:DEBUG() then
			BuffFrame.t = BuffFrame:CreateTexture()
			BuffFrame.t:SetAllPoints(BuffFrame)
			BuffFrame.t:SetColorTexture(0, 1, 1, 1)
			MABuffBar.t = MABuffBar:CreateTexture()
			MABuffBar.t:SetAllPoints(MABuffBar)
			MABuffBar.t:SetColorTexture(1, 0, 0, 0.2)
		end

		local rel = "RIGHT"
		local dirH = "LEFT"
		local dirV = "BOTTOM"
		function MoveAny:UpdateBuffDirections()
			local p1, _, p3, _, _ = MABuffBar:GetPoint()
			local bp1, bp3 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
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

		MoveAny:UpdateBuffDirections()
		if TempEnchant1 then
			hooksecurefunc(
				TempEnchant1,
				"SetPoint",
				function(sel, ...)
					if sel.setpoint_te1 then return end
					sel.setpoint_te1 = true
					sel:SetMovable(true)
					if sel.SetUserPlaced and sel:IsMovable() then
						sel:SetUserPlaced(false)
					end

					sel:SetParent(MABuffBar)
					local p1, _, p3, _, _ = MABuffBar:GetPoint()
					local bp1, bp3 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
					local x = 0
					if GetCVarBool("consolidateBuffs") then
						x = x + 1
					end

					if dirH == "LEFT" then
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, x * -(30 + MABUFFSPACINGX), 0)
					else
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, x * (30 + MABUFFSPACINGX), 0)
					end

					sel.setpoint_te1 = false
				end
			)
		end

		if TempEnchant2 then
			hooksecurefunc(
				TempEnchant2,
				"SetPoint",
				function(sel, ...)
					if sel.setpoint_te2 then return end
					sel.setpoint_te2 = true
					sel:SetMovable(true)
					if sel.SetUserPlaced and sel:IsMovable() then
						sel:SetUserPlaced(false)
					end

					sel:SetParent(MABuffBar)
					local p1, _, p3, _, _ = MABuffBar:GetPoint()
					local bp1, bp3 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
					local x = 1
					if GetCVarBool("consolidateBuffs") then
						x = x + 1
					end

					local posy = 0
					if MABUFFLIMIT == 1 then
						posy = -30 - MABUFFSPACINGY
					end

					if dirH == "LEFT" then
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, x * -(30 + MABUFFSPACINGX), posy)
					else
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, x * (30 + MABUFFSPACINGX), 0)
					end

					sel.setpoint_te2 = false
				end
			)
		end

		if TempEnchant3 then
			hooksecurefunc(
				TempEnchant3,
				"SetPoint",
				function(sel, ...)
					if sel.setpoint_te3 then return end
					sel.setpoint_te3 = true
					sel:SetMovable(true)
					if sel.SetUserPlaced and sel:IsMovable() then
						sel:SetUserPlaced(false)
					end

					sel:SetParent(MABuffBar)
					local p1, _, p3, _, _ = MABuffBar:GetPoint()
					local bp1, bp3 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
					local x = 2
					if GetCVarBool("consolidateBuffs") then
						x = x + 1
					end

					if dirH == "LEFT" then
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, -x * (30 + MABUFFSPACINGX), 0)
					else
						MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, x * (30 + MABUFFSPACINGX), 0)
					end

					sel.setpoint_te3 = false
				end
			)
		end

		function MoveAny:GetEnchantCount()
			local count = 0
			local e1, _, _, _, e2, _, _, _, e3, _, _, _ = GetWeaponEnchantInfo()
			if e1 then
				count = count + 1
			end

			if e2 then
				count = count + 1
			end

			if e3 then
				count = count + 1
			end

			return count
		end

		function MoveAny:UpdateBuffs()
			MABUFFLIMIT = MoveAny:GetEleOption("MABuffBar", "MABUFFLIMIT", 10)
			MABUFFSPACINGX = MoveAny:GetEleOption("MABuffBar", "MABUFFSPACINGX", 4)
			MABUFFSPACINGY = MoveAny:GetEleOption("MABuffBar", "MABUFFSPACINGY", 10)
			MoveAny:UpdateBuffDirections()
			if ConsolidatedBuffs then
				ConsolidatedBuffs:SetParent(MABuffBar)
			end

			if TempEnchant1 then
				TempEnchant1:SetPoint("CENTER", 0, 0)
			end

			if TempEnchant2 then
				TempEnchant2:SetPoint("CENTER", 0, 0)
			end

			if TempEnchant3 then
				TempEnchant3:SetPoint("CENTER", 0, 0)
			end

			if MoveAny:GetWoWBuild() == "RETAIL" then
				MoveAny:ForeachChildren(
					BuffFrame.AuraContainer,
					function(child)
						if child and child.masetup == nil then
							child.masetup = true
							function child:GetMAEle()
								return MABuffBar
							end

							if MoveAny:GetEleOption("MABuffBar", "ClickThrough", false, "ClickThrough6") then
								hooksecurefunc(
									child,
									"EnableMouse",
									function(sel, bo)
										if sel.ma_enablemouse then return end
										sel.ma_enablemouse = true
										sel:EnableMouse(false)
										sel.ma_enablemouse = false
									end
								)

								child:EnableMouse(false)
							end
						end
					end, "Buffbar"
				)
			else
				for bid = 1, 32 do
					local bbtn = _G["BuffButton" .. bid]
					if bbtn then
						if bbtn.masetup == nil then
							bbtn.masetup = true
							function bbtn:GetMAEle()
								return MABuffBar
							end

							if MoveAny:GetEleOption("MABuffBar", "ClickThrough", false, "ClickThrough7") then
								hooksecurefunc(
									bbtn,
									"EnableMouse",
									function(sel, bo)
										if sel.ma_enablemouse then return end
										sel.ma_enablemouse = true
										sel:EnableMouse(false)
										sel.ma_enablemouse = false
									end
								)

								bbtn:EnableMouse(false)
							end

							hooksecurefunc(
								bbtn,
								"SetPoint",
								function(sel, ...)
									if sel.setpoint_bbtn then return end
									sel.setpoint_bbtn = true
									local p1, _, p3, _, _ = MABuffBar:GetPoint()
									local bp1, bp3 = MoveAny:GetBuffPosition("MABuffBar", p1, p3)
									local sw2, sh2 = sel:GetSize()
									local numBuffs = 1
									local prevBuff = nil
									for i = 1, 32 do
										local btn = _G["BuffButton" .. i]
										if i == bid then break end
										if btn and MoveAny:GetParent(btn) == BuffFrame then
											numBuffs = numBuffs + 1
											prevBuff = btn
										end
									end

									local count = MoveAny:GetEnchantCount()
									if GetCVarBool("consolidateBuffs") then
										if MoveAny:GetWoWBuild() == "CLASSIC" then
											SetCVar("consolidateBuffs", false)
											MoveAny:INFO("Consolidate Buffs is 'true', but classic era don't have this. Setting it to 'false'.")
										end

										count = count + 1
									end

									local id = numBuffs + count
									local caly = (id - 0.1) / MABUFFLIMIT
									local cy = caly - caly % 1
									if MoveAny:GetParent(bbtn) == BuffFrame then
										if numBuffs == 1 then
											local posx = 0
											if rel == "RIGHT" then
												posx = -count * (sw2 + MABUFFSPACINGX)
											else
												posx = count * (sw2 + MABUFFSPACINGX)
											end

											local posy = 0
											if MABUFFLIMIT == 1 then
												posx = 0
												if dirV == "BOTTOM" then
													posy = -30 - MABUFFSPACINGY
												else
													posy = 30 + MABUFFSPACINGY
												end
											end

											MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, posx, posy)
										else
											if id % MABUFFLIMIT == 1 or MABUFFLIMIT == 1 then
												if dirV == "BOTTOM" then
													MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, 0, -cy * (sh2 + MABUFFSPACINGY))
												else
													MoveAny:SetPoint(sel, bp1, MABuffBar, bp3, 0, cy * (sh2 + MABUFFSPACINGY))
												end
											elseif prevBuff then
												if rel == "RIGHT" then
													MoveAny:SetPoint(sel, rel, prevBuff, dirH, -MABUFFSPACINGX, 0)
												else
													MoveAny:SetPoint(sel, rel, prevBuff, dirH, MABUFFSPACINGX, 0)
												end
											end
										end
									end

									sel.setpoint_bbtn = false
								end
							)
						end

						bbtn:ClearAllPoints()
						bbtn:SetPoint("CENTER", 0, 0)
					end
				end
			end

			-- Masque
			if LibStub then
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
		end

		hooksecurefunc(
			MABuffBar,
			"SetPoint",
			function(sel, ...)
				MoveAny:UpdateBuffs()
			end
		)

		local f = CreateFrame("FRAME")
		f:RegisterEvent("UNIT_AURA")
		f:SetScript(
			"OnEvent",
			function(sel, event, ...)
				if event == "UNIT_AURA" then
					local unit = ...
					if unit and unit == "player" then
						MoveAny:UpdateBuffs()
					end
				end
			end
		)

		C_Timer.After(1, MoveAny.UpdateBuffs)
	end
end
