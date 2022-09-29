
local AddOnName, MoveAny = ...

local btnsize = 36

function MoveAny:InitDebuffBar()
	MADebuffBar = CreateFrame( "Frame", "MADebuffBar", UIParent )
	
	MADebuffBar:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -165, -132 )

	MADebuffBar:SetSize( btnsize * 8, btnsize * 3 )

	function IALoadDebuff()
		if DebuffButton1 then
			hooksecurefunc( DebuffButton1, "SetPoint", function( self, ... )
				if self.masetpoint_buff then return end
				self.masetpoint_buff = true

				self:SetMovable( true )
				if self.SetUserPlaced then
					self:SetUserPlaced( false )
				end

				self:ClearAllPoints()
				self:SetPoint( "TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0 )
				
				self.masetpoint_buff = false
			end )
			DebuffButton1:ClearAllPoints()
			DebuffButton1:SetPoint( "TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0 )
		else
			C_Timer.After( 0.1, IALoadDebuff )
		end
	end
	IALoadDebuff()

	if false then
		DebuffButton1.t = DebuffButton1:CreateTexture()
		DebuffButton1.t:SetAllPoints( DebuffButton1 )
		DebuffButton1.t:SetColorTexture( 0, 1, 1, 1 )

		MADebuffBar.t = MADebuffBar:CreateTexture()
		MADebuffBar.t:SetAllPoints( MADebuffBar )
		MADebuffBar.t:SetColorTexture( 1, 0, 0, 0.2 )
	end
end
