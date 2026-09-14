local _, D4 = ...
local initRealms = false
local initRealmLangs = false
local missingRealmNameOnce = true
local missingRealms = {}
local realms = {}
local realmsSupported = false
local missingRealmLangs = {}
local region = GetCurrentRegion and GetCurrentRegion() or 1
local withoutSpaces = {}
local realmLangs = {}
local missingRegionOnce = true
local missingWoWBuildOnce = true
local realmData = {}
local regions = {
    ["US"] = 1,
    ["KR"] = 2,
    ["EU"] = 3,
    ["TW"] = 4,
}

local function IsUkrainianLetters(str)
    return str:match("[\192-\199]") ~= nil
end

local function IsRussianLetters(str)
    return str:match("[\192-\255]") ~= nil
end

local function IsChineseLetters(str)
    return str:match("[\228-\233]") ~= nil
end

local function IsKoreanLetters(str)
    return str:match("[\234-\237]") ~= nil
end

function D4:AddRealmData(func)
    table.insert(realmData, func)
end

function D4:MissingRealmRegion(reg)
    if reg == 5 then return end
    if missingRegionOnce == false then return end
    missingRegionOnce = false
    if reg == 72 then return end
    D4:MSG("[D4] Missing REGION", reg)
end

local function InitRealms()
    if #realmData == 0 and missingWoWBuildOnce then
        missingWoWBuildOnce = false
        D4:MSG("[D4] Missing WoW-Build", D4:GetWoWBuildNr())
    end

    for i = 1, #realmData do
        realmData[i](realms, region, regions)
    end

    for name, val in pairs(realms) do
        if string.find(name, "-", 1, true) ~= nil then
            withoutSpaces[name:gsub("-", "")] = val
        end

        if string.find(name, " ", 1, true) ~= nil then
            withoutSpaces[name:gsub(" ", "")] = val
        end
    end

    for name, val in pairs(withoutSpaces) do
        realms[name] = val
    end

    realmsSupported = next(realms) ~= nil
end

function D4:GetRealmLang(realmName)
    if D4:IsSecret(realmName) then return "" end
    if initRealms == false then
        initRealms = true
        InitRealms()
    end

    if realmsSupported == false then return "" end
    if realmName == nil then
        if missingRealmNameOnce then
            missingRealmNameOnce = false
            D4:MSG("[D4] Realmname is nil!")
        end

        return ""
    end

    if realmName == "" then
        realmName = GetRealmName()
    end

    if realms[realmName] == nil then
        if IsUkrainianLetters(realmName) then
            return "ukUA"
        elseif IsRussianLetters(realmName) then
            return "ruRU"
        elseif IsChineseLetters(realmName) then
            return "zhCN"
        elseif IsKoreanLetters(realmName) then
            return "koKR"
        else
            if missingRealms[realmName] == nil then
                missingRealms[realmName] = true
                D4:MSG("[D4][GetRealmLang] Missing Realm-Language", realmName)
            end

            return ""
        end
    end

    return realms[realmName]
end

local function AddRealmLangs(lang, names)
    for i = 1, #names do
        realmLangs[names[i]] = lang
    end
end

