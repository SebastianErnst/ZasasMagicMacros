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
        -- Selfbuff anything but buffs than were still on you (except if you gained a stack)
        "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
        -- Selfbuff fades (also dispelled?
        "CHAT_MSG_SPELL_AURA_GONE_SELF",
        -- Heal
        "CHAT_MSG_SPELL_SELF_BUFF",
        -- All dot DMG (all sources) vs mobs
        -- "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
        -- All dot DMG (all sources) vs player
        "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
        -- Any dot wearing off
        "CHAT_MSG_SPELL_AURA_GONE_OTHER",
    }

    

    for _, event in ipairs(events) do
        combatLogFrame:RegisterEvent(event)
    end

    combatLogFrame:SetScript("OnEvent", function()
        local combatLogText = arg1
        print(event)
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
