function Warrior_HeroicStrikeQueue()
    local heroicStrikeSlotIndex = Slots:findSlotIndexByTextureName("Ability_BackStab")

    if UnitMana("player") >= 40 then
        CastSpellByName("Heroic Strike")
    end
end

for i = 1, 172 do
    if GetActionTexture(i) then
        local isSameTexture = strfind(GetActionTexture(i), "Ability_Rogue_Ambush")
        if isSameTexture then
            if UnitMana("player") >= 40 and not IsCurrentAction(i) then
                print("jaaaa")
                CastSpellByName("Heroic Strike")
            else
                print("NEIN")
            end
            break
        end
    end
end


--/cast Shield Slam
/run CastSpellByName("Shield Slam") CastSpellByName("Revenge") if UnitMana("player") >= 30 then CastSpellByName("Sunder Armor") end if UnitMana("player") >= 42 then CastSpellByName("Heroic Strike") end if (not PlayerFrame.inCombat) then AttackTarget() end