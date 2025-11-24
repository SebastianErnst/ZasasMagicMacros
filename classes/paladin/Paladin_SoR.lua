function Paladin_SoR()
    local textureName = "Ability_ThunderBolt"
    local isBuffFound = buffs_findBuffByTextureName(textureName)

    if isBuffFound then
        CastSpellByName("Judgement")
    else
        CastSpellByName("Seal of Righteousness")
    end
end