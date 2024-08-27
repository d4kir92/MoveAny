local _, MoveAny = ...
local MAEF = {}
local MACurrentEle = nil
function MoveAny:GetCurrentEle()
	return MACurrentEle
end

function MoveAny:GetEleFrames()
	return MAEF
end

local MAAF = {}
function MoveAny:GetAlphaFrames()
	return MAAF
end

local fnt = {}
function MoveAny:AddFrameName(frame, name)
	if frame == nil then
		MoveAny:MSG("AddFrameName: frame is nil")

		return false
	end

	if name == nil then
		MoveAny:MSG("AddFrameName: name is nil")

		return false
	end

	fnt[frame] = name

	return true
end

function MoveAny:GetFrameName(frame)
	if frame == nil then
		MoveAny:MSG("GetFrameName: frame is nil")

		return "FAILED"
	end

	return fnt[frame]
end

local framelevel = 1100
local function SelectTab(sel)
	PanelTemplates_SetTab(sel:GetParent(), sel:GetID())
	local content = sel:GetParent().currentcontent
	if content then
		content:Hide()
	end

	sel:GetParent().currentcontent = sel.content
	sel.content:Show()
end

local function CreateTabs(frame, args)
	frame.numTabs = #args
	frame.tabs = {}
	local sw, sh = frame:GetSize()
	for i = 1, frame.numTabs do
		local template = "CharacterFrameTabButtonTemplate"
		if MoveAny:GetWoWBuild() == "RETAIL" then
			template = "PanelTabButtonTemplate"
		end

		frame.tabs[i] = CreateFrame("Button", frame:GetName() .. "Tab" .. i, frame, template)
		local tab = frame.tabs[i]
		tab:SetID(i)
		tab:SetText(args[i])
		tab:SetScript(
			"OnClick",
			function(sel)
				SelectTab(sel)
			end
		)

		tab.content = CreateFrame("Frame", frame:GetName() .. "Tab" .. i .. "Content", frame)
		tab.content.name = args[i]
		tab.content:SetSize(sw - 12, sh - 26 - 6)
		tab.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -26)
		tab.content:Hide()
		PanelTemplates_TabResize(tab, 0)
		if i == 1 then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 2)
		else
			tab:SetPoint("TOPLEFT", _G[frame:GetName() .. "Tab" .. (i - 1)], "TOPRIGHT", 4, 0)
		end
	end

	SelectTab(frame.tabs[1])

	return frame.tabs
end

local btnsize = 24
local function MAMoveButton(parent, name, ofsx, ofsy, x, y, texNor, texPus)
	local btn = CreateFrame("Button", "MOVE" .. x .. y, parent)
	btn:SetNormalTexture(texNor)
	btn:SetPushedTexture(texPus)
	btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
	btn:SetSize(btnsize, btnsize)
	btn:SetPoint("TOPLEFT", parent, "TOPLEFT", ofsx, ofsy)
	btn:SetScript(
		"OnClick",
		function()
			local p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
			if p1 and p3 and p4 and p5 then
				MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 + x, p5 + y)
			end

			p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
			parent.pos:SetText(format("Position X: %d Y:%d", p4, p5))
		end
	)

	return btn
end

function MoveAny:CreateSlider(parent, x, y, name, key, value, steps, vmin, vmax, func, lanArray)
	local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	slider:SetWidth(parent:GetWidth() - 20 - x)
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	slider.Low:SetText(vmin)
	slider.High:SetText(vmax)
	if lanArray then
		slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. lanArray[MoveAny:GetEleOption(name, key, value)])
	else
		slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. MoveAny:GetEleOption(name, key, value))
	end

	slider:SetMinMaxValues(vmin, vmax)
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(steps)
	slider:SetValue(MoveAny:GetEleOption(name, key, value, "Slider1"))
	slider:SetScript(
		"OnValueChanged",
		function(sel, val)
			val = tonumber(string.format("%" .. steps .. "f", val))
			if val then
				MoveAny:SetEleOption(name, key, val)
				if lanArray then
					slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. lanArray[val])
				else
					slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. val)
				end

				if func then
					func()
				end
			end
		end
	)

	return slider
end

