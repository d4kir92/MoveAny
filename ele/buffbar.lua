
local AddOnName, MoveAny = ...

local btnsize = 36

local MABUFFLIMIT = 10
local MABUFFSPACINGX = 4
local MABUFFSPACINGY = 10

MABuffBar = CreateFrame( "Frame", "MABuffBar", UIParent )
local sw, sh = BuffFrame:GetSize()
MABuffBar:SetSize( sw, sh )
MABuffBar:SetPoint( BuffFrame:GetPoint() )

function MoveAny:InitBuffBar()
	if MoveAny:IsEnabled( "BUFFS", true ) then
		if BuffFrame then
			MABuffBar:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -165, -32 )
		else
			MABuffBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end
		if MoveAny:IsEnabled( "DEBUFFS", false ) then
			MABuffBar:SetSize( btnsize * 10, btnsize * 3 )
		else
			MABuffBar:SetSize( btnsize * 10, btnsize * 6 )	
		end

		hooksecurefunc( BuffFrame, "SetPoint", function( self, ... )
			if self.buffsetpoint then return end
			self.buffsetpoint = true

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end
			
			self:SetParent( MABuffBar )
			self:ClearAllPoints()
			self:SetPoint( "TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0 )
			
			self.buffsetpoint = false
		end )
		BuffFrame:ClearAllPoints()
		BuffFrame:SetPoint( "TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0 )

		if MoveAny:DEBUG() then
			BuffFrame.t = BuffFrame:CreateTexture()
			BuffFrame.t:SetAllPoints( BuffFrame )
			BuffFrame.t:SetColorTexture( 0, 1, 1, 1 )

			MABuffBar.t = MABuffBar:CreateTexture()
			MABuffBar.t:SetAllPoints( MABuffBar )
			MABuffBar.t:SetColorTexture( 1, 0, 0, 0.2 )
		end

		local rel = "RIGHT"
		local dirH = "LEFT"
		local dirV = "BOTTOM"
		function MAUpdateBuffDirections()
			local p1, p2, p3, p4, p5 = MABuffBar:GetPoint()
			rel = "RIGHT"
			if p1 == "TOPLEFT" then
				rel = "LEFT"
			elseif p1 == "LEFT" then
				rel = "LEFT"
			elseif p1 == "BOTTOMLEFT" then
				rel = "LEFT"
			end
			dirH = "LEFT"
			if rel == "LEFT" then
				dirH = "RIGHT"
			end
			dirV = "BOTTOM"
			if p3 == "BOTTOMLEFT" then
				dirV = "TOP"
			elseif p3 == "BOTTOM" then
				dirV = "TOP"
			elseif p3 == "BOTTOMRIGHT" then
				dirV = "TOP"
			end
		end
		MAUpdateBuffDirections()
		
		if TempEnchant1 then
			hooksecurefunc( TempEnchant1, "SetPoint", function( self, ... )
				if self.setpoint_te1 then return end
				self.setpoint_te1 = true

				self:SetMovable( true )
				if self.SetUserPlaced and self:IsMovable() then
					self:SetUserPlaced( false )
				end

				self:SetParent( MABuffBar )

				local p1, p2, p3, p4, p5 = MABuffBar:GetPoint()
				local x = 0
				if GetCVarBool( "consolidateBuffs" ) then
					x = x + 1
				end
				if dirH == "LEFT" then
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, x * -(30 + MABUFFSPACINGX), 0 )
				else
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, x * (30 + MABUFFSPACINGX), 0 )
				end

				self.setpoint_te1 = false
			end )
		end
		if TempEnchant2 then
			hooksecurefunc( TempEnchant2, "SetPoint", function( self, ... )
				if self.setpoint_te2 then return end
				self.setpoint_te2 = true

				self:SetMovable( true )
				if self.SetUserPlaced and self:IsMovable() then
					self:SetUserPlaced( false )
				end

				self:SetParent( MABuffBar )

				local p1, p2, p3, p4, p5 = MABuffBar:GetPoint()
				local x = 1
				if GetCVarBool( "consolidateBuffs" ) then
					x = x + 1
				end

				local posy = 0
				if MABUFFLIMIT == 1 then
					posy = -30 - MABUFFSPACINGY
				end
				if dirH == "LEFT" then
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, x * -(30 + MABUFFSPACINGX), posy )
				else
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, x * (30 + MABUFFSPACINGX), 0 )
				end


				self.setpoint_te2 = false
			end )
		end
		if TempEnchant3 then
			hooksecurefunc( TempEnchant3, "SetPoint", function( self, ... )
				if self.setpoint_te3 then return end
				self.setpoint_te3 = true

				self:SetMovable( true )
				if self.SetUserPlaced and self:IsMovable() then
					self:SetUserPlaced( false )
				end

				self:SetParent( MABuffBar )
				
				local p1, p2, p3, p4, p5 = MABuffBar:GetPoint()
				local x = 2
				if GetCVarBool( "consolidateBuffs" ) then
					x = x + 1
				end
				if dirH == "LEFT" then
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, -x * (30 + MABUFFSPACINGX), 0 )
				else
					self:ClearAllPoints()
					self:SetPoint( p1, MABuffBar, p3, x * (30 + MABUFFSPACINGX), 0 )
				end


				self.setpoint_te3 = false
			end )
		end

		function GetEnchantCount()
			local count = 0
			local e1, _, _, _, e2, _, _, _, e3, _, _, _  = GetWeaponEnchantInfo()
			if e1 then
				count = count + 1
			end
			if e2 then
				count = count + 1
			end
			if e3 then
				count = count + 1
			end
			return count
		end

		function MAUpdateBuffs()
			MABUFFLIMIT = MoveAny:GetEleOption( "MABuffBar", "MABUFFLIMIT", 10 )
			MABUFFSPACINGX = MoveAny:GetEleOption( "MABuffBar", "MABUFFSPACINGX", 4 )
			MABUFFSPACINGY = MoveAny:GetEleOption( "MABuffBar", "MABUFFSPACINGY", 10 )

			MAUpdateBuffDirections()

			if ConsolidatedBuffs then
				ConsolidatedBuffs:SetParent( MABuffBar )
			end

			if TempEnchant1 then
				TempEnchant1:SetPoint( "CENTER", 0, 0 )
			end
			if TempEnchant2 then
				TempEnchant2:SetPoint( "CENTER", 0, 0 )
			end
			if TempEnchant3 then
				TempEnchant3:SetPoint( "CENTER", 0, 0 )
			end
			
			for bid = 1, 32 do
				local bbtn = _G["BuffButton" .. bid]
				if bbtn then
					if bbtn.masetup == nil then
						bbtn.masetup = true
						
						hooksecurefunc( bbtn, "SetPoint", function( self, ... )
							if self.setpoint_bbtn then return end
							self.setpoint_bbtn = true

							local p1, p2, p3, p4, p5 = MABuffBar:GetPoint()
							local sw, sh = self:GetSize()

							local numBuffs = 1
							local prevBuff = nil
							for i = 1, 32 do
								local btn = _G["BuffButton" .. i]
								if i == bid then
									break 
								end
								if btn then
									if btn:GetParent() == BuffFrame then
										numBuffs = numBuffs + 1
										prevBuff = btn
									end
								end
							end

							local count = GetEnchantCount()
							if GetCVarBool( "consolidateBuffs" ) then
								count = count + 1
							end
							local id = numBuffs + count
							local caly = (id - 0.1) / MABUFFLIMIT
							local cy = caly - caly % 1
							
							if bbtn:GetParent() == BuffFrame then
								self:ClearAllPoints()
								if numBuffs == 1 then
									local posx = 0
									if rel == "RIGHT" then
										posx = -count * (sw + MABUFFSPACINGX)
									else
										posx = count * (sw + MABUFFSPACINGX)
									end
									local posy = 0
									if MABUFFLIMIT == 1 then
										posx = 0
										if dirV == "BOTTOM" then
											posy = -30 - MABUFFSPACINGY
										else
											posy = 30 + MABUFFSPACINGY
										end
									end
									self:SetPoint( p1, MABuffBar, p3, posx, posy )
								else
									if id % MABUFFLIMIT == 1 or MABUFFLIMIT == 1 then
										if dirV == "BOTTOM" then
											self:SetPoint( p1, MABuffBar, p3, 0, -cy * (sh + MABUFFSPACINGY) )
										else
											self:SetPoint( p1, MABuffBar, p3, 0, cy * (sh + MABUFFSPACINGY) )
										end
									elseif prevBuff then
										if rel == "RIGHT" then
											self:SetPoint( rel, prevBuff, dirH, -MABUFFSPACINGX, 0 )
										else
											self:SetPoint( rel, prevBuff, dirH, MABUFFSPACINGX, 0 )
										end
									end
								end
							end

							self.setpoint_bbtn = false
						end )
					end
					bbtn:ClearAllPoints()
					bbtn:SetPoint( "CENTER", 0, 0 )
				end
			end
		end
		
		hooksecurefunc( MABuffBar, "SetPoint", function( self, ... )
			MAUpdateBuffs()
		end )

		local f = CreateFrame( "FRAME" )
		f:RegisterEvent( "UNIT_AURA" )
		f:SetScript( "OnEvent", function( self, event, ... )
			if event == "UNIT_AURA" then
				unit = ...
				if unit and unit == "player" then
					MAUpdateBuffs()
				end
			end
		end )

		C_Timer.After( 1, MAUpdateBuffs )
	end
end
