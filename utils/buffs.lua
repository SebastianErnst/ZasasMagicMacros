function buffs_getBuffIndexByTextureName(textureName)
    local i = 0
    while  GetPlayerBuff(i) >= 0 do
        local isSameTexture = strfind(GetPlayerBuffTexture(i), textureName)
        if isSameTexture then
            return i
        end
        i = i + 1
    end

    return -1
end

function buffs_findBuffByTextureName(textureName)
    if buffs_getBuffIndexByTextureName(textureName) > -1 then
        return true
    end

    return false
end