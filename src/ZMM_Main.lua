-- ZMM_Main.lua
-- Hauptfenster + einfache Rotation-UI für Turtle WoW
-- Lua 5.1 / Vanilla-kompatibel

ZMM = ZMM or {}

-------------------------------------------------
-- Datenmodell
-------------------------------------------------

-- Eine Rotation ist eine Liste von Einträgen:
-- { spellName = "Holy Strike", conditionsText = "nur im Kampf", id = 1 }
ZMM.currentRotation = ZMM.currentRotation or {}
ZMM.nextEntryId = ZMM.nextEntryId or 1

ZMM.availableSpells = {}
for abilityName, texName in pairs(AbilityNamesToTexturesMapping) do
    table.insert(ZMM.availableSpells, {
        name = abilityName,
        icon = texName,
    })
end


-------------------------------------------------
-- Slashcommand
-------------------------------------------------

SLASH_ZMM1 = "/zmm"
SlashCmdList["ZMM"] = function()
    ZMM:ToggleMainFrame()
end

-------------------------------------------------
-- Utilities
-------------------------------------------------

local function deepcopyRotation(src)
    local dst = {}
    for i, v in ipairs(src) do
        dst[i] = {
            spellName = v.spellName,
            conditionsText = v.conditionsText,
            id = v.id,
        }
    end
    return dst
end

-------------------------------------------------
-- Public: Toggle
-------------------------------------------------

function ZMM:ToggleMainFrame()
    local f = self.mainFrame or self:CreateMainFrame()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        self:UpdateRotationList()
    end
end

-------------------------------------------------
-- MainFrame
-------------------------------------------------

function ZMM:CreateMainFrame()
    if self.mainFrame then return self.mainFrame end

    local f = CreateFrame("Frame", "ZMM_MainFrame", UIParent)
    f:SetWidth(700)
    f:SetHeight(450)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:Hide()

    -- Verschiebbar
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    -- Titel
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetText("Zasas Magic Macros")
    f.title = title

    local cancelBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    cancelBtn:SetWidth(22)
    cancelBtn:SetHeight(22)
    cancelBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)
    cancelBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    self:CreateHeader(f)
    self:CreateMacroNameArea(f)
    self:CreateRotationArea(f)
    self:CreateBottomButtons(f)

    self.mainFrame = f
    return f
end

-------------------------------------------------
-- Header: Klassenlabel + Buttons
-------------------------------------------------

function ZMM:CreateHeader(f)
    local className = UnitClass("player")

    local classLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -40)
    classLabel:SetText("Class: " .. (className or "?"))
    f.classLabel = classLabel

    -- Neu
    local btnNew = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnNew:SetWidth(70)
    btnNew:SetHeight(22)
    btnNew:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", 0, -4)
    btnNew:SetText("New")
    btnNew:SetScript("OnClick", function()
        ZMM:NewRotation()
    end)
    f.btnNew = btnNew

    -- Laden (Stub)
    local btnLoad = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnLoad:SetWidth(70)
    btnLoad:SetHeight(22)
    btnLoad:SetPoint("LEFT", btnNew, "RIGHT", 6, 0)
    btnLoad:SetText("Load")
    btnLoad:SetScript("OnClick", function()
        ZMM:ShowLoadNotImplemented()
    end)
    f.btnLoad = btnLoad

    -- Speichern (Stub)
    local btnSave = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnSave:SetWidth(80)
    btnSave:SetHeight(22)
    btnSave:SetPoint("LEFT", btnLoad, "RIGHT", 6, 0)
    btnSave:SetText("Save")
    btnSave:SetScript("OnClick", function()
        ZMM:ShowSaveNotImplemented()
    end)
    f.btnSave = btnSave
end

-------------------------------------------------
-- Makroname
-------------------------------------------------

function ZMM:CreateMacroNameArea(f)
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", f.btnNew, "BOTTOMLEFT", 0, -10)
    label:SetText("Macroname:")
    f.macroNameLabel = label

    local edit = CreateFrame("EditBox", "ZMM_MacroNameEdit", f, "InputBoxTemplate")
    edit:SetWidth(200)
    edit:SetHeight(20)
    edit:SetPoint("LEFT", label, "RIGHT", 8, 0)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(32)
    edit:SetText("ProtPala_Tank")
    f.macroNameEdit = edit
