local _, MoveAny = ...
local MAFRAMES = {"ChatConfigFrame", "CurrencyTransferMenu", "RolePollPopup", "StaticPopup1", "StaticPopup2", "HeroTalentsSelectionDialog", "CurrencyTransferLog", "PVPReadyDialog", "DelvesCompanionConfigurationFrame", "DelvesDifficultyPickerFrame", "ItemRefTooltip", "ReforgingFrameInvisibleButton", "ReforgingFrame", "WeakAurasOptions", "ProfessionsBookFrame", "PlayerSpellsFrame", "GroupLootHistoryFrame", "ModelPreviewFrame", "ScrappingMachineFrame", "TabardFrame", "PVPFrame", "ArchaeologyFrame", "QuestLogDetailFrame", "InspectRecipeFrame", "PVPParentFrame", "SettingsPanel", "SplashFrame", "GameMenuFrame", "InterfaceOptionsFrame", "QuickKeybindFrame", "VideoOptionsFrame", "KeyBindingFrame", "MacroFrame", "AddonList", "ContainerFrameCombinedBags", "LFGParentFrame", "CharacterFrame", "InspectFrame", "SpellBookFrame", "PlayerTalentFrame", "ClassTalentFrame", "FriendsFrame", "HelpFrame", "TradeFrame", "TradeSkillFrame", "CraftFrame", "QuestLogFrame", "WorldMapFrame", "ChallengesKeystoneFrame", "CovenantMissionFrame", "OrderHallMissionFrame", "PVPMatchScoreboard", "GossipFrame", "MerchantFrame", "PetStableFrame", "QuestFrame", "ClassTrainerFrame", "AchievementFrame", "PVEFrame", "EncounterJournal", "WeeklyRewardsFrame", "BankFrame", "WardrobeFrame", "DressUpFrame", "MailFrame", "OpenMailFrame", "AuctionHouseFrame", "AuctionFrame", "ProfessionsCustomerOrdersFrame", "AnimaDiversionFrame", "CovenantSanctumFrame", "SoulbindViewer", "GarrisonLandingPage", "PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton", "WorldStateScoreFrame", "ItemTextFrame", "ExpansionLandingPage", "MajorFactionRenownFrame", "GenericTraitFrame", "FlightMapFrame", "TaxiFrame", "ItemUpgradeFrame", "ProfessionsFrame", "CommunitiesFrame", "CollectionsJournal", "CovenantRenownFrame", "ChallengesKeystoneFrame", "ScriptErrorsFrame", "CalendarFrame", "TimeManagerFrame", "GuildBankFrame", "ItemSocketingFrame", "BlackMarketFrame", "QuestLogPopupDetailFrame", "ItemInteractionFrame", "GarrisonCapacitiveDisplayFrame", "ChannelFrame",}
if StaticPopup1 then
	hooksecurefunc(
		StaticPopup1,
		"Hide",
		function(sel)
			if not InCombatLockdown() or not sel:IsProtected() then
				sel:ClearAllPoints()
			end
		end
	)

	StaticPopup1:ClearAllPoints()
end

if StaticPopup2 then
	hooksecurefunc(
		StaticPopup2,
		"Hide",
		function(sel)
			if not InCombatLockdown() or not sel:IsProtected() then
				sel:ClearAllPoints()
			end
		end
	)

	StaticPopup2:ClearAllPoints()
end

tinsert(MAFRAMES, "ReadyCheckFrame")
local MAFS = {}
for i, v in pairs(MAFRAMES) do
	MAFS[v] = v
end

if ScriptErrorsFrame and ScriptErrorsFrame.DragArea then
	local setParent = false
	hooksecurefunc(
		ScriptErrorsFrame.DragArea,
		"SetParent",
		function(sel)
			if setParent then return end
			setParent = true
			sel:SetParent(MAHIDDEN)
			setParent = false
		end
	)

	ScriptErrorsFrame.DragArea:SetParent(MAHIDDEN)
end

local tab = {}
function MoveAny:SetPoint(window, p1, p2, p3, p4, p5)
	tab[window] = tab[window] or false
	if InCombatLockdown() and window:IsProtected() then return false end
	if p1 then
		local ClearAllPoints = window.FClearAllPoints or window.ClearAllPoints
		ClearAllPoints(window)
		local SetPoint = window.FSetPointBase or window.FSetPoint or window.SetPointBase or window.SetPoint
		tab[window] = true
		SetPoint(window, p1, p2 or "UIParent", p3, p4, p5)
		tab[window] = false
	end

	return true
end

