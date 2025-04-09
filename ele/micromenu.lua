local _, MoveAny = ...
function MoveAny:GetMicroButtonSize()
	if MoveAny:GetWoWBuild() == "RETAIL" then return 24, 32 end

	return 24, 33
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
			MBTNS = {"CharacterMicroButton", "ProfessionMicroButton", "PlayerSpellsMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "EJMicroButton", "StoreMicroButton", "HelpMicroButton", "MainMenuMicroButton"}
		elseif MoveAny:GetWoWBuild() == "CATA" then
			MBTNS = {"CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton", "AchievementMicroButton", "QuestLogMicroButton", "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton", "PVPMicroButton", "LFGMicroButton", "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton", "HelpMicroButton"}
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
		hooksecurefunc(
			MAMenuBar,
			"SetParent",
			function(sel, parent)
				if parent == MAHIDDEN then
					for i, mbname in pairs(MBTNS) do
						local mb = _G[mbname]
						if mb then
							mb:SetAlpha(0)
							mb:EnableMouse(false)
						end
					end
				else
					for i, mbname in pairs(MBTNS) do
						local mb = _G[mbname]
						if mb then
							mb:SetAlpha(1)
							mb:EnableMouse(true)
						end
					end
				end
			end
		)

		if MBTNS then
			for i, mbname in pairs(MBTNS) do
				local mb = _G[mbname]
				if mb then
					function mb:GetMAEle()
						return MAMenuBar
					end

					local sw2, sh2 = MoveAny:GetMicroButtonSize()
					if MoveAny:GetWoWBuild() ~= "RETAIL" then
						mb:SetParent(MAMenuBar)
						mb.ofx = -2
						mb.ofy = 22
						mb.rsw = 24
						mb.rsh = 33
					else
						mb:SetSize(sw2, sh2)
					end

					hooksecurefunc(
						mb,
						"SetPoint",
						function(sel)
							if MAMenuBar.ma_set_po then return end
							MAMenuBar.ma_set_po = true
							if MoveAny.UpdateActionBar then
								MoveAny:UpdateActionBar(MAMenuBar)
							end

							MAMenuBar.ma_set_po = false
						end
					)

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

					if MoveAny:GetWoWBuild() == "RETAIL" then
						hooksecurefunc(
							MAMenuBar,
							"SetScale",
							function(sel, scale)
								if InCombatLockdown() and sel:IsProtected() then return false end
								if scale and type(scale) == "number" then
									mb:SetScale(scale)
								end
							end
						)

						hooksecurefunc(
							mb,
							"SetScale",
							function(sel, scale)
								if InCombatLockdown() and sel:IsProtected() then return false end
								if sel.ma_set_s then return end
								sel.ma_set_s = true
								mb:SetScale(MAMenuBar:GetScale())
								sel.ma_set_s = false
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

					if MicroMenu and MicroMenu.SetScaleAdjustment then
						hooksecurefunc(
							MicroMenu,
							"SetScaleAdjustment",
							function(sel)
								if sel.ma_SetScaleAdjustment then return end
								sel.ma_SetScaleAdjustment = true
								sel:SetScaleAdjustment(1)
								sel.ma_SetScaleAdjustment = false
							end
						)

						MicroMenu:SetScaleAdjustment(1)
					end

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
					if MoveAny:GetWoWBuild() ~= "RETAIL" then
						function MoveAny:UpdateMicroMenu()
							local overrideChanged = false
							local parentChanged = false
							if OverrideActionBar and (OverrideActionBar:IsShown() ~= OverrideActionBar.isshown or OverrideActionBar.slideOut and OverrideActionBar.slideOut:IsPlaying() ~= OverrideActionBar.isplaying) then
								OverrideActionBar.isshown = OverrideActionBar:IsShown()
								OverrideActionBar.isplaying = OverrideActionBar.slideOut:IsPlaying()
								overrideChanged = true
							end

							if CharacterMicroButton.curparent ~= MoveAny:GetParent(CharacterMicroButton) then
								CharacterMicroButton.curparent = MoveAny:GetParent(CharacterMicroButton)
								parentChanged = true
							end

							if MoveAny:GetParent(CharacterMicroButton) ~= MAMenuBar and parentChanged and (MAMenuBar.redots == nil or GetTime() + 0.11 > MAMenuBar.redots) then
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

							C_Timer.After(0.1, MoveAny.UpdateMicroMenu)
						end

						MoveAny:UpdateMicroMenu()
					end
				end
			)
		end
	end
end
