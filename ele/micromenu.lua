local _, MoveAny = ...
function MoveAny:GetMicroButtonSize()
	if MoveAny:GetWoWBuild() == "RETAIL" then return 24, 34 end

	return 26, 32
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
					if D4:GetWoWBuild() ~= "RETAIL" then
						mb:SetParent(MAMenuBar)
						mb.ofx = -2
						mb.ofy = 22
						mb.rsw = 24
						mb.rsh = 32
					else
						mb:SetSize(sw2, sh2)
					end

					mb:ClearAllPoints()
					mb:SetPoint("TOPLEFT", MAMenuBar, "TOPLEFT", 0, 0)
					if MoveAny:GetWoWBuild() == "RETAIL" then
						mb:SetPoint("BOTTOM", MAMenuBar, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
					else
						mb:SetPoint("BOTTOM", MAMenuBar, "BOTTOM", 0, MoveAny:GetMicroButtonYOffset())
					end

					hooksecurefunc(
						MAMenuBar,
						"SetAlpha",
						function(sel, alpha)
							mb:SetAlpha(alpha)
						end
					)

					if D4:GetWoWBuild() == "RETAIL" and mb ~= HelpMicroButton and mb ~= MainMenuMicroButton then
						hooksecurefunc(
							MAMenuBar,
							"SetScale",
							function(sel, scale)
								mb:SetScale(scale)
							end
						)

						mb:SetScale(MAMenuBar:GetScale())
					end

					hooksecurefunc(
						MAMenuBar,
						"Hide",
						function(sel)
							mb:Show()
						end
					)

					mb:Show()
					tinsert(MAMenuBar.btns, mb)
				end
			end
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(MAMenuBar, "MAMenuBar")
			MoveAny:UpdateActionBar(MAMenuBar)
			C_Timer.After(
				1,
				function()
					MoveAny:UpdateActionBar(MAMenuBar)
				end
			)
		end
	end
end