local _, D4 = ...
function D4:AddSlash(name, func)
    local cmdName = string.upper(name)
    if not getglobal("SlashCmdList") then
        setglobal("SlashCmdList", {})
    end

    if getglobal("SlashCmdList")[cmdName] then return end
    SlashCmdList[cmdName] = function(msg)
        func(msg)
    end

    local i = 1
    while getglobal("SLASH_" .. cmdName .. i) ~= nil do
        i = i + 1
    end

    setglobal("SLASH_" .. cmdName .. i, "/" .. name)
end
