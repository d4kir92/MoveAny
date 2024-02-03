local _, MoveAny = ...
local MAFRAMES = {"InspectRecipeFrame", "PVPParentFrame", "SettingsPanel", "SplashFrame", "GameMenuFrame", "InterfaceOptionsFrame", "QuickKeybindFrame", "VideoOptionsFrame", "KeyBindingFrame", "MacroFrame", "AddonList", "ContainerFrameCombinedBags", "LFGParentFrame", "CharacterFrame", "InspectFrame", "SpellBookFrame", "PlayerTalentFrame", "ClassTalentFrame", "FriendsFrame", "HelpFrame", "TradeFrame", "TradeSkillFrame", "CraftFrame", "QuestLogFrame", "WorldMapFrame", "ChallengesKeystoneFrame", "CovenantMissionFrame", "OrderHallMissionFrame", "PVPMatchScoreboard", "GossipFrame", "MerchantFrame", "PetStableFrame", "QuestFrame", "ClassTrainerFrame", "AchievementFrame", "PVEFrame", "EncounterJournal", "WeeklyRewardsFrame", "BankFrame", "WardrobeFrame", "DressUpFrame", "MailFrame", "OpenMailFrame", "AuctionHouseFrame", "AuctionFrame", "ProfessionsCustomerOrdersFrame", "AnimaDiversionFrame", "CovenantSanctumFrame", "SoulbindViewer", "GarrisonLandingPage", "PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton", "WorldStateScoreFrame", "ItemTextFrame", "ExpansionLandingPage", "MajorFactionRenownFrame", "GenericTraitFrame", "FlightMapFrame", "TaxiFrame", "ItemUpgradeFrame", "ProfessionsFrame", "CommunitiesFrame", "CollectionsJournal", "CovenantRenownFrame", "ChallengesKeystoneFrame", "ScriptErrorsFrame", "CalendarFrame", "TimeManagerFrame", "GuildBankFrame", "ItemSocketingFrame", "BlackMarketFrame", "QuestLogPopupDetailFrame", "ItemInteractionFrame", "GarrisonCapacitiveDisplayFrame", "ChannelFrame",}
--[[if MoveAny:GetWoWBuild() ~= "RETAIL" then]]
-- Buggy on retail --
if StaticPopup1 then
	hooksecurefunc(
		StaticPopup1,
		"Hide",
		function(sel)
			if not InCombatLockdown() then
				sel:ClearAllPoints()
			end
		end
	)

	StaticPopup1:ClearAllPoints()
	tinsert(MAFRAMES, "StaticPopup1")
end

if StaticPopup2 then
	hooksecurefunc(
		StaticPopup2,
		"Hide",
		function(sel)
			if not InCombatLockdown() then
				sel:ClearAllPoints()
			end
		end
	)

	StaticPopup2:ClearAllPoints()
	tinsert(MAFRAMES, "StaticPopup2")
end

tinsert(MAFRAMES, "ReadyCheckFrame")
-- Buggy on retail --
--end
local MAFS = {}
for i, v in pairs(MAFRAMES) do
	MAFS[v] = v
end

if ScriptErrorsFrame and ScriptErrorsFrame.DragArea then
	hooksecurefunc(
		ScriptErrorsFrame.DragArea,
		"SetParent",
		function(sel)
			if sel.ma_setparent then return end
			sel.ma_setparent = true
			sel:SetParent(MAHIDDEN)
			sel.ma_setparent = false
		end
	)

	ScriptErrorsFrame.DragArea:SetParent(MAHIDDEN)
end

