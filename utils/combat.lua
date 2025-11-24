function combat_StartAutoAttack()
    if (not PlayerFrame.inCombat) then
        AttackTarget()
    end
end