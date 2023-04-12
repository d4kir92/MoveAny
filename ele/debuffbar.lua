local _, MoveAny = ...
local btnsize = 36
local debuffs = {}

function MoveAny:InitDebuffBar()
	if MoveAny:IsEnabled("DEBUFFS", true) then
		MADebuffBar = CreateFrame("Frame", "MADebuffBar", UIParent)
		MADebuffBar:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -165, -132)
		MADebuffBar:SetSize(btnsize * 10, btnsize * 3)

		function MALoadDebuff()
			for i = 1, 32 do
				local debuffBtn = _G["DebuffButton" .. i]

				if debuffBtn and not tContains(debuffs, debuffBtn) then
					table.insert(debuffs, debuffBtn)

					if i == 1 then
						hooksecurefunc(debuffBtn, "SetPoint", function(sel, ...)
							if sel.debuffsetpoint then return end
							sel.debuffsetpoint = true
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							sel:SetParent(MADebuffBar)
							sel:ClearAllPoints()
							sel:SetPoint("TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0)
							sel.debuffsetpoint = false
						end)

						debuffBtn:ClearAllPoints()
						debuffBtn:SetPoint("TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0)
					else
						local op1, op2, op3, op4, op5 = debuffBtn:GetPoint()

						hooksecurefunc(debuffBtn, "SetPoint", function(sel, ...)
							if sel.debuffsetpoint then return end
							sel.debuffsetpoint = true
							local p1, p2, p3, p4, p5 = ...
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							sel:SetParent(MADebuffBar)
							sel:ClearAllPoints()
							sel:SetPoint(p1, p2, p3, p4, p5)
							sel.debuffsetpoint = false
						end)

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

		function MAUpdateDebuffDirections()
			local p1, _, p3, _, _ = MADebuffBar:GetPoint()
			rel = "RIGHT"

			if p1 == "TOPLEFT" then
				rel = "LEFT"
			elseif p1 == "LEFT" then
				rel = "LEFT"
			elseif p1 == "BOTTOMLEFT" then
				rel = "LEFT"
			end

			dirH = "LEFT"

			if rel == "LEFT" then
				dirH = "RIGHT"
			end

			dirV = "BOTTOM"

			if p3 == "BOTTOMLEFT" then
				dirV = "TOP"
			elseif p3 == "BOTTOM" then
				dirV = "TOP"
			elseif p3 == "BOTTOMRIGHT" then
				dirV = "TOP"
			end
		end

		MAUpdateDebuffDirections()

		function MAUpdateDebuffs()
			MAUpdateDebuffDirections()

			for i = 1, 32 do
				local dbtn = _G["DebuffButton" .. i]

				if dbtn then
					if dbtn.masetup == nil then
						dbtn.masetup = true

						hooksecurefunc(dbtn, "SetPoint", function(sel, ...)
							if sel.setpoint_dbtn then return end
							sel.setpoint_dbtn = true
							local p1, _, p3, _, _ = MADebuffBar:GetPoint()
							local _, sh = sel:GetSize()
							local id = i
							local caly = (id - 0.1) / 10
							local cy = caly - caly % 1
							sel:ClearAllPoints()

							if i == 1 then
								if rel == "RIGHT" then
									sel:SetPoint(p1, MADebuffBar, p3, 0, 0)
								else
									sel:SetPoint(p1, MADebuffBar, p3, 0, 0)
								end
							else
								if id % 10 == 1 then
									if dirV == "BOTTOM" then
										sel:SetPoint(p1, MADebuffBar, p3, 0, -cy * (sh + 10))
									else
										sel:SetPoint(p1, MADebuffBar, p3, 0, cy * (sh + 10))
									end
								else
									if rel == "RIGHT" then
										sel:SetPoint(rel, _G["DebuffButton" .. (i - 1)], dirH, -4, 0)
									else
										sel:SetPoint(rel, _G["DebuffButton" .. (i - 1)], dirH, 4, 0)
									end
								end
							end

							sel.setpoint_dbtn = false
						end)
					end

					dbtn:SetPoint("CENTER", 0, 0)
				end
			end
		end

		if MABuffBar then
			hooksecurefunc(MABuffBar, "SetPoint", function(sel, ...)
				MAUpdateDebuffs()
			end)
		end

		hooksecurefunc(MADebuffBar, "SetPoint", function(sel, ...)
			MAUpdateDebuffs()
		end)

		local f = CreateFrame("FRAME")
		f:RegisterEvent("UNIT_AURA")

		f:SetScript("OnEvent", function(sel, event, ...)
			if event == "UNIT_AURA" then
				unit = ...

				if unit and unit == "player" then
					MAUpdateDebuffs()
				end
			end
		end)

		C_Timer.After(1, MAUpdateDebuffs)
	end
end