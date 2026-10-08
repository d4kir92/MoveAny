local addonName, D4 = ...
local VERSION = 3
local DB_KEY = "D4WAYPOINT"
local ARRIVAL_DISTANCE = 10
local UPDATE_INTERVAL = 0.02
local EDGE_MARGIN = 40
local DEFAULT_FOV = 90
local FOV_ASPECT = 2.09
local MARKER_DELAY = 0.1
local MEDIA = "Interface\\AddOns\\" .. addonName .. "\\libs\\D4Lib\\media\\"
local FALLBACK_ATLASES = {
    ["Navigation-Tracked-Icon"] = {"IngameNavigationUI", 23, 35, 0.453125, 0.8125, 0.015625, 0.5625},
    ["Navigation-Tracked-Arrow"] = {"IngameNavigationUI", 22, 18, 0.015625, 0.359375, 0.5625, 0.84375},
    ["Waypoint-MapPin-Tracked"] = {"WaypoinMapPinUI", 30, 30, 0.320312, 0.554688, 0.515625, 0.984375},
    ["Waypoint-MapPin-Untracked"] = {"WaypoinMapPinUI", 30, 30, 0.570312, 0.804688, 0.015625, 0.484375},
    ["Waypoint-MapPin-Highlight"] = {"WaypoinMapPinUI", 30, 30, 0.320312, 0.554688, 0.015625, 0.484375},
    ["UI-QuestPoi-QuestNumber"] = {"QuestMapIcons", 32, 32, 0.261719, 0.386719, 0.273438, 0.523438},
    ["UI-QuestPoi-QuestNumber-Pressed"] = {"QuestMapIcons", 32, 32, 0.261719, 0.386719, 0.539062, 0.789062},
    ["UI-QuestPoi-QuestNumber-SuperTracked"] = {"QuestMapIcons", 32, 32, 0.394531, 0.519531, 0.273438, 0.523438},
    ["UI-QuestPoi-QuestNumber-Pressed-SuperTracked"] = {"QuestMapIcons", 32, 32, 0.394531, 0.519531, 0.0078125, 0.257812},
}

local NAV_ICON = "Navigation-Tracked-Icon"
local NAV_ARROW = "Navigation-Tracked-Arrow"
local MAP_PIN = {
    ["tracked"] = "Waypoint-MapPin-Tracked",
    ["untracked"] = "Waypoint-MapPin-Untracked",
    ["highlight"] = "Waypoint-MapPin-Highlight",
}
local registry = _G["D4WaypointRegistry"]
if type(registry) ~= "table" then
    registry = {
        ["version"] = 0,
        ["callbacks"] = {},
        ["markers"] = {},
        ["dbs"] = {},
        ["tracked"] = true,
    }

    _G["D4WaypointRegistry"] = registry
end

registry.markers = registry.markers or {}

local impl = {}
function impl.IsNative()
    return C_Map ~= nil and C_Map.SetUserWaypoint ~= nil and UiMapPoint ~= nil and UiMapPoint.CreateFromCoordinates ~= nil
end

function impl.IsFallback()
    return registry.enabled == true and not impl.IsNative()
end

function impl.Notify()
    for _, callback in ipairs(registry.callbacks) do
        callback()
    end
end

function impl.Save()
    local wp = registry.waypoint
    local data = {
        ["stamp"] = registry.stamp or 0,
        ["tracked"] = registry.tracked,
    }

    if wp ~= nil then
        data.mapID = wp.mapID
        data.x = wp.x
        data.y = wp.y
    end

    for _, getDB in ipairs(registry.dbs) do
        local db = getDB()
        if type(db) == "table" then db[DB_KEY] = data end
    end
end

function impl.CreateWaypoint(mapID, x, y)
    if C_Map == nil or C_Map.GetWorldPosFromMapPos == nil or CreateVector2D == nil then return nil end
    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x, y))
    if continentID == nil or worldPos == nil then return nil end

    return {
        ["mapID"] = mapID,
        ["x"] = x,
        ["y"] = y,
        ["continentID"] = continentID,
        ["worldPos"] = worldPos,
    }
end

