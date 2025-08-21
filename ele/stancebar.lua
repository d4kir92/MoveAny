local _, MoveAny = ...
local btnsize = 30
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
	if StanceBar and cou and StanceBar.cou ~= cou then
		StanceBar.cou = cou
		StanceBar.btns = {}
		-- wrong class/no stances: 10
		if cou ~= 10 then
			for i = 1, cou do
				local bb = _G["StanceButton" .. i]
				if bb then
					if bb.setup == nil then
						bb.setup = true
						bb:SetSize(btnsize, btnsize)
						bb:SetMovable(true)
						if bb.SetUserPlaced and bb:IsMovable() then
							bb:SetUserPlaced(false)
						end

						bb:SetParent(StanceBar)
					end

					tinsert(StanceBar.btns, bb)
				end
			end
		end

		StanceBar:SetSize(cou * btnsize, btnsize)
		if MoveAny.UpdateActionBar then
			StanceBar.btns = StanceBar.btns or {}
			MoveAny:UpdateActionBar(StanceBar)
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

				for y, btn in pairs(StanceBar.btns) do
					if btn then
						local btnName = MoveAny:GetName(btn)
						if _G[btnName .. "FloatingBG"] then
							_G[btnName .. "FloatingBG"]:SetParent(MAHIDDEN)
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

	MoveAny:After(1, MoveAny.UpdateStanceBar, "UpdateStanceBar")
end

function MoveAny:InitStanceBar()
	if not StanceBarAnchor then
		StanceBarAnchor = CreateFrame("Frame", "StanceBarAnchor", MoveAny:GetMainPanel())
		StanceBarAnchor:SetSize(btnsize, btnsize)
		StanceBarAnchor:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 120)
	end

	if not StanceBar then
		StanceBar = CreateFrame("Frame", "StanceBar", MoveAny:GetMainPanel())
		StanceBar:SetSize(btnsize, btnsize)
		StanceBar.cou = -1
		StanceBar.btns = StanceBar.btns or {}
	end

	if MoveAny:IsEnabled("STANCEBARANCHOR", false) and StanceBar then
		StanceBar.btns = StanceBar.btns or {}
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

		StanceBar:ClearAllPoints()
		StanceBar:SetPoint("CENTER", StanceBarAnchor, "CENTER", 0, 0)
		local cou = MoveAny:GetStanceBarCount()
		if StanceBar.actionButtons then
			for i, v in pairs(StanceBar.actionButtons) do
				if i <= cou then
					tinsert(StanceBar.btns, v)
				end
			end
		else
			MoveAny:UpdateStanceBar()
		end

		if MoveAny.UpdateActionBar then
			MoveAny:AddBarName(StanceBar, "StanceBar")
			StanceBar.btns = StanceBar.btns or {}
			MoveAny:UpdateActionBar(StanceBar)
		end
	end
end
