Paladin = Paladin or {}

function Paladin:OneButtonProtectionAoE()
    local crusaderStrike = Abilities:new("Crusader Strike")
    local holyStrike = Abilities:new("Holy Strike")
    local holyShield = Abilities:new("Holy Shield")
    local consecration = Abilities:new("Consecration")
    local greaterBlessingOfSanctuary = Abilities:new("Greater Blessing of Sanctuary")

    Combat:startAutoAttack()

    if holyStrike:isInRange() then
        consecration:cast()
    end

    holyShield:cast()

    if crusaderStrike:getBuffApplications() == 3 then
        Paladin:SmartCrusaderStrike()
    else
        holyStrike:cast()
    end

    Paladin:SealOfRighteousness()
    greaterBlessingOfSanctuary:cast()
end
