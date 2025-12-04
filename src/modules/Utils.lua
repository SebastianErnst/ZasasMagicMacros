Utils = {}
Utils.__index = Utils

function Utils:printAllVisibleBuffs(target)
    if not target then
        target = "player"
    end

    Utils:printSeperator()

    for i = 0, 63 do
        if UnitBuff(target, i) then
            print(UnitBuff("player", i))
        end
    end
    Utils:printSeperator()
end

function Utils:printAllSlots()
    for i = 1, 172 do
        if GetActionText(i) then
            print(GetActionText(i))
        end
    end
    Utils:printSeperator()
end

function Utils:printSeperator()
    print("---------------------------")
end

function Utils:printSpellbookSpell()
    local output = ""
    local currentName = ""
    local currentSpellId = 0
    for i = 1, 172 do
        if GetSpellName(i, BOOKTYPE_SPELL) then
            local name, _, spellId = GetSpellName(i, BOOKTYPE_SPELL)
            if currentName == "" and name and spellId then
                currentName = name
                currentSpellId = spellId
            end

            if currentName ~= name and name and spellId then
                local _, _, currentTexture = SpellInfo(currentSpellId)
                currentTexture = Utils:stringSplit(currentTexture, "\\")[3]
                output = output .. "[\"" .. currentName .. "\"] = \"" .. currentTexture .. "\",\n"
                currentName = name
                currentSpellId = spellId
            end
        end
    end
    for i = 1, 172 do
        if GetSpellName(i, BOOKTYPE_PET) then
            local name, _, spellId = GetSpellName(i, BOOKTYPE_PET)
            if currentName == "" and name and spellId then
                currentName = name
                currentSpellId = spellId
            end

            if currentName ~= name and name and spellId then
                local _, _, currentTexture = SpellInfo(currentSpellId)
                currentTexture = Utils:stringSplit(currentTexture, "\\")[3]
                output = output .. "[\"" .. currentName .. "\"] = \"" .. currentTexture .. "\",\n"
                currentName = name
                currentSpellId = spellId
            end
        end
    end
    ExportFile("sachengibtsdiegibtsgarnicht", output)
end

function Utils:stringSplit(str, sep)
    local parts = {}
    local start = 1

    while true do
        local pos = string.find(str, sep, start, true)
        if not pos then
            table.insert(parts, string.sub(str, start))
            break
        end
        table.insert(parts, string.sub(str, start, pos - 1))
        start = pos + 1
    end

    return parts
end

-- TODO: From here it'S BetterCharacterStats GetHaste function and really needs to be refactored
-------------------------------------------------------------------------------------------

local _G = _G or getfenv(0)

BCS = BCS or {}

local BCS_Tooltip = BetterCharacterStatsTooltip or
CreateFrame("GameTooltip", "BetterCharacterStatsTooltip", nil, "GameTooltipTemplate")
local BCS_Prefix = "BetterCharacterStatsTooltip"
BCS_Tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local setPattern = "(.+) %(%d/%d%)"
local strfind = strfind
local tonumber = tonumber
local _, playerClass = UnitClass("player")

local function twipe(table)
    if type(table) ~= "table" then
        return nil
    end
    for k in pairs(table) do
        table[k] = nil
    end
end

local BCScache = {
    ["gear"] = {
        damage_and_healing = 0,
        arcane = 0,
        fire = 0,
        frost = 0,
        holy = 0,
        nature = 0,
        shadow = 0,
        healing = 0,
        mp5 = 0,
        casting = 0,
        spell_hit = 0,
        spell_crit = 0,
        hit = 0,
        ranged_hit = 0,
        ranged_crit = 0
    },
    ["talents"] = {
        damage_and_healing = 0,
        healing = 0,
        spell_hit = 0,
        spell_hit_fire = 0,
        spell_hit_frost = 0,
        spell_hit_arcane = 0,
        spell_hit_shadow = 0,
        spell_hit_holy = 0,
        spell_crit = 0,
        casting = 0,
        mp5 = 0,
        hit = 0,
        ranged_hit = 0,
        ranged_crit = 0
    },
    ["auras"] = {
        damage_and_healing = 0,
        only_damage = 0,
        arcane = 0,
        fire = 0,
        frost = 0,
        holy = 0,
        nature = 0,
        shadow = 0,
        healing = 0,
        mp5 = 0,
        casting = 0,
        spell_hit = 0,
        spell_crit = 0,
        hit = 0,
        ranged_hit = 0,
        ranged_crit = 0,
        hit_debuff = 0
    },
    ["skills"] = {
        mh = 0,
        oh = 0,
        ranged = 0
    }
}

