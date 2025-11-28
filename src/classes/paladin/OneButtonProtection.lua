Paladin = Paladin or {}

function Paladin:OneButtonProtection()
    if Config.RunnerMode == "RR" then
        Paladin:AROneButtonProtection()
        return
    end

    local crusaderStrike = Abilities:new("Crusader Strike")
    local holyStrike = Abilities:new("Holy Strike")
    local holyShield = Abilities:new("Holy Shield")
    local consecration = Abilities:new("Consecration")
    local greaterBlessingOfSanctuary = Abilities:new("Greater Blessing of Sanctuary")

    Combat:startAutoAttack()

    if crusaderStrike:getBuffApplications() == 3 then
        Paladin:SmartCrusaderStrike()
    else
        holyStrike:cast()
    end

    holyShield:cast()
    Paladin:SealOfRighteousness()

    if holyStrike:isInRange() then
        consecration:cast()
    end

    greaterBlessingOfSanctuary:cast()
end

function Paladin:AROneButtonProtection()
    RotationRunner:run( "OneButtonProtection")
end