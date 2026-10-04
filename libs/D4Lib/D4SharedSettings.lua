local _, D4 = ...
local STAMPS_KEY = "SHAREDSETTINGS"
local registry = _G["D4SharedSettingsRegistry"]
if type(registry) ~= "table" then
    registry = {
        ["entries"] = {},
    }

    _G["D4SharedSettingsRegistry"] = registry
end

local function IsOn(value)
    return value ~= false
end

local function GetDB(entry)
    local db = entry.getDB()
    if type(db) ~= "table" then return nil end
    return db
end

local function GetStamp(entry, key)
    local db = GetDB(entry)
    local stamps = db ~= nil and db[STAMPS_KEY] or nil
    return type(stamps) == "table" and tonumber(stamps[key]) or 0
end

local function Apply(entry, key, value, stamp, notify)
    local db = GetDB(entry)
    if db == nil then return end
    if type(db[STAMPS_KEY]) ~= "table" then db[STAMPS_KEY] = {} end
    db[STAMPS_KEY][key] = stamp
    if IsOn(entry.get(key)) == value then return end
    entry.set(key, value)
    if notify and entry.onChange ~= nil then entry.onChange(key, value) end
end

local function GetNewest(key)
    local value, stamp = nil, -1
    for _, entry in ipairs(registry.entries) do
        if entry.keys[key] and GetDB(entry) ~= nil then
            local entryStamp = GetStamp(entry, key)
            local entryValue = IsOn(entry.get(key))
            if entryStamp > stamp or entryStamp == stamp and not entryValue then
                value = entryValue
                stamp = entryStamp
            end
        end
    end

    return value, stamp
end

local function Reconcile(key)
    local value, stamp = GetNewest(key)
    if value == nil then return end
    for _, entry in ipairs(registry.entries) do
        if entry.keys[key] then Apply(entry, key, value, stamp, true) end
    end
end

local function ReconcileAll()
    local keys = {}
    for _, entry in ipairs(registry.entries) do
        for key in pairs(entry.keys) do
            keys[key] = true
        end
    end

    for key in pairs(keys) do
        Reconcile(key)
    end
end

if registry.frame == nil then
    registry.frame = CreateFrame("Frame")
    registry.frame:RegisterEvent("PLAYER_LOGIN")
    registry.frame:SetScript("OnEvent", function()
        registry.ready = true
        ReconcileAll()
    end)
end

function D4:RegisterSharedSettings(options)
    local entry = {
        ["owner"] = self,
        ["getDB"] = options.getDB,
        ["get"] = options.get,
        ["set"] = options.set,
        ["onChange"] = options.onChange,
        ["keys"] = {},
    }

    for _, key in ipairs(options.keys or {}) do
        entry.keys[key] = true
    end

    tinsert(registry.entries, entry)
    if registry.ready then
        for key in pairs(entry.keys) do
            Reconcile(key)
        end
    end
end

function D4:SetSharedSetting(key, value)
    value = IsOn(value)
    local _, newest = GetNewest(key)
    local stamp = max(time(), (newest or 0) + 1)
    for _, entry in ipairs(registry.entries) do
        if entry.keys[key] then Apply(entry, key, value, stamp, entry.owner ~= self) end
    end
end
