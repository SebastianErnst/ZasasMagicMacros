Buffs = {}

function Buffs:getBuffIndexByTextureName(textureName)
    local i = 0
    while GetPlayerBuff(i) >= 0 do
        if strfind(GetPlayerBuffTexture(i), textureName) then
            return i
        end
        i = i + 1
    end
    return -1
end

function Buffs:findBuffByTextureName(textureName)
    return self:getBuffIndexByTextureName(textureName) > -1
end

function Buffs:printAll()
    print("----------------")
    for i = 0, 63 do
        if UnitBuff("player", i) then
            print(UnitBuff("player", i))
        end
    end
    print("----------------")
end
