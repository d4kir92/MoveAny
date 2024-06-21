local _, D4 = ...
function D4:GV(db, key, value)
    if db == nil then
        D4:MSG("[D4:GV] db is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return value
    end

    if type(db) ~= "table" then
        D4:MSG("[D4:GV] db is not table", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return value
    end

    if db[key] ~= nil then return db[key] end

    return value
end

function D4:SV(db, key, value)
    if db == nil then
        D4:MSG("[D4:SV] db is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return false
    end

    if key == nil then
        D4:MSG("[D4:SV] key is nil", "db", tostring(db), "key", tostring(key), "value", tostring(value))

        return false
    end

    db[key] = value
end