function impl.Load()
    local newest = nil
    for _, getDB in ipairs(registry.dbs) do
        local db = getDB()
        local data = type(db) == "table" and db[DB_KEY] or nil
        if type(data) == "table" and (newest == nil or (tonumber(data.stamp) or 0) > (tonumber(newest.stamp) or 0)) then newest = data end
    end

    if newest == nil then return end
    registry.stamp = tonumber(newest.stamp) or 0
    registry.tracked = newest.tracked ~= false
    registry.waypoint = nil
    if newest.mapID ~= nil and newest.x ~= nil and newest.y ~= nil then registry.waypoint = impl.CreateWaypoint(newest.mapID, newest.x, newest.y) end
    impl.Save()
end

function impl.Changed()
    registry.stamp = max(time(), (registry.stamp or 0) + 1)
    impl.Save()
    impl.UpdateArrow()
    impl.Notify()
end

function impl.SetWaypoint(mapID, x, y)
    local wp = impl.CreateWaypoint(mapID, x, y)
    if wp == nil then return false, "invalid" end
    registry.waypoint = wp
    registry.tracked = true
    impl.Changed()

    return true
end

function impl.ClearWaypoint()
    if registry.waypoint == nil then return end
    registry.waypoint = nil
    impl.Changed()
end

function impl.SetTracked(tracked)
    tracked = tracked == true
    if registry.tracked == tracked then return end
    registry.tracked = tracked
    impl.Changed()
end

function impl.GetPositionForMap(mapID)
    local wp = registry.waypoint
    if wp == nil or mapID == nil then return nil end
    if wp.mapID == mapID then return CreateVector2D(wp.x, wp.y) end
    if C_Map.GetMapPosFromWorldPos == nil then return nil end
    local _, pos = C_Map.GetMapPosFromWorldPos(wp.continentID, wp.worldPos, mapID)
    if pos == nil then return nil end
    local x, y = pos:GetXY()
    if x == nil or y == nil or x < 0 or x > 1 or y < 0 or y > 1 then return nil end

    return pos
end

function impl.GetRelative()
    local wp = registry.waypoint
    if wp == nil or UnitPosition == nil or GetPlayerFacing == nil then return nil end
    local px, py, _, instanceID = UnitPosition("player")
    local facing = GetPlayerFacing()
    if px == nil or py == nil or facing == nil or instanceID ~= wp.continentID then return nil end
    if D4:IsSecret(px) or D4:IsSecret(py) or D4:IsSecret(facing) then return nil end
    local tx, ty = wp.worldPos:GetXY()
    local dx, dy = tx - px, ty - py
    local zoom = GetCameraZoom ~= nil and GetCameraZoom() or 0
    if zoom == nil or D4:IsSecret(zoom) then zoom = 0 end
    local cx, cy = dx + zoom * math.cos(facing), dy + zoom * math.sin(facing)

    return math.sqrt(dx * dx + dy * dy), math.atan2(cy, cx) - facing
end

function impl.Debug()
    local distance, angle = impl.GetRelative()
    if distance == nil then return "no waypoint or no position" end
    angle = (angle + math.pi) % (2 * math.pi) - math.pi
    local wp = registry.waypoint
    local px, py = UnitPosition("player")
    local tx, ty = wp.worldPos:GetXY()
    local raw = (math.atan2(ty - py, tx - px) - GetPlayerFacing() + math.pi) % (2 * math.pi) - math.pi
    local offset = impl.GetScreenOffset(angle)

    return format("angle=%.2f raw=%.2f dist=%.1f zoom=%.1f fov=%s ui=%.0fx%.0f px=%.0fx%.0f offset=%.0f", math.deg(angle), math.deg(raw), distance, GetCameraZoom ~= nil and GetCameraZoom() or -1, tostring(GetCVar("cameraFov")), UIParent:GetWidth(), UIParent:GetHeight(), GetPhysicalScreenSize ~= nil and select(1, GetPhysicalScreenSize()) or 0, GetPhysicalScreenSize ~= nil and select(2, GetPhysicalScreenSize()) or 0, offset)
end

function impl.PlaySound(key)
    if SOUNDKIT ~= nil and SOUNDKIT[key] ~= nil then PlaySound(SOUNDKIT[key]) end
end

function impl.OnMapClick(map, button, x, y)
    if button ~= "LeftButton" or not IsControlKeyDown() or not impl.IsFallback() then return false end
    if not impl.SetWaypoint(map:GetMapID(), x, y) then return false end
    impl.PlaySound("UI_MAP_WAYPOINT_CONTROL_CLICK")

    return true
end

