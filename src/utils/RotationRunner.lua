RotationRunner = {}

function RotationRunner:run(rotationName, rotation)
    local actualRotation = nil
    print("Name:", rotationName)
    if rotationName ~= "" then
        actualRotation = Rotations[rotationName]
    else
        actualRotation = rotation
    end

    for _, rotationStep in pairs(actualRotation) do
        repeat
            if rotationStep.abilityName == "Attack" then
                Combat:startAutoAttack()
                break
            end

            if not RotationRunner:hasConditions(rotationStep.conditions) or RotationRunner:isAnyConditionTrue(rotationStep.conditions) then
                local rotationStepAbility = nil
                if rotationStep.abilityName then
                    rotationStepAbility = Abilities:new(rotationStep.abilityName)
                end

                if rotationStepAbility then
                    print("Spell")
                    rotationStepAbility:cast()
                    --break
                end

                local subRotationWithName = nil
                if rotationStep.rotationName then
                    subRotationWithName = rotationStep.rotationName
                end

                if subRotationWithName then
                    print("subRotationWithName")
                    RotationRunner:run(rotationStep.rotationName)
                    --                    break
                end

                local subRotation = nil
                if rotation then
                    subRotation = rotation
                end

                if subRotation then
                    print("Namenlose subRotation")
                    RotationRunner:run(_, subRotation)
                    --                    break
                end
            end
        until true
    end
end

function RotationRunner:hasConditions(conditions)
    if not conditions or table.getn(conditions) == 0 then
        return false
    end

    return true
end

function RotationRunner:isAnyConditionTrue(conditions)
    for _, condition in pairs(conditions) do
        local conditionAbilityState = Abilities:new(condition.abilityName).getState()
        if RotationRunner:compare(conditionAbilityState[condition.actual], condition.operator, condition.expected) then
            print(condition.actual, condition.operator, condition.expected)
            return true
        end
    end

    return false
end

function RotationRunner:isSubRotation(rotation)

end

function RotationRunner:compare(a, op, b)
    if op == "==" then return a == b end
    if op == "~=" then return a ~= b end
    if op == "<" then return a < b end
    if op == "<=" then return a <= b end
    if op == ">" then return a > b end
    if op == ">=" then return a >= b end
    return false
end