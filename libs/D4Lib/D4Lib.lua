local _, _ = ...
D4 = D4 or {}
--[[ Basics ]]
local BuildNr = select(4, GetBuildInfo())
local Build = "CLASSIC"
if BuildNr >= 100000 then
    Build = "RETAIL"
elseif BuildNr > 29999 then
    Build = "WRATH"
elseif BuildNr > 19999 then
    Build = "TBC"
end

function D4:GetWoWBuildNr()
    return BuildNr
end

function D4:GetWoWBuild()
    return Build
end

D4.oldWow = D4.oldWow or false
if C_Timer == nil then
    print("[D4] ADD C_Timer")
    C_Timer = {}
    local f = CreateFrame("Frame")
    f.tab = {}
    f:HookScript(
        "OnUpdate",
        function()
            for i, v in pairs(f.tab) do
                if v[1] < GetTime() then
                    local func = v[2]
                    func()
                    tremove(f.tab, i)
                end
            end
        end
    )

    C_Timer.After = function(duration, callback)
        tinsert(f.tab, {GetTime() + duration, callback})
    end

    D4.oldWow = true
end

if GetClassColor == nil then
    print("[D4] ADD GetClassColor")
    GetClassColor = function(classFilename)
        local color = RAID_CLASS_COLORS[classFilename]
        if color then return color.r, color.g, color.b, color.colorStr end

        return 1, 1, 1, "ffffffff"
    end

    D4.oldWow = true
end

function D4:IsOldWow()
    return D4.oldWow
end

--[[ QOL ]]
local ICON_TAG_LIST_EN = {
    ["star"] = 1,
    ["yellow"] = 1,
    ["cirlce"] = 2,
    ["orange"] = 2,
    ["diamond"] = 3,
    ["triangle"] = 4,
    ["moon"] = 5,
    ["square"] = 6,
    ["blue"] = 6,
    ["cross"] = 7,
    ["red"] = 7,
    ["skull"] = 8,
}

local function FixIconChat(self, event, message, author, ...)
    if ICON_LIST then
        for tag in string.gmatch(message, "%b{}") do
            local term = strlower(string.gsub(tag, "[{}]", ""))
            if ICON_TAG_LIST_EN[term] and ICON_LIST[ICON_TAG_LIST_EN[term]] then
                message = string.gsub(message, tag, ICON_LIST[ICON_TAG_LIST_EN[term]] .. "0|t")
            end
        end
    end

    return false, message, author, ...
end

local chatChannels = {}
for i, v in pairs(_G) do
    if string.find(i, "CHAT_MSG_", 1, true) and not tContains(chatChannels, i) then
        tinsert(chatChannels, i)
    end
end

for i, v in pairs(chatChannels) do
    ChatFrame_AddMessageEventFilter(i, FixIconChat)
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FixIconChat)
C_Timer.After(
    4,
    function()
        if D4.LoadTargetHealth == nil then
            function D4:LoadTargetHealth()
                if D4:GetWoWBuild() ~= "RETAIL" and ShouldKnowUnitHealth and ShouldKnowUnitHealth("target") == false then
                    function ShouldKnowUnitHealth(unit)
                        return true
                    end
                end
            end

            D4:LoadTargetHealth()
        end
    end
)