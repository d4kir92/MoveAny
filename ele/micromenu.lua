local _, MoveAny = ...

function MoveAny:GetMicroButtonSize()
	if MoveAny:GetWoWBuild() == "RETAIL" then return 24, 34 end

	return 24, 32
end

function MoveAny:GetMicroButtonYOffset()
	if MoveAny:GetWoWBuild() == "RETAIL" then return -3 end

	return -4
end

function MoveAny:InitMicroMenu()
	if MoveAny:IsEnabled("MICROMENU", false) then
		local MBTNS = MICRO_BUTTONS

		if MICRO_BUTTONS == nil then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "HelpMicroButton", "MainMenuMicroButton"}
		elseif MoveAny:GetWoWBuild() == "RETAIL" then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "HelpMicroButton", "MainMenuMicroButton"}
		end

		if MoveAny:GetWoWBuild() == "CLASSIC" then
			for i, v in pairs(MBTNS) do
				if v == "LFGMicroButton" then
					tremove(MBTNS, i)
				end
			end
		end

		if MicroButtonAndBagsBar and MicroButtonAndBagsBar.MicroBagBar then
			MicroButtonAndBagsBar.MicroBagBar:Hide()
		end

		local sw1, sh1 = MoveAny:GetMicroButtonSize()
		local mbc = 11

		if MBTNS then
			mbc = #MBTNS
		end

		local opts = MoveAny:GetEleOptions("MICROMENU")
		opts["ROWS"] = opts["ROWS"] or 1
		MAMenuBar = CreateFrame("Frame", "MAMenuBar", MoveAny:GetMainPanel())
		MAMenuBar:SetSize(sw1 * mbc, sh1)

		if MicroButtonAndBagsBar then
			local p1, _, p3, p4, p5 = MicroButtonAndBagsBar:GetPoint()
			MAMenuBar:SetPoint(p1, MoveAny:GetMainPanel(), p3, p4, p5)
		elseif MoveAny:GetWoWBuild() ~= "RETAIL" then
			MAMenuBar:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", 0, 0)
		else
			MAMenuBar:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
		end

		MAMenuBar.btns = {}

		if MBTNS then
			for i, mbname in pairs(MBTNS) do
				local mb = _G[mbname]

				if mb then
					function mb:GetMAEle()
						return MAMenuBar
					end

					local sw2, sh2 = MoveAny:GetMicroButtonSize()
					local hb = CreateFrame("FRAME", mbname .. "_HB", MAMenuBar)
					hb:SetParent(MAMenuBar)
					hb:SetSize(sw2, sh2)
					hb:SetPoint("TOPLEFT", MAMenuBar, "TOPLEFT", 0, 0)

					if MoveAny:DEBUG() then
						hb.t = hb:CreateTexture("hb_debug" .. i, "BACKGROUND", nil, 1)
						hb.t:SetAllPoints(hb)
						hb.t:SetColorTexture(0, 1, 0, 0.5)
					end

					hooksecurefunc(mb, "SetPoint", function(sel, ...)
						if sel.mmbsetpoint then return end
						sel.mmbsetpoint = true
						mb:SetMovable(true)

						if mb.SetUserPlaced and mb:IsMovable() then
							mb:SetUserPlaced(false)
						end

						mb:ClearAllPoints()
						mb:SetParent(hb)

						if MoveAny:GetWoWBuild() == "RETAIL" then
							mb:SetPoint("BOTTOM", hb, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
						else
							mb:SetPoint("BOTTOM", hb, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
						end

						sel.mmbsetpoint = false
					end)

					hooksecurefunc(mb, "SetParent", function(sel, parent)
						if sel.masetparent then return end
						sel.masetparent = true

						if parent ~= hb then
							sel:SetParent(hb)
						end

						sel.masetparent = false
					end)

					mb:ClearAllPoints()
					mb:SetParent(hb)

					if MoveAny:GetWoWBuild() == "RETAIL" then
						mb:SetPoint("BOTTOM", hb, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
					else
						mb:SetPoint("BOTTOM", hb, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
					end

					hooksecurefunc(mb, "Hide", function(sel)
						sel:Show()
					end)

					mb:Show()
					tinsert(MAMenuBar.btns, hb)
				end
			end
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(MAMenuBar, "MAMenuBar")
			MoveAny:UpdateActionBar(MAMenuBar)
		end
	end
end