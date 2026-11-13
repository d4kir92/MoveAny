local _, D4 = ...
local UI = D4.UI

local function GetSettingID(element, since)
    if not element.settingLabel or element.isCategory or element.hidden or element.whatsNew == false then return end
    local added = element.added
    if type(added) == "number" then added = date("%Y-%m-%d", added) end
    if type(added) ~= "string" or not added:match("^%d%d%d%d%-%d%d%-%d%d$") or since and added < since then return end

    local id = tostring(element.added) .. ":" .. element.settingLabel
    if element.frame and element.frame.slider and element.keywords and element.keywords ~= "" then id = id .. ":" .. element.keywords end
    local category = element.category
    while category do
        if category.hidden then return end
        id = (category.settingLabel or category.key) .. ":" .. id
        category = category.category
    end

    return id
end

local function GetCategories(element)
    local list = {}
    local category = element.category
    while category do
        table.insert(list, 1, category)
        category = category.category
    end

    return list
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
                    if row.control.UpdateLabel then row.control:UpdateLabel() end
                elseif row.category then
                    local text = UI:Text(row.category.settingLabel)
                    row.header.Label:SetText(text)
                    UI:SetLabel(row.element, text)
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

    local function AddHeader(category, id)
        local header = win:AddCategory({label = category.settingLabel, key = id, added = category.added, level = category.level})
        win.category = nil
        win.categoryStack = {}
        return {category = category, header = header, element = header.element}
    end

    local function AddCheckboxRow(setting)
        local source, options = setting.checkbox, setting.setting
        local control = win:AddCheckbox({
            label = options.label,
            added = options.added,
            textFunc = options.textFunc,
            tooltip = options.tooltip,
            value = source:GetChecked(),
            func = function(value)
                source:SetChecked(value)
                if options.func then options.func(value, source) end
            end
        })
        return {control = control, source = source, element = control.uiElement}
    end

    local function AddSliderRow(setting)
        local source, options = setting.frame, setting.setting
        local control = win:AddSlider({
            label = options.label,
            added = options.added,
            min = options.min,
            max = options.max,
            step = options.step,
            decimals = options.decimals,
            commitOnRelease = options.commitOnRelease,
            value = source.value,
            func = function(value)
                if source.value ~= value then source.slider:SetValue(value) end
            end
        })
        return {control = control, sliderSource = source, element = control.uiElement}
    end

    local function AddRow(setting)
        if setting.whatsNewControl then
            local control = setting.whatsNewControl(win)
            return {control = control, element = control.uiElement}
        end

        if setting.checkbox and setting.setting then return AddCheckboxRow(setting) end
        if setting.frame and setting.frame.slider and setting.setting then return AddSliderRow(setting) end

        local holder = CreateFrame("Frame", nil, win.content)
        local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", holder, "TOPLEFT", 4, -3)
        local body = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        body:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        body:SetWidth(win.contentWidth - 16)
        body:SetJustifyH("LEFT")
        holder.Label = label
        return {label = label, text = body, element = UI:Add(win, holder, UI.ROW, nil, true, nil, setting.added)}
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
            win = D4:CreateUIWindow({name = tab.name, title = tab.title, width = 520, height = 500, resizable = false})
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

        local order, shown = 0, {}
        local function Place(id, row, depth, parent)
            rows[id] = row
            order = order + 1
            row.element.hidden = false
            row.element.noticeOrder = order
            row.element.depth = depth
            row.element.category = parent
        end

        for _, entry in ipairs(entries) do
            local path, parent = "", nil
            local categories = GetCategories(entry.setting)
            for depth, category in ipairs(categories) do
                path = path .. ":" .. (category.settingLabel or category.key or "")
                local headerID = "category" .. path
                local header = rows[headerID] or AddHeader(category, headerID)
                if not shown[headerID] then
                    shown[headerID] = true
                    Place(headerID, header, depth - 1, parent)
                end
                parent = header.element
            end

            local row = rows[entry.id] or AddRow(entry.setting)
            row.setting = entry.setting
            if row.source then row.control:SetChecked(row.source:GetChecked()) end
            if row.sliderSource then row.control.slider:SetValue(row.sliderSource.value) end
            Place(entry.id, row, #categories, parent)
        end
        table.sort(win.elements, function(left, right) return (left.noticeOrder or math.huge) < (right.noticeOrder or math.huge) end)

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
