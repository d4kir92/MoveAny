
local AddOnName, MoveAny = ...

local btnsize = 36

local debuffs = {}
function MoveAny:InitDebuffBar()
	if MoveAny:IsEnabled( "DEBUFFS", true ) then
		MADebuffBar = CreateFrame( "Frame", "MADebuffBar", UIParent )
		
		MADebuffBar:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -165, -132 )

		MADebuffBar:SetSize( btnsize * 8, btnsize * 3 )

		function IALoadDebuff()
			for i = 1, 32 do
				local debuffBtn = _G["DebuffButton" .. i]
				
				if debuffBtn and not tContains( debuffs, debuffBtn ) then
					table.insert( debuffs, debuffBtn )
					
					if i == 1 then
						hooksecurefunc( debuffBtn, "SetPoint", function( self, ... )
							if self.masetpoint_buff then return end
							self.masetpoint_buff = true
		
							self:SetMovable( true )
							if self.SetUserPlaced then
								self:SetUserPlaced( false )
							end
		
							self:SetParent( MADebuffBar )
							self:ClearAllPoints()
							self:SetPoint( "TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0 )
							
							self.masetpoint_buff = false
						end )
						debuffBtn:ClearAllPoints()
						debuffBtn:SetPoint( "TOPRIGHT", MADebuffBar, "TOPRIGHT", 0, 0 )
					else
						local op1, op2, op3, op4, op5 = debuffBtn:GetPoint()
						hooksecurefunc( debuffBtn, "SetPoint", function( self, ... )
							if self.masetpoint_buff then return end
							self.masetpoint_buff = true

							p1, p2, p3, p4, p5 = ...

							self:SetMovable( true )
							if self.SetUserPlaced then
								self:SetUserPlaced( false )
							end
		
							self:SetParent( MADebuffBar )
							self:ClearAllPoints()
							self:SetPoint( p1, p2, p3, p4, p5 )
							
							self.masetpoint_buff = false
						end )
						debuffBtn:ClearAllPoints()
						debuffBtn:SetPoint( op1, op2, op3, op4, op5 )
					end
				end
			end

			C_Timer.After( 0.3, IALoadDebuff )
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
end
