local _, MoveAny = ...

function MoveAny:InitMAVehicleSeatIndicator()
	if VehicleSeatIndicator then
		MAVehicleSeatIndicator = CreateFrame("Frame", "MAVehicleSeatIndicator", UIParent)
		MAVehicleSeatIndicator:SetSize(100, 100)
		MAVehicleSeatIndicator:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -300)

		hooksecurefunc(MAVehicleSeatIndicator, "SetPoint", function(sel, ...)
			if sel.mavsisetpoint then return end
			sel.mavsisetpoint = true
			sel:SetMovable(true)

			if sel.SetUserPlaced and sel:IsMovable() then
				sel:SetUserPlaced(false)
			end

			VehicleSeatIndicator:ClearAllPoints()
			VehicleSeatIndicator:SetPoint("CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
			sel.mavsisetpoint = false
		end)

		hooksecurefunc(MAVehicleSeatIndicator, "SetScale", function(sel, scale)
			VehicleSeatIndicator:SetScale(scale)
		end)

		hooksecurefunc(MAVehicleSeatIndicator, "SetAlpha", function(sel, alpha)
			VehicleSeatIndicator:SetAlpha(alpha)
		end)

		hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(sel, ...)
			if sel.vsisetpoint then return end
			sel.vsisetpoint = true
			sel:SetMovable(true)

			if sel.SetUserPlaced and sel:IsMovable() then
				sel:SetUserPlaced(false)
			end

			sel:ClearAllPoints()
			sel:SetPoint("CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
			sel.vsisetpoint = false
		end)

		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
	end
end