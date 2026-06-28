local _, MoveAny = ...
local ma_setalpha = {}
local ma_mm_show = {}
function MoveAny:InitMinimap()
	if not MoveAny:IsEnabled("MINIMAP", false) then return end
	if ElvUI then return end
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
				if ma_setalpha[self] then return end
				ma_setalpha[self] = true
				Minimap:SetAlpha(0)
				ma_setalpha[self] = false
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
					if ma_setalpha[self] then return end
					ma_setalpha[self] = true
					MinimapBackdrop:SetAlpha(0)
					ma_setalpha[self] = false
				end
			end
		)
	end

	local debugMinimap = false
	local miniMapTab = {"MiniMapMailFrame", "GarrisonLandingPageMinimapButton", "QueueStatusMinimapButton", "MiniMapInstanceDifficulty", "MiniMapChallengeMode", "GuildInstanceDifficulty", "MiniMapLFGFrame", "MiniMapBattlefieldFrame", "MiniMapTracking"}
	if debugMinimap then
		for i, name in pairs(miniMapTab) do
			local btn = _G[name]
			if btn then
				hooksecurefunc(
					btn,
					"Hide",
					function(sel)
						if ma_mm_show[sel] then return end
						ma_mm_show[sel] = true
						sel:Show()
						ma_mm_show[sel] = false
					end
				)

				btn:Show()
			else
				MoveAny:MSG(tostring(name) .. " not found")
			end
		end
	end
end
