Debuff = {}
Debuff.__index = Debuff

function Debuff:new(name, unit)
    local unit = unit or "target"
    local function findDebuffIndexByIcon(textureName)
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

    local spellInfo = Utils:getSpellInfoByName(name) 
    local icon = spellInfo.icon
    local duration = spellInfo.duration
    local playerhaste = Utils:getHaste()
    local debuffIndex = findDebuffIndexByIcon(icon)

    local public = {}
    function public.isActive()
        return debuffIndex >= 0
    end

    return public
end