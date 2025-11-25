-- ZasasMagicMacros Macro Builder
ZMM_Macros = {
    {
        name = "ZMM_Prot",
        icon = 41,
        body = "/run Paladin:OneButtonProtection()",
    },
    {
        name = "ZMM_ProtAoE",
        icon = 63,
        body = "/run Paladin:OneButtonProtectionAoE()",
    },
    {
        name = "ZMM_SoR",
        icon = 15,
        body = "/run Paladin:SealOfRighteousness()",
    },
    {
        name = "ZMM_SoW",
        icon = 54,
        body = "/run Paladin:SealOfWisdom()",
    },
    {
        name = "ZMM_SCS",
        icon = 105,
        body = "/run Paladin:SmartCrusaderStrike()",
    },
}

ZMM_Build = ZMM_Build or {}
local builder = ZMM_Build

local pendingCreate = false



function builder:GetFreeMacroSlots()
    local numGlobal, numChar = GetNumMacros()
    local freeGlobal = 18 - numGlobal
    local freeChar   = 18 - numChar
    return freeGlobal, freeChar
end

function builder:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[ZMM]|r " .. tostring(msg))
end

function builder:AskCreateMacros()
    local needed = table.getn(ZMM_Macros)
    local freeGlobal, freeChar = self:GetFreeMacroSlots()

    self:Print("Ich würde " .. needed .. " Makros anlegen.")
    self:Print("Freie Global-Slots: " .. freeGlobal .. " / Freie Char-Slots: " .. freeChar)

    if freeGlobal + freeChar < needed then
        self:Print("Du hast nicht genug freie Macro-Slots. Bitte lösche etwas.")
        pendingCreate = false
        return
    end

    self:Print("Wenn das okay ist, tippe: /zmmcreatemacros")
    pendingCreate = true
end

function builder:CreateMacros()
    if not pendingCreate then
        self:Print("Bitte zuerst /zmmbuild benutzen, um zu bestätigen.")
        return
    end

    local freeGlobal, freeChar = self:GetFreeMacroSlots()
    local usePerChar = 1

    for _, m in ipairs(ZMM_Macros) do
        local id = GetMacroIndexByName(m.name)
        if id == 0 then
            local icon = m.icon or "INV_Misc_QuestionMark"
            CreateMacro(m.name, m.icon, m.body, 1, 1)
        else
            EditMacro(id, nil, m.icon or nil, m.body, 1, 1)
        end
    end

    self:Print("Makros wurden erstellt / aktualisiert.")
    pendingCreate = false
end

SLASH_ZMMBUILD1 = "/zmmbuild"
SlashCmdList["ZMMBUILD"] = function(msg)
    if builder:AskCreateMacros() then
        builder:AskCreateMacros()
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[ZMM]|r Build-Modul nicht geladen.")
    end
end

SLASH_ZMMCREATEMACROS1 = "/zmmcreatemacros"
SlashCmdList["ZMMCREATEMACROS"] = function(msg)
    if builder:CreateMacros() then
        builder:CreateMacros()
    end
end