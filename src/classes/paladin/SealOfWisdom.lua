Paladin = Paladin or {}

function Paladin:SealOfWisdom()
    local judgement = Abilities:new("Judgement")
    local sealOfWidsom = Abilities:new("Seal of Wisdom")

    if sealOfWidsom:isBuffed() then
        if not sealOfWidsom:isDebuffed() then
            judgement:cast()
        end
    else
        sealOfWidsom:cast()
    end
end
