local _, D4 = ...
local hooksecurefunc = getglobal("hooksecurefunc")
local cmds = {}
function D4:AddSlash(name, func)
    if name == nil then
        D4:MSG("failed to add slash command, missing name")

        return false
    end

    cmds["/" .. string.upper(name)] = func
end

function D4:InitSlash()
    local lastMessage = ""
    if ChatEdit_ParseText and type(ChatEdit_ParseText) == "function" then
        hooksecurefunc(
            "ChatEdit_ParseText",
            function(editBox, send, parseIfNoSpace)
                if send == 0 and editBox:GetText() ~= "" then
                    lastMessage = editBox:GetText()
                end
            end
        )
    else
        D4:MSG("FAILED TO ADD SLASH COMMAND #1")
    end

    if ChatEdit_SendText and type(ChatEdit_SendText) == "function" then
        hooksecurefunc(
            "ChatEdit_SendText",
            function(frame)
                if lastMessage and lastMessage ~= "" then
                    local cmd = string.upper(lastMessage)
                    if cmds[cmd] ~= nil then
                        cmds[cmd]()
                        lastMessage = ""
                    end
                end
            end
        )
    else
        D4:MSG("FAILED TO ADD SLASH COMMAND #2")
    end
end

D4:InitSlash()
