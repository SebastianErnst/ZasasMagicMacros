Debuff = {}
Debuff.__index = Debuff

function Debuff:new(name, unit)
    local unit = unit or "target"
    local function findDebuffIndexByTextureName(textureName)
        local i = 1
        while UnitDebuff(unit, i) do
            local isSameTexture = strfind(UnitDebuff(unit, i), textureName)

            if isSameTexture then
                return i
            end

            i = i + 1
        end
        return -1
    end

    local textureName = NamesToTexturesMapping[name]
    local debuffIndex = findDebuffIndexByTextureName(textureName)

    local public = {}
    function public.isActive()
        return debuffIndex >= 0
    end

    return public
end