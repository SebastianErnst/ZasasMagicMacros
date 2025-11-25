Paladin = Paladin or {}

function Paladin:SmartCrusaderStrike()
    local crusaderStrike = Abilities:new("Crusader Strike")
    local holyStrike = Abilities:new("Holy Strike")

    if not crusaderStrike:isBuffed() then
        crusaderStrike:cast()
    end

    if crusaderStrike:isBuffed() and (crusaderStrike:getBuffTimeLeft() < 7 or crusaderStrike:getBuffApplications() < 3) then
        crusaderStrike:cast()
    end

    holyStrike:cast()
end