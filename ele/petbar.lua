local _, MoveAny = ...
local ma_setparent = {}
local btnsize = 36
local once = true
local bar = nil
local petbarReady = false
function MoveAny:UpdatePetBar()
	if bar then
		-- Masque
		if LibStub then
			local MSQ = LibStub("Masque", true)
			if MSQ then
				local MAMasqueGroups = {}
				MAMasqueGroups.Groups = {}
				if once then
					once = false
					MSQ:Register("MoveAny Blizzard Action Bars", function() end, {})
				end

				local abtns = MoveAny:GetAbBtns(bar)
				for y = 1, #abtns do
					local btn = abtns[y]
					if btn then
						local btnName = MoveAny:GetName(btn)
						if _G[btnName .. "FloatingBG"] then
							_G[btnName .. "FloatingBG"]:SetParent(MoveAny:GetHidden())
						end

						local parent = "MAPetBar"
						local group = nil
						if MAMasqueGroups.Groups["MA " .. parent] == nil then
							MAMasqueGroups.Groups["MA " .. parent] = MSQ:Group("MA Blizzard Action Bars", "MA " .. parent)
						end

						group = MAMasqueGroups.Groups["MA " .. parent]
						if not btn.MasqueButtonData then
							btn.MasqueButtonData = {
								Button = btn,
								Icon = _G[btnName .. "IconTexture"],
							}

							group:AddButton(btn, btn.MasqueButtonData, "Item")
						end
					end
				end
			end
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(bar, "MAPetBar")
			MoveAny:UpdateActionBar(bar)
		end
	end
end

local petbarEventFrame = CreateFrame("Frame")
MoveAny:RegisterEvent(petbarEventFrame, "PET_BAR_UPDATE")
MoveAny:RegisterEvent(petbarEventFrame, "UNIT_PET")
MoveAny:RegisterEvent(petbarEventFrame, "UPDATE_BONUS_ACTIONBAR")
MoveAny:OnEvent(
	petbarEventFrame,
	function(sel, event, unit)
		if event == "UNIT_PET" and unit ~= "player" then return end
		if petbarReady then
			MoveAny:UpdatePetBar()
		end
	end, "UpdatePetBar"
)

function MoveAny:InitPetBar()
	if MoveAny:IsEnabled("PETBAR", false) then
		if not PetActionBar then
			bar = CreateFrame("Frame", "MAPetBar", MoveAny:GetMainPanel())
			bar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 110)
			MoveAny:ResetAbBtns(bar)
			if _G["PetActionButton" .. 1] then
				btnsize = _G["PetActionButton" .. 1]:GetSize()
			end

			for i = 1, 10 do
				local bb = _G["PetActionButton" .. i]
				if bb then
					bb:SetSize(btnsize, btnsize)
					hooksecurefunc(
						bb,
						"SetParent",
						function(sel, ...)
							if ma_setparent[sel] then return end
							ma_setparent[sel] = true
							bb:SetParent(bar)
							ma_setparent[sel] = false
						end
					)

					hooksecurefunc(
						bar,
						"SetPoint",
						function(sel, ...)
							bb:SetParent(bar)
							bb:SetMovable(true)
							if bb.SetUserPlaced and bb:IsMovable() then
								bb:SetUserPlaced(false)
							end

							MoveAny:SetPoint(bb, "TOPLEFT", bar, "TOPLEFT", (i - 1) * btnsize, 0)
						end
					)

					bb:ClearAllPoints()
					bb:SetPoint("TOPLEFT", bar, "TOPLEFT", (i - 1) * btnsize, 0)
					MoveAny:AddAbBtns(bar, bb)
				end
			end

			bar:SetSize(10 * btnsize, btnsize)
			if ShowPetActionBar then
				hooksecurefunc(
					"ShowPetActionBar",
					function()
						bar:SetAlpha(1)
						MoveAny:SetMAShow(bar, true)
					end
				)

				hooksecurefunc(
					"HidePetActionBar",
					function()
						if UnitExists("pet") then
							bar:SetAlpha(1)
							MoveAny:SetMAShow(bar, true)
						else
							bar:SetAlpha(0)
							MoveAny:SetMAShow(bar, false)
						end
					end
				)
			else
				MoveAny:MSG("MISSING ShowPetActionBar")
			end

			petbarReady = true
			MoveAny:UpdatePetBar()
		elseif PetActionBar then
			MoveAny:ResetAbBtns(PetActionBar)
			for i = 1, 12 do
				local btn = _G["PetActionButton" .. i]
				if btn then
					MoveAny:AddAbBtns(PetActionBar, btn)
				end
			end

			bar = PetActionBar
			petbarReady = true
			MoveAny:UpdatePetBar()
		elseif PetActionBarFrame then
			MoveAny:ResetAbBtns(PetActionBarFrame)
			for i = 1, 12 do
				local btn = _G["PetActionButton" .. i]
				if btn then
					MoveAny:AddAbBtns(PetActionBarFrame, btn)
				end
			end

			bar = PetActionBar
			petbarReady = true
			MoveAny:UpdatePetBar()
		end
	end
end
