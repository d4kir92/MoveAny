-- deDE German Deutsch
local _, MoveAny = ...
local ltab = {}
function MoveAny:GetLangTab()
	return ltab
end

local missingTab = {}
function MoveAny:GT(str)
	local result = MoveAny:GetLangTab()[str]
	if result ~= nil then
		return result
	elseif not tContains(missingTab, str) then
		tinsert(missingTab, str)
		MoveAny:MSG(format("Missing Translation: %s", str))

		return str
	end

	return str
end

function MoveAny:UpdateLanguage()
	MoveAny:LangenUS()
	if GetLocale() == "deDE" then
		MoveAny:LangdeDE()
	elseif GetLocale() == "enUS" then
		MoveAny:LangenUS()
	elseif GetLocale() == "esES" then
		MoveAny:LangesES()
	elseif GetLocale() == "frFR" then
		MoveAny:LangfrFR()
	elseif GetLocale() == "itIT" then
		MoveAny:LangitIT()
	elseif GetLocale() == "koKR" then
		MoveAny:LangkoKR()
	elseif GetLocale() == "ptBR" then
		MoveAny:LangptBR()
	elseif GetLocale() == "ruRU" then
		MoveAny:LangruRU()
	elseif GetLocale() == "zhCN" then
		MoveAny:LangzhCN()
	end
end

MoveAny:UpdateLanguage()
