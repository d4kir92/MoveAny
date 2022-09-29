
local AddOnName, MoveAny = ...

function MoveAny:InitMAVehicleSeatIndicator()
	if VehicleSeatIndicator then
		MAVehicleSeatIndicator = CreateFrame( "Frame", "MAVehicleSeatIndicator", UIParent )
		MAVehicleSeatIndicator:SetSize( 100, 100 )

		MAVehicleSeatIndicator:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -300, -300 )

		hooksecurefunc( MAVehicleSeatIndicator, "SetPoint", function( self, ... )
			if self.masetpoint_maseat then return end
			self.masetpoint_maseat = true

			self:SetMovable( true )
			if self.SetUserPlaced then
				self:SetUserPlaced( false )
			end

			VehicleSeatIndicator:ClearAllPoints()
			VehicleSeatIndicator:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
			self.masetpoint_maseat = false
		end )

		hooksecurefunc( VehicleSeatIndicator, "SetPoint", function( self, ... )
			if self.masetpoint_seat then return end
			self.masetpoint_seat = true

			self:SetMovable( true )
			if self.SetUserPlaced then
				self:SetUserPlaced( false )
			end

			self:ClearAllPoints()
			self:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
			self.masetpoint_seat = false
		end )
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint( "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0 )
	end
end
