function Paladin:OneButtonProtection()
    local holyStrike = Spell:new("Holy Strike")
    local zeal = Buff:new("Zeal")
    local holyShield = Spell:new("Holy Shield")
    local consecration = Spell:new("Consecration")
    local greaterBlessingOfSanctuary = Spell:new("Greater Blessing of Sanctuary")
    local manaPercentage = UnitMana("player") / UnitManaMax("player") * 100
    local judgement = Spell:new("Judgement")
    local sealOfRighteousness = Spell:new("Seal of Righteousness")
    local sealOfRighteousnessBuff = Buff:new("Seal of Righteousness")
    local exorcism = Spell:new("Exorcism")

    Combat:startAutoAttack()

    if holyStrike:getCooldown() <= 0.5 and holyStrike:getCooldown() > 0 then
        return
    end

    if zeal:getStacks() == 3 then
        Paladin:SmartCrusaderStrike()
    end

    holyStrike:cast()

    holyShield:cast()

    if sealOfRighteousnessBuff:isActive() then
        judgement:cast()
    else
        sealOfRighteousness:cast()
    end

    if holyStrike:isInRange() then
        consecration:cast()
    end

    exorcism:cast()

    if manaPercentage >= 50 and UnitPlayerOrPetInRaid("player") then
        greaterBlessingOfSanctuary:cast()
    end
end
