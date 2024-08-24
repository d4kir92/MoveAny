local _, MoveAny = ...
local MAFRAMES = {"HeroTalentsSelectionDialog", "CurrencyTransferLog", "PVPReadyDialog", "DelvesCompanionConfigurationFrame", "DelvesDifficultyPickerFrame", "ItemRefTooltip", "BattlefieldMapFrame", "ReforgingFrameInvisibleButton", "ReforgingFrame", "WeakAurasOptions", "ProfessionsBookFrame", "PlayerSpellsFrame", "GroupLootHistoryFrame", "ModelPreviewFrame", "ScrappingMachineFrame", "TabardFrame", "PVPFrame", "ArchaeologyFrame", "QuestLogDetailFrame", "InspectRecipeFrame", "PVPParentFrame", "SettingsPanel", "SplashFrame", "GameMenuFrame", "InterfaceOptionsFrame", "QuickKeybindFrame", "VideoOptionsFrame", "KeyBindingFrame", "MacroFrame", "AddonList", "ContainerFrameCombinedBags", "LFGParentFrame", "CharacterFrame", "InspectFrame", "SpellBookFrame", "PlayerTalentFrame", "ClassTalentFrame", "FriendsFrame", "HelpFrame", "TradeFrame", "TradeSkillFrame", "CraftFrame", "QuestLogFrame", "WorldMapFrame", "ChallengesKeystoneFrame", "CovenantMissionFrame", "OrderHallMissionFrame", "PVPMatchScoreboard", "GossipFrame", "MerchantFrame", "PetStableFrame", "QuestFrame", "ClassTrainerFrame", "AchievementFrame", "PVEFrame", "EncounterJournal", "WeeklyRewardsFrame", "BankFrame", "WardrobeFrame", "DressUpFrame", "MailFrame", "OpenMailFrame", "AuctionHouseFrame", "AuctionFrame", "ProfessionsCustomerOrdersFrame", "AnimaDiversionFrame", "CovenantSanctumFrame", "SoulbindViewer", "GarrisonLandingPage", "PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton", "WorldStateScoreFrame", "ItemTextFrame", "ExpansionLandingPage", "MajorFactionRenownFrame", "GenericTraitFrame", "FlightMapFrame", "TaxiFrame", "ItemUpgradeFrame", "ProfessionsFrame", "CommunitiesFrame", "CollectionsJournal", "CovenantRenownFrame", "ChallengesKeystoneFrame", "ScriptErrorsFrame", "CalendarFrame", "TimeManagerFrame", "GuildBankFrame", "ItemSocketingFrame", "BlackMarketFrame", "QuestLogPopupDetailFrame", "ItemInteractionFrame", "GarrisonCapacitiveDisplayFrame", "ChannelFrame",}
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

