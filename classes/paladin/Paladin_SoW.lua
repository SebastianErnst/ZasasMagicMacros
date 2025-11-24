function Paladin_SoW()
    local textureName = "Spell_Holy_RighteousnessAura"
    local isBuffFound = buffs_findBuffByTextureName(textureName)

    if isBuffFound then
        CastSpellByName("Judgement")
    else
        CastSpellByName("Seal of Wisdom")
    end
end