function impl.HasMarker(mapID, x, y)
    for _, marker in ipairs(registry.markers) do
        if marker(mapID, x, y) then return true end
    end

    return false
end

function impl.QueueMapPin()
    if registry.mapPinQueued or C_Timer == nil then return end
    registry.mapPinQueued = true
    C_Timer.After(MARKER_DELAY, function()
        registry.mapPinQueued = false
        registry.impl.UpdateMapPin(true)
    end)
end

function impl.UpdateMapPin(queued)
    local pin = registry.mapPin
    if pin == nil then return end
    local pos = nil
    local mapID = WorldMapFrame:GetMapID()
    if impl.IsFallback() and WorldMapFrame:IsShown() then pos = impl.GetPositionForMap(mapID) end
    if pos == nil then
        pin:Hide()

        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    local scale = 1 / max(WorldMapFrame:GetCanvasScale() or 1, 0.01)
    local x, y = pos:GetXY()
    pin:SetScale(scale)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", canvas, "TOPLEFT", canvas:GetWidth() * x / scale, -canvas:GetHeight() * y / scale)
    pin:SetFrameLevel(canvas:GetFrameLevel() + 2500)
    impl.SetAtlas(pin.Icon, registry.tracked and MAP_PIN.tracked or MAP_PIN.untracked, false)
    pin:SetShown(not impl.HasMarker(mapID, x, y))
    if not queued then impl.QueueMapPin() end
end

function impl.InstallMap()
    if registry.mapPin ~= nil or WorldMapFrame == nil or WorldMapFrame.AddCanvasClickHandler == nil or WorldMapFrame.GetCanvas == nil then return end
    WorldMapFrame:AddCanvasClickHandler(function(map, button, x, y) return registry.impl.OnMapClick(map, button, x, y) end, 100)
    local pin = CreateFrame("Button", nil, WorldMapFrame:GetCanvas())
    pin:SetSize(FALLBACK_ATLASES[MAP_PIN.tracked][2], FALLBACK_ATLASES[MAP_PIN.tracked][3])
    pin:RegisterForClicks("LeftButtonUp")
    pin.Icon = pin:CreateTexture(nil, "OVERLAY")
    pin.Icon:SetAllPoints(pin)
    impl.SetAtlas(pin.Icon, MAP_PIN.tracked, false)
    pin.Highlight = pin:CreateTexture(nil, "HIGHLIGHT")
    pin.Highlight:SetAllPoints(pin)
    pin.Highlight:SetBlendMode("ADD")
    impl.SetAtlas(pin.Highlight, MAP_PIN.highlight, false)
    pin:SetScript("OnClick", function()
        if IsControlKeyDown() then
            registry.impl.ClearWaypoint()
            registry.impl.PlaySound("UI_MAP_WAYPOINT_REMOVE")

            return
        end

        local tracked = not registry.tracked
        registry.impl.SetTracked(tracked)
        registry.impl.PlaySound(tracked and "UI_MAP_WAYPOINT_SUPER_TRACK_ON" or "UI_MAP_WAYPOINT_SUPER_TRACK_OFF")
    end)

    pin:Hide()
    registry.mapPin = pin
    local function Update()
        registry.impl.UpdateMapPin()
    end

    if WorldMapFrame.OnMapChanged ~= nil then hooksecurefunc(WorldMapFrame, "OnMapChanged", Update) end
    if WorldMapFrame.OnCanvasScaleChanged ~= nil then hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", Update) end
    WorldMapFrame:HookScript("OnShow", Update)
    Update()
end

function impl.UpdateArrow()
    impl.UpdateMapPin()
    local frame = registry.arrow
    if frame == nil then return end
    if registry.waypoint == nil or not registry.tracked then
        frame:Hide()

        return
    end

    frame.elapsed = UPDATE_INTERVAL
    frame:Show()
end

function impl.GetDistanceFormat()
    local locale = GetLocale()
    if locale == "enUS" or locale == "enGB" then return "%s yds" end

    return "%s m"
end

function impl.GetHalfFov()
    local fov = tonumber(GetCVar ~= nil and GetCVar("cameraFov") or nil) or DEFAULT_FOV
    if fov < 30 or fov > 150 then fov = DEFAULT_FOV end

    return math.rad(fov) / 2
end