end

-------------------------------------------------
-- Rotation / Prioritätenliste
-------------------------------------------------

function ZMM:CreateRotationArea(f)
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f.macroNameLabel, "BOTTOMLEFT", 0, -14)
    title:SetText("Rotation / Prio list")
    f.rotationTitle = title

    local listFrame = CreateFrame("Frame", nil, f)
    listFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -4, -8)
    listFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 60)

    listFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f.rotationListFrame = listFrame

    -- Header-Zeile
    local header = CreateFrame("Frame", "Hoden", listFrame)
    header:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 4, -4)
    header:SetPoint("RIGHT", listFrame, "RIGHT", -4, 0)
    header:SetHeight(20)

    --local hBg = header:CreateTexture(nil, "BACKGROUND")
    --hBg:SetAllPoints(header)
    --hBg:SetTexture(0, 0, 0, 0.8)

    local colIndex = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    colIndex:SetPoint("LEFT", header, "LEFT", 8, 0)
    colIndex:SetText("#")

    local colSpell = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    colSpell:SetPoint("LEFT", colIndex, "RIGHT", 24, 0)
    colSpell:SetText("Spell")

    local colCond = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    colCond:SetPoint("LEFT", header, "LEFT", 260, 0)
    colCond:SetText("Conditions")

    --local colActions = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    --colActions:SetPoint("LEFT", header, "LEFT", 460, 0)
    --colActions:SetText("Aktionen")

    -- Scrollbarer Bereich für Einträge
    local scrollFrame = CreateFrame("ScrollFrame", "ZMM_RotationScrollFrame", listFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 4, -26)
    scrollFrame:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", -26, 4)

    local content = CreateFrame("Frame", "ZMM_RotationScrollChild", scrollFrame)
    content:SetWidth(listFrame:GetWidth() - 30)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)
    listFrame:SetScript("OnSizeChanged", function()
        if ZMM and ZMM.mainFrame and ZMM.mainFrame.rotationContent then
            ZMM.mainFrame.rotationContent:SetWidth(this:GetWidth() - 30)
        end
    end)


    f.rotationScrollFrame = scrollFrame
    f.rotationContent = content

    self:CreateRotationRows(content)
end

function ZMM:CreateRotationRows(parent)
    self.rotationRows = self.rotationRows or {}

    local rowHeight = 22
    local maxRows = 12

    for i = 1, maxRows do
        local row = CreateFrame("Frame", nil, parent)
        row:SetWidth(1) -- wird über Anker gestreckt
        row:SetHeight(rowHeight)

        if i == 1 then
            row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        else
            row:SetPoint("TOPLEFT", self.rotationRows[i - 1], "BOTTOMLEFT", 0, 0)
            row:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        end

        -- Hintergrund leicht alternierend
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(row)
        if (math.mod(i, 2) == 0) then
            bg:SetTexture(0, 0, 0, 0.2)
        else
            bg:SetTexture(0, 0, 0, 0.1)
        end
        row.bg = bg

        -- Index
        local indexText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        indexText:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.indexText = indexText

        -- Spellname
        local spellText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        spellText:SetPoint("LEFT", indexText, "RIGHT", 24, 0)
        spellText:SetWidth(180)
        spellText:SetJustifyH("LEFT")
        row.spellText = spellText

        -- Conditions-Button
        local condBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        condBtn:SetWidth(90)
        condBtn:SetHeight(18)
        condBtn:SetPoint("LEFT", row, "LEFT", 260, 0)
        condBtn:SetText("Conditions")
        condBtn:SetScript("OnClick", function()
            if row.entry then
                ZMM:OpenConditionEditor(row.entry)
            end
        end)
        row.condBtn = condBtn

        -- Up Button (^)
        local btnUp = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnUp:SetWidth(22)
        btnUp:SetHeight(22)
        btnUp:SetText("^")
        btnUp:ClearAllPoints()
        btnUp:SetPoint("LEFT", row, "LEFT", 460, 0)
        btnUp:SetScript("OnClick", function()
            if row.entryIndex then
                ZMM:MoveEntryUp(row.entryIndex)
            end
        end)
        row.btnUp = btnUp

        -- Down Button (v)
        local btnDown = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnDown:SetWidth(22)
        btnDown:SetHeight(22)
        btnDown:SetText("v")
        btnDown:ClearAllPoints()
        btnDown:SetPoint("LEFT", btnUp, "RIGHT", 4, 0)
        btnDown:SetScript("OnClick", function()
            if row.entryIndex then
                ZMM:MoveEntryDown(row.entryIndex)
            end
        end)
        row.btnDown = btnDown

        -- Delete Button (X)
        local btnDel = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnDel:SetWidth(22)
        btnDel:SetHeight(22)
        btnDel:SetText("X")
        btnDel:ClearAllPoints()
        btnDel:SetPoint("LEFT", btnDown, "RIGHT", 4, 0)
        btnDel:SetScript("OnClick", function()
            if row.entryIndex then
                ZMM:DeleteEntry(row.entryIndex)
            end
        end)
        row.btnDel = btnDel


        row:Hide()
        self.rotationRows[i] = row
    end