function MoveAny:SetPoint(window, p1, p2, p3, p4, p5)
	window.ma_ignore_setpointbase = window.ma_ignore_setpointbase or false
	if InCombatLockdown() and window:IsProtected() then return false end
	if p1 then
		window:ClearAllPoints()
		local SetPoint = window.SetPointBase or window.SetPoint
		window.ma_ignore_setpointbase = true
		SetPoint(window, p1, p2 or "UIParent", p3, p4, p5)
		window.ma_ignore_setpointbase = false
	end

	return true
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
				local newScale = math.min(currentFrame:GetScale() + 0.006, 2.5)
				if newScale > 0 then
					newScale = tonumber(string.format("%.3f", newScale))
					currentFrame:SetScale(newScale)
					if currentFrame.isMaximized and newScale > 1 then
						newScale = 1
					end

					MoveAny:SetFrameScale(currentFrameName, newScale)
				end
			elseif curMouseY < prevMouseY then
				local newScale = math.max(currentFrame:GetScale() - 0.006, 0.5)
				if newScale > 0 then
					newScale = tonumber(string.format("%.3f", newScale))
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
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYSCALE"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		elseif IsMouseButtonDown("LeftButton") then
			if MoveAny:IsEnabled("FRAMESKEYDRAG", false) then
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYDRAG"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		elseif IsMouseButtonDown("MiddleButton") then
			if MoveAny:IsEnabled("FRAMESKEYRESET", false) then
				MoveAny:MSG(format(MoveAny:GT("LID_FRAMESKEYRESET"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. ".")
			end
		end
	end
end

local EnableMouseFrames = {"PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton"}
local HookedEnableMouseFrames = {}
local run = false
function MoveAny:UpdateMoveFrames(force)
	if force then
		run = false
	end

	if run then return end
	run = true
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
			local count = 0
			for i, name in pairs(MAFS) do
				count = count + 1
				local frame = MoveAny:GetFrame(_G[name], name)
				if frame ~= nil then
					MAFS[name] = nil
					local fm = _G[name .. "Move"]
					if fm == nil then
						fm = CreateFrame("FRAME", name .. "Move", MoveAny:GetMainPanel())
						fm:SetMovable(true)
						fm:SetUserPlaced(false)
						fm:SetClampedToScreen(false)
						fm:RegisterForDrag("LeftClick")
						fm:EnableMouse(false)
						hooksecurefunc(
							frame,
							"SetScale",
							function(sel, scale)
								if scale and scale > 0 and (currentFrame == nil or currentFrame ~= sel) then
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
									MoveAny:SaveFramePointToDB(name, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", fM.ma_x, fM.ma_y)
									local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
									if name == "LootFrame" and MoveAny:IsEnabled("MOVELOOTFRAME", false) == false then return end
									if dbp1 and dbp3 and not InCombatLockdown() then
										MoveAny:SetPoint(frame, dbp1, nil, dbp3, dbp4, dbp5)
									else
										frame:ClearAllPoints()
										frame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", fM.ma_x, fM.ma_y)
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
							MoveAny:SaveFramePointToDB(name, nil, nil, nil, nil, nil)
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

					frame:RegisterForDrag("LeftClick")
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
								MoveAny:SaveFramePointToDB(name, nil, nil, nil, nil, nil)
								MoveAny:SetFrameScale(name, nil)
								frame:SetScale(1)
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

							if name == "LootFrame" and MoveAny:IsEnabled("MOVELOOTFRAME", false) == false then return end
							local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
							if dbp1 and dbp3 then
								--if not InCombatLockdown() then
								sel.maretrysetpoint = nil
								local w, h = sel:GetSize()
								MoveAny:SetPoint(sel, dbp1, nil, dbp3, dbp4, dbp5)
								if sel:GetNumPoints() > 1 then
									sel:SetSize(w, h)
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
							if name == "LootFrame" and MoveAny:IsEnabled("MOVELOOTFRAME", false) == false then return end
							if MoveAny:GetFrameScale(name) or scale then
								local sca = MoveAny:GetFrameScale(name) or scale
								if sel.isMaximized and sca and sca > 1 then
									sca = 1
								end

								if sca and sca > 0 and (currentFrame == nil or currentFrame ~= sel) then
									sel:SetScale(sca)
								end
							end

							sel.masetscale_frame = false
						end
					)

					if MoveAny:GetFrameScale(name) and MoveAny:GetFrameScale(name) > 0 then
						if frame:GetHeight() * MoveAny:GetFrameScale(name) > GetScreenHeight() then
							frame:SetScale(MoveAny:GetFrameScale(name))
							C_Timer.After(
								4,
								function()
									if frame:GetHeight() * MoveAny:GetFrameScale(name) > GetScreenHeight() then
										if GetScreenHeight() / frame:GetHeight() > 0 then
											MoveAny:SetFrameScale(name, GetScreenHeight() / frame:GetHeight())
										end

										frame:SetScale(MoveAny:GetFrameScale(name))
									end
								end
							)
						elseif MoveAny:GetFrameScale(name) and MoveAny:GetFrameScale(name) > 0 then
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
						if name ~= "LootFrame" or MoveAny:IsEnabled("MOVELOOTFRAME", false) then
							MoveAny:SetPoint(frame, p1, p2, p3, p4, p5)
						end
					end
				end
			end
		else
			C_Timer.After(
				0.04,
				function()
					run = false
					MoveAny:UpdateMoveFrames(false)
				end
			)
		end
	end
end

function MoveAny:ThinkMoveFrames()
	MoveAny:UpdateMoveFrames(false)
	C_Timer.After(
		1,
		function()
			MoveAny:ThinkMoveFrames()
		end
	)
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

	if MoveAny:IsEnabled("MOVELOOTFRAME", false) or MoveAny:IsEnabled("SCALELOOTFRAME", false) then
		MAFS["LootFrame"] = "LootFrame"
	end

	f:SetScript(
		"OnEvent",
		function(sel, event, ...)
			MoveAny:UpdateMoveFrames(true)
		end
	)

	MoveAny:UpdateMoveFrames(true)
	MoveAny:ThinkMoveFrames()
	if BattlefieldFrame then
		BattlefieldFrame:EnableMouse(false)
	end
end
