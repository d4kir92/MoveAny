
local AddOnName, MoveAny = ...

local ltab = {}
function MoveAny:GetLangTab()
	return ltab
end

function MoveAny:GT( str )
	local result = MoveAny:GetLangTab()[str]
	if result ~= nil then
		return result
	else
		MoveAny:MSG( format( "Missing Translation: %s", str ) )
		return str
	end
end

function MoveAny:UpdateLanguage()
	MoveAny:Lang_enUS()
	if GetLocale() == "deDE" then
		MoveAny:Lang_deDE()
	elseif GetLocale() == "enUS" then
		MoveAny:Lang_enUS()
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
MoveAny:UpdateLanguage()
