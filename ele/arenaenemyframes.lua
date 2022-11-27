
local AddOnName, MoveAny = ...

function MoveAny:InitArenaEnemyFrames()
	if MoveAny:IsEnabled( "ARENAENEMYFRAMES", false ) and Arena_LoadUI then
		if _G["ArenaEnemyFrame" .. 1] == nil and Arena_LoadUI then
			Arena_LoadUI()
		end

		if _G["ArenaEnemyFrame" .. 1] then
			local sw, sh = _G["ArenaEnemyFrame" .. 1]:GetSize()
			ArenaEnemyFrames:SetSize( sw, sh * 5 + 4 * 21 )
		end

		MAArenaEnemyFrames = CreateFrame( "FRAME", "MAArenaEnemyFrames", UIParent )
		MAArenaEnemyFrames:SetSize( ArenaEnemyFrames:GetSize() )
		MAArenaEnemyFrames:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", 100, 100 )

		ArenaEnemyFrames:ClearAllPoints()
		ArenaEnemyFrames:SetPoint( "CENTER", MAArenaEnemyFrames, "CENTER", 0, 0 )

		function ArenaEnemyFrames:ClearAllPoints()
			
		end
		function ArenaEnemyFrames:SetPoint( ... )
			
		end

		hooksecurefunc( MAArenaEnemyFrames, "SetScale", function( self, scale )
			ArenaEnemyFrames:SetScale( scale )
		end )
		hooksecurefunc( MAArenaEnemyFrames, "SetAlpha", function( self, alpha )
			ArenaEnemyFrames:SetAlpha( alpha )
		end )

		if MoveAny:DEBUG() then
			hooksecurefunc( ArenaEnemyFrames, "Hide", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Show()
				self.mahide = false
			end )
			ArenaEnemyFrames:Show()

			for i = 1, 5 do
				hooksecurefunc( _G["ArenaEnemyFrame" .. i], "Hide", function( self )
					if self.mahide then return end
					self.mahide = true
					self:Show()
					self.mahide = false
				end )
				_G["ArenaEnemyFrame" .. i]:Show()
			end
		end
	end
end

function MoveAny:InitArenaPrepFrames()
	if MoveAny:IsEnabled( "ARENAPREPFRAMES", false ) and Arena_LoadUI then
		if _G["ArenaPrepFrame" .. 1] == nil and Arena_LoadUI then
			Arena_LoadUI()
		end

		if _G["ArenaPrepFrame" .. 1] then
			local sw, sh = _G["ArenaPrepFrame" .. 1]:GetSize()
			ArenaPrepFrames:SetSize( sw, sh * 5 + 4 * 21 )
		end

		MAArenaPrepFrames = CreateFrame( "FRAME", "MAArenaPrepFrames", UIParent )
		MAArenaPrepFrames:SetSize( ArenaPrepFrames:GetSize() )
		MAArenaPrepFrames:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", 100, 100 )
		
		ArenaPrepFrames:ClearAllPoints()
		ArenaPrepFrames:SetPoint( "CENTER", MAArenaPrepFrames, "CENTER", 0, 0 )

		function ArenaPrepFrames:ClearAllPoints()
			
		end
		function ArenaPrepFrames:SetPoint( ... )
			
		end
		
		hooksecurefunc( MAArenaPrepFrames, "SetScale", function( self, scale )
			ArenaPrepFrames:SetScale( scale )
		end )
		hooksecurefunc( MAArenaPrepFrames, "SetAlpha", function( self, alpha )
			ArenaPrepFrames:SetAlpha( alpha )
		end )
		
		if MoveAny:DEBUG() then
			hooksecurefunc( ArenaPrepFrames, "Hide", function( self )
				if self.mahide then return end
				self.mahide = true
				self:Show()
				self.mahide = false
			end )
			ArenaPrepFrames:Show()

			for i = 1, 5 do
				hooksecurefunc( _G["ArenaPrepFrame" .. i], "Hide", function( self )
					if self.mahide then return end
					self.mahide = true
					self:Show()
					self.mahide = false
				end )
				_G["ArenaPrepFrame" .. i]:Show()
			end
		end
	end
end