function impl.GetScreenOffset(angle)
    angle = (angle + math.pi) % (2 * math.pi) - math.pi
    local halfWidth = UIParent:GetWidth() / 2 - EDGE_MARGIN
    if math.abs(angle) >= math.pi / 2 then return angle > 0 and -halfWidth or halfWidth, true end
    local offset = -math.tan(angle) / math.tan(impl.GetHalfFov()) * UIParent:GetHeight() * FOV_ASPECT / 2
    if offset > halfWidth then return halfWidth, true end
    if offset < -halfWidth then return -halfWidth, true end

    return offset, false
end

function impl.OnArrowUpdate(frame, elapsed)
    frame.elapsed = (frame.elapsed or 0) + elapsed
    if frame.elapsed < UPDATE_INTERVAL then return end
    frame.elapsed = 0
    local distance, angle = impl.GetRelative()
    if distance == nil then
        frame:SetAlpha(0)

        return
    end

    if distance <= ARRIVAL_DISTANCE then
        impl.ClearWaypoint()

        return
    end

    local offset, clamped = impl.GetScreenOffset(angle)
    frame:SetAlpha(1)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", offset, 0)
    frame.Arrow:SetShown(clamped)
    if clamped then
        frame.Arrow:ClearAllPoints()
        frame.Arrow:SetPoint("CENTER", frame.Icon, "CENTER", offset > 0 and 28 or -28, 0)
        frame.Arrow:SetRotation(offset > 0 and -math.pi / 2 or math.pi / 2)
    end

    local yards = floor(distance)
    if BreakUpLargeNumbers ~= nil then yards = BreakUpLargeNumbers(yards) end
    frame.Distance:SetText(format(impl.GetDistanceFormat(), yards))
end

function impl.IsClientAtlas(name)
    return C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil and C_Texture.GetAtlasInfo(name) ~= nil
end

function impl.SetAtlas(texture, name, useAtlasSize)
    if impl.IsClientAtlas(name) and (impl.IsNative() or FALLBACK_ATLASES[name] == nil) then
        texture:SetAtlas(name, useAtlasSize)

        return true
    end

    local def = FALLBACK_ATLASES[name]
    if def == nil then return false end
    texture:SetTexture(MEDIA .. def[1])
    texture:SetTexCoord(def[4], def[5], def[6], def[7])
    if useAtlasSize then texture:SetSize(def[2], def[3]) end

    return true
end

function impl.CreateArrow()
    if registry.arrow ~= nil then return end
    local frame = CreateFrame("Frame", "D4WaypointArrow", UIParent)
    frame:SetSize(FALLBACK_ATLASES[NAV_ICON][2], FALLBACK_ATLASES[NAV_ICON][3])
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("BACKGROUND")
    frame:EnableMouse(false)
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:Hide()
    frame.Icon = frame:CreateTexture(nil, "BACKGROUND")
    frame.Icon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    impl.SetAtlas(frame.Icon, NAV_ICON, true)
    frame.Arrow = frame:CreateTexture(nil, "BACKGROUND")
    impl.SetAtlas(frame.Arrow, NAV_ARROW, true)
    frame.Arrow:Hide()
    frame.Distance = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
    frame.DistanceText = frame.Distance
    frame.Distance:SetPoint("TOP", frame.Icon, "BOTTOM", 0, -8)
    frame:SetScript("OnUpdate", function(self, elapsed)
        registry.impl.OnArrowUpdate(self, elapsed)
    end)

    frame:SetScript("OnEvent", function(self)
        self:EnableMouse(IsControlKeyDown())
    end)

    frame:SetScript("OnShow", function(self)
        self:EnableMouse(IsControlKeyDown())
    end)

    frame:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" or not IsControlKeyDown() then return end
        registry.impl.ClearWaypoint()
        registry.impl.PlaySound("UI_MAP_WAYPOINT_REMOVE")
    end)

    registry.arrow = frame
end

function impl.CreateEventFrame()
    if registry.eventFrame ~= nil then return end
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    if impl.IsNative() then
        frame:RegisterEvent("USER_WAYPOINT_UPDATED")
        if C_SuperTrack ~= nil then frame:RegisterEvent("SUPER_TRACKING_CHANGED") end
    else
        frame:RegisterEvent("ADDON_LOADED")
    end

    frame:SetScript("OnEvent", function(_, event, name)
        if event == "ADDON_LOADED" then
            if name == "Blizzard_WorldMap" and registry.enabled then registry.impl.InstallMap() end

            return
        end

        if event == "PLAYER_LOGIN" then
            registry.ready = true
            if registry.impl.IsFallback() then
                registry.impl.InstallMap()
                registry.impl.Load()
                registry.impl.UpdateArrow()
                registry.impl.Notify()
            end

            return
        end

        registry.impl.Notify()
    end)

    registry.eventFrame = frame
