CombatLogHandler                    = {}
CombatLogHandler.__index            = CombatLogHandler

-- SELF
local PATTERN_BUFF_GAINED_SELF      = "You gain ([^%(%.]+)%s*%(?(%d*)%)?%."
local PATTERN_BUFF_LOST_SELF        = "^(.+) fades from you%.$"
local PATTERN_HEALTH_GAINED_SELF    = "^Your (.+) heals you for (%d+)%.$"
local PATTERN_DEBUFF_APPLIED_TARGET = "^(.+) suffers (%d+) (.+) damage from your (.+)%.$"

function CombatLogHandler:new()
    local combatLogFrame = CreateFrame("Frame")
    local events = {
        ['CHAT_MSG_COMBAT_PET_HITS'] = true,
        ['CHAT_MSG_COMBAT_PET_MISSES'] = true,
        ['CHAT_MSG_COMBAT_SELF_HITS'] = true,
        ['CHAT_MSG_COMBAT_SELF_MISSES'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS'] = true,
        ['CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES'] = true,
        -- ['CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS'] = true,
        -- ['CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES'] = true,
        ['CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS'] = true,
        ['CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES'] = true,
        ['CHAT_MSG_COMBAT_PARTY_HITS'] = true,
        ['CHAT_MSG_COMBAT_PARTY_MISSES'] = true,
        ['CHAT_MSG_SPELL_PET_BUFF'] = true,
        ['CHAT_MSG_SPELL_PET_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_SELF_BUFF'] = true,
        ['CHAT_MSG_SPELL_SELF_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF'] = true,
        ['CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE'] = true,
        -- ['CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF'] = true,
        -- ['CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF'] = true,
        ['CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_PARTY_BUFF'] = true,
        ['CHAT_MSG_SPELL_PARTY_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS'] = true,
        ['CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE'] = true,
        -- ['CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS'] = true,
        -- ['CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS'] = true,
        ['CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE'] = true,
        ['CHAT_MSG_SPELL_AURA_GONE_OTHER'] = true,
        ['CHAT_MSG_SPELL_AURA_GONE_SELF'] = true,
        ['CHAT_MSG_SPELL_AURA_GONE_PARTY'] = true,
        ['CHAT_MSG_SPELL_BREAK_AURA'] = true,
        -- ['CHAT_MSG_COMBAT_FRIENDLY_DEATH'] = true,
        ['CHAT_MSG_COMBAT_HOSTILE_DEATH'] = true,
        ['CHAT_MSG_SPELL_ITEM_ENCHANTMENTS'] = true,
        ['CHAT_MSG_COMBAT_XP_GAIN'] = true,
        ['CHAT_MSG_COMBAT_HONOR_GAIN'] = true,
        ['CHAT_MSG_COMBAT_FACTION_CHANGE'] = true,
        ['CHAT_MSG_SPELL_TRADESKILLS'] = true,
        ['CHAT_MSG_SPELL_FAILED_LOCALPLAYER'] = false,
    }

    -- local events = {
    --     -- Selfbuff anything but buffs than were still on you (except if you gained a stack)
    --     "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
    --     -- Selfbuff fades (also dispelled?
    --     "CHAT_MSG_SPELL_AURA_GONE_SELF",
    --     -- Heal
    --     "CHAT_MSG_SPELL_SELF_BUFF",
    --     -- All dot DMG (all sources) vs mobs
    --     -- "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
    --     -- All dot DMG (all sources) vs player
    --     "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
    --     -- Any dot wearing off
    --     "CHAT_MSG_SPELL_AURA_GONE_OTHER",
    -- }


    for key, value in pairs(events) do
        combatLogFrame:RegisterEvent(key)
    end

    combatLogFrame:SetScript("OnEvent", function()
        print(event)
        local combatLogText = arg1
        if event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
            handleDotDamage(combatLogText)
        end

        if event == "CHAT_MSG_SPELL_SELF_BUFF" then
            handleHealthGained(combatLogText)
        end

        if event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
            handleBuffGained(combatLogText)
        end

        if event == "CHAT_MSG_SPELL_AURA_GONE_SELF" then
            handleBuffLost(combatLogText)
        end
    end)

    function handleDotDamage(combatLogText)
        local _, _, target, dmg, dmgType, spell = string.find(combatLogText, PATTERN_DEBUFF_APPLIED_TARGET)
        target = target or nil

        if not target then
            return
        end

        dmg = tonumber(dmg)
        dmgType = dmgType
        spell = spell
        print("Target: " .. target .. " Damage: " .. dmg .. " Type: " .. dmgType .. " Spell: " .. spell)
    end

    function handleHealthGained(combatLogText)
        local _, _, spell, amount = string.find(combatLogText, PATTERN_HEALTH_GAINED_SELF)
        local amount = tonumber(amount) or 0
        spell = spell or "Unknown Spell"
        print("Spell: " .. spell .. " Amount: " .. amount)
    end

    function handleBuffGained(combatLogText)
        local _, _, buffName, stacks = string.find(combatLogText, PATTERN_BUFF_GAINED_SELF)
        local stacks = tonumber(stacks) or 1

        buffName = buffName or "Unknown Buff"
        stacks = stacks or 0
        print("Buff gained: " .. buffName .. " Stacks: " .. stacks)
    end

    function handleBuffLost(combatLogText)
        local _, _, buffName = string.find(combatLogText, PATTERN_BUFF_LOST_SELF)
        print("Buff lost: " .. buffName)
    end

    local public = {}
end

CombatLogHandler:new()