end

function ZMM:UpdateRotationList()
    if not self.mainFrame or not self.rotationRows then return end

    local rows = self.rotationRows
    local rotation = self.currentRotation

    for i, row in ipairs(rows) do
        local entry = rotation[i]
        if entry then
            row.entry = entry
            row.entryIndex = i
            row.indexText:SetText(i .. ".")
            row.spellText:SetText(entry.spellName or "<kein Spell>")
            row:Show()
        else
            row.entry = nil
            row.entryIndex = nil
            row:Hide()
        end
    end

    -- ScrollChild-Höhe anpassen
    local visibleCount = math.min(table.getn(rotation or {}), table.getn(rows or {}))
    local rowHeight = 22
    local totalHeight = visibleCount * rowHeight
    if totalHeight < rowHeight then
        totalHeight = rowHeight
    end
    self.mainFrame.rotationContent:SetHeight(totalHeight)
end

-------------------------------------------------
-- Bottom Buttons
-------------------------------------------------

function ZMM:CreateBottomButtons(f)
    local addSpellButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    addSpellButton:SetWidth(90)
    addSpellButton:SetHeight(24)
    addSpellButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 16)
    addSpellButton:SetText("Add spell")
    addSpellButton:SetScript("OnClick", function()
        ZMM:OpenAddSpellDialog()
    end)
    f.addSpellButton = addSpellButton

    local generateButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    generateButton:SetWidth(140)
    generateButton:SetHeight(24)
    generateButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 16)
    generateButton:SetText("Create macro")
    generateButton:SetScript("OnClick", function()
        local name = f.macroNameEdit:GetText()
        ZMM:GenerateMacro(name)
    end)
    f.generateButton = generateButton
end

-------------------------------------------------
-- Rotation-Manipulation
-------------------------------------------------

function ZMM:NewRotation()
    self.currentRotation = {}
    self.nextEntryId = 1
    self:UpdateRotationList()
end

function ZMM:AddEntry(spellName)
    if not spellName or spellName == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZMM:|r Kein Spellname angegeben.")
        return
    end
    local entry = {
        spellName = spellName,
        conditionsText = "",
        id = self.nextEntryId,
    }
    self.nextEntryId = self.nextEntryId + 1
    table.insert(self.currentRotation, entry)
    self:UpdateRotationList()
end

function ZMM:DeleteEntry(index)
    table.remove(self.currentRotation, index)
    self:UpdateRotationList()
end

function ZMM:MoveEntryUp(index)
    if index <= 1 then return end
    local rot = self.currentRotation
    rot[index], rot[index - 1] = rot[index - 1], rot[index]
    self:UpdateRotationList()
end

function ZMM:MoveEntryDown(index)
    local rot = self.currentRotation
    if index >= table.getn(rot) then return end
    rot[index], rot[index + 1] = rot[index + 1], rot[index]
    self:UpdateRotationList()
end

-------------------------------------------------
-- AddSpell-Dialog (einfacher Name-Input)
-------------------------------------------------