end

if registry.version < VERSION then
    registry.version = VERSION
    registry.impl = impl
end

registry.impl.CreateEventFrame()
function D4:EnableWaypointFallback(getDB)
    local api = registry.impl
    if api.IsNative() then return false end
    if getDB ~= nil then tinsert(registry.dbs, getDB) end
    if registry.enabled then
        if registry.ready and getDB ~= nil then api.Save() end

        return true
    end

    registry.enabled = true
    api.CreateArrow()
    api.InstallMap()
    if registry.ready then
        api.Load()
        api.UpdateArrow()
        api.Notify()
    end

    return true
end

function D4:GetWaypointDistance()
    if registry.impl.IsFallback() then return registry.impl.GetRelative() or 0 end
    if C_Navigation ~= nil and C_Navigation.GetDistance ~= nil then return C_Navigation.GetDistance() or 0 end

    return 0
end

function D4:GetWaypointFrame()
    if registry.impl.IsFallback() then return registry.arrow end

    return SuperTrackedFrame
end

function D4:HasWaypointSupport()
    return registry.impl.IsNative() or registry.impl.IsFallback()
end

function D4:RegisterWaypointCallback(callback)
    tinsert(registry.callbacks, callback)
end

function D4:RegisterWaypointMarker(marker)
    tinsert(registry.markers, marker)
end

function D4:HasAtlasOrFallback(name)
    return name ~= nil and (registry.impl.IsClientAtlas(name) or FALLBACK_ATLASES[name] ~= nil)
end

function D4:SetAtlasOrFallback(texture, name, useAtlasSize)
    return registry.impl.SetAtlas(texture, name, useAtlasSize)
end

function D4:HasUserWaypoint()
    if registry.impl.IsFallback() then return registry.waypoint ~= nil end
    if C_Map == nil or C_Map.HasUserWaypoint == nil then return false end

    return C_Map.HasUserWaypoint()
end

function D4:GetUserWaypoint()
    if registry.impl.IsFallback() then
        local wp = registry.waypoint
        if wp == nil then return nil end

        return {
            ["uiMapID"] = wp.mapID,
            ["position"] = CreateVector2D(wp.x, wp.y),
        }
    end

    if C_Map == nil or C_Map.GetUserWaypoint == nil then return nil end

    return C_Map.GetUserWaypoint()
end

function D4:GetUserWaypointPositionForMap(mapID)
    if registry.impl.IsFallback() then return registry.impl.GetPositionForMap(mapID) end
    if C_Map == nil or C_Map.GetUserWaypointPositionForMap == nil then return nil end

    return C_Map.GetUserWaypointPositionForMap(mapID)
end

function D4:ClearUserWaypoint()
    if registry.impl.IsFallback() then
        registry.impl.ClearWaypoint()

        return
    end

    if C_Map ~= nil and C_Map.ClearUserWaypoint ~= nil then C_Map.ClearUserWaypoint() end
end

function D4:IsWaypointTracked()
    if registry.impl.IsFallback() then return registry.tracked end
    if C_SuperTrack == nil or C_SuperTrack.IsSuperTrackingUserWaypoint == nil then return true end

    return C_SuperTrack.IsSuperTrackingUserWaypoint()
end

function D4:SetWaypointTracked(tracked)
    if registry.impl.IsFallback() then
        registry.impl.SetTracked(tracked)

        return
    end

    if C_SuperTrack ~= nil and C_SuperTrack.SetSuperTrackedUserWaypoint ~= nil then C_SuperTrack.SetSuperTrackedUserWaypoint(tracked) end
end

function D4:SetTrackedWaypoint(mapID, x, y)
    if mapID == nil or x == nil or y == nil then return false end
    if registry.impl.IsFallback() then return registry.impl.SetWaypoint(mapID, x, y) end
    if not registry.impl.IsNative() then return false end
    if C_Map.CanSetUserWaypointOnMap ~= nil and not C_Map.CanSetUserWaypointOnMap(mapID) then return false, "invalid" end
    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
    D4:SetWaypointTracked(true)

    return true
end
