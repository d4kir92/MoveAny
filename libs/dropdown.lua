
local AddOnName, MoveAny = ...

--[[local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function MoveAny:CreateDropdown( opts )
	local CB = LibDD:Create_UIDropDownMenu( opts.name, opts.parent )
	LibDD:UIDropDownMenu_SetWidth( CB, 120 )
	LibDD:UIDropDownMenu_SetText( CB, opts.defaultVal )
	LibDD:UIDropDownMenu_Initialize( CB, function( self, level, menuList )
		local tab = {}
		for i, v in pairs( opts.items ) do
			local info = LibDD:UIDropDownMenu_CreateInfo()
			info.func = self.SetValue
			info.text = v
			info.arg1 = v
			LibDD:UIDropDownMenu_AddButton(info)
		end
	end)
	function CB:SetValue( newValue )
		opts.changeFunc( CB, newValue )
		LibDD:UIDropDownMenu_SetText( CB, newValue )
		CloseDropDownMenus()
	end
	CB:SetPoint("TOPLEFT", 0, -4)
	
	local text = CB:CreateFontString(nil, "ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
	text:SetPoint("LEFT", CB, "RIGHT", 0, 4)
	text:SetText( MoveAny:GT(opts.title) )

    return CB
end]]

function MoveAny:CreateDropdown( opts )
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = MoveAny:GT( opts['title'] ) or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	local dd_title = dropdown:CreateFontString(dropdown_name, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end
