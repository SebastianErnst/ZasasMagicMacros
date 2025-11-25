Combat = {}

function Combat:startAutoAttack()
    ---@diagnostic disable-next-line: undefined-global
    if (not PlayerFrame.inCombat) then
        AttackTarget()
    end
end