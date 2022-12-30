
local AddOnName, MoveAny = ...

function MoveAny:InitMAVehicleSeatIndicator()
	if VehicleSeatIndicator then
		MAVehicleSeatIndicator = CreateFrame( "Frame", "MAVehicleSeatIndicator", UIParent )
		MAVehicleSeatIndicator:SetSize( 100, 100 )

		MAVehicleSeatIndicator:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -300, -300 )
		hooksecurefunc( MAVehicleSeatIndicator, "SetPoint", function( self, ... )
			if self.mavsisetpoint then return end
			self.mavsisetpoint = true

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end

			VehicleSeatIndicator:ClearAllPoints()
			VehicleSeatIndicator:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
			self.mavsisetpoint = false
		end )

		hooksecurefunc( MAVehicleSeatIndicator, "SetScale", function( self, scale )
			VehicleSeatIndicator:SetScale( scale )
		end )
		hooksecurefunc( MAVehicleSeatIndicator, "SetAlpha", function( self, alpha )
			VehicleSeatIndicator:SetAlpha( alpha )
		end )

		hooksecurefunc( VehicleSeatIndicator, "SetPoint", function( self, ... )
			if self.vsisetpoint then return end
			self.vsisetpoint = true

			self:SetMovable( true )
			if self.SetUserPlaced and self:IsMovable() then
				self:SetUserPlaced( false )
			end

			self:ClearAllPoints()
			self:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
			self.vsisetpoint = false
		end )
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
	end
end
