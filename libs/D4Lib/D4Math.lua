local _, _ = ...
D4 = D4 or {}
D4.LibVersion = D4.LibVersion or 0
local D4LibVersion = 1.0
if D4.LibVersion >= D4LibVersion then return end
function D4:MClamp(val, vmin, vmax)
    if val < vmin then
        return vmin
    elseif val > vmax then
        return vmax
    end

    return val
end