local SetBonus = {
    hit = {},
    spellHit = {},
    rangedCrit = {},
    spellCrit = {},
    spellCritClass = {},
    spellPower = {},
    healingPower = {},
    mp5 = {},
    haste = {},
    armor_pen = {},
    spell_pen = {},
}

function BCS:GetPlayerAura(searchText, auraType)
    if not auraType then
        -- Buffs
        -- http://blue.cardplace.com/cache/wow-dungeons/624230.htm
        -- 32 buffs max
        local _, numValues = gsub(searchText, "%(%%d%+?%)", "")
        if numValues > 0 then
            local total1, total2 = 0, 0
            local s, e
            for i = 0, 31 do
                local index = GetPlayerBuff(i, "HELPFUL")
                if index > -1 then
                    BCS_Tooltip:SetPlayerBuff(index)
                    for line = 1, BCS_Tooltip:NumLines() do
                        local text = _G[BCS_Prefix .. "TextLeft" .. line]:GetText()
                        if text then
                            local _s, _e, amount, amount2 = strfind(text, searchText)
                            if amount then
                                total1 = total1 + tonumber(amount)
                                s, e = _s, _e
                            end
                            if amount2 then
                                total2 = total2 + tonumber(amount2)
                                s, e = _s, _e
                            end
                        end
                    end
                end
            end
            total1 = total1 > 0 and total1 or nil
            total2 = total2 > 0 and total2 or nil
            return s, e, total1, total2
        end
        for i = 0, 31 do
            local index = GetPlayerBuff(i, "HELPFUL")
            if index > -1 then
                BCS_Tooltip:SetPlayerBuff(index)
                for line = 1, BCS_Tooltip:NumLines() do
                    local text = _G[BCS_Prefix .. "TextLeft" .. line]:GetText()
                    if text then
                        if strfind(text, searchText) then
                            return strfind(text, searchText)
                        end
                    end
                end
            end
        end
    elseif auraType == "HARMFUL" then
        for i = 0, 6 do
            local index = GetPlayerBuff(i, auraType)
            if index > -1 then
                BCS_Tooltip:SetPlayerBuff(index)
                for line = 1, BCS_Tooltip:NumLines() do
                    local text = _G[BCS_Prefix .. "TextLeft" .. line]:GetText()
                    if text then
                        if strfind(text, searchText) then
                            return strfind(text, searchText)
                        end
                    end
                end
            end
        end
    end
end

function BCS:GetItemTypeForSlot(slot)
    local _, _, id = string.find(GetInventoryItemLink("player", GetInventorySlotInfo(slot)) or "",
        "(item:%d+:%d+:%d+:%d+)")
    if not id then
        return
    end

    local _, _, _, _, _, itemType = GetItemInfo(id)

    return itemType
end