function MoveAny:MenuOptions(opt, frame)
	if frame == nil then
		MoveAny:MSG("FRAME NOT FOUND")

		return
	end

	local name = MoveAny:GetFrameName(frame)
	local opts = MoveAny:GetEleOptions(name, "MenuOptions")
	local tabs = {GENERAL}
	if string.find(name, "MAActionBar") or string.find(name, "MultiBar") or name == "MainMenuBar" or name == "MAMenuBar" or name == "PetActionBar" or name == "MAPetBar" or name == "StanceBar" then
		table.insert(tabs, ACTIONBARS_LABEL)
	end

	if string.find(name, "MABuffBar") then
		table.insert(tabs, MoveAny:GT("LID_BUFFS"))
	end

	if string.find(name, "MADebuffBar") then
		table.insert(tabs, MoveAny:GT("LID_DEBUFFS"))
	end

	if string.find(name, "MainMenuExpBar") then
		table.insert(tabs, MoveAny:GT("LID_MAINMENUEXPBAR"))
	end

	if string.find(name, "ReputationWatchBar") then
		table.insert(tabs, MoveAny:GT("LID_REPUTATIONWATCHBAR"))
	end

	CreateTabs(opt, tabs)
	for i, tab in pairs(opt.tabs) do
		local content = tab.content
		if string.find(content.name, GENERAL) then
			content.pos = content:CreateFontString(nil, nil, "GameFontNormal")
			content.pos:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
			local _, _, _, p4, p5 = MoveAny:GetElePoint(name)
			content.pos:SetText(format("Position X: %d Y:%d", p4, p5))
			MAMoveButton(content, name, btnsize * 2, -btnsize * 1, 0, 5, "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			MAMoveButton(content, name, btnsize * 2, -btnsize * 2, 0, 1, "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			MAMoveButton(content, name, btnsize * 2, -btnsize * 4, 0, -1, "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			MAMoveButton(content, name, btnsize * 2, -btnsize * 5, 0, -5, "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up", "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			MAMoveButton(content, name, 0, -btnsize * 3, -5, 0, "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
			MAMoveButton(content, name, btnsize * 1, -btnsize * 3, -1, 0, "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
			MAMoveButton(content, name, btnsize * 3, -btnsize * 3, 1, 0, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			MAMoveButton(content, name, btnsize * 4, -btnsize * 3, 5, 0, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			content.scale = content:CreateFontString(nil, nil, "GameFontNormal")
			content.scale:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -4)
			local scale = MoveAny:GetEleScale(name) or 1
			content.scale:SetText(format("Scale: %0.1f", scale))
			local sup = CreateFrame("Button", "sup", content)
			sup:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
			sup:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			sup:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sup:SetSize(btnsize, btnsize)
			sup:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -24)
			sup:SetScript(
				"OnClick",
				function()
					local val = tonumber(string.format("%.1f", frame:GetScale() + 0.1))
					MoveAny:SetEleScale(name, val)
					content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
				end
			)

			local sup2 = CreateFrame("Button", "sup2", content)
			sup2:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
			sup2:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			sup2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sup2:SetSize(btnsize, btnsize)
			sup2:SetPoint("TOPLEFT", content, "TOPLEFT", 220, -24)
			sup2:SetScript(
				"OnClick",
				function()
					local val = tonumber(string.format("%.2f", frame:GetScale() + 0.01))
					MoveAny:SetEleScale(name, val)
					content.scale:SetText(format("Scale: %0.2f", MoveAny:GetEleScale(name)))
				end
			)

			local sdn = CreateFrame("Button", "sdn", content)
			sdn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			sdn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			sdn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sdn:SetSize(btnsize, btnsize)
			sdn:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -48)
			sdn:SetScript(
				"OnClick",
				function()
					if frame:GetScale() > 0.2 then
						local val = tonumber(string.format("%.1f", frame:GetScale() - 0.1))
						MoveAny:SetEleScale(name, val)
						content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
					end
				end
			)

			local sdn2 = CreateFrame("Button", "sdn2", content)
			sdn2:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			sdn2:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			sdn2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sdn2:SetSize(btnsize, btnsize)
			sdn2:SetPoint("TOPLEFT", content, "TOPLEFT", 220, -48)
			sdn2:SetScript(
				"OnClick",
				function()
					if frame:GetScale() > 0.2 then
						local val = tonumber(string.format("%.2f", frame:GetScale() - 0.01))
						MoveAny:SetEleScale(name, val)
						content.scale:SetText(format("Scale: %0.2f", MoveAny:GetEleScale(name)))
					end
				end
			)

			local resetDB = CreateFrame("Button", "resetdb", content, "UIPanelButtonTemplate")
			resetDB:SetText(MoveAny:GT("LID_RESETELEMENT"))
			resetDB:SetSize(btnsize * 6, btnsize)
			resetDB:SetPoint("TOPLEFT", content, "TOPLEFT", 300, -8)
			resetDB:SetScript(
				"OnClick",
				function()
					MoveAny:ResetElement(name)
					MoveAny:TrySaveEditMode()
					C_UI.Reload()
				end
			)

			local hide = CreateFrame("CheckButton", "hide", content, "ChatConfigCheckButtonTemplate")
			hide:SetSize(btnsize, btnsize)
			hide:SetPoint("TOPLEFT", content, "TOPLEFT", 150, -110)
			hide:SetChecked(MoveAny:GetEleOption(name, "Hide", false, "Hide1"))
			hide:SetText(HIDE)
			hide:SetScript(
				"OnClick",
				function()
					local checked = hide:GetChecked()
					MoveAny:SetEleOption(name, "Hide", checked)
					local maframe1 = _G["MA" .. name]
					local maframe2 = _G[string.gsub(name, "MA", "")]
					local dragf = _G[name .. "_MA_DRAG"]
					if checked then
						frame.oldparent = frame.oldparent or frame:GetParent()
						frame:SetParent(MAHIDDEN)
						if maframe1 then
							maframe1.oldparent = maframe1.oldparent or maframe1:GetParent()
							maframe1:SetParent(MAHIDDEN)
						end

						if maframe2 then
							maframe2.oldparent = maframe2.oldparent or maframe2:GetParent()
							maframe2:SetParent(MAHIDDEN)
						end

						dragf.t:SetVertexColor(MoveAny:GetColor("hidden"))
						if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
							dragf:Hide()
						else
							dragf:Show()
						end
					else
						frame:SetParent(frame.oldparent)
						if maframe1 then
							maframe1:SetParent(maframe1.oldparent)
						end

						if maframe2 then
							maframe2:SetParent(maframe2.oldparent)
						end

						if MACurrentEle == frame then
							dragf.t:SetVertexColor(MoveAny:GetColor("se"))
						else
							dragf.t:SetVertexColor(MoveAny:GetColor("el"))
						end
					end
				end
			)

			hide.text = hide:CreateFontString(nil, "ARTWORK")
			hide.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
			hide.text:SetPoint("LEFT", hide, "RIGHT", 0, 0)
			hide.text:SetText(getglobal("HIDE"))
			local clickthrough = CreateFrame("CheckButton", "clickthrough", content, "ChatConfigCheckButtonTemplate")
			clickthrough:SetSize(btnsize, btnsize)
			clickthrough:SetPoint("TOPLEFT", content, "TOPLEFT", 150, -140)
			clickthrough:SetChecked(MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough1"))
			clickthrough:SetText(MoveAny:GT("LID_CLICKTHROUGH"))
			clickthrough:SetScript(
				"OnClick",
				function()
					local checked = clickthrough:GetChecked()
					MoveAny:SetEleOption(name, "ClickThrough", checked)
					local dragf = _G[name .. "_MA_DRAG"]
					if checked then
						if frame then
							dragf:Show()
							dragf.t:SetVertexColor(MoveAny:GetColor("clickthrough"))
							frame:EnableMouse(false)
						else
							dragf:Hide()
						end
					else
						if frame then
							dragf.t:SetVertexColor(MoveAny:GetColor("el"))
							frame:EnableMouse(true)
						else
							dragf:Hide()
						end
					end
				end
			)

			clickthrough.text = clickthrough:CreateFontString(nil, "ARTWORK")
			clickthrough.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
			clickthrough.text:SetPoint("LEFT", clickthrough, "RIGHT", 0, 0)
			clickthrough.text:SetText(MoveAny:GT("LID_CLICKTHROUGH"))
			local fullhp = CreateFrame("CheckButton", "FULLHPENABLED", content, "ChatConfigCheckButtonTemplate")
			fullhp:SetSize(btnsize, btnsize)
			fullhp:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -220)
			fullhp:SetChecked(MoveAny:GetEleOption(name, "FULLHPENABLED", false, "fullhp1"))
			fullhp:SetScript(
				"OnClick",
				function()
					local checked = fullhp:GetChecked()
					MoveAny:SetEleOption(name, "FULLHPENABLED", checked)
				end
			)

			local space = -30
			local Y = -190
			MoveAny:CreateSlider(content, 10, Y, name, "ALPHAINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			MoveAny:CreateSlider(content, 30, Y, name, "ALPHAISFULLHEALTH", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			MoveAny:CreateSlider(content, 10, Y, name, "ALPHAINVEHICLE", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			MoveAny:CreateSlider(content, 10, Y, name, "ALPHAISMOUNTED", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			MoveAny:CreateSlider(content, 10, Y, name, "ALPHAINRESTEDAREA", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			MoveAny:CreateSlider(content, 10, Y, name, "ALPHAISSTEALTHED", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			Y = Y + space
			if C_PetBattles then
				MoveAny:CreateSlider(content, 10, Y, name, "ALPHAISINPETBATTLE", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
				Y = Y + space
			end

			MoveAny:CreateSlider(content, 10, Y, name, "ALPHANOTINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
		elseif string.find(content.name, ACTIONBARS_LABEL) then
			local slides = {}
			local items = {}
			local function UpdateRowItems()
				if frame.btns then
					local maxBtns = getn(frame.btns)
					if frame ~= MAMenuBar and frame ~= StanceBar and opts["COUNT"] and opts["COUNT"] > 0 then
						maxBtns = opts["COUNT"]
					end

					items = {}
					for id = 1, maxBtns do
						tinsert(items, id)
					end
				end
			end

			UpdateRowItems()
			local vmin = 1
			if frame == MAActionBar1 or frame == MainMenuBar then
				vmin = 6
			end

			local max = 1
			if frame.btns then
				max = getn(frame.btns)
			else
				max = 1
			end

			local count = opts["COUNT"] or max
			local rows = opts["ROWS"] or 1
			local offset = opts["OFFSET"] or 0
			local PY = -20
			if frame ~= MAMenuBar and frame ~= StanceBar then
				slides.sliderCount = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				local sliderCount = slides.sliderCount
				sliderCount:SetWidth(content:GetWidth() - 110)
				sliderCount:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				sliderCount.Low:SetText("")
				sliderCount.High:SetText("")
				sliderCount.Text:SetText(MoveAny:GT("LID_COUNT") .. ": " .. count)
				sliderCount:SetMinMaxValues(vmin, max)
				sliderCount:SetObeyStepOnDrag(true)
				sliderCount:SetValueStep(1)
				sliderCount:SetValue(count)
				sliderCount:SetScript(
					"OnValueChanged",
					function(sel, val)
						val = tonumber(string.format("%" .. 0 .. "f", val))
						if val and val ~= opts["ROWS"] then
							opts["COUNT"] = val
							sel.Text:SetText(MoveAny:GT("LID_COUNT") .. ": " .. val)
							UpdateRowItems()
							if slides.sliderRows then
								slides.sliderRows:SetMinMaxValues(1, #items)
								slides.sliderRows:SetValue(slides.sliderRows:GetValue())
							end

							if MoveAny.UpdateActionBar then
								MoveAny:UpdateActionBar(frame)
							end
						end
					end
				)

				PY = PY - 30
			end

			if #items >= 1 then
				slides.sliderRows = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				local sliderRows = slides.sliderRows
				sliderRows:SetWidth(content:GetWidth() - 110)
				sliderRows:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				sliderRows.Low:SetText("")
				sliderRows.High:SetText("")
				sliderRows.Text:SetText(MoveAny:GT("LID_ROWS") .. ": " .. rows)
				sliderRows:SetMinMaxValues(1, getn(items))
				sliderRows:SetObeyStepOnDrag(true)
				sliderRows:SetValueStep(1)
				sliderRows:SetValue(rows)
				sliderRows:SetScript(
					"OnValueChanged",
					function(sel, val)
						val = tonumber(string.format("%" .. 0 .. "f", val))
						local value = items[val]
						if value and value ~= opts["ROWS"] then
							opts["ROWS"] = value
							sel.Text:SetText(MoveAny:GT("LID_ROWS") .. ": " .. value)
							if frame.UpdateSystemSettingNumRows then
								frame.numRows = value
								frame:UpdateSystemSettingNumRows()
							end

							if MoveAny.UpdateActionBar then
								MoveAny:UpdateActionBar(frame)
							end
						end
					end
				)

				PY = PY - 30
			end

			slides.offset = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			local sliderOffset = slides.offset
			sliderOffset:SetWidth(content:GetWidth() - 110)
			sliderOffset:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
			sliderOffset.Low:SetText(-4)
			sliderOffset.High:SetText(8)
			sliderOffset.Text:SetText(MoveAny:GT("LID_OFFSET") .. ": " .. offset)
			sliderOffset:SetMinMaxValues(-4, 8)
			sliderOffset:SetObeyStepOnDrag(true)
			sliderOffset:SetValueStep(1)
			sliderOffset:SetValue(offset)
			sliderOffset:SetScript(
				"OnValueChanged",
				function(sel, value)
					val = tonumber(string.format("%" .. 0 .. "f", value))
					if value and value ~= opts["OFFSET"] then
						opts["OFFSET"] = value
						sel.Text:SetText(MoveAny:GT("LID_OFFSET") .. ": " .. value)
						if MoveAny.UpdateActionBar then
							MoveAny:UpdateActionBar(frame)
						end
					end
				end
			)

			PY = PY - 30
			local flipped = CreateFrame("CheckButton", "flipped", content, "ChatConfigCheckButtonTemplate")
			flipped:SetSize(btnsize, btnsize)
			flipped:SetPoint("TOPLEFT", content, "TOPLEFT", 4, PY)
			flipped:SetChecked(MoveAny:GetEleOption(name, "FLIPPED", false, "Flipped1"))
			flipped:SetText(MoveAny:GT("LID_FLIPPED"))
			flipped:SetScript(
				"OnClick",
				function()
					local checked = flipped:GetChecked()
					MoveAny:SetEleOption(name, "FLIPPED", checked)
					if MoveAny.UpdateActionBar then
						MoveAny:UpdateActionBar(frame)
					end
				end
			)

			flipped.text = flipped:CreateFontString(nil, "ARTWORK")
			flipped.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
			flipped.text:SetPoint("LEFT", flipped, "RIGHT", 0, 0)
			flipped.text:SetText(MoveAny:GT("LID_FLIPPED"))
			PY = PY - 40
			opts["SPACING"] = opts["SPACING"] or 2
			local slider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			slider:SetWidth(content:GetWidth() - 110)
			slider:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
			slider.Low:SetText(0)
			slider.High:SetText(16)
			slider.Text:SetText(MoveAny:GT("LID_SPACING") .. ": " .. opts["SPACING"])
			slider:SetMinMaxValues(0, 16)
			slider:SetObeyStepOnDrag(true)
			slider:SetValueStep(1)
			slider:SetValue(opts["SPACING"])
			slider:SetScript(
				"OnValueChanged",
				function(sel, valu)
					val = tonumber(string.format("%" .. 0 .. "f", valu))
					if val and val ~= opts["SPACING"] then
						opts["SPACING"] = val
						slider.Text:SetText(MoveAny:GT("LID_SPACING") .. ": " .. val)
						if MoveAny.UpdateActionBar then
							MoveAny:UpdateActionBar(frame)
						end
					end
				end
			)
		elseif string.find(content.name, MoveAny:GT("LID_BUFFS")) then
			--MoveAny:CreateSlider(parent, x, y, name, key, value, steps, vmin, vmax, func)
			local y = -20
			if MoveAny:GetWoWBuild() ~= "RETAIL" then
				MoveAny:CreateSlider(
					content,
					10,
					y,
					name,
					"MABUFFMODE",
					0,
					1,
					0,
					4,
					function()
						MoveAny:UpdateBuffs()
						DebuffFrame:UpdatePoint()
					end,
					{
						[0] = "AUTO",
						[1] = "TOPRIGHT",
						[2] = "TOPLEFT",
						[3] = "BOTTOMRIGHT",
						[4] = "BOTTOMLEFT"
					}
				)

				y = y - 40
			end

			MoveAny:CreateSlider(
				content,
				10,
				y,
				name,
				"MABUFFLIMIT",
				10,
				1,
				1,
				20,
				function()
					MoveAny:UpdateBuffs()
					DebuffFrame:UpdatePoint()
				end
			)

			y = y - 40
			MoveAny:CreateSlider(
				content,
				10,
				y,
				name,
				"MABUFFSPACINGX",
				4,
				1,
				0,
				30,
				function()
					MoveAny:UpdateBuffs()
					DebuffFrame:UpdatePoint()
				end
			)

			y = y - 40
			MoveAny:CreateSlider(
				content,
				10,
				y,
				name,
				"MABUFFSPACINGY",
				10,
				1,
				0,
				30,
				function()
					MoveAny:UpdateBuffs()
					DebuffFrame:UpdatePoint()
				end
			)

			y = y - 40
		elseif string.find(content.name, MoveAny:GT("LID_DEBUFFS")) then
			--MoveAny:CreateSlider(parent, x, y, name, key, value, steps, vmin, vmax, func)
			local y = -20
			if MoveAny:GetWoWBuild() ~= "RETAIL" then
				MoveAny:CreateSlider(
					content,
					10,
					y,
					name,
					"MADEBUFFMODE",
					0,
					1,
					0,
					4,
					MoveAny.UpdateDebuffs,
					{
						[0] = "AUTO",
						[1] = "TOPRIGHT",
						[2] = "TOPLEFT",
						[3] = "BOTTOMRIGHT",
						[4] = "BOTTOMLEFT"
					}
				)

				y = y - 40
			end

			MoveAny:CreateSlider(content, 10, y, name, "MADEBUFFLIMIT", 10, 1, 1, 20, MoveAny.UpdateDebuffs)
			y = y - 40
			MoveAny:CreateSlider(content, 10, y, name, "MADEBUFFSPACINGX", 4, 1, 0, 30, MoveAny.UpdateDebuffs)
			y = y - 40
			MoveAny:CreateSlider(content, 10, y, name, "MADEBUFFSPACINGY", 10, 1, 0, 30, MoveAny.UpdateDebuffs)
			y = y - 40
		elseif string.find(content.name, MoveAny:GT("LID_MAINMENUEXPBAR")) or string.find(content.name, MoveAny:GT("LID_REPUTATIONWATCHBAR")) then
			opts["WIDTH"] = opts["WIDTH"] or 1024
			local width = opts["WIDTH"]
			opts["HEIGHT"] = opts["HEIGHT"] or 15
			local height = opts["HEIGHT"]
			local sliderW = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			sliderW:SetWidth(content:GetWidth() - 30)
			sliderW:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -30)
			sliderW.Low:SetText(100)
			sliderW.High:SetText(1024)
			sliderW.Text:SetText(MoveAny:GT("LID_WIDTH") .. ": " .. width)
			sliderW:SetMinMaxValues(100, 1024)
			sliderW:SetObeyStepOnDrag(true)
			sliderW:SetValueStep(2)
			sliderW:SetValue(width)
			sliderW:SetScript(
				"OnValueChanged",
				function(sel, valu)
					valu = tonumber(string.format("%" .. 0 .. "f", valu))
					if valu and valu ~= opts["WIDTH"] then
						opts["WIDTH"] = valu
						sel.Text:SetText(MoveAny:GT("LID_WIDTH") .. ": " .. valu)
						if frame and frame.UpdateSize then
							frame:UpdateSize()
						end
					end
				end
			)

			local sliderH = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			sliderH:SetWidth(content:GetWidth() - 30)
			sliderH:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -60)
			sliderH.Low:SetText(2)
			sliderH.High:SetText(64)
			sliderH.Text:SetText(MoveAny:GT("LID_HEIGHT") .. ": " .. height)
			sliderH:SetMinMaxValues(2, 64)
			sliderH:SetObeyStepOnDrag(true)
			sliderH:SetValueStep(1)
			sliderH:SetValue(height)
			sliderH:SetScript(
				"OnValueChanged",
				function(sel, valu)
					val = tonumber(string.format("%" .. 0 .. "f", valu))
					if val and val ~= opts["HEIGHT"] then
						opts["HEIGHT"] = val
						sel.Text:SetText(MoveAny:GT("LID_HEIGHT") .. ": " .. val)
						if frame and frame.UpdateSize then
							frame:UpdateSize()
						end
					end
				end
			)
		end
	end
end

function MoveAny:GetFrame(ele, name)
	if ele == nil then return ele end
	local _, e1 = strfind(name, ".", 1, true)
	if e1 then
		local tab = {strsplit(".", name)}
		for i, na in pairs(tab) do
			if i == 1 and _G[na] then
				ele = _G[na]
			elseif i > 1 and ele[na] then
				ele = ele[na]
			end
		end
	end

	if ele and ele.GetName then return ele end

	return nil
end

local ses = {}
local runSelectedReset = false
function MoveAny:ResetSelectedText()
	if not runSelectedReset then
		runSelectedReset = true
		local cb = MoveAny:GetLastSelected()
		if cb then
			cb:UpdateText()
		end

		runSelectedReset = false
	end
end

function MoveAny:ClearSelectEle()
	if MACurrentEle and MACurrentEle.t then
		MACurrentEle.t:SetVertexColor(MoveAny:GetColor("el"))
		MACurrentEle.name:Hide()
	end

	MACurrentEle = nil
end

function MoveAny:SelectEle(ele)
	if MACurrentEle and MACurrentEle.t then
		MACurrentEle.t:SetVertexColor(MoveAny:GetColor("el"))
		MACurrentEle.name:Hide()
	end

	MACurrentEle = ele
	MACurrentEle.t:SetVertexColor(MoveAny:GetColor("se"))
	MACurrentEle.name:Show()
end

function MoveAny:GetSelectEleName(lstr)
	return ses[lstr]
end

function MoveAny:RegisterSelectEle(lstr, name)
	ses[lstr] = name
end

function MoveAny:UpdateHiddenFrames()
	for i, v in pairs(MoveAny:GetDragFrames()) do
		if v.t:GetVertexColor() == MoveAny:GetColor("hidden") then
			if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
				v:Hide()
			else
				v:Show()
			end
		end
	end
end

function MoveAny:IsPresetProfileActive()
	if EditModeManagerFrame then
		if not EditModeManagerFrame:IsInitialized() or EditModeManagerFrame.layoutApplyInProgress then return true end
		local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
		local isPresetLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Preset

		return isPresetLayout
	end

	return true
end

--[[if MoveAny:GetWoWBuild() == "RETAIL" then
	C_Timer.After(
		1,
		function()
			local MA_HelpProfileFrame = CreateFrame("FRAME", "MoveAnyHelpFrame")
			MA_HelpProfileFrame:SetParent(MoveAny:GetMainPanel())
			MA_HelpProfileFrame:SetSize(1200, 200)
			MA_HelpProfileFrame:ClearAllPoints()
			MA_HelpProfileFrame:SetPoint("TOP", MoveAny:GetMainPanel(), "TOP", 0, -100)
			MA_HelpProfileFrame:EnableMouse(false)
			MA_HelpProfileFrame.t1 = MA_HelpProfileFrame:CreateFontString(nil, nil, "GameFontNormal")
			MA_HelpProfileFrame.t1:SetPoint("CENTER", MA_HelpProfileFrame, "CENTER", 0, 0)
			local font, _, fontFlags = MA_HelpProfileFrame.t1:GetFont()
			MA_HelpProfileFrame.t1:SetFont(font, 32, fontFlags)
			MA_HelpProfileFrame.t1:SetText(MoveAny:GT("LID_PLEASESWITCHPROFILE1"))
			MA_HelpProfileFrame.t2 = MA_HelpProfileFrame:CreateFontString(nil, nil, "GameFontNormal")
			MA_HelpProfileFrame.t2:SetPoint("CENTER", MA_HelpProfileFrame, "CENTER", 0, -40)
			local font2, _, fontFlags2 = MA_HelpProfileFrame.t2:GetFont()
			MA_HelpProfileFrame.t2:SetFont(font2, 24, fontFlags2)
			MA_HelpProfileFrame.t2:SetText(MoveAny:GT("LID_PLEASESWITCHPROFILE2"))
			MA_HelpProfileFrame.t3 = MA_HelpProfileFrame:CreateFontString(nil, nil, "GameFontNormal")
			MA_HelpProfileFrame.t3:SetPoint("CENTER", MA_HelpProfileFrame, "CENTER", 0, -90)
			local font3, _, fontFlags3 = MA_HelpProfileFrame.t3:GetFont()
			MA_HelpProfileFrame.t3:SetFont(font3, 32, fontFlags3)
			MA_HelpProfileFrame.t3:SetText(MoveAny:GT("LID_PLEASESWITCHPROFILE3"))
			function MoveAny:ThinkHelpFrame()
				if MoveAny:IsPresetProfileActive() then
					MA_HelpProfileFrame:Show()
					C_Timer.After(0.5, MoveAny.ThinkHelpFrame)
				else
					MA_HelpProfileFrame:Hide()
					C_Timer.After(1.1, MoveAny.ThinkHelpFrame)
				end
			end

			MoveAny:ThinkHelpFrame()
		end
	)
end]]
if MoveAny:GetWoWBuild() == "RETAIL" then
	C_Timer.After(
		1,
		function()
			local lastCheck = false
			local wasPreset = MoveAny:IsPresetProfileActive()
			function MoveAny:ThinkHelpFrame()
				local isPreset = MoveAny:IsPresetProfileActive()
				if lastCheck ~= isPreset then
					lastCheck = isPreset
					if isPreset then
						MoveAny:MSG(MoveAny:GT("LID_PLEASESWITCHPROFILE1") .. " " .. MoveAny:GT("LID_PLEASESWITCHPROFILE2") .. " " .. MoveAny:GT("LID_PLEASESWITCHPROFILE3"))
					elseif wasPreset then
						MoveAny:MSG("ALL GOOD.")
					end
				end

				if isPreset then
					C_Timer.After(0.5, MoveAny.ThinkHelpFrame)
				else
					C_Timer.After(1.1, MoveAny.ThinkHelpFrame)
				end
			end

			MoveAny:ThinkHelpFrame()
		end
	)
end

function MoveAny:RegisterWidget(tab)
	local name = tab.name
	local lstr = tab.lstr
	local lstri = tab.lstri
	MoveAny:RegisterSelectEle(lstr, name)
	if lstri then
		lstr = format(MoveAny:GT(lstr), lstri)
	else
		lstr = MoveAny:GT(lstr)
	end

	local sw = tab.sw
	local sh = tab.sh
	local secure = tab.ma_secure
	local noreparent = tab.noreparent or false
	local userplaced = tab.userplaced
	local cleft = tab.cleft
	local cright = tab.cright
	local ctop = tab.ctop
	local cbottom = tab.cbottom
	local posx = tab.posx
	local posy = tab.posy
	local setup = tab.setup
	tab.delay = tab.delay or 0.2
	local enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
	if (enabled1 or enabled2) and (not forced1 and not forced2) then
		MoveAny:MSG(format(MoveAny:GT("LID_HELPTEXT"), lstr))

		return
	end

	C_Timer.After(
		1,
		function()
			enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
			enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
			if (enabled1 or enabled2) and (not forced1 and not forced2) then
				MoveAny:MSG(format(MoveAny:GT("LID_HELPTEXT"), lstr))

				return
			end
		end
	)

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[name] then
		UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
	end

	local frame = MoveAny:GetFrame(_G[name], name)
	if frame then
		MoveAny:AddFrameName(frame, name)
	end

	if _G[name .. "_MA_DRAG"] == nil then
		_G[name .. "_MA_DRAG"] = CreateFrame("FRAME", name .. "_MA_DRAG", MoveAny:GetMainPanel())
		local dragframe = _G[name .. "_MA_DRAG"]
		dragframe:SetClampedToScreen(true)
		dragframe:SetFrameStrata("MEDIUM")
		dragframe:SetFrameLevel(99)
		dragframe:SetAlpha(0)
		dragframe:EnableMouse(false)
		if MoveAny:GetEleSize(name) then
			dragframe:SetSize(MoveAny:GetEleSize(name))
		else
			dragframe:SetSize(100, 100)
		end

		dragframe:ClearAllPoints()
		dragframe:SetPoint("CENTER", frame or UIParent, "CENTER", 0, 0)
		dragframe:SetToplevel(true)
		dragframe.t = dragframe:CreateTexture(name .. "_MA_DRAG.t", "BACKGROUND", nil, 1)
		dragframe.t:SetAllPoints(dragframe)
		if dragframe.t.SetColorTexture then
			dragframe.t:SetColorTexture(1, 1, 1, 1)
		else
			dragframe.t:SetTexture(1, 1, 1, 1)
		end

		dragframe.t:SetVertexColor(MoveAny:GetColor("el"))
		dragframe.t:SetAlpha(0.4)
		dragframe.name = dragframe:CreateFontString(nil, nil, "GameFontHighlightLarge")
		dragframe.name:SetPoint("CENTER", dragframe, "CENTER", 0, 0)
		local font, _, fontFlags = dragframe.name:GetFont()
		dragframe.name:SetFont(font, 15, fontFlags)
		local enab, forc = MoveAny:IsInEditModeEnabled(name)
		if enab and not forc then
			lstr = lstr .. " |cFFFFFF00" .. MoveAny:GT("LID_ISENABLEDINEDITMODE")
		end

		dragframe.name:SetText(lstr)
		dragframe.name:Hide()
		dragframe:SetScript(
			"OnEnter",
			function()
				if dragframe ~= MACurrentEle then
					dragframe.name:Show()
				end

				dragframe.t:SetAlpha(0.8)
				if dragframe.setup == nil and not InCombatLockdown() then
					dragframe.setup = true
					dragframe:EnableKeyboard(true)
					dragframe:SetPropagateKeyboardInput(true)
					dragframe:HookScript(
						"OnKeyDown",
						function(sel, btn)
							if dragframe == MACurrentEle then
								local p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
								if btn == "RIGHT" then
									MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 + 1, p5)
								elseif btn == "LEFT" then
									MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 - 1, p5)
								elseif btn == "UP" then
									MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4, p5 + 1)
								elseif btn == "DOWN" then
									MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4, p5 - 1)
								end
							else
								return
							end
						end
					)
				end
			end
		)

		dragframe:SetScript(
			"OnLeave",
			function()
				if dragframe ~= MACurrentEle then
					dragframe.name:Hide()
				end

				dragframe.t:SetAlpha(0.4)
			end
		)

		dragframe:SetScript(
			"OnMouseDown",
			function(sel, btn)
				local fram = _G[name]
				if btn == "LeftButton" then
					MoveAny:SelectEle(sel)
				end

				if btn == "LeftButton" then
					dragframe:SetMovable(true)
					dragframe:StartMoving()
					dragframe.ma_ismoving = true
				elseif btn == "RightButton" then
					if dragframe.opt == nil then
						dragframe.opt = CreateFrame("Frame", name .. ".opt", MoveAny:GetMainPanel(), "BasicFrameTemplateWithInset")
						dragframe.opt.TitleText:SetText(name)
						dragframe.opt:SetFrameStrata("HIGH")
						dragframe.opt:SetFrameLevel(framelevel)
						framelevel = framelevel + 1
						if dragframe.opt.CloseButton then
							dragframe.opt.CloseButton:SetFrameLevel(framelevel)
						end

						framelevel = framelevel + 100
						dragframe.opt:SetSize(500, 500)
						dragframe.opt:SetPoint("CENTER")
						dragframe.opt:SetClampedToScreen(true)
						dragframe.opt:SetMovable(true)
						dragframe.opt:EnableMouse(true)
						dragframe.opt:RegisterForDrag("LeftButton")
						dragframe.opt:SetScript("OnDragStart", dragframe.opt.StartMoving)
						dragframe.opt:SetScript("OnDragStop", dragframe.opt.StopMovingOrSizing)
						MoveAny:MenuOptions(dragframe.opt, fram)
					elseif dragframe.opt then
						dragframe.opt:Show()
					end
				end
			end
		)

		dragframe:SetScript(
			"OnMouseUp",
			function()
				local fram = _G[name]
				if dragframe.ma_ismoving then
					dragframe.ma_ismoving = false
					dragframe:StopMovingOrSizing()
					dragframe:SetMovable(false)
					local op1, _, op3, op4, op5 = MoveAny:GetElePoint(name)
					local np1, _, np3, p4, p5 = dragframe:GetPoint()
					local np4 = MoveAny:Snap(p4)
					local np5 = MoveAny:Snap(p5)
					if np1 ~= op1 or np3 ~= op3 or np4 ~= op4 or np5 ~= op5 then
						MoveAny:SetElePoint(name, np1, MoveAny:GetMainPanel(), np3, np4, np5)
					end

					if dragframe.opt and dragframe.opt.tabs and dragframe.opt.tabs[1] then
						local tab1 = dragframe.opt.tabs[1]
						tab1.content.pos:SetText(format("Position X: %d Y:%d", p4, p5))
					end

					dragframe:SetMovable(true)
					dragframe:ClearAllPoints()
					dragframe:SetPoint("CENTER", fram, "CENTER", posx or 0, posy or 0)
				end
			end
		)

		tinsert(MoveAny:GetDragFrames(), dragframe)
	end

	local dragf = _G[name .. "_MA_DRAG"]
	if frame then
		dragf:Show()
	else
		dragf:Hide()
	end

	if frame == nil then
		C_Timer.After(
			tab.delay or 0.2,
			function()
				MoveAny:RegisterWidget(tab)
			end
		)

		return false
	end

	--frame:SetParent(MoveAny:GetMainPanel())
	if cleft or cright or ctop or cbottom then
		local l = cleft or 0
		local r = cright or 0
		local t = ctop or 0
		local b = cbottom or 0
		if frame.SetClampRectInsets then
			hooksecurefunc(
				frame,
				"SetClampRectInsets",
				function(sel, ...)
					if sel.scri then return end
					sel.scri = true
					sel:SetClampRectInsets(l, r, t, b)
					local df = _G[name .. "_MA_DRAG"]
					if df then
						df:SetClampRectInsets(l, r, t, b)
					end

					sel.scri = false
				end
			)

			frame:SetClampRectInsets(l, r, t, b)
		end
	end

	tinsert(MoveAny:GetEleFrames(), frame)
	tinsert(MoveAny:GetAlphaFrames(), frame)
	if frame and frame.GetChildren then
		for i, btn in pairs({frame:GetChildren()}) do
			function btn:GetMAEle()
				return frame
			end
		end
	end

	frame.ignoreFramePositionManager = true
	if frame.SetMovable then
		frame:SetMovable(true)
		if frame.SetUserPlaced and frame:IsMovable() then
			frame:SetUserPlaced(userplaced or false)
		end
	end

	if frame.SetDontSavePosition then
		frame:SetDontSavePosition(true)
	end

	if frame.SetClampedToScreen then
		frame:SetClampedToScreen(true)
	end

	local maframe1 = _G["MA" .. name]
	local maframe2 = _G[string.gsub(name, "MA", "")]
	if MoveAny:GetEleOption(name, "Hide", false, "Hide2") then
		frame.oldparent = frame.oldparent or frame:GetParent()
		hooksecurefunc(
			frame,
			"SetParent",
			function(sel, newParent)
				if sel.ma_setparent then return end
				sel.ma_setparent = true
				if MoveAny:GetEleOption(name, "Hide", false, "Hide3") then
					sel:SetParent(MAHIDDEN)
				else
					sel:SetParent(sel.oldparent)
				end

				sel.ma_setparent = false
			end
		)

		frame:SetParent(MAHIDDEN)
		if maframe1 then
			maframe1.oldparent = maframe1.oldparent or frame:GetParent()
			maframe1:SetParent(MAHIDDEN)
		end

		if maframe2 then
			maframe2.oldparent = maframe2.oldparent or frame:GetParent()
			maframe2:SetParent(MAHIDDEN)
		end

		dragf.t:SetVertexColor(MoveAny:GetColor("hidden"))
		if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
			dragf:Hide()
		else
			dragf:Show()
		end
	else
		if frame == MACurrentEle then
			dragf.t:SetVertexColor(MoveAny:GetColor("se"))
		elseif MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough2") then
			dragf.t:SetVertexColor(MoveAny:GetColor("clickthrough"))
			if frame == MABuffBar then
				function frame:UpdateBuffMouse()
					for i = 1, 32 do
						local bb = _G["BuffButton" .. i]
						if bb then
							function bb:GetMAEle()
								return MABuffBar
							end

							bb:EnableMouse(false)
						end

						if not MoveAny:IsEnabled("DEBUFFS", false) then
							local db = _G["DebuffButton" .. i]
							if db then
								function db:GetMAEle()
									return MABuffBar
								end

								db:EnableMouse(false)
							end
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				bbf:RegisterEvent("UNIT_AURA")
				bbf:SetScript(
					"OnEvent",
					function()
						frame:UpdateBuffMouse()
					end
				)

				frame:UpdateBuffMouse()
			elseif frame == MADebuffBar then
				function frame:UpdateDebuffMouse()
					for i = 1, 32 do
						local db = _G["DebuffButton" .. i]
						if db then
							function db:GetMAEle()
								return MABuffBar
							end

							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				bbf:RegisterEvent("UNIT_AURA")
				bbf:SetScript(
					"OnEvent",
					function()
						frame:UpdateDebuffMouse()
					end
				)

				frame:UpdateDebuffMouse()
			elseif frame == TargetFrameBuff1 then
				function frame:UpdateBuffMouse()
					for i = 1, 32 do
						local bb = _G["TargetFrameBuff" .. i]
						if bb then
							bb:EnableMouse(false)
						end

						local db = _G["TargetFrameDebuff" .. i]
						if db then
							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				bbf:RegisterEvent("UNIT_AURA")
				bbf:SetScript(
					"OnEvent",
					function()
						frame:UpdateBuffMouse()
					end
				)

				frame:UpdateBuffMouse()
			elseif frame == FocusFrameBuff1 then
				function frame:UpdateBuffMouse()
					for i = 1, 32 do
						local bb = _G["FocusFrameBuff" .. i]
						if bb then
							bb:EnableMouse(false)
						end

						local db = _G["FocusFrameDebuff" .. i]
						if db then
							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				bbf:RegisterEvent("UNIT_AURA")
				bbf:SetScript(
					"OnEvent",
					function()
						frame:UpdateBuffMouse()
					end
				)

				frame:UpdateBuffMouse()
			end
		else
			dragf.t:SetVertexColor(MoveAny:GetColor("el"))
		end
	end

	if MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough3") then
		hooksecurefunc(
			frame,
			"EnableMouse",
			function(sel, bo)
				if sel.ma_enablemouse then return end
				sel.ma_enablemouse = true
				sel:EnableMouse(false)
				sel.ma_enablemouse = false
			end
		)

		frame:EnableMouse(false)
	end

	frame.ma_secure = secure
	local bToSmall = false
	if sw or sh then
		bToSmall = true
	end

	sw = sw or frame:GetWidth()
	sh = sh or frame:GetHeight()
	sw = MoveAny:MathR(sw)
	sh = MoveAny:MathR(sh)
	if MoveAny:GetElePoint(name) == nil then
		local an, parent, re, px, py = frame:GetPoint()
		if parent == nil or parent == UIParent or parent == MoveAny:GetMainPanel() and an ~= nil and re ~= nil then
			MoveAny:SetElePoint(name, an, MoveAny:GetMainPanel(), re, MoveAny:Snap(px), MoveAny:Snap(py))
		elseif frame:GetLeft() and frame:GetBottom() then
			MoveAny:SetElePoint(name, "BOTTOMLEFT", MoveAny:GetMainPanel(), "BOTTOMLEFT", MoveAny:Snap(frame:GetLeft()), MoveAny:Snap(frame:GetBottom()))
		elseif parent ~= nil then
			MoveAny:SetElePoint(name, an, MoveAny:GetMainPanel(), re, MoveAny:Snap(parent:GetLeft()), MoveAny:Snap(parent:GetBottom()))
		else
			local an1 = tab.an or "CENTER"
			local re1 = tab.re or "CENTER"
			local px1 = tab.px or 0
			local py1 = tab.py or 0
			MoveAny:SetElePoint(name, an1, MoveAny:GetMainPanel(), re1, px1, py1)
		end
	end

	local osw, osh = MoveAny:GetEleSize(name)
	if osw ~= sw or osh ~= sh then
		MoveAny:SetEleSize(name, sw, sh)
	end

	local pointFunc = "SetPoint"
	if frame.SetPointBase then
		pointFunc = "SetPointBase"
	end

	hooksecurefunc(
		frame,
		pointFunc,
		function(sel, ...)
			if sel.elesetpoint then return end
			--sel.layoutApplyInProgress = true
			if not sel.ma_secure then
				if sel.SetMovable then
					sel:SetMovable(true)
				end

				if sel.SetUserPlaced and sel:IsMovable() then
					sel:SetUserPlaced(userplaced or false)
				end

				sel.elesetpoint = true
				local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
				if dbp1 and dbp3 then
					MoveAny:SetPoint(sel, dbp1, nil, dbp3, dbp4, dbp5)
				end

				sel.elesetpoint = false
			end
		end
	)

	if not frame.ma_secure then
		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
		if dbp1 and dbp3 then
			if noreparent then
				MoveAny:SetPoint(frame, dbp1, frame:GetParent(), dbp3, dbp4, dbp5)
			else
				MoveAny:SetPoint(frame, dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			end
		end
	end

	hooksecurefunc(
		frame,
		"SetScale",
		function(sel, scale)
			if sel.masetscale_ele then return end
			sel.masetscale_ele = true
			local newScale = MoveAny:GetEleScale(name) or 1
			if newScale and newScale > 0 and scale ~= newScale and not InCombatLockdown() then
				sel:SetScale(newScale)
			end

			local dragframe = _G[name .. "_MA_DRAG"]
			if dragframe then
				dragframe:SetScale(newScale)
			end

			sel.masetscale_ele = false
		end
	)

	if MoveAny:GetEleScale(name) and MoveAny:GetEleScale(name) > 0 then
		frame:SetScale(MoveAny:GetEleScale(name))
	end

	hooksecurefunc(
		frame,
		"SetSize",
		function(sel, w, h)
			local isToSmall = false
			local df = _G[name .. "_MA_DRAG"]
			df:SetSize(w, h)
			if w < sw then
				w = sw
				isToSmall = true
			end

			if h < sh then
				h = sh
				isToSmall = true
			end

			if bToSmall and isToSmall then
				df:SetSize(w, h)
				sel:SetSize(w, h)
			end
		end
	)

	if not InCombatLockdown() then
		frame:SetSize(sw, sh)
	end

	local dragframe = _G[name .. "_MA_DRAG"]
	dragframe:SetSize(sw, sh)
	dragframe:ClearAllPoints()
	dragframe:SetPoint("CENTER", frame, "CENTER", posx, posy)
	if MoveAny:IsEnabled("MALOCK", false) then
		dragframe:SetAlpha(1)
		dragframe:EnableMouse(true)
	else
		dragframe:SetAlpha(0)
		dragframe:EnableMouse(false)
	end

	if setup then
		setup()
	end
end

local isresting = nil
local ismounted = nil
local invehicle = nil
local incombat = nil
local inpetbattle = nil
local isstealthed = nil
local ischatclosed = nil
local lastchatab = nil
local lastEle = nil
local lastSize = 0
local fullHP = false
function MoveAny:SetEleAlpha(ele, alpha)
	if ele and ele:GetAlpha() ~= alpha then
		ele:SetAlpha(alpha)
	end
end

function MoveAny:SetMouseEleAlpha(ele)
	if lastEle and ele and ele ~= lastEle then
		MoveAny:UpdateAlphas(ele)
	end

	lastEle = ele
end

function MoveAny:IsInPetBattle()
	local inPetBattle = false
	if C_PetBattles then
		inPetBattle = C_PetBattles.IsInBattle()
	end

	return inPetBattle
end

function MoveAny:IsChatClosed()
	for i = 1, 12 do
		if _G["ChatFrame" .. i .. "EditBox"] and _G["ChatFrame" .. i .. "EditBox"]:HasFocus() then return false end
	end

	return true
end

function MoveAny:CurrentChatTab()
	for i = 1, 12 do
		local ct = _G["ChatFrame" .. i .. "EditBox"]
		if ct and ct:IsShown() then return i end
	end

	return 0
end

function MoveAny:CheckAlphas()
	if incombat ~= InCombatLockdown() then
		incombat = InCombatLockdown()
		MoveAny:UpdateAlphas()
	elseif UnitInVehicle and invehicle ~= UnitInVehicle("player") then
		invehicle = UnitInVehicle("player")
		MoveAny:UpdateAlphas()
	elseif IsMounted and ismounted ~= IsMounted() then
		ismounted = IsMounted()
		MoveAny:UpdateAlphas()
	elseif IsResting and isresting ~= IsResting() then
		isresting = IsResting()
		MoveAny:UpdateAlphas()
	elseif MoveAny.IsInPetBattle and inpetbattle ~= MoveAny:IsInPetBattle() then
		inpetbattle = MoveAny:IsInPetBattle()
		MoveAny:UpdateAlphas()
	elseif fullHP ~= (UnitHealth("player") >= UnitHealthMax("player")) then
		fullHP = UnitHealth("player") >= UnitHealthMax("player")
		MoveAny:UpdateAlphas()
	elseif IsStealthed and isstealthed ~= IsStealthed() then
		isstealthed = IsStealthed()
		MoveAny:UpdateAlphas()
	elseif MoveAny.IsChatClosed and ischatclosed ~= MoveAny:IsChatClosed() then
		ischatclosed = MoveAny:IsChatClosed()
		if ischatclosed then
			MoveAny:UpdateAlphas()
		end
	elseif MoveAny.CurrentChatTab and lastchatab ~= MoveAny:CurrentChatTab() then
		lastchatab = MoveAny:CurrentChatTab()
		MoveAny:UpdateAlphas()
	end

	if lastSize ~= getn(MoveAny:GetAlphaFrames()) then
		lastSize = getn(MoveAny:GetAlphaFrames())
		MoveAny:UpdateAlphas()
	end

	local ele = MoveAny:GetMouseFocus()
	if ele and ele ~= CompactRaidFrameManager then
		if ele and (ele == WorldFrame or ele == UIParent) and lastEle ~= nil and ele ~= lastEle then
			lastEle = nil
			MoveAny:UpdateAlphas()
		end

		if ele ~= WorldFrame and ele ~= UIParent then
			local dufloaded = MoveAny:IsAddOnLoaded("DUnitFrames")
			if not dufloaded or (dufloaded and ele ~= PlayerFrame and ele ~= TargetFrame and ele.GetMAEle and ele:GetMAEle() and ele:GetMAEle() ~= PlayerFrame and ele:GetMAEle() ~= TargetFrame) then
				if tContains(MoveAny:GetAlphaFrames(), ele) then
					ele:SetAlpha(1)
					MoveAny:SetMouseEleAlpha(ele)
				elseif ele.GetMAEle then
					ele = ele:GetMAEle()
					if ele then
						ele:SetAlpha(1)
						MoveAny:SetMouseEleAlpha(ele)
					end
				elseif lastEle then
					lastEle = nil
					MoveAny:UpdateAlphas()
				end
			end
		end
	elseif lastEle ~= nil then
		lastEle = nil
		MoveAny:UpdateAlphas()
	end

	C_Timer.After(0.12, MoveAny.CheckAlphas)
end

function MoveAny:UpdateAlpha(ele, mouseEle)
	local dufloaded = MoveAny:IsAddOnLoaded("DUnitFrames")
	if ele == nil then
		MoveAny:MSG("UpdateAlphas: ele is nil")
	else
		local name = MoveAny:GetFrameName(ele)
		if name ~= nil then
			local alphaInCombat = MoveAny:GetEleOption(name, "ALPHAINCOMBAT", 1, "Alpha1")
			local alphaIsFullHealth = MoveAny:GetEleOption(name, "ALPHAISFULLHEALTH", 1, "Alpha2")
			local alphaInVehicle = MoveAny:GetEleOption(name, "ALPHAINVEHICLE", 1, "Alpha3")
			local alphaIsMounted = MoveAny:GetEleOption(name, "ALPHAISMOUNTED", 1, "Alpha4")
			local alphaInRestedArea = MoveAny:GetEleOption(name, "ALPHAINRESTEDAREA", 1, "Alpha5")
			local alphaIsStealthed = MoveAny:GetEleOption(name, "ALPHAISSTEALTHED", 1, "Alpha6")
			local alphaIsInPetBattle = MoveAny:GetEleOption(name, "ALPHAISINPETBATTLE", 1, "Alpha7")
			local alphaNotInCombat = MoveAny:GetEleOption(name, "ALPHANOTINCOMBAT", 1, "Alpha8")
			if not dufloaded or (dufloaded and ele ~= PlayerFrame and ele ~= TargetFrame) then
				if ele.ma_show ~= nil and ele.ma_show == false then
					MoveAny:SetEleAlpha(ele, 0)
				elseif MoveAny.IsInPetBattle and MoveAny:IsInPetBattle() then
					MoveAny:SetEleAlpha(ele, alphaIsInPetBattle)
				elseif ele == mouseEle then
					MoveAny:SetEleAlpha(ele, 1)
				elseif incombat then
					MoveAny:SetEleAlpha(ele, alphaInCombat)
				elseif MoveAny:GetEleOption(name, "FULLHPENABLED", false, "fullhp2") and UnitHealth("player") >= UnitHealthMax("player") then
					MoveAny:SetEleAlpha(ele, alphaIsFullHealth)
				elseif UnitInVehicle and invehicle then
					MoveAny:SetEleAlpha(ele, alphaInVehicle)
				elseif IsMounted and ismounted then
					MoveAny:SetEleAlpha(ele, alphaIsMounted)
				elseif IsResting and isresting then
					MoveAny:SetEleAlpha(ele, alphaInRestedArea)
				elseif IsStealthed and isstealthed then
					MoveAny:SetEleAlpha(ele, alphaIsStealthed)
				elseif not incombat then
					MoveAny:SetEleAlpha(ele, alphaNotInCombat)
				end
			end
		end
	end
end

function MoveAny:UpdateAlphas(mouseEle)
	for i, ele in pairs(MoveAny:GetAlphaFrames()) do
		MoveAny:UpdateAlpha(ele, mouseEle)
	end
end

function MoveAny:AnyActionbarEnabled()
	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		return MoveAny:IsEnabled("ACTIONBARS", false) or MoveAny:IsEnabled("ACTIONBAR3", false) or MoveAny:IsEnabled("ACTIONBAR4", false) or MoveAny:IsEnabled("ACTIONBAR7", false) or MoveAny:IsEnabled("ACTIONBAR8", false) or MoveAny:IsEnabled("ACTIONBAR9", false) or MoveAny:IsEnabled("ACTIONBAR10", false)
	else
		return false
	end
end
