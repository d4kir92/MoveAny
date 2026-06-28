local _, MoveAny = ...
local ma_setup = {}
local btnsize = 30
local once = true
local stanceBarCount = -1
function MoveAny:GetStanceBarCount()
	local cou = 0
	if GetNumShapeshiftForms() > 0 then
		cou = GetNumShapeshiftForms()
	else
		cou = NUM_STANCE_SLOTS or 0
	end

	return cou or 0
end

function MoveAny:UpdateStanceBar()
	if _G["StanceButton" .. 1] then
		btnsize = _G["StanceButton" .. 1]:GetSize()
	end

	local cou = MoveAny:GetStanceBarCount()
	if StanceBar and cou and stanceBarCount ~= cou then
		stanceBarCount = cou
		MoveAny:ResetAbBtns(StanceBar)
		-- wrong class/no stances: 10
		if cou ~= 10 then
			for i = 1, cou do
				local bb = _G["StanceButton" .. i]
				if bb then
					if ma_setup[bb] == nil then
						ma_setup[bb] = true
						bb:SetSize(btnsize, btnsize)
						bb:SetMovable(true)
						if bb.SetUserPlaced and bb:IsMovable() then
							bb:SetUserPlaced(false)
						end

						bb:SetParent(StanceBar)
					end

					MoveAny:AddAbBtns(StanceBar, bb)
				end
			end
		end

		StanceBar:SetSize(cou * btnsize, btnsize)
		if MoveAny.UpdateActionBar then
			MoveAny:UpdateActionBar(StanceBar, "UpdateStanceBar")
		end

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

				local abtns = MoveAny:GetAbBtns(StanceBar)
				for y = 1, #abtns do
					local btn = abtns[y]
					if btn then
						local btnName = MoveAny:GetName(btn)
						if _G[btnName .. "FloatingBG"] then
							_G[btnName .. "FloatingBG"]:SetParent(MoveAny:GetHidden())
						end

						local parent = MoveAny:GetName(MoveAny:GetParent(btn))
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
	end
end

local stanceEventFrame = CreateFrame("Frame")
MoveAny:RegisterEvent(stanceEventFrame, "UPDATE_SHAPESHIFT_FORMS")
MoveAny:RegisterEvent(stanceEventFrame, "PLAYER_ENTERING_WORLD")
MoveAny:RegisterEvent(stanceEventFrame, "PLAYER_ALIVE")
MoveAny:OnEvent(
	stanceEventFrame,
	function(sel, event)
		MoveAny:UpdateStanceBar()
	end, "UpdateStanceBar"
)

function MoveAny:InitStanceBar()
	if not StanceBarAnchor then
		StanceBarAnchor = CreateFrame("Frame", "StanceBarAnchor", MoveAny:GetMainPanel())
		StanceBarAnchor:SetSize(btnsize, btnsize)
		StanceBarAnchor:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 120)
	end

	if not StanceBar then
		StanceBar = CreateFrame("Frame", "StanceBar", MoveAny:GetMainPanel())
		StanceBar:SetSize(btnsize, btnsize)
	end

	if MoveAny:IsEnabled("STANCEBARANCHOR", false) and StanceBar then
		local setStanceBarPoint = false
		hooksecurefunc(
			StanceBar,
			"SetPoint",
			function(sel, ...)
				if setStanceBarPoint then return end
				setStanceBarPoint = true
				MoveAny:GetEleOptions("StanceBarAnchor")["ORIENTATION"] = MoveAny:GetEleOptions("StanceBarAnchor")["ORIENTATION"] or "CENTERED"
				local orientation = MoveAny:GetEleOptions("StanceBarAnchor")["ORIENTATION"]
				StanceBar:ClearAllPoints()
				if orientation == "LEFTALIGNED" then
					StanceBar:SetPoint("LEFT", StanceBarAnchor, "LEFT", 0, 0)
				elseif orientation == "CENTERED" then
					StanceBar:SetPoint("CENTER", StanceBarAnchor, "CENTER", 0, 0)
				elseif orientation == "RIGHTALIGNED" then
					StanceBar:SetPoint("RIGHT", StanceBarAnchor, "RIGHT", 0, 0)
				else
					MoveAny:INFO("WRONG ORIENTATION", orientation)
				end

				setStanceBarPoint = false
			end
		)

		hooksecurefunc(
			StanceBarAnchor,
			"SetScale",
			function(sel, scale)
				StanceBar:SetScale(scale)
			end
		)

		hooksecurefunc(
			StanceBarAnchor,
			"SetAlpha",
			function(sel, alpha)
				StanceBar:SetAlpha(alpha)
			end
		)

		StanceBar:ClearAllPoints()
		StanceBar:SetPoint("CENTER", StanceBarAnchor, "CENTER", 0, 0)
		local cou = MoveAny:GetStanceBarCount()
		if StanceBar.actionButtons then
			for i, v in pairs(StanceBar.actionButtons) do
				if i <= cou then
					MoveAny:AddAbBtns(StanceBar, v)
				end
			end
		else
			MoveAny:UpdateStanceBar()
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(StanceBar, "StanceBar")
			MoveAny:UpdateActionBar(StanceBar, "InitStanceBar")
		end
	end
end
