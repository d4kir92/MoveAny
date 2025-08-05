local _, MoveAny = ...
function MoveAny:InitArenaEnemyFrames()
	if MoveAny:IsEnabled("ARENAENEMYFRAMES", false) and Arena_LoadUI then
		if _G["ArenaEnemyFrame" .. 1] == nil and Arena_LoadUI then
			Arena_LoadUI()
		end

		if ArenaEnemyFrames then
			if _G["ArenaEnemyFrame" .. 1] then
				local sw, sh = _G["ArenaEnemyFrame" .. 1]:GetSize()
				ArenaEnemyFrames:SetSize(sw, sh * 5 + 4 * 21)
			end

			local MAArenaEnemyFrames = CreateFrame("FRAME", "MAArenaEnemyFrames", MoveAny:GetMainPanel())
			MAArenaEnemyFrames:SetSize(ArenaEnemyFrames:GetSize())
			MAArenaEnemyFrames:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", 100, 100)
			ArenaEnemyFrames:ClearAllPoints()
			ArenaEnemyFrames:SetPoint("CENTER", MAArenaEnemyFrames, "CENTER", 0, 0)
			function ArenaEnemyFrames:ClearAllPoints()
			end

			function ArenaEnemyFrames:SetPoint(...)
			end

			hooksecurefunc(
				MAArenaEnemyFrames,
				"SetScale",
				function(sel, scale)
					if InCombatLockdown() and sel:IsProtected() then return false end
					if scale and type(scale) == "number" then
						ArenaEnemyFrames:SetScale(scale)
					end
				end
			)

			hooksecurefunc(
				MAArenaEnemyFrames,
				"SetAlpha",
				function(sel, alpha)
					ArenaEnemyFrames:SetAlpha(alpha)
				end
			)

			if MoveAny:GetEleOption("MAArenaEnemyFrames", "Hide", false, "Hide6") then
				for i = 1, 5 do
					local bb = _G["ArenaEnemyFrame" .. i]
					if bb then
						if bb.setup == nil then
							bb.setup = true
							hooksecurefunc(
								bb,
								"SetAlpha",
								function()
									if bb.setalpha then return end
									bb.setalpha = true
									if MoveAny:GetEleOption("MAArenaEnemyFrames", "Hide", false, "Hide7") then
										bb:SetAlpha(0)
										if not InCombatLockdown() then
											bb:EnableMouse(false)
										end
									end

									bb.setalpha = false
								end
							)
						end

						if MoveAny:GetEleOption("MAArenaEnemyFrames", "Hide", false, "Hide8") then
							bb:SetAlpha(0)
							if not InCombatLockdown() then
								bb:EnableMouse(false)
							end
						end
					end
				end
			end

			if MoveAny:DEBUG() then
				hooksecurefunc(
					ArenaEnemyFrames,
					"Hide",
					function(sel)
						if sel.mahide then return end
						sel.mahide = true
						sel:Show()
						sel.mahide = false
					end
				)

				ArenaEnemyFrames:Show()
				for i = 1, 5 do
					hooksecurefunc(
						_G["ArenaEnemyFrame" .. i],
						"Hide",
						function(sel)
							if sel.mahide then return end
							sel.mahide = true
							sel:Show()
							sel.mahide = false
						end
					)

					_G["ArenaEnemyFrame" .. i]:Show()
				end
			end
		end
	end
end

function MoveAny:InitArenaPrepFrames()
	if MoveAny:IsEnabled("ARENAPREPFRAMES", false) and Arena_LoadUI then
		if _G["ArenaPrepFrame" .. 1] == nil and Arena_LoadUI then
			Arena_LoadUI()
		end

		if ArenaPrepFrames then
			if _G["ArenaPrepFrame" .. 1] then
				local sw, sh = _G["ArenaPrepFrame" .. 1]:GetSize()
				ArenaPrepFrames:SetSize(sw, sh * 5 + 4 * 21)
			end

			local MAArenaPrepFrames = CreateFrame("FRAME", "MAArenaPrepFrames", MoveAny:GetMainPanel())
			MAArenaPrepFrames:SetSize(ArenaPrepFrames:GetSize())
			MAArenaPrepFrames:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", 100, 100)
			ArenaPrepFrames:ClearAllPoints()
			ArenaPrepFrames:SetPoint("CENTER", MAArenaPrepFrames, "CENTER", 0, 0)
			function ArenaPrepFrames:ClearAllPoints()
			end

			function ArenaPrepFrames:SetPoint(...)
			end

			hooksecurefunc(
				MAArenaPrepFrames,
				"SetScale",
				function(sel, scale)
					if InCombatLockdown() and sel:IsProtected() then return false end
					if scale and type(scale) == "number" then
						ArenaPrepFrames:SetScale(scale)
					end
				end
			)

			hooksecurefunc(
				MAArenaPrepFrames,
				"SetAlpha",
				function(sel, alpha)
					ArenaPrepFrames:SetAlpha(alpha)
				end
			)

			if MoveAny:GetEleOption("MAArenaPrepFrames", "Hide", false, "Hide9") then
				for i = 1, 5 do
					local bb = _G["ArenaPrepFrame" .. i]
					if bb then
						if bb.setup == nil then
							bb.setup = true
							hooksecurefunc(
								bb,
								"SetAlpha",
								function()
									if bb.setalpha then return end
									bb.setalpha = true
									if MoveAny:GetEleOption("MAArenaPrepFrames", "Hide", false, "Hide10") then
										bb:SetAlpha(0)
										if not InCombatLockdown() then
											bb:EnableMouse(false)
										end
									end

									bb.setalpha = false
								end
							)
						end

						if MoveAny:GetEleOption("MAArenaPrepFrames", "Hide", false, "Hide11") then
							bb:SetAlpha(0)
							if not InCombatLockdown() then
								bb:EnableMouse(false)
							end
						end
					end
				end
			end

			if MoveAny:DEBUG() then
				hooksecurefunc(
					ArenaPrepFrames,
					"Hide",
					function(sel)
						if sel.mahide then return end
						sel.mahide = true
						sel:Show()
						sel.mahide = false
					end
				)

				ArenaPrepFrames:Show()
				for i = 1, 5 do
					hooksecurefunc(
						_G["ArenaPrepFrame" .. i],
						"Hide",
						function(sel)
							if sel.mahide then return end
							sel.mahide = true
							sel:Show()
							sel.mahide = false
						end
					)

					_G["ArenaPrepFrame" .. i]:Show()
				end
			end
		end
	end
end
