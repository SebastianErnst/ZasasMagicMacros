function Paladin:SmartCrusaderStrike()
    local crusaderStrike = Spell:new("Crusader Strike")
    local zeal = Buff:new("Zeal")
    local holyStrike = Spell:new("Holy Strike")

    if not zeal:isActive() then
        crusaderStrike:cast()
    end

    if zeal:isActive() and (zeal:getTimeLeft() < 7 or zeal:getStacks() < 3) then
        crusaderStrike:cast()
    else
        holyStrike:cast()
    end
end