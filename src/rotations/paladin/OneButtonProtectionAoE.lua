Paladin = Paladin or {}

function Paladin:OneButtonProtectionAoE()
    local crusaderStrike = Spell:new("Crusader Strike")
    local holyStrike = Spell:new("Holy Strike")
    local holyShield = Spell:new("Holy Shield")
    local consecration = Spell:new("Consecration")
    local greaterBlessingOfSanctuary = Spell:new("Greater Blessing of Sanctuary")

    Combat:startAutoAttack()

    if holyStrike:isInRange() then
        consecration:cast()
    end

    holyShield:cast()

    if crusaderStrike:getStacks() == 3 then
        Paladin:SmartCrusaderStrike()
    else
        holyStrike:cast()
    end

    Paladin:SealOfRighteousness()
    greaterBlessingOfSanctuary:cast()
end