local currentFrame = nil
local currentFrameName = nil
local prevMouseX = nil
local prevMouseY = nil
function MoveAny:UpdateCurrentFrame()
	if currentFrame ~= nil then
		if not currentFrame:IsShown() then
			currentFrame:SetAlpha(1)
			currentFrame = nil
			currentFrameName = nil
			GameTooltip:Hide()
		end

		local curMouseX, curMouseY = GetCursorPosition()
		if prevMouseX and prevMouseY then
			if curMouseY > prevMouseY then
				local newScale = math.min(currentFrame:GetScale() + 0.006, 1.5)
				if newScale > 0 then
					newScale = tonumber(string.format("%.4f", newScale))
					currentFrame:SetScale(newScale)
					if currentFrame.isMaximized and newScale > 1 then
						newScale = 1
					end

					MoveAny:SetFrameScale(currentFrameName, newScale)
				end
			elseif curMouseY < prevMouseY then
				local newScale = math.max(currentFrame:GetScale() - 0.006, 0.5)
				if newScale > 0 then
					newScale = tonumber(string.format("%.4f", newScale))
					currentFrame:SetScale(newScale)
					if currentFrame.isMaximized and newScale > 1 then
						newScale = 1
					end

					MoveAny:SetFrameScale(currentFrameName, newScale)
				end
			end
		end

		GameTooltip:SetOwner(currentFrame)
		GameTooltip:SetText(MoveAny:MathR(currentFrame:GetScale() * 100) .. "%")
		prevMouseX = curMouseX
		prevMouseY = curMouseY
		C_Timer.After(0.01, MoveAny.UpdateCurrentFrame)
	end
end

function MoveAny:FrameDragInfo(c)
	if c > 0 then
		if IsMouseButtonDown("RightButton") or IsMouseButtonDown("LeftButton") or IsMouseButtonDown("MiddleButton") then
			C_Timer.After(
				0.01,
				function()
					MoveAny:FrameDragInfo(c - 1)
				end
			)
		end
	elseif MoveAny:IsEnabled("SHOWTIPS", true) then
		if IsMouseButtonDown("RightButton") then
			if MoveAny:IsEnabled("FRAMESKEYSCALE", false) then
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYSCALE"), MoveAny:GV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		elseif IsMouseButtonDown("LeftButton") then
			if MoveAny:IsEnabled("FRAMESKEYDRAG", false) then
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYDRAG"), MoveAny:GV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		elseif IsMouseButtonDown("MiddleButton") then
			if MoveAny:IsEnabled("FRAMESKEYRESET", false) then
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYRESET"), MoveAny:GV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		end
	end
end

