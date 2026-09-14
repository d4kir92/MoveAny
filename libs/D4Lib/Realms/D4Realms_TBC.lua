-- By D4KiR
-- REALMS FROM: 11.09.2026
local _, D4 = ...
if D4:GetWoWBuild() ~= "TBC" then return end
D4:AddRealmData(
    function(realms, region, regions)
        if region == regions["US"] then
            if GetLocale() == "enUS" then
                realms["Dreamscythe"] = "Anniversary"
                realms["Maladath"] = "Anniversary"
                realms["Nightslayer"] = "Anniversary"
            elseif GetLocale() == "deDE" then
                realms["Dreamscythe"] = "Jubiläum"
                realms["Maladath"] = "Jubiläum"
                realms["Nightslayer"] = "Jubiläum"
            elseif GetLocale() == "esES" then
                realms["Dreamscythe"] = "Aniversario"
                realms["Maladath"] = "Aniversario"
                realms["Nightslayer"] = "Aniversario"
            elseif GetLocale() == "frFR" then
                realms["Dreamscythe"] = "Anniversaire"
                realms["Maladath"] = "Anniversaire"
                realms["Nightslayer"] = "Anniversaire"
            elseif GetLocale() == "itIT" then
                realms["Dreamscythe"] = "Anniversary"
                realms["Maladath"] = "Anniversary"
                realms["Nightslayer"] = "Anniversary"
            elseif GetLocale() == "koKR" then
                realms["드림사이드"] = "기념일"
                realms["말라다스"] = "기념일"
                realms["밤그림자"] = "기념일"
            elseif GetLocale() == "ptBR" then
                realms["Darquimeros"] = "Aniversário"
                realms["Maladath"] = "Aniversário"
                realms["Matador Noturno"] = "Aniversário"
            elseif GetLocale() == "ruRU" then
                realms["Dreamscythe"] = "Годовщина"
                realms["Maladath"] = "Годовщина"
                realms["Nightslayer"] = "Годовщина"
            elseif GetLocale() == "zhCN" then
                realms["夜幕杀手"] = "周年纪念版"
                realms["德姆塞卡尔"] = "周年纪念版"
                realms["玛拉达斯"] = "周年纪念版"
            elseif GetLocale() == "zhTW" then
                realms["德姆塞卡爾"] = "週年慶"
                realms["瑪拉達斯"] = "週年慶"
                realms["黑夜殺手"] = "週年慶"
            end
        elseif region == regions["EU"] then
            if GetLocale() == "enUS" then
                realms["Anniversary"] = "Russian"
                realms["Spineshatter"] = "Anniversary"
                realms["Thunderstrike"] = "Anniversary"
            elseif GetLocale() == "deDE" then
                realms["Anniversary"] = "Russisch"
                realms["Spineshatter"] = "Jubiläum"
                realms["Thunderstrike"] = "Jubiläum"
            elseif GetLocale() == "esES" then
                realms["Anniversary"] = "Ruso"
                realms["Spineshatter"] = "Aniversario"
                realms["Thunderstrike"] = "Aniversario"
            elseif GetLocale() == "frFR" then
                realms["Anniversary"] = "Russe"
                realms["Spineshatter"] = "Anniversaire"
                realms["Thunderstrike"] = "Anniversaire"
            elseif GetLocale() == "itIT" then
                realms["Anniversary"] = "Russo"
                realms["Spineshatter"] = "Anniversary"
                realms["Thunderstrike"] = "Anniversary"
            elseif GetLocale() == "koKR" then
                realms["기념일"] = "러시아어"
                realms["척추 파쇄"] = "기념일"
                realms["천둥의 일격"] = "기념일"
            elseif GetLocale() == "ptBR" then
                realms["Aniversário"] = "Russo"
                realms["Golpeforte"] = "Aniversário"
                realms["Quebra-espinha"] = "Aniversário"
            elseif GetLocale() == "ruRU" then
                realms["Spineshatter"] = "Годовщина"
                realms["Thunderstrike"] = "Годовщина"
                realms["Годовщина"] = "Русский"
            elseif GetLocale() == "zhCN" then
                realms["周年纪念版"] = "俄语"
                realms["碎脊者"] = "周年纪念版"
                realms["雷霆打击"] = "周年纪念版"
            elseif GetLocale() == "zhTW" then
                realms["碎脊者"] = "週年慶"
                realms["週年慶"] = "俄羅斯"
                realms["雷霆之擊"] = "週年慶"
            end
        elseif region == regions["KR"] then
            if GetLocale() == "enUS" then
                realms["Fengus' Ferocity"] = "Anniversary"
                realms["Mol'dar's Moxie"] = "Anniversary"
            elseif GetLocale() == "deDE" then
                realms["Fengus' Ferocity"] = "Jubiläum"
                realms["Mol'dar's Moxie"] = "Jubiläum"
            elseif GetLocale() == "esES" then
                realms["Fengus' Ferocity"] = "Aniversario"
                realms["Mol'dar's Moxie"] = "Aniversario"
            elseif GetLocale() == "frFR" then
                realms["Fengus' Ferocity"] = "Anniversaire"
                realms["Mol'dar's Moxie"] = "Anniversaire"
            elseif GetLocale() == "itIT" then
                realms["Fengus' Ferocity"] = "Anniversary"
                realms["Mol'dar's Moxie"] = "Anniversary"
            elseif GetLocale() == "koKR" then
                realms["몰다르의 투지"] = "기념일"
                realms["펜구스의 흉포"] = "기념일"
            elseif GetLocale() == "ptBR" then
                realms["Ferocidade de Fengus"] = "Aniversário"
                realms["Valentia do Mol'dar"] = "Aniversário"
            elseif GetLocale() == "ruRU" then
                realms["Fengus' Ferocity"] = "Годовщина"
                realms["Mol'dar's Moxie"] = "Годовщина"
            elseif GetLocale() == "zhCN" then
                realms["摩尔达的勇气"] = "周年纪念版"
                realms["芬古斯的狂暴"] = "周年纪念版"
            elseif GetLocale() == "zhTW" then
                realms["摩爾達的勇氣"] = "週年慶"
                realms["芬古斯的狂暴"] = "週年慶"
            end
        elseif region == regions["TW"] then
            if GetLocale() == "enUS" then
                realms["Fengus' Ferocity"] = "Anniversary"
                realms["Mol'dar's Moxie"] = "Anniversary"
            elseif GetLocale() == "deDE" then
                realms["Fengus' Ferocity"] = "Jubiläum"
                realms["Mol'dar's Moxie"] = "Jubiläum"
            elseif GetLocale() == "esES" then
                realms["Fengus' Ferocity"] = "Aniversario"
                realms["Mol'dar's Moxie"] = "Aniversario"
            elseif GetLocale() == "frFR" then
                realms["Fengus' Ferocity"] = "Anniversaire"
                realms["Mol'dar's Moxie"] = "Anniversaire"
            elseif GetLocale() == "itIT" then
                realms["Fengus' Ferocity"] = "Anniversary"
                realms["Mol'dar's Moxie"] = "Anniversary"
            elseif GetLocale() == "koKR" then
                realms["몰다르의 투지"] = "기념일"
                realms["펜구스의 흉포"] = "기념일"
            elseif GetLocale() == "ptBR" then
                realms["Ferocidade de Fengus"] = "Aniversário"
                realms["Valentia do Mol'dar"] = "Aniversário"
            elseif GetLocale() == "ruRU" then
                realms["Fengus' Ferocity"] = "Годовщина"
                realms["Mol'dar's Moxie"] = "Годовщина"
            elseif GetLocale() == "zhCN" then
                realms["摩尔达的勇气"] = "周年纪念版"
                realms["芬古斯的狂暴"] = "周年纪念版"
            elseif GetLocale() == "zhTW" then
                realms["摩爾達的勇氣"] = "週年慶"
                realms["芬古斯的狂暴"] = "週年慶"
            end
        else
            D4:MissingRealmRegion(region)
        end
    end
)
