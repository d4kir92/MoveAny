local _, MoveAny = ...
function MoveAny:GetMicroButtonSize()
	if D4:GetWoWBuild() == "RETAIL" then return 24, 32 end

	return 24, 33
end

function MoveAny:GetMicroButtonYOffset()
	if D4:GetWoWBuild() == "RETAIL" then return -3 end

	return -4
end

function MoveAny:InitMicroMenu()
	if MoveAny:IsEnabled("MICROMENU", false) then
		local MBTNS = MICRO_BUTTONS
		if MICRO_BUTTONS == nil then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "HelpMicroButton", "MainMenuMicroButton"}
		elseif D4:GetWoWBuild() == "RETAIL" then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "HelpMicroButton", "MainMenuMicroButton"}
		elseif D4:GetWoWBuild() == "CATA" then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "PVPMicroButton", "LFGMicroButton", "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton", "HelpMicroButton"}
		end

		if D4:GetWoWBuild() == "CLASSIC" then
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
		elseif D4:GetWoWBuild() ~= "RETAIL" then
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
						mb.rsh = 33
					else
						mb:SetSize(sw2, sh2)
					end

					mb:ClearAllPoints()
					if D4:GetWoWBuild() == "RETAIL" then
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
					function UpdateMicroMenu()
						local overrideChanged = false
						local parentChanged = false
						if OverrideActionBar:IsShown() ~= OverrideActionBar.isshown or OverrideActionBar.slideOut and OverrideActionBar.slideOut:IsPlaying() ~= OverrideActionBar.isplaying then
							OverrideActionBar.isshown = OverrideActionBar:IsShown()
							OverrideActionBar.isplaying = OverrideActionBar.slideOut:IsPlaying()
							overrideChanged = true
						end

						if CharacterMicroButton.curparent ~= CharacterMicroButton:GetParent() then
							CharacterMicroButton.curparent = CharacterMicroButton:GetParent()
							parentChanged = true
						end

						if CharacterMicroButton:GetParent() ~= MAMenuBar and parentChanged and (MAMenuBar.redots == nil or GetTime() + 0.11 > MAMenuBar.redots) then
							MAMenuBar.redots = GetTime() + 0.11
						end

						if overrideChanged and (MAMenuBar.redots == nil or GetTime() + 0.51 > MAMenuBar.redots) then
							MAMenuBar.redots = GetTime() + 0.51
						end

						if MAMenuBar.redots ~= nil and GetTime() > MAMenuBar.redots + 0.1 then
							if CharacterMicroButton then
								for i, v in pairs(MBTNS) do
									local mmbtn = _G[v]
									if mmbtn then
										mmbtn:SetParent(MAMenuBar)
									end
								end
							end

							MoveAny:UpdateActionBar(MAMenuBar)
							MAMenuBar.redots = nil
						end

						C_Timer.After(0.1, UpdateMicroMenu)
					end

					UpdateMicroMenu()
				end
			)
		end
	end
end
