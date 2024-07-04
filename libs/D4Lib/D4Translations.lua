local _, D4 = ...
function D4:Trans(key, lang, t1, t2, t3)
    D4.trans = D4.trans or {}
    if lang == nil then
        lang = GetLocale()
    end

    D4.trans[lang] = D4.trans[lang] or {}
    local result = nil
    if D4.trans[lang][key] ~= nil then
        result = D4.trans[lang][key]
    elseif D4.trans["enUS"] and D4.trans["enUS"][key] ~= nil then
        result = D4.trans["enUS"][key]
    else
        return key
    end

    if t1 and t2 and t3 then
        result = string.format(result, t1, t2, t3)
    end

    if t1 and t2 then
        result = string.format(result, t1, t2)
    end

    if t1 then
        result = string.format(result, t1)
    end

    return result or key
end

function D4:AddTrans(lang, key, value)
    D4.trans = D4.trans or {}
    if lang == nil then
        D4:MSG("[D4:AddTrans] lang is nil")

        return false
    end

    if key == nil then
        D4:MSG("[D4][AddTrans] key is nil")

        return false
    end

    if value == nil then
        D4:MSG("[D4][AddTrans] value is nil")

        return false
    end

    D4.trans[lang] = D4.trans[lang] or {}
    D4.trans[lang][key] = value
end
