Abilities = {}

function Abilities:new(name)
    local abilityName = name
    local textureName = AbilityNamesToTexturesMapping[name]
    local buffIndex = Buffs:getBuffIndexByTextureName(textureName)
    local buffApplications = GetPlayerBuffApplications(buffIndex)
    local debuffIndex = Debuffs:findDebuffByTextureName(textureName)
    local buffTimeLeft = GetPlayerBuffTimeLeft(buffIndex)

    local public = {}

    function public.getState()
        return {
            isBuffed = public.isBuffed(),
            timeLeft = public.getBuffTimeLeft(),
            stacks = public.getBuffApplications(),
            isInRange = public.isInRange()
        }
    end

    function public:getAbilityName()
        return abilityName
    end

    function public:getTextureName()
        return textureName
    end

    function public:getBuffIndex()
        return buffIndex
    end

    function public:getBuffApplications()
        return buffApplications
    end

    function public.getBuffTimeLeft()
        return buffTimeLeft
    end

    function public:cast()
        CastSpellByName(abilityName)
    end

    function public.isBuffed()
        if buffIndex >= 0 then
            return true
        end

        return false
    end

    function public.isDebuffed()
        if debuffIndex >= 0 then
            return true
        end

        return false
    end

    function public:isInRange()
        for i = 1, 172 do
            if GetActionTexture(i) then
                local isSameTexture = strfind(GetActionTexture(i), textureName)
                if isSameTexture then
                    if IsActionInRange(i) == 1 then
                        return true
                    else
                        return false
                    end
                end
            end
        end

        return false
    end

    return public
end
