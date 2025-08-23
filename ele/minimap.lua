local _, MoveAny = ...
local hooksecurefunc = getglobal("hooksecurefunc")
function MoveAny:InitMinimap()
	local MinimapToggleButton = getglobal("MinimapToggleButton")
	local MinimapBorderTop = getglobal("MinimapBorderTop")
	if not MoveAny:IsEnabled("MINIMAP", false) then return end
	if getglobal("ElvUI") then return end
	if MinimapToggleButton then
		MinimapToggleButton:SetParent(MoveAny:GetHidden())
	end

	if MinimapBorderTop then
		MinimapBorderTop:SetParent(MoveAny:GetHidden())
	end

	hooksecurefunc(
		Minimap,
		"SetAlpha",
		function()
			local alpha = MoveAny:GetMainPanel():GetAlpha()
			if alpha == 0 then
				if self.ma_setalpha then return end
				self.ma_setalpha = true
				Minimap:SetAlpha(0)
				self.ma_setalpha = false
			end
		end
	)

	if MinimapBackdrop then
		hooksecurefunc(
			MinimapBackdrop,
			"SetAlpha",
			function()
				local alpha = MoveAny:GetMainPanel():GetAlpha()
				if alpha == 0 then
					if self.ma_setalpha then return end
					self.ma_setalpha = true
					MinimapBackdrop:SetAlpha(0)
					self.ma_setalpha = false
				end
			end
		)
	end

	local debugMinimap = false
	local miniMapTab = {"MiniMapMailFrame", "GarrisonLandingPageMinimapButton", "QueueStatusMinimapButton", "MiniMapInstanceDifficulty", "MiniMapChallengeMode", "GuildInstanceDifficulty", "MiniMapLFGFrame", "MiniMapBattlefieldFrame", "MiniMapTracking"}
	if debugMinimap then
		for i, name in pairs(miniMapTab) do
			local btn = getglobal(name)
			if btn then
				hooksecurefunc(
					btn,
					"Hide",
					function(sel)
						if sel.mashow then return end
						sel.mashow = true
						sel:Show()
						sel.mashow = false
					end
				)

				btn:Show()
			else
				MoveAny:MSG(tostring(name) .. " not found")
			end
		end
	end
end
