
local AddOnName, MoveAny = ...

LANG_MA = LANG_MA or {}

function MAGT( str )
	local result = LANG_MA[str]
	if result ~= nil then
		return result
	else
		MoveAny:MSG( format( "Missing Translation: %s", str ) )
		return str
	end
end

function MAUpdateLanguage()
	MALang_enUS()
	if GetLocale() == "deDE" then
		MALang_deDE()
	elseif GetLocale() == "enUS" then
		MALang_enUS()
	elseif GetLocale() == "esES" then
		MALang_esES()
	elseif GetLocale() == "frFR" then
		MALang_frFR()
	elseif GetLocale() == "itIT" then
		MALang_frFR()
	elseif GetLocale() == "ptBR" then
		MALang_ptBR()
	elseif GetLocale() == "ruRU" then
		MALang_ruRU()
	elseif GetLocale() == "zhCN" then
		MALang_zhCN()
	end
end
MAUpdateLanguage()
