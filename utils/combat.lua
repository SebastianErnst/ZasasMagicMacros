function combat_StartAutoAttack()
    if (not PlayerFrame.inCombat) then
        AttackTarget()
    end
end

function combat_isTextureNameInRange(textureName)
    for i = 1, 172 do
        local isSameTexture = strfind(GetActionTexture(i), textureName)
        if isSameTexture then
            if IsActionInRange(i) == 1 then
                return true
            else
                return false
            end
        end
    end

    return false
end
