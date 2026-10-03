local _, D4 = ...
function D4:FindAtlas(candidates)
    for _, atlas in ipairs(candidates or {}) do
        if type(atlas) == "string" and atlas ~= "" and D4:AtlasExists(atlas) == true then return atlas end
    end

    return nil
end

function D4:SetIconTexture(texture, icon, noCrop)
    if type(icon) == "string" and icon ~= "" and texture.SetAtlas ~= nil and D4:AtlasExists(icon) == true then
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetAtlas(icon)

        return true
    end

    texture:SetTexture(icon)
    if noCrop then
        texture:SetTexCoord(0, 1, 0, 1)
    else
        texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    return false
end
