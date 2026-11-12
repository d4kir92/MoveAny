local _, D4 = ...
local GUILDINVITE_OWNERS = "D4GuildInviteOwners"
local GUILDINVITE_INSTANCES = "D4GuildInviteInstances"
local GUILDINVITE_EVENTS = {"CHAT_MSG_WHISPER", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_CHANNEL", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER"}
function D4:GetGuildInviteOwner()
    local owners = _G[GUILDINVITE_OWNERS]
    if owners == nil then return nil end
    local best, bestPriority
    for name, priority in pairs(owners) do
        if best == nil or priority > bestPriority or (priority == bestPriority and name < best) then best, bestPriority = name, priority end
    end

    return best
end

function D4:GetGuildInviteInstance()
    local instances = _G[GUILDINVITE_INSTANCES]

    return instances and instances[D4:GetGuildInviteOwner()]
end

function D4:InviteToGuild(name)
    if type(name) ~= "string" or name == "" then return end
    if C_GuildInfo and C_GuildInfo.Invite then
        C_GuildInfo.Invite(name)
    elseif GuildInvite then
        GuildInvite(name)
    end
end

function D4:HandleGuildInviteLink(link, button)
    if type(link) ~= "string" or not D4:CanAccessValue(link) or link:sub(1, 5) ~= "ginv:" then return false end
    local instance = D4:GetGuildInviteInstance()
    if instance == nil then return false end
    local name = link:sub(6)
    if button == "MiddleButton" then
        if CommunitiesFrame then CommunitiesFrame:Show() end
    else
        D4:InviteToGuild(name)
    end

    return true
end

function D4:HookGuildInviteLinks()
    if _G.D4GuildInviteLinksHooked then return end
    _G.D4GuildInviteLinksHooked = true
    if D4:GetWoWBuild() ~= "RETAIL" and ItemRefTooltip and ItemRefTooltip.SetHyperlink then
        local original = ItemRefTooltip.SetHyperlink
        ItemRefTooltip.SetHyperlink = function(tooltip, link, ...)
            if D4:HandleGuildInviteLink(link, select(2, ...)) then return end

            return original(tooltip, link, ...)
        end
    else
        hooksecurefunc("SetItemRef", function(link, _, button) D4:HandleGuildInviteLink(link, button) end)
    end
end

function D4:CreateGuildInvite(options)
    options = options or {}
    local owner = options.owner or "D4"
    _G[GUILDINVITE_OWNERS] = _G[GUILDINVITE_OWNERS] or {}
    _G[GUILDINVITE_OWNERS][owner] = options.priority or 0
    _G[GUILDINVITE_INSTANCES] = _G[GUILDINVITE_INSTANCES] or {}
    local Invite = {
        owner = owner
    }

    _G[GUILDINVITE_INSTANCES][owner] = Invite
    function Invite:IsActive()
        return D4:GetGuildInviteOwner() == self.owner
    end

    function Invite:Get(key)
        return options.get and options.get(key)
    end

    function Invite:Trans(key)
        return options.trans and options.trans(key) or key
    end

    function Invite:Linkify(msg, name)
        local function replace(text)
            return (text:gsub("%f[%a]([gG][iI][nN][vV])%f[%A]", function(word) return "|cffffff00|Hginv:" .. name .. "|h[" .. word .. "]|h|r" end))
        end

        local parts = {}
        local position = 1
        for first, link, last in msg:gmatch("()(|H.-|h.-|h)()") do
            parts[#parts + 1] = replace(msg:sub(position, first - 1))
            parts[#parts + 1] = link
            position = last
        end

        parts[#parts + 1] = replace(msg:sub(position))

        return table.concat(parts)
    end

    function Invite:Filter(msg, name, ...)
        if not self:IsActive() or not self:Get("LINKS") then return false end
        if not D4:CanAccessValues(msg, name) or type(msg) ~= "string" or type(name) ~= "string" or name == "" then return false end
        if not msg:find("[gG][iI][nN][vV]") then return false end

        return false, self:Linkify(msg, name), name, ...
    end

    function Invite:IsOwnMessage(name, guid)
        if type(guid) == "string" and guid ~= "" and UnitGUID then return guid == UnitGUID("player") end
        local key, ownName = D4:GetPlayerCharacterKey()
        if key and (name == key or name == ownName) then return true end
        local short = strsplit("-", name)
        if key and not D4:IsForever() then return short == ownName end

        local legacyName = UnitName("player")
        return D4:CanAccessValue(legacyName) and short == legacyName
    end

    function Invite:IsRequest(msg)
        local word = self:Get("WORD")
        if type(word) ~= "string" then return false end
        word = strlower(strtrim(word))
        if word == "" then return false end
        local command, rest = strlower(strtrim(msg)):match("^(%S+)%s+(.+)$")

        return command == "ginv" and rest == word
    end

    function Invite:ShowPopup(name)
        StaticPopupDialogs.D4_GUILDINVITE = StaticPopupDialogs.D4_GUILDINVITE or {
            button1 = INVITE or "Invite",
            button2 = DECLINE or "Decline",
            OnAccept = function(_, data) D4:InviteToGuild(data) end,
            timeout = 120,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }

        StaticPopupDialogs.D4_GUILDINVITE.text = self:Trans("LID_GUILDINVITEPOPUP")
        StaticPopup_Show("D4_GUILDINVITE", name, nil, name)
    end

    function Invite:OnChat(msg, name, guid)
        if not self:IsActive() or not self:Get("KEYWORD") then return end
        if not D4:CanAccessValues(msg, name, guid) or type(msg) ~= "string" or type(name) ~= "string" or name == "" then return end
        if self:IsOwnMessage(name, guid) or not self:IsRequest(msg) then return end
        if not IsInGuild() or (CanGuildInvite and not CanGuildInvite()) then return end
        self:ShowPopup(name)
    end

    local function filter(_, _, msg, name, ...)
        return Invite:Filter(msg, name, ...)
    end

    for _, event in ipairs(GUILDINVITE_EVENTS) do
        if ChatFrame_AddMessageEventFilter then
            ChatFrame_AddMessageEventFilter(event, filter)
        elseif ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter then
            ChatFrameUtil.AddMessageEventFilter(event, filter)
        end
    end

    local frame = CreateFrame("Frame")
    for _, event in ipairs(GUILDINVITE_EVENTS) do
        if not options.whisperOnly or event == "CHAT_MSG_WHISPER" then frame:RegisterEvent(event) end
    end

    frame:SetScript("OnEvent", function(_, _, msg, name, _, _, _, _, _, _, _, _, _, guid) Invite:OnChat(msg, name, guid) end)
    D4:HookGuildInviteLinks()

    return Invite
end