local vengefulStrikes
function Utils:getHaste()
    BCS.needScanTalents = true

    if BCS.needScanTalents then
        BCScache["talents"].spell_haste = 0
        vengefulStrikes = nil
        -- Talents
        for tab = 1, GetNumTalentTabs() do
            for talent = 1, GetNumTalents(tab) do
                BCS_Tooltip:SetTalent(tab, talent)
                for line = 1, BCS_Tooltip:NumLines() do
                    local left = _G[BCS_Prefix .. "TextLeft" .. line]
                    local text = left:GetText()
                    if text then
                        local _, _, _, _, rank = GetTalentInfo(tab, talent)
                        -- Priest (Mental Strength)
                        local _, _, value = strfind(text,
                            "Increases your total intellect by %d+%% and your spell casting speed by (%d+)%%")
                        if value and rank > 0 then
                            BCScache["talents"].spell_haste = BCScache["talents"].spell_haste + tonumber(value)
                            break
                        end
                        -- Paladin (Vengeful Strikes)
                        _, _, value = strfind(text,
                            "Zeal increases your attack and casting speed by an additional (%d+)%% per stack")
                        if value and rank > 0 then
                            vengefulStrikes = tonumber(value)
                            break
                        end
                    end
                end
            end
        end
    end

    BCS.needScanGear = true
    if BCS.needScanGear then
        BCScache["gear"].haste = 0
        BCScache["gear"].spell_haste = 0
        -- Gear
        twipe(SetBonus.haste)
        for slot = 1, 19 do
            if BCS_Tooltip:SetInventoryItem("player", slot) then
                local _, _, eqItemLink = strfind(GetInventoryItemLink("player", slot), "(item:%d+:%d+:%d+:%d+)")
                if eqItemLink then
                    BCS_Tooltip:ClearLines()
                    BCS_Tooltip:SetHyperlink(eqItemLink)
                end
                local setName
                for line = 1, BCS_Tooltip:NumLines() do
                    local left = _G[BCS_Prefix .. "TextLeft" .. line]
                    local text = left:GetText()
                    if text then
                        local _, _, value = strfind(text, "^Equip: Increases your attack and casting speed by (%d+)%%")
                        if value then
                            BCScache["gear"].haste = BCScache["gear"].haste + tonumber(value)
                        end
                        _, _, value = strfind(text, "^Equip: Increases your casting speed by (%d+)%%")
                        if value then
                            BCScache["gear"].spell_haste = BCScache["gear"].spell_haste + tonumber(value)
                        end
                        -- Sigil of Quickness (shoulder enchant)
                        _, _, value = strfind(text, "^%+(%d+)%% Haste")
                        if value then
                            BCScache["gear"].haste = BCScache["gear"].haste + tonumber(value)
                        end
                        -- Arcanum of Rapidity (gives spell haste too)
                        _, _, value = strfind(text, "^Attack Speed %+(%d+)%%")
                        if value then
                            BCScache["gear"].haste = BCScache["gear"].haste + tonumber(value)
                        end
                        -- Set Bonuses
                        _, _, value = strfind(text, setPattern)
                        if value then
                            setName = value
                        end
                        _, _, value = strfind(text, "^Set: Increases your attack and casting speed by (%d+)%%")
                        if value and setName and not SetBonus.haste[setName] then
                            SetBonus.haste[setName] = true
                            BCScache["gear"].haste = BCScache["gear"].haste + tonumber(value)
                        end
                    end
                end
            end
        end
    end

    BCS.needScanAuras = true

    if BCS.needScanAuras then
        BCScache["auras"].haste = 0
        BCScache["auras"].spell_haste = 0
        -- Buffs
        -- Bloodlust (self buff)
        local _, _, value, value2 = BCS:GetPlayerAura(
            "^Increases attack speed by (%d+)%% and spell casting speed by (%d+)%%")
        if value then
            BCScache["auras"].haste = BCScache["auras"].haste + tonumber(value)
            -- BCScache["auras"].spell_haste = BCScache["auras"].spell_haste + tonumber(value2)
        end
        -- Bloodlust (proc for party members)
        _, _, value = BCS:GetPlayerAura("^Increases attack and spell casting speed by (%d+)%%")
        if value then
            BCScache["auras"].haste = BCScache["auras"].haste + tonumber(value)
        end
        -- Master Demonologist (imp)
        _, _, value = BCS:GetPlayerAura("increases casting speed by (%d+)%%")
        if value then
            BCScache["auras"].spell_haste = BCScache["auras"].spell_haste + tonumber(value)
        end
        -- Master Demonologist (infernal)
        _, _, value = BCS:GetPlayerAura("^Increases casting and attack speed by (%d+)%%")
        if value then
            BCScache["auras"].haste = BCScache["auras"].haste + tonumber(value)
        end
        -- Chastise
        _, _, value = BCS:GetPlayerAura("^Increases attack and casting speed by (%d+)%%")
        if value then
            BCScache["auras"].haste = BCScache["auras"].haste + tonumber(value)
        end
        -- Arcane Power
        _, _, value = BCS:GetPlayerAura("^Casting speed increased by (%d+)%%")
        if value then
            BCScache["auras"].spell_haste = BCScache["auras"].spell_haste + tonumber(value)
        end
        -- Zeal
        _, _, value = BCS:GetPlayerAura("^Attack and casting speed increased by (%d+)%%")
        if value then
            value = tonumber(value)
            if vengefulStrikes then
                for i = 1, 32 do
                    local icon, stacks = UnitBuff("player", i)
                    if icon and stacks and icon == "Interface\\Icons\\Spell_Holy_CrusaderStrike" then
                        value = value + (vengefulStrikes * stacks)
                        break
                    end
                end
            end
            BCScache["auras"].haste = BCScache["auras"].haste + value
        end
        -- Power of the Guardian (Druid)
        _, _, value = BCS:GetPlayerAura("^Increases your attack and casting speed by (%d+)%%")
        if value then
            BCScache["auras"].haste = BCScache["auras"].haste + tonumber(value)
        end
    end

    local _, race = UnitRace("player")
    local haste = race == "NightElf" and 1 or 0
    haste = haste + BCScache["gear"].haste + BCScache["auras"].haste
    local spellHaste = BCScache["gear"].spell_haste + BCScache["auras"].spell_haste + BCScache["talents"].spell_haste

    return haste, spellHaste
end