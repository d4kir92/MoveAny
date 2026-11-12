local _, D4 = ...
local UI = D4.UI

local function GetSettingID(element, since)
    if not element.settingLabel or element.isCategory or element.hidden or element.whatsNew == false then return end
    local added = element.added
    if type(added) == "number" then added = date("%Y-%m-%d", added) end
    if type(added) ~= "string" or not added:match("^%d%d%d%d%-%d%d%-%d%d$") or since and added < since then return end

    local id = tostring(element.added) .. ":" .. element.settingLabel
    local category = element.category
    while category do
        if category.hidden then return end
        id = (category.settingLabel or category.key) .. ":" .. id
        category = category.category
    end

    return id
end

function D4:CreateUIWhatsNew(tab)
    local db = tab.db
    db.seen = db.seen or {}
    local notice = {}
    local win, heading, hideButton, settingsCheckbox, refreshLanguageButton
    local rows = {}

    function notice:RefreshLanguage()
        if not win then return end
        heading:SetText(UI:Text("LID_WHATSNEW"))
        hideButton:SetText(UI:Text("LID_HIDEWHATSNEW"))
        for _, row in pairs(rows) do
            if not row.element.hidden then
                if row.control then
                    row.control:UpdateLabel()
                else
                    local setting = row.setting
                    row.label:SetText(UI:Text(setting.settingLabel))
                    row.text:SetText(UI:Text(setting.whatsNew))
                    row.element.height = row.label:GetStringHeight() + 6
                    if setting.whatsNew then row.element.height = row.element.height + row.text:GetStringHeight() + 4 end
                    row.element.frame:SetHeight(row.element.height)
                end
            end
        end

        if refreshLanguageButton then refreshLanguageButton() end
        win:Layout()
    end

    local function AddRow(setting)
        if setting.whatsNewControl then
            local control = setting.whatsNewControl(win)
            return {control = control, element = control.uiElement}
        end

        local holder = CreateFrame("Frame", nil, win.content)
        local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", holder, "TOPLEFT", 4, -3)
        local body = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        body:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        body:SetWidth(win.contentWidth - 16)
        body:SetJustifyH("LEFT")
        return {label = label, text = body, element = UI:Add(win, holder, UI.ROW, nil, true)}
    end

    local function Show(onlyNew)
        if db.enabled == false then return end
        local settings = tab.getSettings()
        local entries = {}
        for _, setting in ipairs(settings.elements) do
            local id = GetSettingID(setting, tab.since)
            if id and (not onlyNew or not db.seen[id]) then
                entries[#entries + 1] = {id = id, setting = setting}
            end
        end
        if #entries == 0 then return end

        if not win then
            win = D4:CreateUIWindow({name = tab.name, title = tab.title, width = 520, height = 250, resizable = false})
            if tab.addLanguageButton then refreshLanguageButton = tab.addLanguageButton(win) end
            local header = win:AddHeader()
            heading = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            heading:SetPoint("LEFT", header, "LEFT", 8, 0)

            local footer = win:AddFooter()
            hideButton = D4:CreateButton(win:GetName() .. "Hide", footer)
            hideButton:SetSize(300, UI.ROW)
            hideButton:SetPoint("CENTER", footer, "CENTER")
            hideButton:SetScript("OnClick", function()
                db.enabled = false
                if settingsCheckbox then settingsCheckbox:SetChecked(false) end
                win:Hide()
            end)
        end

        for _, row in pairs(rows) do
            row.element.hidden = true
            row.element.noticeOrder = math.huge
        end
        for index, entry in ipairs(entries) do
            local row = rows[entry.id] or AddRow(entry.setting)
            rows[entry.id] = row
            row.setting = entry.setting
            row.element.hidden = false
            row.element.noticeOrder = index
        end
        table.sort(win.elements, function(left, right) return left.noticeOrder < right.noticeOrder end)

        win:Show()
        notice:RefreshLanguage()
        win:Raise()
        for _, entry in ipairs(entries) do
            db.seen[entry.id] = true
        end
    end

    function notice:ShowIfNew()
        Show(true)
    end

    function notice:AddSettingsCheckbox(settings, added)
        settingsCheckbox = settings:AddCheckbox({
            label = "LID_SHOWWHATSNEW",
            added = added,
            whatsNew = false,
            value = db.enabled ~= false,
            func = function(value)
                db.enabled = value
                if value then
                    Show(false)
                elseif win then
                    win:Hide()
                end
            end
        })
        return settingsCheckbox
    end

    return notice
end