function ZMM:OpenAddSpellDialog()
    if self.addSpellFrame then
        self.addSpellFrame:Show()
        self.addSpellFrame.searchEdit:SetText("")
        ZMM:UpdateAddSpellList("") -- alle anzeigen
        return
    end

    local f = CreateFrame("Frame", "ZMM_AddSpellFrame", UIParent)
    f:SetWidth(320)
    f:SetHeight(260)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetFrameLevel(10)

    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })

    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", f, "TOP", 0, -20)
    title:SetText("Fähigkeit hinzufügen")

    -- Suchfeld
    local searchLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    searchLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -50)
    searchLabel:SetText("Suche:")

    local searchEdit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    searchEdit:SetHeight(20)
    searchEdit:SetPoint("LEFT", searchLabel, "RIGHT", 18, 0)
    searchEdit:SetPoint("RIGHT", f, "RIGHT", -22, 0)
    searchEdit:SetAutoFocus(false)
    searchEdit:SetScript("OnTextChanged", function()
        local txt = this:GetText() or ""
        ZMM:UpdateAddSpellList(txt)
    end)
    f.searchEdit = searchEdit

    -- Liste / „Dropdown-Body“
    local listFrame = CreateFrame("Frame", nil, f)
    listFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -82)
    listFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 46)
    listFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f.listFrame = listFrame

    -- Scrollchild für Rows
    local scrollFrame = CreateFrame("ScrollFrame", "ZMM_AddSpellScrollFrame", listFrame, "UIPanelScrollFrameTemplate")

    scrollFrame:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 4, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", -26, 4)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(50)
    content:SetHeight(50)
    scrollFrame:SetScrollChild(content)

    f.spellScrollFrame = scrollFrame
    f.spellContent = content

    self.addSpellRows = {}
    local rowHeight = 22
    local maxRows = 10

    for i = 1, maxRows do
        local row = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        row:SetHeight(rowHeight)
        row:SetNormalTexture(nil)
        row:SetPushedTexture(nil)

        if i == 1 then
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", scrollFrame, "RIGHT", 8, 0)
        else
            row:SetPoint("TOPLEFT", self.addSpellRows[i - 1], "BOTTOMLEFT", 0, 0)
            row:SetPoint("RIGHT", scrollFrame, "RIGHT", 8, 0)
        end

        -- Icon LINKS
        local icon = row:CreateTexture(nil, "OVERLAY")
        icon:SetWidth(18)
        icon:SetHeight(18)
        icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.icon = icon

        -- Text rechts daneben
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        text:SetJustifyH("LEFT")
        text:SetWidth(200)
        row.text = text

        row:SetScript("OnClick", function()
            if row.spellName then
                ZMM:AddEntry(row.spellName)
                --f:Hide()
            end
        end)

        row:Hide()
        self.addSpellRows[i] = row
    end

    local cancelBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    cancelBtn:SetWidth(22)
    cancelBtn:SetHeight(22)
    cancelBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)
    cancelBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    self.addSpellFrame = f
    ZMM:UpdateAddSpellList("")
end

function ZMM:UpdateAddSpellList(filterText)
    if not self.addSpellFrame or not self.addSpellRows then return end

    local rows = self.addSpellRows
    local spells = self.availableSpells or {}
    filterText = string.lower(filterText or "")

    local filtered = {}
    for i = 1, table.getn(spells) do
        local data = spells[i]
        local name = data.name
        if filterText == "" or string.find(string.lower(name), filterText, 1, true) then
            table.insert(filtered, data)
        end
    end

    local countRows = table.getn(rows)
    local countSpells = table.getn(filtered)

    for i = 1, countRows do
        local row = rows[i]
        local data = filtered[i] -- enthält { name = ..., icon = ... }

        if data then
            row.spellName = data.name
            row.text:SetText(data.name)

            if data.icon and row.icon then
                row.icon:SetTexture("Interface\\Icons\\" .. data.icon)
                row.icon:Show()
            end

            row:Show()
        else
            row.spellName = nil
            row.text:SetText("")

            if row.icon then
                row.icon:Hide()
            end

            row:Hide()
        end
    end

    local rowHeight = 18
    local visibleCount = countSpells
    if visibleCount > countRows then
        visibleCount = countRows
    end
    if visibleCount < 1 then visibleCount = 1 end
    self.addSpellFrame.spellContent:SetHeight(visibleCount * rowHeight)
