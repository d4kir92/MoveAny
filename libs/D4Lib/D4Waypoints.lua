local _, D4 = ...
function D4:IsWaypointTracked()
    if C_SuperTrack == nil or C_SuperTrack.IsSuperTrackingUserWaypoint == nil then return true end

    return C_SuperTrack.IsSuperTrackingUserWaypoint()
end

function D4:SetWaypointTracked(tracked)
    if C_SuperTrack ~= nil and C_SuperTrack.SetSuperTrackedUserWaypoint ~= nil then C_SuperTrack.SetSuperTrackedUserWaypoint(tracked) end
end

function D4:SetTrackedWaypoint(mapID, x, y)
    if mapID == nil or x == nil or y == nil then return false end
    if C_Map == nil or C_Map.SetUserWaypoint == nil or UiMapPoint == nil or UiMapPoint.CreateFromCoordinates == nil then return false end
    if C_Map.CanSetUserWaypointOnMap ~= nil and not C_Map.CanSetUserWaypointOnMap(mapID) then return false, "invalid" end
    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
    D4:SetWaypointTracked(true)

    return true
end
