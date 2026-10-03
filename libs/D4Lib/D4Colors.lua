local _, D4 = ...
function D4:GetLevelDifficultyColor(level, r, g, b)
    if r == nil then
        r, g, b = 1, 0.82, 0
    end

    if type(GetQuestDifficultyColor) ~= "function" then return r, g, b end
    local ok, color = pcall(GetQuestDifficultyColor, level)
    if not ok or type(color) ~= "table" then return r, g, b end

    return color.r or 1, color.g or 1, color.b or 1
end

function D4:GetColorCode(r, g, b)
    local red = min(255, max(0, floor((r or 1) * 255 + 0.5)))
    local green = min(255, max(0, floor((g or 1) * 255 + 0.5)))
    local blue = min(255, max(0, floor((b or 1) * 255 + 0.5)))

    return format("|cff%02x%02x%02x", red, green, blue)
end
