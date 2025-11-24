function Paladin_OneButtonProtection()
    local textureName = "Spell_Holy_CrusaderStrike"
    local buffIndex = buffs_getBuffIndexByTextureName(textureName)

    combat_StartAutoAttack()

    if GetPlayerBuffApplications(buffIndex) == 3 then
        Paladin_SmartCrusaderStrike()
    else
        CastSpellByName("Crusader Strike")
    end

    CastSpellByName("Holy Shield")
    Paladin_SoR()
    CastSpellByName("Consecration")
    CastSpellByName("Greater Blessing of Sanctuary")
end
