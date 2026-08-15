local _, D4 = ...
local missingTranslationsEn = {}
local missingTranslations = {}
local missingLang = {}
local langs = {}
langs["enUS"] = true
langs["deDE"] = true
langs["esES"] = true
langs["esMX"] = true
langs["frFR"] = true
langs["itIT"] = true
langs["koKR"] = true
langs["ptBR"] = true
langs["ruRU"] = true
langs["zhCN"] = true
langs["zhTW"] = true
function D4:TryTrans(key, lang, ...)
    if key == nil then return "" end
    if key:find("LID_") then return D4:Trans(key, lang, ...) end
    return key
end

function D4:Trans(key, lang, ...)
    D4.trans = D4.trans or {}
    if lang == nil then lang = GetLocale() end
    if key and strfind(key, "LID_", 1, true) == nil then
        D4:INFO("[D4] PREFIX missing:", key)
        return key
    end

    if langs[lang] == nil then
        missingLang[lang] = true
        local ver = "MISSING"
        if D4.GetVersion then ver = D4:GetVersion() end
        D4:MSG("[GET] LANGUAGE IS MISSING [" .. lang .. "]", ver, "(", ..., ")")
    end

    D4.trans[lang] = D4.trans[lang] or {}
    if key and key ~= "" and key ~= "LID_" and D4.trans["enUS"] and D4.trans["enUS"][key] == nil and key and key ~= "" and missingTranslationsEn[key] == nil then
        missingTranslationsEn[key] = true
        local ver = "MISSING"
        if D4.GetVersion then ver = D4:GetVersion() end
        D4:MSG("TRANSLATION-KEY IS MISSING [" .. key .. "]", ver, "(", lang, ..., ")")
    end

    local result = nil
    if D4.trans[lang][key] ~= nil then
        result = D4.trans[lang][key]
    elseif D4.trans["enUS"] and D4.trans["enUS"][key] ~= nil then
        result = D4.trans["enUS"][key]
    else
        if key and key ~= "" and key ~= "LID_" and missingTranslations[key] == nil then
            missingTranslations[key] = true
            local ver = "MISSING"
            if D4.GetVersion then ver = D4:GetVersion() end
            D4:MSG("TRANSLATION MISSING [" .. key .. "]", ver, "(", lang, ..., ")")
        end
        return key
    end

    if select(1, ...) then result = string.format(result, ...) end
    return result or key
end

function D4:AddTrans(lang, key, value)
    D4.trans = D4.trans or {}
    if lang == nil then
        D4:MSG("[D4:AddTrans] lang is nil")
        return false
    end

    if key and strfind(key, "LID_", 1, true) == nil then
        D4:MSG("[D4:AddTrans] Missing LID_ for " .. key)
        return false
    end

    if langs[lang] == nil then
        missingLang[lang] = true
        local ver = "MISSING"
        if D4.GetVersion then ver = D4:GetVersion() end
        D4:MSG("[ADD] LANGUAGE IS MISSING [" .. lang .. "]", ver, "(", value, ")")
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