local currentWindowName = nil
local prevMouseX = nil
local prevMouseY = nil
local updatingFrame = false
function MoveAny:UpdateCurrentWindow()
	if currentWindowName ~= nil then
		local currentWindow = _G[currentWindowName]
		if currentWindow then
			if updatingFrame then return end
			updatingFrame = true
			if not currentWindow:IsShown() then
				currentWindow:SetAlpha(1)
				currentWindowName = nil
				GameTooltip:Hide()
			end

			if currentWindowName ~= nil and MoveAny:IsEnabled("SCALEFRAMES", true) then
				local curMouseX, curMouseY = GetCursorPosition()
				if prevMouseX and prevMouseY then
					if curMouseY > prevMouseY then
						local newScale = math.min(currentWindow:GetScale() + 0.006, 2.5)
						if newScale > 0 then
							newScale = tonumber(string.format("%.3f", newScale))
							currentWindow:SetScale(newScale)
							if currentWindow.isMaximized and newScale > 1 then
								newScale = 1
							end

							MoveAny:SetFrameScale(currentWindowName, newScale)
						end
					elseif curMouseY < prevMouseY then
						local newScale = math.max(currentWindow:GetScale() - 0.006, 0.5)
						if newScale > 0 then
							newScale = tonumber(string.format("%.3f", newScale))
							currentWindow:SetScale(newScale)
							if currentWindow.isMaximized and newScale > 1 then
								newScale = 1
							end

							MoveAny:SetFrameScale(currentWindowName, newScale)
						end
					end
				end

				GameTooltip:SetOwner(currentWindow)
				GameTooltip:SetText(MoveAny:MathR(currentWindow:GetScale() * 100) .. "%")
				prevMouseX = curMouseX
				prevMouseY = curMouseY
			end

			updatingFrame = false
			C_Timer.After(0.02, MoveAny.UpdateCurrentWindow)
		end
	end
end