local function InitRealmLangs()
    AddRealmLangs("deDE", {"Deutsch", "German", "Allemand", "Alemán", "Alemão", "Tedesco", "Нем.", "독일어", "德國", "德语",})
    AddRealmLangs(
        "esES",
        {
            "Spanish",
            "Spanisch",
            "Español",
            "Espagnol",
            "Espanhol",
            "Spagnolo",
            "Исп.",
            "스페인어",
            "西班牙",
            "西班牙语",
            "Latin America",
            "Lateinamerika",
            "América Latina",
            "America Latina",
            "Amérique latine",
            "Латинская Америка",
            "拉丁美洲",
            "라틴 아메리카",
        }
    )

    AddRealmLangs("frFR", {"French", "Französisch", "Français", "Francés", "Francês", "Francese", "Франц.", "프랑스어", "法國", "法语",})
    AddRealmLangs("itIT", {"Italian", "Italienisch", "Italiano", "Italien", "Итальянск.", "이탈리아어", "義大利", "意大利语",})
    AddRealmLangs("koKR", {"Korea", "Corea", "Coreia", "Corée", "Корея", "한국", "韓國", "韩国",})
    AddRealmLangs("ptBR", {"Brazil", "Brasilien", "Brasil", "Brasile", "Brésil", "Бразилия", "브라질", "巴西",})
    AddRealmLangs("ruRU", {"Russian", "Russisch", "Russe", "Ruso", "Russo", "Русский", "러시아어", "俄羅斯", "俄语",})
    AddRealmLangs("chTW", {"Taiwan", "Taiwán", "Taïwan", "Тайвань", "대만", "台灣", "中国台湾",})
    AddRealmLangs("enGB", {"Oceanic", "Oceania", "Oceánico", "Océanique", "Ozeanisch", "Океания", "오세아니아", "大洋洲", "英國",})
    local enLang = "enUS"
    if region == regions["EU"] then
        enLang = "enGB"
    end

    AddRealmLangs(
        enLang,
        {
            "English",
            "Englisch",
            "Anglais",
            "Inglés",
            "Inglês",
            "Inglese",
            "Англ.",
            "영어",
            "英语",
            "United States",
            "Vereinigte Staaten",
            "Estados Unidos",
            "États-Unis",
            "Stati Uniti",
            "США",
            "미국",
            "美国",
            "美國",
            "US East",
            "USA Ost",
            "미국 동부",
            "美東",
            "US West",
            "USA West",
            "미국 서부",
            "美西",
            "Global",
            "Globale",
            "Mondial",
            "Глобальный",
            "글로벌",
            "全球",
            "Seasonal",
            "Saisonbedingt",
            "Saisonnier",
            "Sazonal",
            "De temporada",
            "Stagionale",
            "Сезонные",
            "시즌",
            "赛季",
            "賽季",
            "Classic Era",
            "Classic-Ära",
            "Klassisch",
            "Era Classic",
            "Ère classique",
            "Clásicos",
            "Классические",
            "클래식 시대",
            "經典時期",
            "旧世经典服务器（60级）",
            "Hardcore",
            "Extrême",
            "Серьезный",
            "하드코어",
            "专家模式",
            "專家模式",
            "Anniversary",
            "Anniversaire",
            "Aniversario",
            "Aniversário",
            "Jubiläum",
            "Годовщина",
            "기념일",
            "周年纪念版",
            "週年慶",
            "Legacy",
            "Legado",
            "Héritage",
            "낭만",
            "旧版",
            "懷舊",
            "Active",
            "Aktiv",
            "Actif",
            "Activos",
            "Ativo",
            "Активные",
            "활성화",
            "激活",
            "現行",
        }
    )

    AddRealmLangs("koKR", {"koKR",})
    AddRealmLangs("ruRU", {"ruRU",})
    AddRealmLangs("ukUA", {"ukUA",})
    AddRealmLangs("zhCN", {"zhCN",})
end

function D4:GetRealmFlag(realmName)
    if D4:IsSecret(realmName) then return "" end
    if initRealmLangs == false then
        initRealmLangs = true
        InitRealmLangs()
    end

    if realmName == "" then
        realmName = GetRealmName()
    end

    local realmLang = D4:GetRealmLang(realmName)
    if realmLang == nil or realmLang == "" then return "" end
    if realmLangs[realmLang] == nil then
        if missingRealmLangs[realmLang] == nil then
            missingRealmLangs[realmLang] = true
            D4:MSG("[D4] Missing realmsLangs", realmName, realmLang)
        end

        return ""
    end

    return realmLangs[realmLang]
end

function D4:LoadRealms()
    InitRealms()
    InitRealmLangs()
end
