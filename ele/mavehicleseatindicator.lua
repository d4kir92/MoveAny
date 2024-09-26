local _, MoveAny = ...
local tries = 0
function MoveAny:InitMAVehicleSeatIndicator()
	tries = tries + 1
	if VehicleSeatIndicator and MoveAny:IsEnabled("VEHICLESEATINDICATOR", false) then
		local MAVehicleSeatIndicator = CreateFrame("Frame", "MAVehicleSeatIndicator", MoveAny:GetMainPanel())
		MAVehicleSeatIndicator:SetSize(100, 100)
		MAVehicleSeatIndicator:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -300, -300)
		hooksecurefunc(
			MAVehicleSeatIndicator,
			"SetPoint",
			function(sel, ...)
				if sel.mavsisetpoint then return end
				sel.mavsisetpoint = true
				sel:SetMovable(true)
				if sel.SetUserPlaced and sel:IsMovable() then
					sel:SetUserPlaced(false)
				end

				MoveAny:SetPoint(VehicleSeatIndicator, "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
				sel.mavsisetpoint = false
			end
		)

		hooksecurefunc(
			MAVehicleSeatIndicator,
			"SetScale",
			function(sel, scale)
				if InCombatLockdown() and sel:IsProtected() then return false end
				if scale and type(scale) == "number" then
					VehicleSeatIndicator:SetScale(scale)
				end
			end
		)

		hooksecurefunc(
			MAVehicleSeatIndicator,
			"SetAlpha",
			function(sel, alpha)
				VehicleSeatIndicator:SetAlpha(alpha)
			end
		)

		hooksecurefunc(
			VehicleSeatIndicator,
			"SetPoint",
			function(sel, ...)
				if sel.vsisetpoint then return end
				sel.vsisetpoint = true
				sel:SetMovable(true)
				if sel.SetUserPlaced and sel:IsMovable() then
					sel:SetUserPlaced(false)
				end

				MoveAny:SetPoint(sel, "CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
				sel.vsisetpoint = false
			end
		)

		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("CENTER", MAVehicleSeatIndicator, "CENTER", 0, 0)
	elseif tries < 10 then
		C_Timer.After(1, MoveAny.InitMAVehicleSeatIndicator)
	end
end
