local _, D4 = ...
local cmds = {}
local hooked = {}
local lastText = {}

local function GetEditBoxText(editBox)
    if type(editBox) ~= "table" then return nil end
    if type(editBox.GetText) ~= "function" then return nil end
    local ok, text = pcall(editBox.GetText, editBox)
    if not ok then return nil end
    if not D4:CanAccessValue(text) then return nil end
    if type(text) ~= "string" then return nil end

    return text
end

local function FindCmd(text)
    if type(text) ~= "string" then return nil end
    if string.sub(text, 1, 1) ~= "/" then return nil end
    local cmd, args = string.match(text, "^(/%S+)%s*(.*)$")
    if not cmd then return nil end
    local func = cmds[string.lower(cmd)]
    if not func then return nil end

    return func, args or ""
end

local function OnKeyDown(editBox, key)
    if key ~= "ENTER" and key ~= "NUMPADENTER" then return end
    local action, args = FindCmd(GetEditBoxText(editBox))
    if not action then return end
    if type(action) == "string" then
        lastText[editBox] = nil
        editBox:SetText("/" .. action .. (args ~= "" and " " .. args or ""))
        return
    end

    lastText[editBox] = nil
    editBox:SetText("")
    action(args)
end

local function OnTextChanged(editBox)
    local text = GetEditBoxText(editBox)
    if text and text ~= "" then lastText[editBox] = text end
end

local function OnEnterPressed(editBox)
    local text = lastText[editBox]
    lastText[editBox] = nil
    local action, args = FindCmd(text)
    if type(action) ~= "function" then return end
    action(args)
end

local function HookEditBox(editBox)
    if type(editBox) ~= "table" then return end
    if hooked[editBox] then return end
    if type(editBox.HookScript) ~= "function" then return end
    hooked[editBox] = true
    editBox:HookScript("OnKeyDown", OnKeyDown)
    editBox:HookScript("OnTextChanged", OnTextChanged)
    editBox:HookScript("OnEnterPressed", OnEnterPressed)
end

local function HookChatFrame(name)
    local frame = _G[name]
    if not frame then return end
    HookEditBox(frame.editBox or _G[name .. "EditBox"])
end

local function HookChatEditBoxes()
    local names = _G["CHAT_FRAMES"]
    if type(names) == "table" then
        for _, name in pairs(names) do
            if type(name) == "string" then HookChatFrame(name) end
        end
    end

    for i = 1, (_G["NUM_CHAT_WINDOWS"] or 10) do
        HookChatFrame("ChatFrame" .. i)
    end
end

local watcher = CreateFrame("FRAME")
watcher:SetScript("OnEvent", HookChatEditBoxes)
for _, ev in ipairs({"PLAYER_LOGIN", "UPDATE_CHAT_WINDOWS", "UPDATE_FLOATING_CHAT_WINDOWS"}) do
    pcall(watcher.RegisterEvent, watcher, ev)
end

if type(_G["FCF_OpenTemporaryWindow"]) == "function" then hooksecurefunc("FCF_OpenTemporaryWindow", HookChatEditBoxes) end

function D4:AddSlash(name, func)
    if type(name) ~= "string" then return end
    if type(func) ~= "function" then return end
    local key = "/" .. string.lower(name)
    if cmds[key] then return end
    cmds[key] = func
    HookChatEditBoxes()
end

function D4:AddSlashAlias(name, target)
    if type(name) ~= "string" then return end
    if type(target) ~= "string" then return end
    target = string.match(target, "^/?([^%s]+)$")
    if not target then return end
    local key = "/" .. string.lower(name)
    if cmds[key] then return end
    cmds[key] = string.lower(target)
    HookChatEditBoxes()
end
