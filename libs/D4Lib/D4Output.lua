local _, _ = ...
D4 = D4 or {}
D4.LibVersion = D4.LibVersion or 0
local D4LibVersion = 1.0
if D4.LibVersion >= D4LibVersion then return end
function D4:msg(...)
    print("[D4] ", ...)
end

function D4:MSG(name, icon, ...)
    print(string.format("[|cFFA0A0FF%s|r |T%s:0:0:0:0|t]", name, icon), ...)
end
