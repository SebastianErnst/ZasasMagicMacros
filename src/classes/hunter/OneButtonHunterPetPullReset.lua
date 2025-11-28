function Hunter:OneButtonHunterPetPullReset()
    CastSpellByName("Furious Howl")
    if UnitExists("pet") then
        if Buffs:findBuffByTextureName("Ability_Rogue_FeignDeath") then
            CastSpellByName("Eyes of the Beast")
        end
        CastSpellByName("Feign Death")
    end
    CastSpellByName("Call Pet")
    CastSpellByName("Revive Pet")
end