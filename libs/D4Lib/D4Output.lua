function D4:msg(...)
    print("[D4] ", ...)
end

function D4:MSG(name, icon, ...)
    print(format("[|cFFA0A0FF%s|r |T%s:0:0:0:0|t]", name, icon), ...)
end