end

-------------------------------------------------
-- Condition-Editor (freier Text)
-------------------------------------------------

function ZMM:OpenConditionEditor(entry)
    if not entry then return end

    if not self.conditionFrame then
        local f = CreateFrame("Frame", "ZMM_ConditionFrame", UIParent)
        f:SetWidth(400)
        f:SetHeight(220)
        f:SetPoint("CENTER", UIParent, "CENTER", 20, 20)

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })

        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function()
            this:StartMoving()
        end)
        f:SetScript("OnDragStop", function()
            this:StopMovingOrSizing()
        end)

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", f, "TOP", 0, -10)
        title:SetText("Edit condition")
        f.title = title

        local info = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        info:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -32)
        info:SetText("Freitext-Beschreibung der Bedingungen:")

        local edit = CreateFrame("EditBox", nil, f)
        edit:SetMultiLine(true)
        edit:SetWidth(360)
        edit:SetHeight(110)
        edit:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -8)
        edit:SetAutoFocus(false)
        edit:SetFontObject("GameFontHighlightSmall")
        edit:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        edit:SetBackdropColor(0, 0, 0, 0.8)
        edit:SetScript("OnEscapePressed", function()
            this:ClearFocus()
        end)
        f.editBox = edit

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", edit, "TOPLEFT", 0, 0)
        scroll:SetPoint("BOTTOMRIGHT", edit, "BOTTOMRIGHT", 0, 0)
        scroll:SetScrollChild(edit)
        f.scrollFrame = scroll

        local okBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        okBtn:SetWidth(80)
        okBtn:SetHeight(22)
        okBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 12)
        okBtn:SetText("OK")
        okBtn:SetScript("OnClick", function()
            if f.currentEntry then
                f.currentEntry.conditionsText = f.editBox:GetText() or ""
                ZMM:UpdateRotationList()
            end
            f:Hide()
        end)

        local cancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        cancelBtn:SetWidth(80)
        cancelBtn:SetHeight(22)
        cancelBtn:SetPoint("RIGHT", okBtn, "LEFT", -8, 0)
        cancelBtn:SetText("Abbrechen")
        cancelBtn:SetScript("OnClick", function()
            f:Hide()
        end)

        self.conditionFrame = f
    end

    local f = self.conditionFrame
    f.currentEntry = entry
    f.title:SetText("Bedingungen für: " .. (entry.spellName or "?"))
    f.editBox:SetText(entry.conditionsText or "")
    f:Show()
end

-------------------------------------------------
-- Stub-Funktionen für Laden/Speichern/Makro/Test
-------------------------------------------------

function ZMM:ShowLoadNotImplemented()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZMM:|r Laden noch nicht implementiert.")
end

function ZMM:ShowSaveNotImplemented()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZMM:|r Speichern noch nicht implementiert.")
end

function ZMM:GenerateMacro(name)
    name = name or "ZMM_Rotation"
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZMM:|r Makro '" .. name ..
        "' noch nicht wirklich generiert. Benutze z.B.:")
    DEFAULT_CHAT_FRAME:AddMessage("/script ZMM_ExecuteRotation()")
end

function ZMM:TestCurrentRotation()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZMM:|r Test der aktuellen Rotation:")
    for i, entry in ipairs(self.currentRotation) do
        DEFAULT_CHAT_FRAME:AddMessage(i .. ". " .. (entry.spellName or "?") ..
            "  |cffaaaaaa(" .. (entry.conditionsText or "") .. ")|r")
    end
end

-------------------------------------------------
-- Beispiel Executor (für eigenes Makro nutzbar)
-------------------------------------------------

function ZMM_ExecuteRotation()
    if not ZMM or not ZMM.currentRotation then return end

    -- Sehr einfache Demo: nur den ersten Eintrag casten, wenn vorhanden
    local entry = ZMM.currentRotation[1]
    if entry and entry.spellName and entry.spellName ~= "" then
        CastSpellByName(entry.spellName)
    end
end
