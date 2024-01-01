function D4:Trans(key, value, lang)
    D4.trans = D4.trans or {}
    if lang == nil then
        lang = GetLocale()
    end

    D4.trans[lang] = D4.trans[lang] or {}
    if D4.trans[lang][key] ~= nil then return D4.trans[lang][key] end
    if value ~= nil then return value end

    return key
end

function D4:AddTrans(lang, key, value)
    D4.trans = D4.trans or {}
    if lang == nil then
        D4:msg("[D4:AddTrans] lang is nil")

        return false
    end

    if key == nil then
        D4:msg("[D4:AddTrans] key is nil")

        return false
    end

    if value == nil then
        D4:msg("[D4:AddTrans] value is nil")

        return false
    end

    D4.trans[lang] = D4.trans[lang] or {}
    D4.trans[lang][key] = value
end