function MoveAny:FrameDragInfo(frame, c)
	if c > 0 then
		if IsMouseButtonDown("RightButton") or IsMouseButtonDown("LeftButton") or IsMouseButtonDown("MiddleButton") then
			C_Timer.After(
				0.01,
				function()
					MoveAny:FrameDragInfo(frame, c - 1)
				end
			)
		end
	else
		local text = nil
		if IsMouseButtonDown("RightButton") then
			if MoveAny:IsEnabled("SCALEFRAMES", true) then
				if MoveAny:IsEnabled("FRAMESKEYSCALE", false) then
					text = format(MoveAny:GT("LID_FRAMESKEYSCALE"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. "."
				end
			else
				text = MoveAny:GT("LID_FRAMESCALEDISABLED")
			end
		elseif IsMouseButtonDown("LeftButton") then
			if MoveAny:IsEnabled("FRAMESKEYDRAG", false) then
				text = format(MoveAny:GT("LID_FRAMESKEYDRAG"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. "."
			end
		elseif IsMouseButtonDown("MiddleButton") then
			if MoveAny:IsEnabled("FRAMESKEYRESET", false) then
				text = format(MoveAny:GT("LID_FRAMESKEYRESET"), MoveAny:MAGV("KEYBINDWINDOWKEY", "SHIFT")) .. "."
			end
		end

		if text then
			GameTooltip:SetOwner(frame)
			GameTooltip:SetText(text)
		end
	end
end

local EnableMouseFrames = {"PlayerChoiceFrame", "GenericPlayerChoiseTobbleButton"}
local HookedEnableMouseFrames = {}
local run = false
local id = 0
local waitingFrames = {}
local waitingFramesDone = {}
local maframesetpoint = {}
local masetscale_frame = {}
local ma_ismoving = {}
function MoveAny:UpdateMoveFrames(from, force, ts)
	id = id + 1
	if run then return end
	run = true
	local runId = id
	if MoveAny:Loaded() and MoveAny:IsEnabled("MOVEFRAMES", true) then
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

		local count = 0
		for i, name in pairs(MAFS) do
			count = count + 1
			local frame = MoveAny:GetFrameByName(name)
			if frame ~= nil and frame:IsShown() and (not InCombatLockdown() or not frame:IsProtected()) then
				MAFS[name] = nil
				local fm = _G[name .. "Move"]
				if fm == nil then
					fm = CreateFrame("FRAME", name .. "Move", MoveAny:GetMainPanel())
					fm:SetMovable(true)
					fm:SetUserPlaced(false)
					fm:SetClampedToScreen(false)
					fm:RegisterForDrag("LeftClick")
					if HookedEnableMouseFrames[name] == nil then
						fm:EnableMouse(false)
					end

					hooksecurefunc(
						frame,
						"SetScale",
						function(sel, scale)
							if InCombatLockdown() and sel:IsProtected() then return false end
							if MoveAny:IsEnabled("SCALEFRAMES", true) == false then return false end
							if scale and type(scale) == "number" and scale > 0 and (currentWindowName == nil) then
								fm:SetScale(scale)
							end
						end
					)

					function fm:UpdatePreview()
						local fM = _G[name .. "Move"]
						if fM and ma_ismoving[fM] then
							if fM:GetLeft() then
								fM.ma_x = fM:GetLeft()
								fM.ma_y = fM:GetTop() - fM:GetHeight()
								fM.ma_x = MoveAny:Snap(fM.ma_x, MoveAny:GetSnapWindowSize())
								fM.ma_y = MoveAny:Snap(fM.ma_y, MoveAny:GetSnapWindowSize())
								MoveAny:SaveFramePointToDB(name, "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", fM.ma_x, fM.ma_y)
								local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
								if name == "LootFrame" and MoveAny:IsEnabled("MOVELOOTFRAME", false) == false then return end
								if dbp1 and dbp3 then
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
					local name2 = MoveAny:GetName(frameObj)
					if name2 then
						local fM = _G[name2 .. "Move"]
						if not fM then
							MoveAny:INFO("FAILED TO STOP MOVING", name)

							return
						end

						if fM and ma_ismoving[fM] then
							ma_ismoving[fM] = false
							fM:StopMovingOrSizing()
							fM:SetUserPlaced(false)
						end
					end

					currentWindowName = nil
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
				if frame:IsMovable() then
					if frame:HasScript("OnMouseDown") then
						frame:SetScript("OnMouseDown", function() end)
					end

					if frame:HasScript("OnMouseUp") then
						frame:SetScript("OnMouseUp", function() end)
					end
				else
					frame:SetMovable(true)
				end

				function frame:MA_OnMouseDown(sel, btn)
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
						currentWindowName = name
						MoveAny:UpdateCurrentWindow()
						GameTooltip:Hide()
					elseif (MoveAny:IsEnabled("FRAMESKEYDRAG", false) and MoveAny:IsFrameKeyDown() and btn == "LeftButton") or (not MoveAny:IsEnabled("FRAMESKEYDRAG", false) and btn == "LeftButton") then
						fm:StartMoving()
						fm:SetUserPlaced(false)
						ma_ismoving[fm] = true
						fm:UpdatePreview()
					elseif (MoveAny:IsEnabled("FRAMESKEYRESET", false) and MoveAny:IsFrameKeyDown() and MoveAny:IsResetButtonDown(btn)) or (not MoveAny:IsEnabled("FRAMESKEYRESET", false) and MoveAny:IsResetButtonDown(btn)) then
						MoveAny:SaveFramePointToDB(name, nil, nil, nil, nil, nil)
						MoveAny:SetFrameScale(name, nil)
						frame:SetScale(1)
						MoveAny:MSG("[" .. name .. "] is reset, reopen the frame.")
					else
						if MoveAny:IsResetButtonDown(btn) then
							MoveAny:FrameDragInfo(frame, 0)
						else
							MoveAny:FrameDragInfo(frame, 20)
						end
					end
				end

				function frame:MA_OnMouseUp(sel, btn)
					MoveAny:MAFrameStopMoving(sel)
				end

				if frame.Header then
					if frame.Header:HasScript("OnMouseDown") then
						frame.Header:SetScript(
							"OnMouseDown",
							function(sel, btn)
								frame:MA_OnMouseDown(frame, btn)
							end
						)
					end

					if frame.Header:HasScript("OnMouseUp") then
						frame.Header:SetScript(
							"OnMouseUp",
							function(sel, btn)
								frame:MA_OnMouseUp(frame, btn)
							end
						)
					end
				end

				if frame == CharacterFrame and frame.TitleContainer then
					if frame.TitleContainer:HasScript("OnMouseDown") then
						frame.TitleContainer:SetScript(
							"OnMouseDown",
							function(sel, btn)
								frame:MA_OnMouseDown(frame, btn)
							end
						)
					end

					if frame.TitleContainer:HasScript("OnMouseUp") then
						frame.TitleContainer:SetScript(
							"OnMouseUp",
							function(sel, btn)
								frame:MA_OnMouseUp(frame, btn)
							end
						)
					end
				end

				if CharacterNameText and frame == CharacterFrame and PaperDollItemsFrame then
					CharacterNameText:HookScript(
						"OnMouseDown",
						function(sel, btn)
							frame:MA_OnMouseDown(frame, btn)
						end
					)

					CharacterNameText:HookScript(
						"OnMouseUp",
						function(sel, btn)
							frame:MA_OnMouseUp(frame, btn)
						end
					)
				end

				frame:HookScript(
					"OnMouseDown",
					function(sel, btn)
						frame:MA_OnMouseDown(sel, btn)
					end
				)

				frame:HookScript(
					"OnMouseUp",
					function(sel, btn)
						frame:MA_OnMouseUp(sel, btn)
					end
				)

				hooksecurefunc(
					frame,
					"SetPoint",
					function(sel, p1, p2, p3, p4, p5)
						if maframesetpoint[sel] then return end
						maframesetpoint[sel] = true
						sel:SetMovable(true)
						if sel.SetUserPlaced and sel:IsMovable() then
							sel:SetUserPlaced(false)
						end

						if name == "LootFrame" and MoveAny:IsEnabled("MOVELOOTFRAME", false) == false then return end
						local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetFramePoint(name)
						if dbp1 and dbp3 then
							sel.maretrysetpoint = nil
							local w, h = sel:GetSize()
							MoveAny:SetPoint(sel, dbp1, nil, dbp3, dbp4, dbp5)
							if sel:GetNumPoints() > 1 then
								sel:SetSize(w, h)
							end
						end

						maframesetpoint[sel] = false
					end
				)

				hooksecurefunc(
					frame,
					"SetScale",
					function(sel, scale)
						if InCombatLockdown() and sel:IsProtected() then return false end
						if masetscale_frame[sel] then return end
						masetscale_frame[sel] = true
						if name == "LootFrame" and MoveAny:IsEnabled("SCALELOOTFRAME", false) == false then return end
						if MoveAny:GetFrameScale(name) or (scale and type(scale) == "number") then
							local sca = MoveAny:GetFrameScale(name) or scale
							if sel.isMaximized and sca and sca > 1 then
								sca = 1
							end

							--scale > 0.001 fix for TSM - TradeSkillMaster, they "hide" it with low scale
							if MoveAny:IsEnabled("SCALEFRAMES", true) and sca and type(sca) == "number" and sca > 0 and (currentWindowName == nil) and scale > 0.001 then
								sel:SetScale(sca)
							end
						end

						masetscale_frame[sel] = false
					end
				)

				if MoveAny:IsEnabled("SCALEFRAMES", true) then
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
				end

				if frame.GetPoint and frame:GetPoint() then
					local p1, p2, p3, p4, p5 = frame:GetPoint()
					if name ~= "LootFrame" or MoveAny:IsEnabled("MOVELOOTFRAME", false) then
						MoveAny:SetPoint(frame, p1, p2, p3, p4, p5)
					end
				end
			elseif frame ~= nil and waitingFrames[name] == nil and frame.Show then
				waitingFrames[name] = true
				hooksecurefunc(
					frame,
					"Show",
					function()
						if waitingFramesDone[name] == nil then
							waitingFramesDone[name] = true
							MoveAny:UpdateMoveFrames("WAITING: " .. name .. " From: " .. from, true, ts)
						end
					end
				)
			end
		end
	else
		for i, name in pairs(MAFS) do
			local frame = MoveAny:GetFrameByName(name)
			if frame ~= nil and waitingFrames[name] == nil and frame.Show then
				waitingFrames[name] = true
				hooksecurefunc(
					frame,
					"Show",
					function()
						if waitingFramesDone[name] == nil then
							waitingFramesDone[name] = true
							MoveAny:UpdateMoveFrames("WAITING: " .. name .. " From: " .. from, true, ts)
						end
					end
				)
			end
		end
	end

	if ts ~= nil then
		C_Timer.After(
			ts,
			function()
				run = false
				if runId ~= id then
					MoveAny:UpdateMoveFrames("RETRY: " .. from, force, ts)
				end
			end
		)
	else
		run = false
	end
end

local allowedFrameTypes = {}
allowedFrameTypes["frame"] = true
allowedFrameTypes["Frame"] = true
allowedFrameTypes["FRAME"] = true
hooksecurefunc(
	"CreateFrame",
	function(frameType, frameName, parent, template)
		if allowedFrameTypes[frameType] then
			MoveAny:UpdateMoveFrames("CreateFrame", 0.1)
		end
	end
)

function MoveAny:MoveFrames()
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

	MoveAny:UpdateMoveFrames("Start", true)
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript(
		"OnEvent",
		function(sel, event, ...)
			MoveAny:UpdateMoveFrames("ADDON_LOADED", true)
		end
	)

	if BattlefieldFrame then
		BattlefieldFrame:EnableMouse(false)
	end
end
