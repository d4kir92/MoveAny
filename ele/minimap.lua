
local AddOnName, MoveAny = ...

function MoveAny:InitMinimap()
	if MinimapToggleButton then
		MinimapToggleButton:SetParent( MAHIDDEN )
	end
	MinimapCluster:SetParent( MAHIDDEN )
	MinimapBackdrop:SetParent( MAHIDDEN )
	for i, v in pairs({MinimapCluster:GetChildren()}) do
		if v ~= Minimap then
			v:SetParent( Minimap )
		end
	end
	for i, v in pairs({MinimapBackdrop:GetChildren()}) do
		if v ~= Minimap then
			v:SetParent( Minimap )
		end
	end
	Minimap:SetParent( UIParent )
	--Minimap:ClearAllPoints()
	--Minimap:SetPoint( "CENTER", MinimapCluster, "CENTER", 0, 0 )

	local sw, sh = Minimap:GetSize()
	local texture = MinimapBorder:GetTexture()
	local texcoord = { MinimapBorder:GetTexCoord() }

	Minimap.Border = Minimap:CreateTexture( "Minimap.Border", "ARTWORK", nil, 1 )
	Minimap.Border:SetPoint( "CENTER", Minimap, "CENTER", -6, -17 )
	Minimap.Border:SetTexture( texture )
	Minimap.Border:SetSize( sw, sh )
	Minimap.Border:SetTexCoord( unpack( texcoord ) )
	Minimap.Border:SetScale( 1.40 )
	
	-- FIX MINIMAP
	if MiniMapTracking and MiniMapTrackingButton then
		MiniMapTrackingButton:ClearAllPoints()
		MiniMapTrackingButton:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", -14, -20 )
		MiniMapTrackingButton:SetParent( Minimap )
		MiniMapTrackingButton:SetFrameLevel( 5 )

		hooksecurefunc( MiniMapTrackingButton, "SetPoint", function( self, ... )
			local p1, p2, p3, p4, p5 = self:GetPoint()
			MiniMapTracking:ClearAllPoints()
			MiniMapTracking:SetPoint( p1, Minimap, p3, p4, p5 )
		end )
		hooksecurefunc( MiniMapTracking, "SetPoint", function( self, ... )
			local p1, p2, p3, p4, p5 = MiniMapTrackingButton:GetPoint()
			if self.iasetpoint then return end
			self.iasetpoint = true
			self:ClearAllPoints()
			self:SetPoint( p1, Minimap, p3, p4, p5 )
			self.iasetpoint = false
		end )
		local p1, p2, p3, p4, p5 = MiniMapTrackingButton:GetPoint()
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint( p1, Minimap, p3, p4, p5 )
		MiniMapTracking:SetParent( Minimap )
		MiniMapTracking:SetFrameLevel( 4 )
	elseif MiniMapTracking then
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", -14, -20 )
		MiniMapTracking:SetParent( Minimap )
	end

	if TimeManagerClockButton then
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint( "BOTTOM", Minimap, "BOTTOM", 0, -18 )
	end

	if MinimapZoneTextButton then
		MinimapZoneTextButton:ClearAllPoints()
		MinimapZoneTextButton:SetPoint( "BOTTOM", Minimap, "TOP", 0, 12 )
	end

	if MinimapZoomIn then
		MinimapZoomIn:ClearAllPoints()
		MinimapZoomIn:SetPoint( "BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 8, 8 )
	end

	if MinimapZoomOut then
		MinimapZoomOut:ClearAllPoints()
		MinimapZoomOut:SetPoint( "BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -10, -10 )
	end

	if GameTimeFrame then
		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint( "TOPRIGHT", Minimap, "TOPRIGHT", 20, -10 )
	end
	
	if MiniMapWorldMapButton then
		MiniMapWorldMapButton:ClearAllPoints()
		MiniMapWorldMapButton:SetPoint( "TOPRIGHT", Minimap, "TOPRIGHT", -6, 6 )
	end

	if MiniMapInstanceDifficulty then
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", 0, 0 )
	end

	if MiniMapChallengeMode then
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", 0, 0 )
	end

	if MiniMapLFGFrame then
		MiniMapLFGFrame:ClearAllPoints()
		MiniMapLFGFrame:SetPoint( "BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0 )
	end

	if GarrisonLandingPageMinimapButton then
		hooksecurefunc( GarrisonLandingPageMinimapButton, "SetPoint", function( self, ... )
			if IsAddOnLoaded( "ImproveAny" ) then
				return
			end
			if self.iasetpoint then return end
			self.iasetpoint = true
			GarrisonLandingPageMinimapButton:ClearAllPoints()
			GarrisonLandingPageMinimapButton:SetPoint( "BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -30 )
			self.iasetpoint = false
		end )
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:SetPoint( "BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, -30 )
	end

	if QueueStatusMinimapButton then
		hooksecurefunc( QueueStatusMinimapButton, "SetPoint", function( self, ... )
			if IsAddOnLoaded( "ImproveAny" ) then
				return
			end
			if self.iasetpoint then return end
			self.iasetpoint = true
			QueueStatusMinimapButton:ClearAllPoints()
			QueueStatusMinimapButton:SetPoint( "BOTTOMLEFT", Minimap, "BOTTOMLEFT", -10, 2 )
			self.iasetpoint = false
		end )
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:SetPoint( "BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0 )
	end

	local debugMinimap = false
	local miniMapTab = {
		"MiniMapMailFrame",
		"GarrisonLandingPageMinimapButton",
		"QueueStatusMinimapButton",
		"MiniMapInstanceDifficulty",
		"MiniMapChallengeMode",
		"MiniMapLFGFrame",
		"MiniMapBattlefieldFrame",
		"MiniMapTracking"
	}

	if debugMinimap then

		for i, name in pairs( miniMapTab ) do
			local btn = _G[name]
			if btn then
				btn.Hide = btn.Show
				btn:Show()
			else
				print(name, "not found")
			end
		end
	end
end
