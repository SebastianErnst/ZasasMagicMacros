Paladin = Paladin or {}

function Paladin:SealOfRighteousness()
    local judgement = Abilities:new("Judgement")
    local sealOfRighteousness = Abilities:new("Seal of Righteousness")

    if sealOfRighteousness:isBuffed() then
        judgement:cast()
    else
        sealOfRighteousness:cast()
    end
end