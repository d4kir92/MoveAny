
local AddOnName, MoveAny = ...

function MoveAny:InitArenaEnemyFrames()
	if MoveAny:IsEnabled( "ARENAENEMYFRAMES", false ) then
		if _G["ArenaEnemyFrame" .. 1] == nil then
			Arena_LoadUI()
		end

		if _G["ArenaEnemyFrame" .. 1] then
			local sw, sh = _G["ArenaEnemyFrame" .. 1]:GetSize()
			ArenaEnemyFrames:SetSize( sw, sh * 5 + 4 * 21 )
		end

		if false then

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
	if MoveAny:IsEnabled( "ARENAPREPFRAMES", false ) then
		if _G["ArenaPrepFrame" .. 1] == nil then
			Arena_LoadUI()
		end

		if _G["ArenaPrepFrame" .. 1] then
			local sw, sh = _G["ArenaPrepFrame" .. 1]:GetSize()
			ArenaPrepFrames:SetSize( sw, sh * 5 + 4 * 21 )
		end
		
		if false then

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
