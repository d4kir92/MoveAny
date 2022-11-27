
local AddOnName, MoveAny = ...

function MoveAny:InitMinimap()
	if not MoveAny:IsEnabled( "MINIMAP", true ) then
		return
	end

	if ElvUI then
		return
	end

	if MinimapToggleButton then
		MinimapToggleButton:SetParent( MAHIDDEN )
	end
	
	if MinimapCluster then
		for i, v in pairs({MinimapCluster:GetChildren()}) do
			if v ~= Minimap then
				v:SetParent( Minimap )
			end
		end
		MinimapCluster:SetParent( MAHIDDEN )
	end

	if MinimapBackdrop then
		for i, v in pairs({MinimapBackdrop:GetChildren()}) do
			if v ~= Minimap then
				v:SetParent( Minimap )
			end
		end
		MinimapBackdrop:SetParent( MAHIDDEN )
	end

	local zoneTextBG = nil
	for i, v in pairs( {Minimap:GetChildren()} ) do
		for x, w in pairs( v ) do
			if x == "layoutTextureKit" then
				zoneTextBG = v
			end
		end
	end
	if zoneTextBG then
		zoneTextBG:ClearAllPoints()
		zoneTextBG:SetPoint( "TOP", Minimap, "TOP", 0, 32 )
	end
	Minimap:SetParent( UIParent )
	
	if MinimapBorder then
		local sw, sh = Minimap:GetSize()
		local texture = MinimapBorder:GetTexture()
		local texcoord = { MinimapBorder:GetTexCoord() }

		MinimapBorder = Minimap:CreateTexture( "MinimapBorder2", "ARTWORK", nil, 1 )
		MinimapBorder:SetPoint( "CENTER", Minimap, "CENTER", -6, -17 )
		MinimapBorder:SetTexture( texture )
		MinimapBorder:SetSize( sw, sh )
		MinimapBorder:SetTexCoord( unpack( texcoord ) )
		MinimapBorder:SetScale( 1.40 )
	end

	if MiniMapTracking and MiniMapTrackingButton then
		MiniMapTrackingButton:ClearAllPoints()
		MiniMapTrackingButton:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", -20, -40 )
		MiniMapTrackingButton:SetParent( Minimap )
		MiniMapTrackingButton:SetFrameLevel( 5 )

		hooksecurefunc( MiniMapTrackingButton, "SetPoint", function( self, ... )
			local p1, p2, p3, p4, p5 = self:GetPoint()

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end

			MiniMapTracking:ClearAllPoints()
			MiniMapTracking:SetPoint( p1, Minimap, p3, p4, p5 )
		end )

		hooksecurefunc( MiniMapTracking, "SetPoint", function( self, ... )
			if self.mmtsetpoint then return end
			self.mmtsetpoint = true

			self:ClearAllPoints()
			self:SetPoint( "CENTER", MiniMapTrackingButton, "CENTER", 0, 0 )

			self.mmtsetpoint = false
		end )
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint( "CENTER", MiniMapTrackingButton, "CENTER", 0, 0 )
		MiniMapTracking:SetParent( MiniMapTrackingButton )
		MiniMapTracking:SetFrameLevel( 4 )
	elseif MiniMapTracking then
		MiniMapTracking:ClearAllPoints()
		MiniMapTracking:SetPoint( "TOPLEFT", Minimap, "TOPLEFT", -14, -20 )
		MiniMapTracking:SetParent( Minimap )
	end

	if TimeManagerClockButton then
		if MoveAny:GetWoWBuild() == "RETAIL" then
			
		else
			TimeManagerClockButton:ClearAllPoints()
			TimeManagerClockButton:SetPoint( "BOTTOM", Minimap, "BOTTOM", 0, -18 )
		end
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
		if MoveAny:GetWoWBuild() == "RETAIL" then
			
		else
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint( "TOPRIGHT", Minimap, "TOPRIGHT", 20, -10 )
		end
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

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end

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

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end

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
				hooksecurefunc( btn, "Hide", function( self )
					if self.mashow then return end
					self.mashow = true
					self:Show()
					self.mashow = false
				end )
				btn:Show()
			else
				MoveAny:MSG( tostring( name ) .. " not found" )
			end
		end
	end
end
