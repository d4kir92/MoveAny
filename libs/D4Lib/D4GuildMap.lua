local _, D4 = ...
local GUILDMAP_OWNERS = "D4GuildMapOwners"
local GUILDMAP_HOOKS = "D4GuildMapHooks"
local GUILDMAP_MAPS = "D4GuildMapInstances"
function D4:AttachGuildMapHooks()
    local attached = _G.D4GuildMapAttached
    for hookOwner, hooks in pairs(_G[GUILDMAP_HOOKS]) do
        if hooks.attach ~= nil then
            for mapOwner, guild in pairs(_G[GUILDMAP_MAPS]) do
                local key = hookOwner .. ":" .. mapOwner
                if not attached[key] then
                    attached[key] = true
                    hooks.attach(guild)
                end
            end
        end
    end
end

function D4:GetGuildMapOwner()
    local owners = _G[GUILDMAP_OWNERS]
    if owners == nil then return nil end
    local best, bestPriority
    for name, priority in pairs(owners) do
        if best == nil or priority > bestPriority or (priority == bestPriority and name < best) then best, bestPriority = name, priority end
    end

    return best
end

function D4:CreateGuildMap(options)
    if WorldMapFrame == nil or C_Map == nil or C_Map.GetBestMapForUnit == nil or C_Map.GetPlayerMapPosition == nil or C_Map.GetMapRectOnMap == nil then return nil end
    options = options or {}
    local owner = options.owner or "D4"
    _G[GUILDMAP_OWNERS] = _G[GUILDMAP_OWNERS] or {}
    _G[GUILDMAP_OWNERS][owner] = options.priority or 0
    _G[GUILDMAP_HOOKS] = _G[GUILDMAP_HOOKS] or {}
    _G[GUILDMAP_MAPS] = _G[GUILDMAP_MAPS] or {}
    _G.D4GuildMapAttached = _G.D4GuildMapAttached or {}
    _G[GUILDMAP_HOOKS][owner] = {
        isHidden = options.isHidden,
        getClip = options.getClip,
        getZoneSpace = options.getZoneSpace,
        setPinScale = options.setPinScale,
        attach = options.attach
    }

    local Guild = {
        owner = owner,
        prefix = "MapUtils",
        tag = "G",
        scale = 10000,
        sendInterval = 5,
        heartbeat = 30,
        moveEpsilon = 0.0015,
        expireOwn = 75,
        checkInterval = 0.1,
        pruneInterval = 2,
        dotSize = 12,
        levelDotSize = 16,
        levelFontSize = 9,
        levelOffsetX = 1,
        nameFontSize = 10,
        crownSize = 12,
        crownOverlap = 5,
        nameCrownOverlap = 1,
        crownAtlas = "UI-HUD-UnitFrame-Player-Group-LeaderIcon",
        crownTexture = "Interface\\GroupFrame\\UI-Group-LeaderIcon",
        border = 1.5,
        mask = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
        fallbackColor = {
            r = 0.2,
            g = 1,
            b = 0.4
        },
        textColor = {
            r = 1,
            g = 1,
            b = 1
        },
        members = {},
        pins = {},
        rects = {},
        online = {},
        ranks = {},
        rosterLevels = {},
        rosterZones = {},
        kinship = {},
        elapsed = 0,
        sincePrune = 0,
        dirty = true,
        lastSent = {},
        sources = {
            MapUtils = 75,
            GuildHelper = 75,
            GuildMapDots = 15,
            GuildMap = 20,
            GuildAtlas = 150,
            GuildCrest = 30,
            Kinship = 1900
        },
        ownSources = {
            MapUtils = true,
            GuildHelper = true
        }
    }

    function Guild.IsActive()
        return D4:GetGuildMapOwner() == Guild.owner
    end

    function Guild.IsSecret(...)
        for i = 1, select("#", ...) do
            if D4:IsSecret(select(i, ...)) then return true end
        end

        return false
    end

    function Guild.GetConfig(key, default)
        if D4.GetConfig == nil then return default end

        return D4:GetConfig(key, default) == true
    end

    function Guild.IsShown()
        return Guild.IsActive() and Guild.GetConfig("GUILDMEMBERPINS", true)
    end

    function Guild.IsSharing()
        return Guild.IsActive() and Guild.GetConfig("GUILDMEMBERSHARE", true)
    end

    function Guild.IsHiddenOn(mapID)
        for _, hooks in pairs(_G[GUILDMAP_HOOKS]) do
            if hooks.isHidden ~= nil and hooks.isHidden(mapID) then return true end
        end

        return false
    end

    function Guild.GetClip(mapID)
        local low, high = 0, 1
        for _, hooks in pairs(_G[GUILDMAP_HOOKS]) do
            if hooks.getClip ~= nil then
                local hookLow, hookHigh = hooks.getClip(mapID)
                if hookLow ~= nil and hookLow < low then low = hookLow end
                if hookHigh ~= nil and hookHigh > high then high = hookHigh end
            end
        end

        return low, high
    end

    function Guild.SetPinScale(pin, scale)
        for _, hooks in pairs(_G[GUILDMAP_HOOKS]) do
            if hooks.setPinScale ~= nil then hooks.setPinScale(pin, scale) end
        end
    end

    function Guild.GetName(sender)
        if Ambiguate ~= nil then return Ambiguate(sender, "none") end

        return sender
    end

    function Guild.GetOwnRosterName()
        if Guild.ownRosterName ~= nil then return Guild.ownRosterName end
        if not D4:IsForever() or UnitGUID == nil or GetNumGuildMembers == nil or GetGuildRosterInfo == nil then return nil end
        local guid = UnitGUID("player")
        if guid == nil or Guild.IsSecret(guid) then return nil end
        for index = 1, GetNumGuildMembers() or 0 do
            local memberName, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, memberGUID = GetGuildRosterInfo(index)
            if memberGUID == guid and type(memberName) == "string" then
                Guild.ownRosterName = strlower(strsplit("-", memberName))

                return Guild.ownRosterName
            end
        end
    end

    function Guild.IsSelfSender(sender)
        local key, ownName = D4:GetPlayerCharacterKey()
        if key and (sender == key or sender == ownName) then return true end
        if not key or D4:IsForever() then
            local name, realm = UnitFullName("player")
            if not D4:CanAccessValues(name, realm) or name == nil then return key == nil end
            if sender == name or (realm ~= nil and realm ~= "" and sender == name .. "-" .. realm) then return true end
        end
        local own = type(sender) == "string" and Guild.GetOwnRosterName()

        return own ~= nil and own == strlower(strsplit("-", sender))
    end

    function Guild.IsSelf(sender, name)
        if Guild.IsSelfSender(sender) or name == UnitName("player") then return true end
        local first, second = UnitName("player", true)
        if type(first) == "string" and type(second) == "string" and second ~= "" then
            local full = first .. " " .. second
            if name == full or sender == full or name == first .. "-" .. second then return true end
        end

        return false
    end

    function Guild.GetOwnPosition()
        local mapID = C_Map.GetBestMapForUnit("player")
        if Guild.IsSecret(mapID) or type(mapID) ~= "number" then return nil end
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos == nil then return nil end
        local x, y = pos:GetXY()
        if Guild.IsSecret(x, y) or type(x) ~= "number" or type(y) ~= "number" or (x == 0 and y == 0) then return nil end

        return mapID, x, y
    end

    function Guild.CanSend()
        if not Guild.IsSharing() or not IsInGuild() or C_ChatInfo == nil or C_ChatInfo.SendAddonMessage == nil then return false end
        if C_GuildInfo ~= nil and C_GuildInfo.CanSpeakInGuildChat ~= nil and not C_GuildInfo.CanSpeakInGuildChat() then return false end

        return true
    end

    function Guild.Send(message)
        local ok, result = pcall(C_ChatInfo.SendAddonMessage, Guild.prefix, message, "GUILD")

        return ok and (result == nil or result == true or result == 0)
    end

    function Guild.Broadcast()
        if not Guild.CanSend() then return end
        local mapID, x, y = Guild.GetOwnPosition()
        if mapID == nil then return end
        local last = Guild.lastSent
        local now = GetTime()
        local moved = last.mapID ~= mapID or last.x == nil or math.abs(last.x - x) > Guild.moveEpsilon or math.abs(last.y - y) > Guild.moveEpsilon
        local taxi = UnitOnTaxi ~= nil and UnitOnTaxi("player")
        local faction = UnitFactionGroup("player")
        if Guild.IsSecret(taxi, faction) then return end
        taxi = taxi and 1 or 0
        if faction ~= "Horde" and faction ~= "Alliance" then faction = "" end
        if not moved and last.taxi == taxi and last.faction == faction and last.time ~= nil and now - last.time < Guild.heartbeat then return end
        local _, class = UnitClass("player")
        local message = format("%s%d:%d:%d:%s:%d:%s:%d:%s", Guild.tag, mapID, x * Guild.scale + 0.5, y * Guild.scale + 0.5, class or "", UnitLevel("player") or 0, Guild.owner, taxi, faction)
        if Guild.Send(message) then last.mapID, last.x, last.y, last.time, last.taxi, last.faction = mapID, x, y, now, taxi, faction end
    end

    function Guild.RefreshTicker()
        local active = Guild.IsSharing() and IsInGuild()
        if active and Guild.ticker == nil then
            Guild.lastSent.time = nil
            Guild.ticker = C_Timer.NewTicker(Guild.sendInterval, Guild.Broadcast)
            C_Timer.After(1, Guild.Broadcast)
        elseif not active and Guild.ticker ~= nil then
            Guild.ticker:Cancel()
            Guild.ticker = nil
        end
    end

    function Guild.Store(sender, source, mapID, x, y, class, level, taxi, faction)
        if type(mapID) ~= "number" or type(x) ~= "number" or type(y) ~= "number" or mapID <= 0 then return end
        if x < 0 or x > 1 or y < 0 or y > 1 or (x == 0 and y == 0) then return end
        local name = Guild.GetName(sender)
        if name == nil or name == "" or Guild.IsSelf(sender, name) then return end
        Guild.online[name] = true
        local now = GetTime()
        local member = Guild.members[name]
        if member == nil then
            member = {
                name = name
            }

            Guild.members[name] = member
        elseif not Guild.ownSources[source] and Guild.ownSources[member.source or ""] and now < member.expire then
            return
        end

        member.source = source
        member.taxi = taxi == "1"
        member.faction = (faction == "Horde" or faction == "Alliance") and faction or nil
        member.mapID, member.x, member.y = mapID, x, y
        if type(class) == "string" and RAID_CLASS_COLORS[class] ~= nil then member.class = class end
        if type(level) == "number" and level > 0 then member.level = level end
        member.time = now
        member.expire = now + (Guild.sources[source] or Guild.expireOwn)
        Guild.dirty = true
    end

    function Guild.Remove(sender, source)
        local name = Guild.GetName(sender)
        local member = name and Guild.members[name]
        if member ~= nil and member.source == source then
            Guild.members[name] = nil
            Guild.dirty = true
        end
    end

    function Guild.OnKinshipChunk(sender, body)
        local id, index, total, chunk = body:match("^(%d+):(%d+):(%d+):(.*)$")
        index, total = tonumber(index), tonumber(total)
        if id == nil or total < 1 or total > 30 or index < 1 or index > total then return end
        local now = GetTime()
        for key, partial in pairs(Guild.kinship) do
            if now - partial.time > 30 then Guild.kinship[key] = nil end
        end

        local key = sender .. "#" .. id
        local partial = Guild.kinship[key]
        if partial == nil then
            partial = {
                total = total,
                count = 0,
                parts = {},
                time = now
            }

            Guild.kinship[key] = partial
        end

        if partial.total ~= total or partial.parts[index] ~= nil then return end
        partial.parts[index] = chunk
        partial.count = partial.count + 1
        if partial.count < total then return end
        Guild.kinship[key] = nil
        local fields = {}
        for pair in table.concat(partial.parts):gmatch("[^;]+") do
            local k, v = pair:match("^(%w+)=(.*)$")
            if k == "c" or k == "l" or k == "mp" or k == "px" or k == "py" then fields[k] = v:gsub("~(%x%x)", function(h) return string.char(tonumber(h, 16)) end) end
        end

        local x, y = tonumber(fields.px), tonumber(fields.py)
        if x == nil or y == nil then return end
        Guild.Store(sender, "Kinship", tonumber(fields.mp), x / 1000, y / 1000, fields.c, tonumber(fields.l))
    end

    Guild.parsers = {
        MapUtils = function(message, sender)
            if message:sub(1, 1) ~= Guild.tag then return end
            local mapID, x, y, class, level, source, taxi, faction = strsplit(":", message:sub(2))
            x, y = tonumber(x), tonumber(y)
            if x == nil or y == nil then return end
            if not Guild.ownSources[source or ""] then source = "MapUtils" end
            Guild.Store(sender, source, tonumber(mapID), x / Guild.scale, y / Guild.scale, class, tonumber(level), taxi, faction)
        end,
        GMD1 = function(message, sender)
            local tag, mapID, x, y, class = strsplit("|", message)
            x, y = tonumber(x), tonumber(y)
            if tag ~= "P" or x == nil or y == nil then return end
            Guild.Store(sender, "GuildMapDots", tonumber(mapID), x / Guild.scale, y / Guild.scale, class)
        end,
        GuildMapEx1 = function(message, sender)
            local _, _, level, class, _, x, y, mapID = strsplit(",", message)
            Guild.Store(sender, "GuildMap", tonumber(mapID), tonumber(x), tonumber(y), class and class:upper(), tonumber(level))
        end,
        GQHMAP = function(message, sender)
            if message == "0" then return Guild.Remove(sender, "GuildAtlas") end
            local mapID, x, y = message:match("^1;(%d+);([%d%.]+);([%d%.]+)$")
            Guild.Store(sender, "GuildAtlas", tonumber(mapID), tonumber(x), tonumber(y))
        end,
        GCF1 = function(message, sender)
            local mapID, x, y, class, level = message:match("^1~POS~[^~]*~(%d+)~([%d%.]+)~([%d%.]+)~(%u+)~(%d+)~%d+$")
            Guild.Store(sender, "GuildCrest", tonumber(mapID), tonumber(x), tonumber(y), class, tonumber(level))
        end,
        Kinship = function(message, sender)
            local kind, body = message:match("^(%u):(.*)$")
            if kind == "P" then
                local mapID, x, y = body:match("^(%d+):(%d+):(%d+):")
                x, y = tonumber(x), tonumber(y)
                if x == nil or y == nil then return end
                Guild.Store(sender, "Kinship", tonumber(mapID), x / 1000, y / 1000)
            elseif kind == "D" then
                Guild.OnKinshipChunk(sender, body)
            end
        end
    }

    function Guild.UpdateRoster()
        if GetNumGuildMembers == nil or GetGuildRosterInfo == nil then return end
        local count = GetNumGuildMembers()
        if Guild.IsSecret(count) or type(count) ~= "number" then return end
        wipe(Guild.rosterZones)
        Guild.dirty = true
        wipe(Guild.online)
        wipe(Guild.ranks)
        wipe(Guild.rosterLevels)
        local leader
        for index = 1, count do
            local name, rank, rankIndex, level, _, zone, _, _, online, _, class, _, _, mobile = GetGuildRosterInfo(index)
            if not Guild.IsSecret(name, rank, rankIndex, online) and type(name) == "string" then
                name = Guild.GetName(name)
                Guild.online[name] = online and true or false
                Guild.ranks[name] = type(rank) == "string" and rank or nil
                if not Guild.IsSecret(level) and type(level) == "number" and level > 0 then Guild.rosterLevels[name] = level end
                if rankIndex == 0 then leader = name end
                if online and not Guild.IsSecret(zone, class, mobile) and not mobile and type(zone) == "string" and zone ~= "" and not Guild.IsSelf(name, name) then
                    Guild.rosterZones[name] = {name = name, zone = zone, class = class}
                end
            end
        end

        if Guild.leader ~= leader then
            Guild.leader = leader
            Guild.dirty = true
        end

        for name in pairs(Guild.members) do
            if Guild.online[name] == false then
                Guild.members[name] = nil
                Guild.dirty = true
            end
        end
    end

    function Guild.RequestRoster()
        local now = GetTime()
        if Guild.lastRoster ~= nil and now - Guild.lastRoster < 30 then return end
        Guild.lastRoster = now
        if C_GuildInfo ~= nil and C_GuildInfo.GuildRoster ~= nil then
            pcall(C_GuildInfo.GuildRoster)
        elseif GuildRoster ~= nil then
            pcall(GuildRoster)
        end
    end

    function Guild.Prune()
        local now = GetTime()
        for name, member in pairs(Guild.members) do
            if now > member.expire then
                Guild.members[name] = nil
                Guild.dirty = true
            end
        end
    end

    function Guild.GetRect(sourceID, targetID)
        local key = sourceID * 100000 + targetID
        local rect = Guild.rects[key]
        if rect == nil then
            local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(sourceID, targetID)
            if minX ~= nil and maxX ~= nil and minY ~= nil and maxY ~= nil and minX < maxX and minY < maxY then
                rect = {minX, maxX, minY, maxY}
            else
                rect = false
            end

            Guild.rects[key] = rect
        end

        return rect or nil
    end

    function Guild.Project(sourceID, targetID, x, y)
        local visited = {}
        while sourceID ~= targetID do
            if visited[sourceID] then return nil end
            visited[sourceID] = true
            local rect = Guild.GetRect(sourceID, targetID)
            if rect ~= nil then return rect[1] + x * (rect[2] - rect[1]), rect[3] + y * (rect[4] - rect[3]) end
            rect = Guild.GetRect(targetID, sourceID)
            if rect ~= nil then return (x - rect[1]) / (rect[2] - rect[1]), (y - rect[3]) / (rect[4] - rect[3]) end
            local info = C_Map.GetMapInfo(sourceID)
            local parentID = info and info.parentMapID
            if parentID == nil or parentID == 0 then return nil end
            rect = Guild.GetRect(sourceID, parentID)
            if rect == nil then return nil end
            x, y = rect[1] + x * (rect[2] - rect[1]), rect[3] + y * (rect[4] - rect[3])
            sourceID = parentID
        end

        return x, y
    end

    function Guild.IsGrouped(name)
        return UnitInParty(name) or UnitInRaid(name)
    end

    function Guild.IsLeader(name)
        return name == Guild.leader
    end

    function Guild.HasCrownAtlas()
        return C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil and C_Texture.GetAtlasInfo(Guild.crownAtlas) ~= nil
    end

    function Guild.GetCrownMarkup()
        if CreateAtlasMarkup ~= nil and Guild.HasCrownAtlas() then return CreateAtlasMarkup(Guild.crownAtlas, 14, 14) end

        return "|T" .. Guild.crownTexture .. ":14:14|t"
    end

    function Guild.OnPinEnter(pin)
        if pin.zoneMembers ~= nil then
            GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
            local zones = {}
            local commonZone
            for index, member in ipairs(pin.zoneMembers) do
                local info = member.mapID and C_Map.GetMapInfo(member.mapID)
                local rosterMember = Guild.rosterZones[member.name]
                local zone = member.zone or (info and info.name) or (rosterMember and rosterMember.zone)
                zones[index] = zone
                if index == 1 then
                    commonZone = zone
                elseif zone ~= commonZone then
                    commonZone = nil
                end
            end

            GameTooltip:SetText(commonZone or GUILD)
            for index, member in ipairs(pin.zoneMembers) do
                local color = RAID_CLASS_COLORS[member.class or ""] or Guild.fallbackColor
                local details = {}
                local rank = member.rank or Guild.ranks[member.name]
                local level = Guild.rosterLevels[member.name] or member.level
                if rank ~= nil and rank ~= "" then details[#details + 1] = rank end
                if level ~= nil then details[#details + 1] = format("%s %d", LEVEL or "Level", level) end
                if commonZone == nil and zones[index] ~= nil then details[#details + 1] = zones[index] end
                local text = member.name
                if #details > 0 then text = text .. " (" .. table.concat(details, ", ") .. ")" end
                GameTooltip:AddLine(text, color.r, color.g, color.b, true)
            end
            GameTooltip:Show()

            return
        end

        local member = pin.member
        if member == nil then return end
        GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
        local color = RAID_CLASS_COLORS[member.class or ""] or Guild.fallbackColor
        GameTooltip:SetText(member.name, color.r, color.g, color.b)
        local rank = member.rank or Guild.ranks[member.name]
        if rank ~= nil then
            if (member.debug and Guild.debug.crown) or (not member.debug and Guild.IsLeader(member.name)) then rank = Guild.GetCrownMarkup() .. " " .. rank end
            GameTooltip:AddLine(rank, 0.25, 1, 0.25)
        end

        local info = C_Map.GetMapInfo(member.mapID)
        if member.level ~= nil then GameTooltip:AddLine(format("%s %d", LEVEL or "Level", member.level), 1, 1, 1) end
        if member.taxi then
            local labels = Guild.debugLabels[GetLocale()] or Guild.debugLabels.enUS
            GameTooltip:AddLine(labels.flying, 1, 0.82, 0)
        end
        if info ~= nil and info.name ~= nil then GameTooltip:AddLine(info.name, 1, 1, 1) end
        GameTooltip:AddLine(format(D4:Trans("LID_GUILDMEMBERSEEN"), math.max(0, math.floor(GetTime() - member.time))), 0.7, 0.7, 0.7)
        if member.source ~= nil then GameTooltip:AddLine(member.source, 0.5, 0.5, 0.5) end
        GameTooltip:Show()
    end

    function Guild.CreatePin(canvas)
        local pin = CreateFrame("Frame", nil, canvas)
        pin:EnableMouse(true)
        pin.border = pin:CreateTexture(nil, "BACKGROUND")
        pin.border:SetAllPoints()
        pin.border:SetTexture(Guild.mask)
        pin.border:SetVertexColor(0, 0, 0, 0.9)
        pin.dot = pin:CreateTexture(nil, "ARTWORK")
        pin.dot:SetTexture(Guild.mask)
        pin.mask = pin:CreateMaskTexture()
        pin.mask:SetTexture(Guild.mask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        pin.mask:SetAllPoints(pin.dot)
        pin.dot:AddMaskTexture(pin.mask)
        pin.crown = pin:CreateTexture(nil, "OVERLAY")
        if pin.crown.SetAtlas ~= nil and Guild.HasCrownAtlas() then
            pin.crown:SetAtlas(Guild.crownAtlas)
        else
            pin.crown:SetTexture(Guild.crownTexture)
        end

        pin.level = pin:CreateFontString(nil, "OVERLAY")
        pin.name = pin:CreateFontString(nil, "OVERLAY")
        pin:SetScript("OnEnter", Guild.OnPinEnter)
        pin:SetScript("OnLeave", function(sel) if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end end)
        pin:SetScript("OnHide", function(sel) if GameTooltip:IsOwned(sel) then GameTooltip:Hide() end end)

        return pin
    end

    function Guild.SetLabel(label, text, size, color)
        if text == nil then
            label:Hide()

            return
        end

        if label.size ~= size then
            label:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
            label.size = size
        end

        label:SetText(text)
        label:SetTextColor(color.r, color.g, color.b, 1)
        label:Show()
    end

    function Guild.GetPinLevel(canvas)
        if not InCombatLockdown() and WorldMapFrame.GetPinFrameLevelsManager ~= nil then
            local manager = WorldMapFrame:GetPinFrameLevelsManager()
            if manager ~= nil and manager.GetValidFrameLevel ~= nil then
                local ok, level = pcall(manager.GetValidFrameLevel, manager, "PIN_FRAME_LEVEL_GROUP_MEMBER")
                if ok and type(level) == "number" then return level end
            end
        end

        return canvas:GetFrameLevel() + 30
    end

    Guild.debug = {enabled = false, taxi = false, crown = false, y = 0}
    Guild.debugArrows = {}
    Guild.debugLabels = {
        deDE = {flying = "Auf einem Taxiflug", crown = "Gildenleiter-Krone", enabled = "Eigenen Gildenmarker testen", taxi = "Taxiflug", title = "Gildenmarker-Test", y = "Y-Versatz"},
        enUS = {flying = "On a taxi flight", crown = "Guild leader crown", enabled = "Test own guild marker", taxi = "Taxi flight", title = "Guild marker test", y = "Y offset"},
        esES = {flying = "En un vuelo de transporte", crown = "Corona de maestro de hermandad", enabled = "Probar mi marcador de hermandad", taxi = "Vuelo de transporte", title = "Prueba de marcador", y = "Desplazamiento Y"},
        esMX = {flying = "En un vuelo de transporte", crown = "Corona de maestro de hermandad", enabled = "Probar mi marcador de hermandad", taxi = "Vuelo de transporte", title = "Prueba de marcador", y = "Desplazamiento Y"},
        frFR = {flying = "Sur un trajet aérien", crown = "Couronne de chef de guilde", enabled = "Tester mon marqueur de guilde", taxi = "Trajet aérien", title = "Test du marqueur de guilde", y = "Décalage Y"},
        itIT = {flying = "Su un volo di trasporto", crown = "Corona del capogilda", enabled = "Prova il mio indicatore di gilda", taxi = "Volo di trasporto", title = "Prova indicatore di gilda", y = "Scostamento Y"},
        koKR = {flying = "비행 경로로 이동 중", crown = "길드장 왕관", enabled = "내 길드 지도 표시 테스트", taxi = "비행 경로 이동", title = "길드 지도 표시 테스트", y = "Y 오프셋"},
        ptBR = {flying = "Em um voo de transporte", crown = "Coroa do mestre da guilda", enabled = "Testar meu marcador de guilda", taxi = "Voo de transporte", title = "Teste de marcador da guilda", y = "Deslocamento Y"},
        ruRU = {flying = "В полёте на такси", crown = "Корона главы гильдии", enabled = "Проверить свой маркер гильдии", taxi = "Полёт на такси", title = "Проверка маркера гильдии", y = "Смещение Y"},
        zhCN = {flying = "正在乘坐飞行坐骑", crown = "公会会长皇冠", enabled = "测试自己的公会标记", taxi = "飞行路线", title = "公会标记测试", y = "Y轴偏移"},
        zhTW = {flying = "正在搭乘飛行坐騎", crown = "公會會長皇冠", enabled = "測試自己的公會標記", taxi = "飛行路線", title = "公會標記測試", y = "Y軸偏移"}
    }

    function Guild.SetDebugArrowHidden(hidden)
        if not hidden and not Guild.debugArrowHidden then return end
        Guild.debugArrowHidden = hidden
        if hidden and WorldMapFrame.EnumeratePinsByTemplate ~= nil then
            for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
                if pin.SetShouldShowUnits ~= nil then
                    if not Guild.debugArrows[pin] then
                        Guild.debugArrows[pin] = true
                        hooksecurefunc(pin, "SetShouldShowUnits", function(arrow, unit, shown)
                            if Guild.debugArrowHidden and unit == "player" and shown then arrow:SetShouldShowUnits("player", false) end
                        end)
                    end
                    pin:SetShouldShowUnits("player", false)
                    if pin.StopPlayerPing ~= nil then pin:StopPlayerPing() end
                end
            end
        elseif not hidden then
            for pin in pairs(Guild.debugArrows) do
                if pin.UpdateShownUnits ~= nil then pin:UpdateShownUnits() end
            end
        end
    end

    function Guild.UpdateDebugMember()
        local debug = Guild.debug
        local mapID, x, y
        if debug.enabled and Guild.IsActive() then mapID, x, y = Guild.GetOwnPosition() end
        if mapID == nil then
            Guild.members[debug] = nil
            return
        end
        local member = Guild.members[debug] or {}
        Guild.members[debug] = member
        member.debug = true
        member.name = UnitName("player")
        member.mapID, member.x, member.y = mapID, x, y
        member.class = select(2, UnitClass("player"))
        member.level = UnitLevel("player")
        local _, rank = GetGuildInfo("player")
        member.rank = not Guild.IsSecret(rank) and type(rank) == "string" and rank or nil
        member.faction = UnitFactionGroup("player")
        member.taxi = debug.taxi
        member.source = Guild.owner
        member.time, member.expire = GetTime(), math.huge
    end

    function Guild.ToggleDebugMenu()
        if Guild.debugMenu ~= nil then
            Guild.debugMenu:SetShown(not Guild.debugMenu:IsShown())
            return
        end
        local labels = Guild.debugLabels[GetLocale()] or Guild.debugLabels.enUS
        local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        Guild.debugMenu = frame
        frame:SetSize(350, 235)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        frame:SetClampedToScreen(true)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        frame:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
        frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 16, -16)
        title:SetText(labels.title)
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT")
        close:SetScript("OnClick", function() frame:Hide() end)
        for index, key in ipairs({"enabled", "taxi", "crown"}) do
            local check = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
            check:SetPoint("TOPLEFT", 14, -42 - (index - 1) * 32)
            check:SetChecked(Guild.debug[key])
            local label = check.text or check.Text or check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            label:ClearAllPoints()
            label:SetPoint("LEFT", check, "RIGHT", 2, 0)
            label:SetText(labels[key])
            check:SetScript("OnClick", function(button)
                Guild.debug[key] = button:GetChecked() == true
                Guild.UpdateDebugMember()
                Guild.dirty = true
                Guild.UpdatePins()
            end)
        end
        local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", 28, -175)
        slider:SetSize(290, 18)
        slider:SetMinMaxValues(-100, 100)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)
        slider.Low = slider.Low or slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slider.High = slider.High or slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slider.Text = slider.Text or slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
        slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
        slider.Text:SetPoint("BOTTOM", slider, "TOP", 0, 3)
        slider.Low:SetText("-100")
        slider.High:SetText("100")
        slider:SetValue(Guild.debug.y)
        slider.Text:SetText(labels.y .. ": " .. Guild.debug.y)
        slider:SetScript("OnValueChanged", function(control, value)
            Guild.debug.y = math.floor(value + 0.5)
            control.Text:SetText(labels.y .. ": " .. Guild.debug.y)
            Guild.dirty = true
            Guild.UpdatePins()
        end)
    end

    function Guild.GetZoneSpace(mapID)
        if mapID == nil or not Guild.GetConfig("GUILDMEMBERZONES", true) then return nil end
        for _, hooks in pairs(_G[GUILDMAP_HOOKS]) do
            if hooks.getZoneSpace ~= nil then
                local space = hooks.getZoneSpace(mapID)
                if space ~= nil then return space end
            end
        end
    end

    function Guild.GetZonePoints(mapID, space)
        if Guild.zoneMapID == mapID and Guild.zoneSpaceID == space then return Guild.zonePoints end
        Guild.zoneMapID, Guild.zoneSpaceID = mapID, space
        local points = {}
        Guild.zonePoints = points
        local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone
        if zoneType == nil or C_Map.GetMapChildrenInfo == nil then return points end
        local info = C_Map.GetMapInfo(mapID)
        local currentZone = info and info.mapType == zoneType and info.name
        if currentZone then points[currentZone] = {x = 0.5, y = 0.5} end
        local hostRect = space ~= nil and space ~= mapID and Guild.GetRect(mapID, space)
        local sourceMap = hostRect and space or mapID
        for _, zone in ipairs(C_Map.GetMapChildrenInfo(sourceMap, zoneType, true) or {}) do
            if zone.name ~= currentZone then
                local x, y = Guild.Project(zone.mapID, sourceMap, 0.5, 0.5)
                if x and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                    if hostRect then
                        x = (x - hostRect[1]) / (hostRect[2] - hostRect[1])
                        y = (y - hostRect[3]) / (hostRect[4] - hostRect[3])
                    end
                    if points[zone.name] == nil then
                        points[zone.name] = {x = x, y = y}
                    else
                        points[zone.name] = false
                    end
                end
            end
        end

        return points
    end

    function Guild.DrawZonePie(pin, members, size, inset, fontSize)
        local classes, counts = {}, {}
        for _, member in ipairs(members) do
            local class = member.class or ""
            if counts[class] == nil then
                classes[#classes + 1] = class
                counts[class] = 0
            end
            counts[class] = counts[class] + 1
        end
        table.sort(classes)

        if pin.pie == nil then
            pin.pie = CreateFrame("Frame", nil, pin)
            pin.pie:SetAllPoints()
            pin.pie:SetFrameLevel(pin:GetFrameLevel() + 1)
            pin.pie.count = pin.pie:CreateFontString(nil, "OVERLAY")
            pin.pie.count:SetPoint("CENTER")
            pin.pie.runs = {}
        end

        local pie = pin.pie
        pie:SetFrameLevel(pin:GetFrameLevel() + 1)
        pie:Show()
        Guild.SetLabel(pie.count, #members > 1 and #members or nil, fontSize, Guild.textColor)
        local signature = {}
        local sectors, total = {}, 0
        for _, class in ipairs(classes) do
            total = total + counts[class]
            sectors[#sectors + 1] = total / #members
            signature[#signature + 1] = class .. counts[class]
        end
        local key = table.concat(signature, ":")
        if pie.key == key and pie.size == size and pie.inset == inset then return end
        pie.key, pie.size, pie.inset = key, size, inset

        local resolution = 24
        local pixel = size / resolution
        local radius = resolution / 2 - inset / pixel
        local used = 0
        for row = 0, resolution - 1 do
            local y = row + 0.5 - resolution / 2
            local start, previous
            for column = 0, resolution do
                local x = column + 0.5 - resolution / 2
                local sector
                if x * x + y * y < radius ^ 2 then
                    local angle = (math.atan2(x, -y) / (2 * math.pi)) % 1
                    sector = 1
                    while angle >= sectors[sector] do sector = sector + 1 end
                end
                if sector ~= previous then
                    if previous ~= nil then
                        used = used + 1
                        local run = pie.runs[used]
                        if run == nil then
                            run = pie:CreateTexture(nil, "ARTWORK")
                            pie.runs[used] = run
                        end
                        local color = RAID_CLASS_COLORS[classes[previous]] or Guild.fallbackColor
                        run:SetColorTexture(color.r, color.g, color.b)
                        run:SetPoint("TOPLEFT", pie, "TOPLEFT", start * pixel, -row * pixel)
                        run:SetSize((column - start) * pixel, pixel)
                        run:Show()
                    end
                    start, previous = column, sector
                end
            end
        end
        for index = used + 1, #pie.runs do pie.runs[index]:Hide() end
    end

    function Guild.SetGroupPin(pin, members, zone, size, scale)
        table.sort(members, function(a, b) return a.name < b.name end)
        pin.member, pin.zone, pin.zoneMembers = nil, zone, members
        pin.dot:Hide()
        pin.level:Hide()
        pin.name:Hide()
        pin.crown:Hide()
        Guild.DrawZonePie(pin, members, size, Guild.border / scale, Guild.levelFontSize / scale)
    end

    function Guild.MergeOverlappingPins(canvas, count, size, scale)
        local points = {}
        for index = 1, count do
            local pin = Guild.pins[index]
            if not (pin.member and pin.member.debug) then
                local _, _, _, x, y = pin:GetPoint(1)
                local point = {pin = pin, x = x, y = y, index = index}
                point.root = point
                points[#points + 1] = point
            end
        end
        table.sort(points, function(a, b)
            if a.x == b.x then return a.index < b.index end

            return a.x < b.x
        end)

        local function GetRoot(point)
            while point.root ~= point do
                point.root = point.root.root
                point = point.root
            end

            return point
        end

        local diameterSquared = size * size
        for index, point in ipairs(points) do
            for otherIndex = index + 1, #points do
                local other = points[otherIndex]
                local dx = other.x - point.x
                if dx >= size then break end
                local dy = other.y - point.y
                if dx * dx + dy * dy < diameterSquared then GetRoot(other).root = GetRoot(point) end
            end
        end

        local groups = {}
        for _, point in ipairs(points) do
            local root = GetRoot(point)
            local group = groups[root]
            if group == nil then
                group = {}
                groups[root] = group
            end
            group[#group + 1] = point
        end

        for _, group in pairs(groups) do
            if #group > 1 then
                local members = {}
                local x, y = 0, 0
                local pin = group[1].pin
                for _, point in ipairs(group) do
                    local other = point.pin
                    if other.zoneMembers then
                        for _, member in ipairs(other.zoneMembers) do
                            members[#members + 1] = member
                        end
                    else
                        members[#members + 1] = other.member
                    end
                    x, y = x + point.x, y + point.y
                    if other ~= pin then other:Hide() end
                end
                Guild.SetGroupPin(pin, members, nil, size, scale)
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", canvas, "TOPLEFT", x / #group, y / #group)
            end
        end
    end

    function Guild.UpdateZonePins(canvas, mapID, count, scale, width, height, level, size)
        if not Guild.GetConfig("GUILDMEMBERZONES", true) then return count end
        local now = GetTime()
        local groups = {}
        for name, member in pairs(Guild.rosterZones) do
            local tracked = Guild.members[name]
            if (tracked == nil or tracked.expire <= now) and not Guild.IsGrouped(name) then
                local group = groups[member.zone]
                if group == nil then
                    group = {}
                    groups[member.zone] = group
                end
                group[#group + 1] = member
            end
        end
        if next(groups) == nil then return count end

        local points = Guild.GetZonePoints(mapID, Guild.GetZoneSpace(mapID))
        for zone, members in pairs(groups) do
            local point = points[zone]
            if point then
                count = count + 1
                local pin = Guild.pins[count]
                if pin == nil then
                    pin = Guild.CreatePin(canvas)
                    Guild.pins[count] = pin
                end
                if pin:GetFrameLevel() ~= level then pin:SetFrameLevel(level) end
                pin:SetSize(size, size)
                Guild.SetGroupPin(pin, members, zone, size, scale)
                Guild.SetPinScale(pin, scale)
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", canvas, "TOPLEFT", width * point.x, -height * point.y)
                pin:Show()
            end
        end

        return count
    end

    function Guild.HidePins()
        Guild.SetDebugArrowHidden(false)
        for _, pin in ipairs(Guild.pins) do
            pin:Hide()
        end
    end

    function Guild.UpdatePins()
        local canvas = WorldMapFrame:GetCanvas()
        local mapID = WorldMapFrame:GetMapID()
        if canvas == nil or mapID == nil or not Guild.IsShown() or Guild.IsHiddenOn(mapID) then
            Guild.HidePins()

            return
        end

        local scale = canvas:GetScale()
        local width, height = canvas:GetWidth(), canvas:GetHeight()
        if scale == nil or scale <= 0 or width <= 0 or height <= 0 then
            Guild.HidePins()

            return
        end

        local showLevel = Guild.GetConfig("GUILDMEMBERLEVEL", false)
        local showName = Guild.GetConfig("GUILDMEMBERNAME", false)
        local size, inset = (showLevel and Guild.levelDotSize or Guild.dotSize) / scale, Guild.border / scale
        local levelSize, nameSize = Guild.levelFontSize / scale, Guild.nameFontSize / scale
        local crownSize, crownOverlap = Guild.crownSize / scale, Guild.crownOverlap / scale
        local level = Guild.GetPinLevel(canvas)
        local low, high = Guild.GetClip(mapID)
        local count = 0
        local debugVisible = false
        local now = GetTime()
        for name, member in pairs(Guild.members) do
            if member.debug or (member.expire > now and not Guild.IsGrouped(name)) then
                local x, y = Guild.Project(member.mapID, mapID, member.x, member.y)
                if x ~= nil and x >= low and x <= high and y >= low and y <= high then
                    count = count + 1
                    local pin = Guild.pins[count]
                    if pin == nil then
                        pin = Guild.CreatePin(canvas)
                        Guild.pins[count] = pin
                    end

                    pin.member, pin.zone, pin.zoneMembers = member, nil, nil
                    pin.dot:Show()
                    if pin.pie ~= nil then pin.pie:Hide() end
                    if pin:GetFrameLevel() ~= level then pin:SetFrameLevel(level) end
                    pin:SetSize(size, size)
                    pin.dot:ClearAllPoints()
                    pin.dot:SetPoint("TOPLEFT", inset, -inset)
                    pin.dot:SetPoint("BOTTOMRIGHT", -inset, inset)
                    local color = RAID_CLASS_COLORS[member.class or ""] or Guild.fallbackColor
                    local taxiIcon = member.taxi and (member.faction == "Horde" and 132268 or member.faction == "Alliance" and 132239)
                    pin.dot:SetTexture(taxiIcon or Guild.mask)
                    if taxiIcon then
                        pin.dot:SetVertexColor(1, 1, 1, 1)
                    else
                        pin.dot:SetVertexColor(color.r, color.g, color.b, 1)
                    end
                    pin.level:ClearAllPoints()
                    pin.level:SetPoint("CENTER", (member.level or 0) < 10 and Guild.levelOffsetX / scale or 0, 0)
                    Guild.SetLabel(pin.level, showLevel and not taxiIcon and member.level or nil, levelSize, Guild.textColor)
                    Guild.SetLabel(pin.name, showName and member.name or nil, nameSize, color)
                    pin.name:ClearAllPoints()
                    if (member.debug and Guild.debug.crown) or (not member.debug and Guild.IsLeader(name)) then
                        pin.crown:SetSize(crownSize, crownSize)
                        pin.crown:ClearAllPoints()
                        pin.crown:SetPoint("BOTTOM", pin, "TOP", 0, -crownOverlap)
                        pin.crown:Show()
                        pin.name:SetPoint("BOTTOM", pin.crown, "TOP", 0, -Guild.nameCrownOverlap / scale)
                    else
                        pin.crown:Hide()
                        pin.name:SetPoint("BOTTOM", pin, "TOP")
                    end

                    Guild.SetPinScale(pin, scale)
                    pin:ClearAllPoints()
                    pin:SetPoint("CENTER", canvas, "TOPLEFT", width * x, -height * y + (member.debug and Guild.debug.y / scale or 0))
                    if member.debug then debugVisible = true end
                    pin:Show()
                end
            end
        end

        count = Guild.UpdateZonePins(canvas, mapID, count, scale, width, height, level, size)
        Guild.MergeOverlappingPins(canvas, count, size, scale)
        Guild.SetDebugArrowHidden(debugVisible)
        for index = count + 1, #Guild.pins do
            Guild.pins[index]:Hide()
        end
    end

    function Guild.OnUpdate(_, elapsed)
        if not Guild.IsActive() then return end
        Guild.elapsed = Guild.elapsed + elapsed
        if Guild.elapsed < Guild.checkInterval then return end
        Guild.sincePrune = Guild.sincePrune + Guild.elapsed
        Guild.elapsed = 0
        if Guild.sincePrune >= Guild.pruneInterval then
            Guild.sincePrune = 0
            Guild.Prune()
            if Guild.GetConfig("GUILDMEMBERZONES", true) and IsInGuild() then Guild.RequestRoster() end
        end

        local canvas = WorldMapFrame:GetCanvas()
        local mapID = WorldMapFrame:GetMapID()
        local scale = canvas and canvas:GetScale()
        local width = canvas and canvas:GetWidth()
        local zoneSpace = Guild.GetZoneSpace(mapID)
        Guild.UpdateDebugMember()
        if not Guild.debug.enabled and not Guild.dirty and mapID == Guild.lastMapID and scale == Guild.lastScale and width == Guild.lastWidth and zoneSpace == Guild.lastZoneSpace then return end
        Guild.dirty = false
        Guild.lastMapID, Guild.lastScale, Guild.lastWidth, Guild.lastZoneSpace = mapID, scale, width, zoneSpace
        Guild.UpdatePins()
    end

    function Guild.Refresh()
        Guild.dirty = true
        Guild.RefreshTicker()
        if not Guild.IsShown() then Guild.HidePins() end
    end

    function Guild.OnEvent(_, event, ...)
        if not Guild.IsActive() then
            Guild.RefreshTicker()

            return
        end

        if event == "CHAT_MSG_ADDON" then
            local prefix, message, chatType, sender = ...
            if Guild.IsSecret(prefix) then return end
            local parser = Guild.parsers[prefix]
            if parser == nil or Guild.IsSecret(message, chatType, sender) or chatType ~= "GUILD" then return end
            if type(message) ~= "string" or type(sender) ~= "string" or message == "" or #message > 255 or Guild.IsSelfSender(sender) then return end
            pcall(parser, message, sender)

            return
        end

        if event == "GROUP_ROSTER_UPDATE" then
            Guild.dirty = true

            return
        end

        if event == "GUILD_ROSTER_UPDATE" then
            Guild.UpdateRoster()

            return
        end

        if event == "PLAYER_GUILD_UPDATE" then
            wipe(Guild.rosterZones)
            wipe(Guild.rosterLevels)
            wipe(Guild.ranks)
            wipe(Guild.members)
            Guild.lastRoster = nil
            Guild.dirty = true
            if IsInGuild() then Guild.RequestRoster() end
        end
        Guild.RefreshTicker()
    end

    if C_ChatInfo ~= nil and C_ChatInfo.RegisterAddonMessagePrefix ~= nil then
        for prefix in pairs(Guild.parsers) do
            C_ChatInfo.RegisterAddonMessagePrefix(prefix)
        end
    end

    Guild.frame = CreateFrame("Frame")
    Guild.frame:RegisterEvent("PLAYER_LOGIN")
    Guild.frame:RegisterEvent("PLAYER_GUILD_UPDATE")
    Guild.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    Guild.frame:RegisterEvent("GUILD_ROSTER_UPDATE")
    Guild.frame:RegisterEvent("CHAT_MSG_ADDON")
    Guild.frame:SetScript("OnEvent", Guild.OnEvent)
    Guild.updater = CreateFrame("Frame", nil, WorldMapFrame)
    Guild.updater:SetScript("OnUpdate", Guild.OnUpdate)
    WorldMapFrame:HookScript("OnShow", function()
        if not Guild.IsActive() then return end
        Guild.dirty = true
        Guild.elapsed = Guild.checkInterval
        Guild.sincePrune = Guild.pruneInterval
        if IsInGuild() then Guild.RequestRoster() end
    end)

    WorldMapFrame:HookScript("OnHide", Guild.HidePins)

    _G.D4GuildMapDebugOwners = _G.D4GuildMapDebugOwners or {}
    _G.D4GuildMapDebugOwners[owner] = Guild
    SLASH_D4GUILDMAP1 = "/d4guildmap"
    SlashCmdList.D4GUILDMAP = function(message)
        if strtrim(message):lower() ~= "debug" then return end
        local active = _G.D4GuildMapDebugOwners[D4:GetGuildMapOwner()]
        if active ~= nil then active.ToggleDebugMenu() end
    end

    _G[GUILDMAP_MAPS][owner] = Guild
    D4:AttachGuildMapHooks()

    return Guild
end
