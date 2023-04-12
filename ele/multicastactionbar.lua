local _, MoveAny = ...

function MoveAny:InitMultiCastActionBar()
	for i = 1, 4 do
		local btn = _G["MultiCastActionButton" .. i]

		if btn then
			function btn:GetMAEle()
				return MultiCastActionBarFrame
			end
		end
	end

	if MultiCastFlyoutFrameOpenButton then
		MultiCastFlyoutFrameOpenButton:HookScript("OnClick", function()
			for i = 1, 10 do
				local btn = _G["MultiCastFlyoutButton" .. i]

				if btn then
					function btn:GetMAEle()
						return MultiCastActionBarFrame
					end
				end
			end
		end)
	end

	if MultiCastFlyoutFrameCloseButton then
		function MultiCastFlyoutFrameCloseButton:GetMAEle()
			return MultiCastActionBarFrame
		end
	end
end