-- enUS
D4:AddTrans("enUS", "LID_ALTLEFTCLICK", "Alt + Leftclick")
D4:AddTrans("enUS", "LID_ALTMIDDLECLICK", "Alt + Middleclick")
D4:AddTrans("enUS", "LID_ALTRIGHTCLICK", "Alt + Rightclick")
D4:AddTrans("enUS", "LID_CTRLLEFTCLICK", "Ctrl + Leftclick")
D4:AddTrans("enUS", "LID_CTRLMIDDLECLICK", "Ctrl + Middleclick")
D4:AddTrans("enUS", "LID_CTRLRIGHTCLICK", "Ctrl + Rightclick")
D4:AddTrans("enUS", "LID_DEFAULT", "Default")
D4:AddTrans("enUS", "LID_HIDEMINIMAPBUTTON", "Hide Minimap Button")
D4:AddTrans("enUS", "LID_LEFTCLICK", "Leftclick")
D4:AddTrans("enUS", "LID_MIDDLECLICK", "Middleclick")
D4:AddTrans("enUS", "LID_OPENSETTINGS", "Open Settings")
D4:AddTrans("enUS", "LID_RIGHTCLICK", "Rightclick")
D4:AddTrans("enUS", "LID_SHIFTLEFTCLICK", "Shift + Leftclick")
D4:AddTrans("enUS", "LID_SHIFTMIDDLECLICK", "Shift + Middleclick")
D4:AddTrans("enUS", "LID_SHIFTRIGHTCLICK", "Shift + Rightclick")
-- deDE
D4:AddTrans("deDE", "LID_ALTLEFTCLICK", "Alt + Linksklick")
D4:AddTrans("deDE", "LID_ALTMIDDLECLICK", "Alt + Mittlererklick")
D4:AddTrans("deDE", "LID_ALTRIGHTCLICK", "Alt + Rechtsklick")
D4:AddTrans("deDE", "LID_CTRLLEFTCLICK", "Strg + Linksklick")
D4:AddTrans("deDE", "LID_CTRLMIDDLECLICK", "Strg + Mittlererklick")
D4:AddTrans("deDE", "LID_CTRLRIGHTCLICK", "Strg + Rechtsklick")
D4:AddTrans("deDE", "LID_DEFAULT", "Standard")
D4:AddTrans("deDE", "LID_HIDEMINIMAPBUTTON", "Minimapknopf verstecken")
D4:AddTrans("deDE", "LID_LEFTCLICK", "Linksklick")
D4:AddTrans("deDE", "LID_MIDDLECLICK", "Mittlererklick")
D4:AddTrans("deDE", "LID_OPENSETTINGS", "Einstellungen öffnen")
D4:AddTrans("deDE", "LID_RIGHTCLICK", "Rechtsklick")
D4:AddTrans("deDE", "LID_SHIFTLEFTCLICK", "Shift + Linksklick")
D4:AddTrans("deDE", "LID_SHIFTMIDDLECLICK", "Shift + Mittlererklick")
D4:AddTrans("deDE", "LID_SHIFTRIGHTCLICK", "Shift + Rechtsklick")
-- esES
D4:AddTrans("esES", "LID_ALTLEFTCLICK", "Alt + clic izquierdo")
D4:AddTrans("esES", "LID_ALTMIDDLECLICK", "Alt + clic central")
D4:AddTrans("esES", "LID_ALTRIGHTCLICK", "Alt + clic derecho")
D4:AddTrans("esES", "LID_CTRLLEFTCLICK", "Ctrl + clic izquierdo")
D4:AddTrans("esES", "LID_CTRLMIDDLECLICK", "Ctrl + clic central")
D4:AddTrans("esES", "LID_CTRLRIGHTCLICK", "Ctrl + clic derecho")
D4:AddTrans("esES", "LID_DEFAULT", "Predeterminado")
D4:AddTrans("esES", "LID_HIDEMINIMAPBUTTON", "Ocultar botón del minimapa")
D4:AddTrans("esES", "LID_LEFTCLICK", "Clic izquierdo")
D4:AddTrans("esES", "LID_MIDDLECLICK", "Clic central")
D4:AddTrans("esES", "LID_OPENSETTINGS", "Abrir ajustes")
D4:AddTrans("esES", "LID_RIGHTCLICK", "Clic derecho")
D4:AddTrans("esES", "LID_SHIFTLEFTCLICK", "Shift + clic izquierdo")
D4:AddTrans("esES", "LID_SHIFTMIDDLECLICK", "Shift + clic central")
D4:AddTrans("esES", "LID_SHIFTRIGHTCLICK", "Shift + clic derecho")
-- esMX
D4:AddTrans("esMX", "LID_ALTLEFTCLICK", "Alt + clic izquierdo")
D4:AddTrans("esMX", "LID_ALTMIDDLECLICK", "Alt + clic central")
D4:AddTrans("esMX", "LID_ALTRIGHTCLICK", "Alt + clic derecho")
D4:AddTrans("esMX", "LID_CTRLLEFTCLICK", "Ctrl + clic izquierdo")
D4:AddTrans("esMX", "LID_CTRLMIDDLECLICK", "Ctrl + clic central")
D4:AddTrans("esMX", "LID_CTRLRIGHTCLICK", "Ctrl + clic derecho")
D4:AddTrans("esMX", "LID_DEFAULT", "Predeterminado")
D4:AddTrans("esMX", "LID_HIDEMINIMAPBUTTON", "Ocultar botón del minimapa")
D4:AddTrans("esMX", "LID_LEFTCLICK", "Clic izquierdo")
D4:AddTrans("esMX", "LID_MIDDLECLICK", "Clic central")
D4:AddTrans("esMX", "LID_OPENSETTINGS", "Abrir ajustes")
D4:AddTrans("esMX", "LID_RIGHTCLICK", "Clic derecho")
D4:AddTrans("esMX", "LID_SHIFTLEFTCLICK", "Shift + clic izquierdo")
D4:AddTrans("esMX", "LID_SHIFTMIDDLECLICK", "Shift + clic central")
D4:AddTrans("esMX", "LID_SHIFTRIGHTCLICK", "Shift + clic derecho")
-- frFR
D4:AddTrans("frFR", "LID_ALTLEFTCLICK", "Alt + clic gauche")
D4:AddTrans("frFR", "LID_ALTMIDDLECLICK", "Alt + clic molette")
D4:AddTrans("frFR", "LID_ALTRIGHTCLICK", "Alt + clic droit")
D4:AddTrans("frFR", "LID_CTRLLEFTCLICK", "Ctrl + clic gauche")
D4:AddTrans("frFR", "LID_CTRLMIDDLECLICK", "Ctrl + clic molette")
D4:AddTrans("frFR", "LID_CTRLRIGHTCLICK", "Ctrl + clic droit")
D4:AddTrans("frFR", "LID_DEFAULT", "Défaut")
D4:AddTrans("frFR", "LID_HIDEMINIMAPBUTTON", "Masquer le bouton de la minicarte")
D4:AddTrans("frFR", "LID_LEFTCLICK", "Clic gauche")
D4:AddTrans("frFR", "LID_MIDDLECLICK", "Clic molette")
D4:AddTrans("frFR", "LID_OPENSETTINGS", "Ouvrir les paramètres")
D4:AddTrans("frFR", "LID_RIGHTCLICK", "Clic droit")
D4:AddTrans("frFR", "LID_SHIFTLEFTCLICK", "Shift + clic gauche")
D4:AddTrans("frFR", "LID_SHIFTMIDDLECLICK", "Shift + clic molette")
D4:AddTrans("frFR", "LID_SHIFTRIGHTCLICK", "Shift + clic droit")
-- itIT
D4:AddTrans("itIT", "LID_ALTLEFTCLICK", "Alt + clic sinistro")
D4:AddTrans("itIT", "LID_ALTMIDDLECLICK", "Alt + clic centrale")
D4:AddTrans("itIT", "LID_ALTRIGHTCLICK", "Alt + clic destro")
D4:AddTrans("itIT", "LID_CTRLLEFTCLICK", "Ctrl + clic sinistro")
D4:AddTrans("itIT", "LID_CTRLMIDDLECLICK", "Ctrl + clic centrale")
D4:AddTrans("itIT", "LID_CTRLRIGHTCLICK", "Ctrl + clic destro")
D4:AddTrans("itIT", "LID_DEFAULT", "Predefinito")
D4:AddTrans("itIT", "LID_HIDEMINIMAPBUTTON", "Nascondi pulsante minimappa")
D4:AddTrans("itIT", "LID_LEFTCLICK", "Clic sinistro")
D4:AddTrans("itIT", "LID_MIDDLECLICK", "Clic centrale")
D4:AddTrans("itIT", "LID_OPENSETTINGS", "Apri impostazioni")
D4:AddTrans("itIT", "LID_RIGHTCLICK", "Clic destro")
D4:AddTrans("itIT", "LID_SHIFTLEFTCLICK", "Shift + clic sinistro")
D4:AddTrans("itIT", "LID_SHIFTMIDDLECLICK", "Shift + clic centrale")
D4:AddTrans("itIT", "LID_SHIFTRIGHTCLICK", "Shift + clic destro")
-- koKR
D4:AddTrans("koKR", "LID_ALTLEFTCLICK", "Alt + 왼쪽 클릭")
D4:AddTrans("koKR", "LID_ALTMIDDLECLICK", "Alt + 가운데 클릭")
D4:AddTrans("koKR", "LID_ALTRIGHTCLICK", "Alt + 오른쪽 클릭")
D4:AddTrans("koKR", "LID_CTRLLEFTCLICK", "Ctrl + 왼쪽 클릭")
D4:AddTrans("koKR", "LID_CTRLMIDDLECLICK", "Ctrl + 가운데 클릭")
D4:AddTrans("koKR", "LID_CTRLRIGHTCLICK", "Ctrl + 오른쪽 클릭")
D4:AddTrans("koKR", "LID_DEFAULT", "기본값")
D4:AddTrans("koKR", "LID_HIDEMINIMAPBUTTON", "미니맵 버튼 숨기기")
D4:AddTrans("koKR", "LID_LEFTCLICK", "왼쪽 클릭")
D4:AddTrans("koKR", "LID_MIDDLECLICK", "가운데 클릭")
D4:AddTrans("koKR", "LID_OPENSETTINGS", "설정 열기")
D4:AddTrans("koKR", "LID_RIGHTCLICK", "오른쪽 클릭")
D4:AddTrans("koKR", "LID_SHIFTLEFTCLICK", "Shift + 왼쪽 클릭")
D4:AddTrans("koKR", "LID_SHIFTMIDDLECLICK", "Shift + 가운데 클릭")
D4:AddTrans("koKR", "LID_SHIFTRIGHTCLICK", "Shift + 오른쪽 클릭")
--ptBR
D4:AddTrans("ptBR", "LID_ALTLEFTCLICK", "Alt + clique esquerdo")
D4:AddTrans("ptBR", "LID_ALTMIDDLECLICK", "Alt + clique do meio")
D4:AddTrans("ptBR", "LID_ALTRIGHTCLICK", "Alt + clique direito")
D4:AddTrans("ptBR", "LID_CTRLLEFTCLICK", "Ctrl + clique esquerdo")
D4:AddTrans("ptBR", "LID_CTRLMIDDLECLICK", "Ctrl + clique do meio")
D4:AddTrans("ptBR", "LID_CTRLRIGHTCLICK", "Ctrl + clique direito")
D4:AddTrans("ptBR", "LID_DEFAULT", "Padrão")
D4:AddTrans("ptBR", "LID_HIDEMINIMAPBUTTON", "Ocultar botão do minimapa")
D4:AddTrans("ptBR", "LID_LEFTCLICK", "Clique esquerdo")
D4:AddTrans("ptBR", "LID_MIDDLECLICK", "Clique do meio")
D4:AddTrans("ptBR", "LID_OPENSETTINGS", "Abrir configurações")
D4:AddTrans("ptBR", "LID_RIGHTCLICK", "Clique direito")
D4:AddTrans("ptBR", "LID_SHIFTLEFTCLICK", "Shift + clique esquerdo")
D4:AddTrans("ptBR", "LID_SHIFTMIDDLECLICK", "Shift + clique do meio")
D4:AddTrans("ptBR", "LID_SHIFTRIGHTCLICK", "Shift + clique direito")
-- ruRU
D4:AddTrans("ruRU", "LID_ALTLEFTCLICK", "Alt + ЛКМ")
D4:AddTrans("ruRU", "LID_ALTMIDDLECLICK", "Alt + Middleclick")
D4:AddTrans("ruRU", "LID_ALTRIGHTCLICK", "Alt + ПКМ")
D4:AddTrans("ruRU", "LID_CTRLLEFTCLICK", "Ctrl + ЛКМ")
D4:AddTrans("ruRU", "LID_CTRLMIDDLECLICK", "Ctrl + Middleclick")
D4:AddTrans("ruRU", "LID_CTRLRIGHTCLICK", "Ctrl + ПКМ")
D4:AddTrans("ruRU", "LID_DEFAULT", "По умолчанию")
D4:AddTrans("ruRU", "LID_HIDEMINIMAPBUTTON", "Скрыть иконку на миникарте")
D4:AddTrans("ruRU", "LID_LEFTCLICK", "ЛКМ")
D4:AddTrans("ruRU", "LID_MIDDLECLICK", "Middleclick")
D4:AddTrans("ruRU", "LID_OPENSETTINGS", "Открыть настройки")
D4:AddTrans("ruRU", "LID_RIGHTCLICK", "ПКМ")
D4:AddTrans("ruRU", "LID_SHIFTLEFTCLICK", "Shift + ЛКМ")
D4:AddTrans("ruRU", "LID_SHIFTMIDDLECLICK", "Shift + Middleclick")
D4:AddTrans("ruRU", "LID_SHIFTRIGHTCLICK", "Shift + ПКМ")
-- zhCN
D4:AddTrans("zhCN", "LID_ALTLEFTCLICK", "Alt + 左键点击")
D4:AddTrans("zhCN", "LID_ALTMIDDLECLICK", "Alt + 中键点击")
D4:AddTrans("zhCN", "LID_ALTRIGHTCLICK", "Alt + 右键点击")
D4:AddTrans("zhCN", "LID_CTRLLEFTCLICK", "Ctrl + 左键点击")
D4:AddTrans("zhCN", "LID_CTRLMIDDLECLICK", "Ctrl + 中键点击")
D4:AddTrans("zhCN", "LID_CTRLRIGHTCLICK", "Ctrl + 右键点击")
D4:AddTrans("zhCN", "LID_DEFAULT", "默认")
D4:AddTrans("zhCN", "LID_HIDEMINIMAPBUTTON", "隐藏小地图按钮")
D4:AddTrans("zhCN", "LID_LEFTCLICK", "左键点击")
D4:AddTrans("zhCN", "LID_MIDDLECLICK", "中键点击")
D4:AddTrans("zhCN", "LID_OPENSETTINGS", "打开设置")
D4:AddTrans("zhCN", "LID_RIGHTCLICK", "右键点击")
D4:AddTrans("zhCN", "LID_SHIFTLEFTCLICK", "Shift + 左键点击")
D4:AddTrans("zhCN", "LID_SHIFTMIDDLECLICK", "Shift + 中键点击")
D4:AddTrans("zhCN", "LID_SHIFTRIGHTCLICK", "Shift + 右键点击")
-- zhTW
D4:AddTrans("zhTW", "LID_ALTLEFTCLICK", "Alt + 左鍵點擊")
D4:AddTrans("zhTW", "LID_ALTMIDDLECLICK", "Alt + 中鍵點擊")
D4:AddTrans("zhTW", "LID_ALTRIGHTCLICK", "Alt + 右鍵點擊")
D4:AddTrans("zhTW", "LID_CTRLLEFTCLICK", "Ctrl + 左鍵點擊")
D4:AddTrans("zhTW", "LID_CTRLMIDDLECLICK", "Ctrl + 中鍵點擊")
D4:AddTrans("zhTW", "LID_CTRLRIGHTCLICK", "Ctrl + 右鍵點擊")
D4:AddTrans("zhTW", "LID_DEFAULT", "預設")
D4:AddTrans("zhTW", "LID_HIDEMINIMAPBUTTON", "隱藏小地圖按鈕")
D4:AddTrans("zhTW", "LID_LEFTCLICK", "左鍵點擊")
D4:AddTrans("zhTW", "LID_MIDDLECLICK", "中鍵點擊")
D4:AddTrans("zhTW", "LID_OPENSETTINGS", "開啟設定")
D4:AddTrans("zhTW", "LID_RIGHTCLICK", "右鍵點擊")
D4:AddTrans("zhTW", "LID_SHIFTLEFTCLICK", "Shift + 左鍵點擊")
D4:AddTrans("zhTW", "LID_SHIFTMIDDLECLICK", "Shift + 中鍵點擊")
D4:AddTrans("zhTW", "LID_SHIFTRIGHTCLICK", "Shift + 右鍵點擊")