local EnableMouseFrames = {"PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton"}
local HookedEnableMouseFrames = {}
function MoveAny:UpdateMoveFrames()
	if MoveAny:IsEnabled("MOVEFRAMES", true) then
		for i, name in pairs(EnableMouseFrames) do
			local frame = _G[name]
			if frame and HookedEnableMouseFrames[name] == nil then
				HookedEnableMouseFrames[name] = true
				hooksecurefunc(
					frame,
					"Show",
					function(sel)
						sel:EnableMouse(true)
					end
				)

				frame:EnableMouse(true)
			end
		end

		if not InCombatLockdown() then
			for i, name in pairs(MAFS) do
				local frame = MoveAny:GetFrame(_G[name], name)
				if frame then
					MAFS[name] = nil
					local fm = _G[name .. "Move"]
					if fm == nil then
						fm = CreateFrame("FRAME", name .. "Move", MoveAny:GetMainPanel())
						fm:SetMovable(true)
						fm:SetUserPlaced(false)
						fm:SetClampedToScreen(true)
						fm:RegisterForDrag("Any")
						fm:EnableMouse(false)
						hooksecurefunc(
							frame,
							"SetScale",
							function(sel, scale)
								if scale and scale > 0 then
									fm:SetScale(scale)
								end
							end
						)

						function fm:UpdatePreview()
							local fM = _G[name .. "Move"]
							if fM and fM.ma_ismoving then
								if fM:GetLeft() then
									fM.ma_x = fM:GetLeft()
									fM.ma_y = fM:GetTop() - fM:GetHeight()
									fM.ma_x = MoveAny:Snap(fM.ma_x, MoveAny:GetSnapWindowSize())
									fM.ma_y = MoveAny:Snap(fM.ma_y, MoveAny:GetSnapWindowSize())
									MoveAny:SetFramePoint(name, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", fM.ma_x, fM.ma_y)
									local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
									if dbp1 and dbp3 and not InCombatLockdown() then
										frame:ClearAllPoints()
										frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
									end
								end

								C_Timer.After(0.01, fm.UpdatePreview)
							end
						end
					end

					frame:SetClampedToScreen(true)
					function MoveAny:MAFrameStopMoving(frameObj)
						local name2 = frameObj:GetName()
						local fM = _G[name2 .. "Move"]
						if fM.ma_ismoving then
							fM.ma_ismoving = false
							fM:StopMovingOrSizing()
							fM:SetUserPlaced(false)
						end

						currentFrame = nil
						currentFrameName = nil
					end

					function MoveAny:CheckSave(frameObj)
						if not MoveAny:IsEnabled("SAVEFRAMEPOSITION", true) then
							MoveAny:SetFramePoint(name, nil, nil, nil, nil, nil)
							frameObj:SetMovable(true)
							if frameObj.SetUserPlaced then
								frameObj:SetUserPlaced(false)
							end
						end

						if not InCombatLockdown() and not MoveAny:IsEnabled("SAVEFRAMESCALE", true) then
							MoveAny:SetFrameScale(name, nil)
							local scale = frameObj:GetScale()
							if scale and scale > 0 then
								frameObj:SetScale(scale)
							end
						end
					end

					MoveAny:CheckSave(frame)
					frame:HookScript(
						"OnHide",
						function()
							MoveAny:MAFrameStopMoving(frame)
							if MoveAny.CheckSave then
								MoveAny:CheckSave(frame)
							end
						end
					)

					function MoveAny:IsResetButtonDown(btn)
						return btn == "MiddleButton"
					end

					frame:RegisterForDrag("Any")
					frame:HookScript(
						"OnMouseDown",
						function(sel, btn)
							if frame:GetPoint() then
								fm:SetSize(frame:GetSize())
								fm:ClearAllPoints()
								if frame:GetLeft() then
									local x = frame:GetLeft()
									local y = frame:GetTop() - frame:GetHeight()
									x = MoveAny:Snap(x, MoveAny:GetSnapWindowSize())
									y = MoveAny:Snap(y, MoveAny:GetSnapWindowSize())
									fm:SetPoint("BOTTOMLEFT", MoveAny:GetMainPanel(), "BOTTOMLEFT", x, y)
								else
									fm:SetAllPoints(frame)
								end
							end

							if (MoveAny:IsEnabled("FRAMESKEYSCALE", false) and MoveAny:IsFrameKeyDown() and btn == "RightButton") or (not MoveAny:IsEnabled("FRAMESKEYSCALE", false) and btn == "RightButton") then
								currentFrame = frame
								currentFrameName = name
								MoveAny:UpdateCurrentFrame()
								GameTooltip:Hide()
							elseif (MoveAny:IsEnabled("FRAMESKEYDRAG", false) and MoveAny:IsFrameKeyDown() and btn == "LeftButton") or (not MoveAny:IsEnabled("FRAMESKEYDRAG", false) and btn == "LeftButton") then
								if not InCombatLockdown() then
									fm:StartMoving()
									fm:SetUserPlaced(false)
									fm.ma_ismoving = true
								end

								fm:UpdatePreview()
							elseif (MoveAny:IsEnabled("FRAMESKEYRESET", false) and MoveAny:IsFrameKeyDown() and MoveAny:IsResetButtonDown(btn)) or (not MoveAny:IsEnabled("FRAMESKEYRESET", false) and MoveAny:IsResetButtonDown(btn)) then
								MoveAny:SetFramePoint(name, nil, nil, nil, nil, nil)
								MoveAny:SetFrameScale(name, nil)
								frame:SetScale(1)
								--frame:ClearAllPoints()
								MoveAny:MSG("[" .. name .. "] is reset, reopen the frame.")
							else
								if MoveAny:IsResetButtonDown(btn) then
									MoveAny:FrameDragInfo(0)
								else
									MoveAny:FrameDragInfo(20)
								end
							end
						end
					)

					frame:HookScript(
						"OnMouseUp",
						function(sel)
							MoveAny:MAFrameStopMoving(sel)
						end
					)

					function MoveAny:MAFrameRetrySetPoint(frameObj)
						frameObj.maretrysetpoint = true
						if not InCombatLockdown() then
							if frameObj:GetPoint() then
								frameObj:SetPoint(frameObj:GetPoint())
							else
								frameObj:SetPoint("CENTER")
							end
						else
							C_Timer.After(
								0.01,
								function()
									MoveAny:MAFrameRetrySetPoint(frameObj)
								end
							)
						end
					end

					hooksecurefunc(
						frame,
						"SetPoint",
						function(sel, p1, p2, p3, p4, p5)
							if sel.maframesetpoint then return end
							sel.maframesetpoint = true
							sel:SetMovable(true)
							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
							if dbp1 and dbp3 then
								if not InCombatLockdown() then
									sel.maretrysetpoint = nil
									local w, h = sel:GetSize()
									sel:ClearAllPoints()
									sel:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
									if sel:GetNumPoints() > 1 then
										sel:SetSize(w, h)
									end
								elseif sel.maretrysetpoint == nil and MoveAny.MAFrameRetrySetPoint then
									MoveAny:MAFrameRetrySetPoint(frame)
								end
							end

							sel.maframesetpoint = false
						end
					)

					hooksecurefunc(
						frame,
						"SetScale",
						function(sel, scale)
							if sel.masetscale_frame then return end
							sel.masetscale_frame = true
							if MoveAny:GetFrameScale(name) or scale then
								local sca = MoveAny:GetFrameScale(name) or scale
								if sel.isMaximized and sca and sca > 1 then
									sca = 1
								end

								if sca and sca > 0 then
									sel:SetScale(sca)
								end
							end

							sel.masetscale_frame = false
						end
					)

					if MoveAny:GetFrameScale(name) and MoveAny:GetFrameScale(name) > 0 then
						if frame:GetHeight() * MoveAny:GetFrameScale(name) > GetScreenHeight() then
							if GetScreenHeight() / frame:GetHeight() > 0 then
								MoveAny:SetFrameScale(name, GetScreenHeight() / frame:GetHeight())
							end

							frame:SetScale(MoveAny:GetFrameScale(name))
						end

						if MoveAny:GetFrameScale(name) and MoveAny:GetFrameScale(name) > 0 then
							frame:SetScale(MoveAny:GetFrameScale(name))
						end
					else
						local scale = frame:GetScale()
						if scale and scale > 0 then
							frame:SetScale(scale)
						end
					end

					if frame.GetPoint and frame:GetPoint() then
						local p1, p2, p3, p4, p5 = frame:GetPoint()
						if not InCombatLockdown() then
							frame:ClearAllPoints()
							frame:SetPoint(p1, p2, p3, p4, p5)
						else
							function MoveAny:MAFrameUpdatePos(frameObj)
								if not InCombatLockdown() then
									frameObj:ClearAllPoints()
									frameObj:SetPoint(p1, p2, p3, p4, p5)
								else
									C_Timer.After(
										0.03,
										function()
											MoveAny:MAFrameUpdatePos(frameObj)
										end
									)
								end
							end

							MoveAny:MAFrameUpdatePos(frame)
						end
					end
				end
			end
		else
			C_Timer.After(0.1, MoveAny.UpdateMoveFrames)
		end
	end
end

function MoveAny:MoveFrames()
	local f = CreateFrame("FRAME")
	f:RegisterEvent("ADDON_LOADED")
	if MoveAny:IsEnabled("MOVESMALLBAGS", false) then
		for i = 1, 20 do
			if _G["ContainerFrame" .. i] and not MAFS["ContainerFrame" .. i] then
				MAFS["ContainerFrame" .. i] = "ContainerFrame" .. i
			end
		end
	end

	if MoveAny:IsEnabled("MOVELOOTFRAME", false) then
		MAFS["LootFrame"] = "LootFrame"
	end

	f:SetScript(
		"OnEvent",
		function(sel, event, ...)
			MoveAny:UpdateMoveFrames()
		end
	)

	MoveAny:UpdateMoveFrames()
	if PVPFrame then
		PVPFrame:EnableMouse(false)
	end

	if BattlefieldFrame then
		BattlefieldFrame:EnableMouse(false)
	end
end