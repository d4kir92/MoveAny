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

local framelevel = 100

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

		tab:SetScript("OnClick", function(sel)
			SelectTab(sel)
		end)

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

	btn:SetScript("OnClick", function()
		local p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
		MoveAny:SetElePoint(name, p1, MoveAny:GetMainPanel(), p3, p4 + x, p5 + y)
		p1, _, p3, p4, p5 = MoveAny:GetElePoint(name)
		parent.pos:SetText(format("Position X: %d Y:%d", p4, p5))
	end)

	return btn
end

function MoveAny:CreateSlider(parent, x, y, name, key, value, steps, vmin, vmax, func)
	local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	slider:SetWidth(parent:GetWidth() - 20)
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	slider.Low:SetText(vmin)
	slider.High:SetText(vmax)
	slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. MoveAny:GetEleOption(name, key, value))
	slider:SetMinMaxValues(vmin, vmax)
	slider:SetObeyStepOnDrag(true)
	slider:SetValueStep(steps)
	slider:SetValue(MoveAny:GetEleOption(name, key, value, "Slider1"))

	slider:SetScript("OnValueChanged", function(sel, val)
		val = tonumber(string.format("%" .. steps .. "f", val))

		if val then
			MoveAny:SetEleOption(name, key, val)
			slider.Text:SetText(MoveAny:GT("LID_" .. key) .. ": " .. val)

			if func then
				func()
			end
		end
	end)

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

	if string.find(name, "MAActionBar") or string.find(name, "MultiBar") or name == "MainMenuBar" or name == "MAMenuBar" or name == "MAPetBar" or name == "StanceBar" then
		table.insert(tabs, ACTIONBARS_LABEL)
	end

	if string.find(name, "MABuffBar") then
		table.insert(tabs, MoveAny:GT("LID_BUFFS"))
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

			sup:SetScript("OnClick", function()
				local val = tonumber(string.format("%.1f", frame:GetScale() + 0.1))
				MoveAny:SetEleScale(name, val)
				content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
			end)

			local sdn = CreateFrame("Button", "sdn", content)
			sdn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			sdn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			sdn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sdn:SetSize(btnsize, btnsize)
			sdn:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -48)

			sdn:SetScript("OnClick", function()
				if frame:GetScale() > 0.3 then
					local val = tonumber(string.format("%.1f", frame:GetScale() - 0.1))
					MoveAny:SetEleScale(name, val)
					content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
				end
			end)

			local hide = CreateFrame("CheckButton", "hide", content, "ChatConfigCheckButtonTemplate")
			hide:SetSize(btnsize, btnsize)
			hide:SetPoint("TOPLEFT", content, "TOPLEFT", 150, -110)
			hide:SetChecked(MoveAny:GetEleOption(name, "Hide", false, "Hide1"))
			hide:SetText(HIDE)

			hide:SetScript("OnClick", function()
				local checked = hide:GetChecked()
				MoveAny:SetEleOption(name, "Hide", checked)
				local maframe1 = _G["MA" .. name]
				local maframe2 = _G[string.gsub(name, "MA", "")]
				local dragf = _G[name .. "_DRAG"]

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
			end)

			hide.text = hide:CreateFontString(nil, "ARTWORK")
			hide.text:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
			hide.text:SetPoint("LEFT", hide, "RIGHT", 0, 0)
			hide.text:SetText(getglobal("HIDE"))
			MoveAny:CreateSlider(content, 10, -190, name, "ALPHAINVEHICLE", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			MoveAny:CreateSlider(content, 10, -220, name, "ALPHAISMOUNTED", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			MoveAny:CreateSlider(content, 10, -250, name, "ALPHAINRESTEDAREA", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			MoveAny:CreateSlider(content, 10, -280, name, "ALPHAINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
			MoveAny:CreateSlider(content, 10, -310, name, "ALPHANOTINCOMBAT", 1, 0.1, 0, 1, MoveAny.UpdateAlphas)
		elseif string.find(content.name, ACTIONBARS_LABEL) then
			local slides = {}
			local items = {}

			local function UpdateRowItems()
				local maxBtns = getn(frame.btns)

				if frame ~= MAMenuBar and frame ~= StanceBar and opts["COUNT"] and opts["COUNT"] > 0 then
					maxBtns = opts["COUNT"]
				end

				if frame == MAMenuBar then
					if MoveAny:GetWoWBuild() == "RETAIL" then
						items = {"1", "2", "3", "4", "5", "10", "11", "12"}
					elseif MoveAny:GetWoWBuild() == "CLASSIC" then
						items = {"1", "2", "4", "8"}
					else
						items = {"1", "2", "3", "4", "5", "8", "9", "10"}
					end
				elseif maxBtns == 12 then
					items = {"1", "2", "3", "4", "6", "12"}
				elseif maxBtns == 11 then
					items = {"1", "11"}
				elseif maxBtns == 10 then
					items = {"1", "2", "5", "10"}
				elseif maxBtns == 9 then
					items = {"1", "3", "9"}
				elseif maxBtns == 8 then
					items = {"1", "2", "4", "8"}
				elseif maxBtns == 7 then
					items = {"1", "7"}
				elseif maxBtns == 6 then
					items = {"1", "2", "3", "6"}
				elseif maxBtns == 5 then
					items = {"1", "5"}
				elseif maxBtns == 4 then
					items = {"1", "2", "4"}
				elseif maxBtns == 3 then
					items = {"1", "3"}
				elseif maxBtns == 2 then
					items = {"1", "2"}
				elseif maxBtns == 1 then
					items = {"1"}
				else
					--MoveAny:MSG( "FOUND OTHER MAX: " .. maxBtns .. " for " .. name )
					items = {"1"}
				end
			end

			UpdateRowItems()
			local vmin = 1

			if frame == MAActionBar1 or frame == MainMenuBar then
				vmin = 6
			end

			local max = getn(frame.btns)
			local count = opts["COUNT"] or max
			local rows = opts["ROWS"] or 1
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

				sliderCount:SetScript("OnValueChanged", function(sel, val)
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
				end)

				PY = PY - 30
			end

			slides.sliderRows = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			local sliderRows = slides.sliderRows
			sliderRows:SetWidth(content:GetWidth() - 110)
			sliderRows:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
			sliderRows.Low:SetText("")
			sliderRows.High:SetText("")
			sliderRows.Text:SetText(MoveAny:GT("LID_ROWS") .. ": " .. rows)
			sliderRows:SetMinMaxValues(1, #items)
			sliderRows:SetObeyStepOnDrag(true)
			sliderRows:SetValueStep(1)
			sliderRows:SetValue(rows)

			sliderRows:SetScript("OnValueChanged", function(sel, val)
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
			end)

			PY = PY - 30
			local flipped = CreateFrame("CheckButton", "flipped", content, "ChatConfigCheckButtonTemplate")
			flipped:SetSize(btnsize, btnsize)
			flipped:SetPoint("TOPLEFT", content, "TOPLEFT", 4, PY)
			flipped:SetChecked(MoveAny:GetEleOption(name, "FLIPPED", false, "Flipped1"))
			flipped:SetText(MoveAny:GT("LID_FLIPPED"))

			flipped:SetScript("OnClick", function()
				local checked = flipped:GetChecked()
				MoveAny:SetEleOption(name, "FLIPPED", checked)

				if MoveAny.UpdateActionBar then
					MoveAny:UpdateActionBar(frame)
				end
			end)

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

			slider:SetScript("OnValueChanged", function(sel, val)
				val = tonumber(string.format("%" .. 0 .. "f", val))

				if val and val ~= opts["SPACING"] then
					opts["SPACING"] = val
					slider.Text:SetText(MoveAny:GT("LID_SPACING") .. ": " .. val)

					if MoveAny.UpdateActionBar then
						MoveAny:UpdateActionBar(frame)
					end
				end
			end)
		elseif string.find(content.name, MoveAny:GT("LID_BUFFS")) then
			MoveAny:CreateSlider(content, 10, -20, name, "MABUFFLIMIT", 10, 1, 1, 20, MAUpdateBuffs)
			MoveAny:CreateSlider(content, 10, -60, name, "MABUFFSPACINGX", 4, 1, 0, 30, MAUpdateBuffs)
			MoveAny:CreateSlider(content, 10, -100, name, "MABUFFSPACINGY", 10, 1, 0, 30, MAUpdateBuffs)
		end
	end
end

function MoveAny:UpdateMinimapButton()
	if MAMMBTN then
		if MoveAny:IsEnabled("SHOWMINIMAPBUTTON", true) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end
end

function MoveAny:ToggleMinimapButton()
	MoveAny:SetEnabled("SHOWMINIMAPBUTTON", not MoveAny:IsEnabled("SHOWMINIMAPBUTTON", true))

	if MAMMBTN then
		if MoveAny:IsEnabled("SHOWMINIMAPBUTTON", true) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end
end

function MoveAny:HideMinimapButton()
	MoveAny:SetEnabled("SHOWMINIMAPBUTTON", false)

	if MAMMBTN then
		MAMMBTN:Hide("MoveAnyMinimapIcon")
	end
end

function MoveAny:ShowMinimapButton()
	MoveAny:SetEnabled("SHOWMINIMAPBUTTON", true)

	if MAMMBTN then
		MAMMBTN:Show("MoveAnyMinimapIcon")
	end
end

function MoveAny:GetFrame(ele, name)
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

	return ele
end

local ses = {}

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
	local userplaced = tab.userplaced
	local cleft = tab.cleft
	local cright = tab.cright
	local ctop = tab.ctop
	local cbottom = tab.cbottom
	local posx = tab.posx
	local posy = tab.posy
	tab.delay = tab.delay or 0.2

	if tab.delay < 2 then
		tab.delay = tab.delay + 0.2
	end

	local enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)

	if enabled1 or enabled2 then
		if not MoveAny:IsEnabled("EDITMODE", MoveAny:GetWoWBuildNr() < 100000) then
			MoveAny:MSG("YOU NEED EDITMODE IN MOVEANY ENABLED")

			return
		end

		if not forced1 and not forced2 then
			MoveAny:MSG(format(MoveAny:GT("LID_HELPTEXT"), lstr))

			return
		end
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS[name] then
		UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
	end

	local frame = MoveAny:GetFrame(_G[name], name)

	if frame then
		MoveAny:AddFrameName(frame, name)

		if frame.systemInfo and frame.systemInfo.anchorInfo and frame.systemInfo.anchorInfo.relativeTo == "MABack" then
			frame.systemInfo.anchorInfo.relativeTo = "UIParent"
			EditModeSystemMixin.UpdateSystem(frame, frame.systemInfo)
			MoveAny:TrySaveEditMode()
		end
	end

	if _G[name .. "_DRAG"] == nil then
		_G[name .. "_DRAG"] = CreateFrame("FRAME", name .. "_DRAG", MoveAny:GetMainPanel())
		local dragframe = _G[name .. "_DRAG"]
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
		dragframe:SetPoint("CENTER", frame, "CENTER", 0, 0)
		dragframe:SetToplevel(true)
		dragframe.t = dragframe:CreateTexture(name .. "_DRAG.t", "BACKGROUND", nil, 1)
		dragframe.t:SetAllPoints(dragframe)
		dragframe.t:SetColorTexture(1, 1, 1, 1)
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

		dragframe:SetScript("OnEnter", function()
			if dragframe ~= MACurrentEle then
				dragframe.name:Show()
			end

			dragframe.t:SetAlpha(0.8)

			if dragframe.setup == nil and not InCombatLockdown() then
				dragframe.setup = true
				dragframe:EnableKeyboard(true)
				dragframe:SetPropagateKeyboardInput(true)

				dragframe:HookScript("OnKeyDown", function(sel, btn)
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
				end)
			end
		end)

		dragframe:SetScript("OnLeave", function()
			if dragframe ~= MACurrentEle then
				dragframe.name:Hide()
			end

			dragframe.t:SetAlpha(0.4)
		end)

		dragframe:SetScript("OnMouseDown", function(sel, btn)
			local fram = _G[name]

			if btn == "LeftButton" then
				MoveAny:SelectEle(sel)
			end

			if btn == "LeftButton" then
				dragframe:SetMovable(true)
				dragframe:StartMoving()
				dragframe.IsMoving = true
			elseif btn == "RightButton" then
				if dragframe.opt == nil then
					dragframe.opt = CreateFrame("Frame", name .. ".opt", MoveAny:GetMainPanel(), "BasicFrameTemplateWithInset")
					dragframe.opt.TitleText:SetText(name)
					dragframe.opt:SetFrameStrata("HIGH")
					dragframe.opt:SetFrameLevel(framelevel)
					framelevel = framelevel + 510 -- 509 <- closebutton height
					dragframe.opt:SetSize(300, 370)
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
		end)

		dragframe:SetScript("OnMouseUp", function()
			local fram = _G[name]

			if dragframe.IsMoving then
				dragframe.IsMoving = false
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
		end)

		tinsert(MoveAny:GetDragFrames(), dragframe)
	end

	if frame == nil then
		C_Timer.After(tab.delay or 0.2, function()
			MoveAny:RegisterWidget(tab)
		end)

		return false
	end

	if cleft or cright or ctop or cbottom then
		local l = cleft or 0
		local r = cright or 0
		local t = ctop or 0
		local b = cbottom or 0

		if frame.SetClampRectInsets then
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
	local dragf = _G[name .. "_DRAG"]

	if MoveAny:GetEleOption(name, "Hide", false, "Hide2") then
		frame.oldparent = frame.oldparent or frame:GetParent()

		hooksecurefunc(frame, "SetParent", function(sel, newParent)
			if newParent.GetName then
				pn = newParent:GetName()
			end

			if sel.ma_setparent then return end
			sel.ma_setparent = true

			if MoveAny:GetEleOption(name, "Hide", false, "Hide3") then
				sel:SetParent(MAHIDDEN)
			else
				sel:SetParent(sel.oldparent)
			end

			sel.ma_setparent = false
		end)

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
	else
		if frame == MACurrentEle then
			dragf.t:SetVertexColor(MoveAny:GetColor("se"))
		else
			dragf.t:SetVertexColor(MoveAny:GetColor("el"))
		end
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

	if frame.SetPointBase then
		--frame.layoutApplyInProgress = true
		function frame:MAUpdatePoint()
			if frame.ma_retry_setpoint and not InCombatLockdown() then
				local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)

				if not InCombatLockdown() and frame.SetPointBase then
					frame:ClearAllPoints()
					frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
				elseif not frame.SetPointBase then
					frame:ClearAllPoints()
					frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
				end

				frame.ma_retry_setpoint = false
			end

			if frame.ma_retry_setpoint then
				C_Timer.After(0.1, frame.MAUpdate)
			end
		end
	end

	hooksecurefunc(frame, "SetPoint", function(sel, ...)
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

			if not InCombatLockdown() and sel.SetPointBase then
				sel:ClearAllPointsBase()
				sel:SetPointBase(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			elseif not sel.SetPointBase then
				sel:ClearAllPoints()
				sel:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			elseif sel.ma_retry_setpoint == false then
				sel.ma_retry_setpoint = true
				frame:MAUpdatePoint()
			end

			sel.elesetpoint = false
		end
	end)

	if not frame.ma_secure then
		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)

		if dbp1 and dbp3 then
			frame:ClearAllPoints()
			frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			frame:ClearAllPoints()
			frame:SetPoint(dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
		end
	end

	hooksecurefunc(frame, "SetScale", function(sel, scale)
		if sel.masetscale_ele then return end
		sel.masetscale_ele = true

		if scale and scale > 0 then
			local dragframe = _G[name .. "_DRAG"]
			dragframe:SetScale(scale)
		end

		sel.masetscale_ele = false
	end)

	if MoveAny:GetEleScale(name) and MoveAny:GetEleScale(name) > 0 then
		frame:SetScale(MoveAny:GetEleScale(name))
	end

	hooksecurefunc(frame, "SetSize", function(sel, w, h)
		local isToSmall = false
		local df = _G[name .. "_DRAG"]
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
	end)

	if not InCombatLockdown() then
		frame:SetSize(sw, sh)
	end

	local dragframe = _G[name .. "_DRAG"]
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
end

local invehicle = nil
local incombat = nil
local lastEle = nil
local lastSize = 0

function MoveAny:SetEleAlpha(ele, alpha)
	if ele:GetAlpha() ~= alpha then
		ele:SetAlpha(alpha)
	end
end

function MoveAny:SetMouseEleAlpha(ele)
	if lastEle and ele ~= lastEle then
		MoveAny:UpdateAlphas()
	end

	lastEle = ele
end

function MoveAny:CheckAlphas()
	if incombat ~= InCombatLockdown() then
		incombat = InCombatLockdown()
		MoveAny:UpdateAlphas()
	elseif UnitInVehicle and invehicle ~= UnitInVehicle("player") then
		invehicle = UnitInVehicle("player")
		MoveAny:UpdateAlphas()
	end

	if lastSize ~= getn(MoveAny:GetAlphaFrames()) then
		lastSize = getn(MoveAny:GetAlphaFrames())
		MoveAny:UpdateAlphas()
	end

	local ele = GetMouseFocus()

	if ele and ele ~= CompactRaidFrameManager then
		if tContains(MoveAny:GetAlphaFrames(), ele) then
			ele:SetAlpha(1)
			MoveAny:SetMouseEleAlpha(ele)
		elseif ele.GetMAEle then
			ele = ele:GetMAEle()
			ele:SetAlpha(1)
			MoveAny:SetMouseEleAlpha(ele)
		elseif lastEle then
			lastEle = nil
			MoveAny:UpdateAlphas()
		end
	elseif lastEle then
		lastEle = nil
		MoveAny:UpdateAlphas()
	end

	C_Timer.After(0.15, MoveAny.CheckAlphas)
end

function MoveAny:UpdateAlphas()
	for i, ele in pairs(MoveAny:GetEleFrames()) do
		if ele == nil then
			MoveAny:MSG("UpdateAlphas: ele is nil")
		else
			local name = MoveAny:GetFrameName(ele)
			local alphaInVehicle = MoveAny:GetEleOption(name, "ALPHAINVEHICLE", 1, "Alpha1")
			local alphaInCombat = MoveAny:GetEleOption(name, "ALPHAINCOMBAT", 1, "Alpha2")
			local alphaNotInCombat = MoveAny:GetEleOption(name, "ALPHANOTINCOMBAT", 1, "Alpha3")
			local alphaInRestedArea = MoveAny:GetEleOption(name, "ALPHAINRESTEDAREA", 1, "Alpha4")
			local alphaIsMounted = MoveAny:GetEleOption(name, "ALPHAISMOUNTED", 1, "Alpha5")

			if UnitInVehicle and invehicle then
				MoveAny:SetEleAlpha(ele, alphaInVehicle)
			elseif IsMounted and IsMounted() then
				MoveAny:SetEleAlpha(ele, alphaIsMounted)
			elseif IsResting and IsResting() then
				MoveAny:SetEleAlpha(ele, alphaInRestedArea)
			else
				if incombat then
					MoveAny:SetEleAlpha(ele, alphaInCombat)
				elseif not incombat then
					MoveAny:SetEleAlpha(ele, alphaNotInCombat)
				end
			end
		end
	end
end

function MoveAny:AnyActionbarEnabled()
	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		return MoveAny:IsEnabled("ACTIONBARS", false) or MoveAny:IsEnabled("ACTIONBAR3", false) or MoveAny:IsEnabled("ACTIONBAR4", false) or MoveAny:IsEnabled("ACTIONBAR7", false) or MoveAny:IsEnabled("ACTIONBAR8", false) or MoveAny:IsEnabled("ACTIONBAR9", false) or MoveAny:IsEnabled("ACTIONBAR10", false)
	else
		return false
	end
end

function MoveAny:Event(event, ...)
	MoveAny.init = MoveAny.init or false
	if MoveAny.init then return end
	MoveAny.init = true
	local _, class = UnitClass("player")

	if IsAddOnLoaded("D4KiR MoveAndImprove") then
		MoveAny:MSG("DON'T use MoveAndImprove, when you use MoveAny")
	end

	if MoveAny.InitSlash then
		MoveAny:InitSlash()
	end

	if MoveAny.InitDB then
		MoveAny:InitDB()
	end

	if MoveAny:IsEnabled("SHOWTIPS", true) then
		MoveAny:MSG(MoveAny:GT("LID_STARTHELP"))
		MoveAny:MSG(MoveAny:GT("LID_STARTHELP2"))
	end

	if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:IsEnabled("ACTIONBARS", false) then
		if MainMenuBarPerformanceBarFrame then
			MainMenuBarPerformanceBarFrame:SetParent(MAHIDDEN)
		end

		if UIPARENT_MANAGED_FRAME_POSITIONS then
			UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
		end

		if MainMenuBarArtFrame then
			if UIPARENT_MANAGED_FRAME_POSITIONS then
				UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBarArtFrame"] = nil
			end

			MainMenuBarArtFrame:SetParent(MAHIDDEN)
		end

		if MainMenuBar then
			MainMenuBar:SetParent(MAHIDDEN)
		end

		if MainMenuBarOverlayFrame then
			MainMenuBarOverlayFrame:SetParent(MAHIDDEN)
		end

		if MainMenuBarExpText then
			MainMenuBarExpText:SetParent(MainMenuExpBar)
		end
	end

	MoveAny:InitActionBarLayouts()

	if MoveAny:AnyActionbarEnabled() then
		MoveAny:CustomBars()
		MoveAny:UpdateABs()
	end

	if MoveAny.InitStanceBar then
		MoveAny:InitStanceBar()
	end

	if MoveAny.InitPetBar then
		MoveAny:InitPetBar()
	end

	if Arena_LoadUI then
		if MoveAny.InitArenaEnemyFrames then
			MoveAny:InitArenaEnemyFrames()
		end

		if MoveAny.InitArenaPrepFrames then
			MoveAny:InitArenaPrepFrames()
		end
	end

	if PlayerCastingBarFrame then
		if MoveAny:IsEnabled("CASTINGBAR", false) then
			MoveAny:RegisterWidget({
				["name"] = "PlayerCastingBarFrame",
				["lstr"] = "LID_CASTINGBAR",
			})
		end

		if MoveAny:IsEnabled("CASTINGBARTIMER", false) then
			PlayerCastingBarFrameT = CreateFrame("FRAME", MoveAny:GetMainPanel())
			PlayerCastingBarFrameT:SetSize(20, 20)
			PlayerCastingBarFrameT:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			PlayerCastingBarFrame.timer:SetParent(PlayerCastingBarFrameT)
			PlayerCastingBarFrame.timer:ClearAllPoints()
			PlayerCastingBarFrame.timer:SetPoint("CENTER", PlayerCastingBarFrameT, "CENTER", 0, 0)

			MoveAny:RegisterWidget({
				["name"] = "PlayerCastingBarFrameT",
				["lstr"] = "LID_CASTINGBARTIMER",
			})
		end
	else
		if MoveAny:IsEnabled("CASTINGBAR", false) then
			MoveAny:RegisterWidget({
				["name"] = "CastingBarFrame",
				["lstr"] = "LID_CASTINGBAR"
			})
		end
	end

	if TotemFrame and MoveAny:IsEnabled("TOTEMFRAME", false) then
		TotemFrame.unit = "player"
		TotemFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "TotemFrame",
			["lstr"] = "LID_TOTEMFRAME",
			["sw"] = 32 * 4,
			["sh"] = 32,
			["userplaced"] = true,
			["secure"] = true,
		})
	end

	if RuneFrame and MoveAny:IsEnabled("RUNEFRAME", false) and class == "DEATHKNIGHT" then
		RuneFrame.unit = "player"
		RuneFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "RuneFrame",
			["lstr"] = "LID_RUNEFRAME"
		})
	end

	if WarlockPowerFrame and MoveAny:IsEnabled("WARLOCKPOWERFRAME", false) and class == "WARLOCK" then
		WarlockPowerFrame.unit = "player"
		WarlockPowerFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "WarlockPowerFrame",
			["lstr"] = "LID_WARLOCKPOWERFRAME"
		})
	end

	if MonkHarmonyBarFrame and MoveAny:IsEnabled("MONKHARMONYBARFRAME", false) and class == "MONK" then
		MonkHarmonyBarFrame.unit = "player"
		MonkHarmonyBarFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "MonkHarmonyBarFrame",
			["lstr"] = "LID_MONKHARMONYBARFRAME"
		})
	end

	if MonkStaggerBar and MoveAny:IsEnabled("MONKSTAGGERBAR", false) and class == "MONK" then
		MonkStaggerBar.unit = "player"
		MonkStaggerBar:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "MonkStaggerBar",
			["lstr"] = "LID_MONKSTAGGERBAR"
		})
	end

	if MageArcaneChargesFrame and MoveAny:IsEnabled("MAGEARCANECHARGESFRAME", false) and class == "MAGE" then
		MageArcaneChargesFrame.unit = "player"
		MageArcaneChargesFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "MageArcaneChargesFrame",
			["lstr"] = "LID_MAGEARCANECHARGESFRAME"
		})
	end

	if (RogueComboPointBarFrame or DruidComboPointBarFrame) and MoveAny:IsEnabled("COMBOPOINTPLAYERFRAME", false) then
		if class == "ROGUE" then
			RogueComboPointBarFrame.unit = "player"
			RogueComboPointBarFrame:SetParent(MoveAny:GetMainPanel())

			MoveAny:RegisterWidget({
				["name"] = "RogueComboPointBarFrame",
				["lstr"] = "LID_COMBOPOINTPLAYERFRAME"
			})
		elseif class == "DRUID" then
			DruidComboPointBarFrame.unit = "player"
			DruidComboPointBarFrame:SetParent(MoveAny:GetMainPanel())

			MoveAny:RegisterWidget({
				["name"] = "DruidComboPointBarFrame",
				["lstr"] = "LID_COMBOPOINTPLAYERFRAME"
			})
		end
	end

	if EssencePlayerFrame and MoveAny:IsEnabled("ESSENCEPLAYERFRAME", false) and class == "EVOKER" then
		EssencePlayerFrame.unit = "player"
		EssencePlayerFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "EssencePlayerFrame",
			["lstr"] = "LID_ESSENCEPLAYERFRAME"
		})
	end

	if PaladinPowerBarFrame and MoveAny:IsEnabled("PALADINPOWERBARFRAME", false) and class == "PALADIN" then
		PaladinPowerBarFrame.unit = "player"
		PaladinPowerBarFrame:SetParent(MoveAny:GetMainPanel())

		MoveAny:RegisterWidget({
			["name"] = "PaladinPowerBarFrame",
			["lstr"] = "LID_PALADINPOWERBARFRAME"
		})
	end

	if MoveAny:IsEnabled("EDITMODE", MoveAny:GetWoWBuildNr() < 100000) then
		if PlayerFrameBackground and MoveAny:IsEnabled("PLAYERFRAMEBACKGROUND", false) then
			MoveAny:RegisterWidget({
				["name"] = "PlayerFrameBackground",
				["lstr"] = "LID_PLAYERFRAMEBACKGROUND",
				["userplaced"] = true
			})
		end

		if MoveAny:IsEnabled("PLAYERFRAME", false) then
			MoveAny:RegisterWidget({
				["name"] = "PlayerFrame",
				["lstr"] = "LID_PLAYERFRAME",
				["userplaced"] = true
			})
		end

		if TargetFrameNameBackground and MoveAny:IsEnabled("TARGETFRAMENAMEBACKGROUND", false) then
			MoveAny:RegisterWidget({
				["name"] = "TargetFrameNameBackground",
				["lstr"] = "LID_TARGETFRAMENAMEBACKGROUND",
				["userplaced"] = true
			})
		end

		if TargetFrameNumericalThreat and MoveAny:IsEnabled("TargetFrameNumericalThreat", false) then
			MoveAny:RegisterWidget({
				["name"] = "TargetFrameNumericalThreat",
				["lstr"] = "LID_TargetFrameNumericalThreat",
				["userplaced"] = true
			})
		end

		if MoveAny:IsEnabled("TARGETFRAMEBUFF1", false) then
			MoveAny:RegisterWidget({
				["name"] = "TargetFrameBuff1",
				["lstr"] = "LID_TARGETFRAMEBUFF1",
				["userplaced"] = true
			})
		end

		if MoveAny:IsEnabled("TARGETFRAME", false) then
			MoveAny:RegisterWidget({
				["name"] = "TargetFrame",
				["lstr"] = "LID_TARGETFRAME",
				["userplaced"] = true
			})
		end

		if FocusFrame and MoveAny:IsEnabled("FOCUSFRAMEBUFF1", false) then
			MoveAny:RegisterWidget({
				["name"] = "FocusFrameBuff1",
				["lstr"] = "LID_FOCUSFRAMEBUFF1",
				["userplaced"] = true
			})
		end

		if FocusFrame and MoveAny:IsEnabled("FOCUSFRAME", false) then
			MoveAny:RegisterWidget({
				["name"] = "FocusFrame",
				["lstr"] = "LID_FOCUSFRAME",
				["userplaced"] = true
			})
		end

		if MoveAny:IsEnabled("BUFFS", false) then
			MoveAny:RegisterWidget({
				["name"] = "MABuffBar",
				["lstr"] = "LID_BUFFS"
			})
		end

		if MoveAny:IsEnabled("DEBUFFS", false) then
			MoveAny:RegisterWidget({
				["name"] = "MADebuffBar",
				["lstr"] = "LID_DEBUFFS"
			})
		end

		if MoveAny:IsEnabled("GAMETOOLTIP", false) then
			MoveAny:RegisterWidget({
				["name"] = "MAGameTooltip",
				["lstr"] = "LID_GAMETOOLTIP"
			})
		end

		if MoveAny:IsEnabled("PETBAR", false) then
			if PetActionBar then
				MoveAny:RegisterWidget({
					["name"] = "PetActionBar",
					["lstr"] = "LID_PETBAR"
				})
			else
				MoveAny:RegisterWidget({
					["name"] = "MAPetBar",
					["lstr"] = "LID_PETBAR"
				})
			end
		end

		if MoveAny:IsEnabled("STANCEBAR", false) and StanceBar then
			MoveAny:RegisterWidget({
				["name"] = "StanceBar",
				["lstr"] = "LID_STANCEBAR",
				["secure"] = true
			})
		end

		if PossessActionBar then
			if MoveAny:IsEnabled("POSSESSBAR", false) then
				MoveAny:RegisterWidget({
					["name"] = "PossessActionBar",
					["lstr"] = "LID_POSSESSBAR"
				})
			end
		elseif PossessBarFrame then
			if MoveAny:IsEnabled("POSSESSBAR", false) then
				if PossessBarFrame then
					PossessBarFrame:SetParent(MoveAny:GetMainPanel())
				end

				MoveAny:RegisterWidget({
					["name"] = "PossessBarFrame",
					["lstr"] = "LID_POSSESSBAR"
				})
			end
		end

		if MoveAny:IsEnabled("LEAVEVEHICLE", false) then
			if MainMenuBar then
				if MainMenuBarVehicleLeaveButton then
					MainMenuBarVehicleLeaveButton:SetParent(MoveAny:GetMainPanel())
				end

				if UnitInVehicle then
					function MoveAny:UpdateVehicleLeaveButton()
						if UnitInVehicle("player") then
							MainMenuBarVehicleLeaveButton:Show()
						else
							MainMenuBarVehicleLeaveButton:Hide()
						end

						C_Timer.After(0.3, MoveAny.UpdateVehicleLeaveButton)
					end

					MoveAny:UpdateVehicleLeaveButton()
				end
			end

			MoveAny:RegisterWidget({
				["name"] = "MainMenuBarVehicleLeaveButton",
				["lstr"] = "LID_LEAVEVEHICLE"
			})
		end

		if ExtraAbilityContainer and MoveAny:IsEnabled("EXTRAABILITYCONTAINER", false) then
			ExtraAbilityContainer:SetSize(180, 100)

			MoveAny:RegisterWidget({
				["name"] = "ExtraAbilityContainer",
				["lstr"] = "LID_EXTRAABILITYCONTAINER",
				["userplaced"] = true
			})
		end

		if TalkingHeadFrame and MoveAny:IsEnabled("TALKINGHEAD", false) then
			MoveAny:RegisterWidget({
				["name"] = "TalkingHeadFrame",
				["lstr"] = "LID_TALKINGHEAD",
				["secure"] = true
			})
		end

		if MoveAny:IsEnabled("OVERRIDEACTIONBAR", false) then
			MoveAny:RegisterWidget({
				["name"] = "OverrideActionBar",
				["lstr"] = "LID_OVERRIDEACTIONBAR"
			})
		end

		if MoveAny:GetWoWBuild() == "RETAIL" then
			local ABNames = {}
			ABNames[1] = "MainMenuBar"
			ABNames[2] = "MultiBarBottomLeft"
			ABNames[3] = "MultiBarBottomRight"
			ABNames[4] = "MultiBarRight"
			ABNames[5] = "MultiBarLeft"
			ABNames[6] = "MultiBar" .. 5
			ABNames[7] = "MultiBar" .. 6
			ABNames[8] = "MultiBar" .. 7

			for i = 1, 8 do
				if ABNames[i] and MoveAny:IsEnabled("ACTIONBAR" .. i, false) then
					local name = ABNames[i]
					local lstr = "LID_ACTIONBAR" .. i

					MoveAny:RegisterWidget({
						["name"] = name,
						["lstr"] = lstr,
						["secure"] = true,
						["userplaced"] = true,
					})

					local ab = _G[name]

					if ab then
						for x = 1, 12 do
							ab.btns = ab.btns or {}
							local abtn = _G[name .. "Button" .. x]

							if i == 1 then
								abtn = _G["ActionButton" .. x]
							end

							if abtn then
								table.insert(ab.btns, abtn)
							else
								print("[MoveAny] ACTION BUTTON NOT FOUND", name)
							end
						end
					end

					local bar = _G[name]

					if bar then
						hooksecurefunc(bar, "SetPoint", function(sel, ...)
							MoveAny:UpdateActionBar(bar)
						end)

						hooksecurefunc(bar, "SetSize", function(sel, ...)
							if sel.ma_uab_setsize then return end
							sel.ma_uab_setsize = true
							MoveAny:UpdateActionBar(bar)
							sel.ma_uab_setsize = false
						end)

						MoveAny:UpdateActionBar(bar)
					end
				end
			end
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:AnyActionbarEnabled() then
			for i = 1, 10 do
				if i ~= 2 and ((i == 1 or i == 5 or i == 6) and MoveAny:IsEnabled("ACTIONBARS", false)) or MoveAny:IsEnabled("ACTIONBAR" .. i, false) then
					MoveAny:RegisterWidget({
						["name"] = "MAActionBar" .. i,
						["lstr"] = "LID_ACTIONBAR" .. i
					})
				end
			end
		end

		if MoveAny:IsEnabled("ENDCAPS", false) then
			local ecl = CreateFrame("FRAME", "MA_LeftEndCap", MoveAny:GetMainPanel())
			ecl.tex = ecl:CreateTexture("ecl.tex", "OVERLAY")
			ecl.tex:SetAllPoints(ecl)
			local ecr = CreateFrame("FRAME", "MA_RightEndCap", MoveAny:GetMainPanel())
			ecr.tex = ecr:CreateTexture("ecr.tex", "OVERLAY")
			ecr.tex:SetAllPoints(ecr)
			local factionGroup = UnitFactionGroup("player")

			if MainMenuBar.EndCaps then
				ecl:SetSize(MainMenuBar.EndCaps.LeftEndCap:GetSize())
				ecl.tex:SetTexCoord(MainMenuBar.EndCaps.LeftEndCap:GetTexCoord())
				ecr:SetSize(MainMenuBar.EndCaps.RightEndCap:GetSize())
				ecr.tex:SetTexCoord(MainMenuBar.EndCaps.RightEndCap:GetTexCoord())

				if factionGroup and factionGroup ~= "Neutral" then
					if factionGroup == "Alliance" then
						ecl.tex:SetAtlas("ui-hud-actionbar-gryphon-left")
						ecr.tex:SetAtlas("ui-hud-actionbar-gryphon-right")
					elseif factionGroup == "Horde" then
						ecl.tex:SetAtlas("ui-hud-actionbar-wyvern-left")
						ecr.tex:SetAtlas("ui-hud-actionbar-wyvern-right")
					end
				end

				MainMenuBar.EndCaps:SetParent(MAHIDDEN)
				MainMenuBar.BorderArt:SetParent(MAHIDDEN)
			elseif MainMenuBarLeftEndCap then
				ecl:SetSize(MainMenuBarLeftEndCap:GetSize())
				ecl.tex:SetTexture(MainMenuBarLeftEndCap:GetTexture())
				ecl.tex:SetTexCoord(MainMenuBarLeftEndCap:GetTexCoord())
				ecr:SetSize(MainMenuBarRightEndCap:GetSize())
				ecr.tex:SetTexture(MainMenuBarRightEndCap:GetTexture())
				ecr.tex:SetTexCoord(MainMenuBarRightEndCap:GetTexCoord())
				MainMenuBarLeftEndCap:SetParent(MAHIDDEN)
				MainMenuBarRightEndCap:SetParent(MAHIDDEN)
			end

			ecl:SetFrameLevel(3)
			ecr:SetFrameLevel(3)
			ecl.tex:SetDrawLayer("OVERLAY", 2)
			ecr.tex:SetDrawLayer("OVERLAY", 2)
			ecl:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)
			ecr:SetPoint("CENTER", MoveAny:GetMainPanel(), "CENTER", 0, 0)

			MoveAny:RegisterWidget({
				["name"] = "MA_LeftEndCap",
				["lstr"] = "LID_ENDCAPLEFT",
			})

			MoveAny:RegisterWidget({
				["name"] = "MA_RightEndCap",
				["lstr"] = "LID_ENDCAPRIGHT",
			})
		end

		for i = 1, 10 do
			local cf = _G["ChatFrame" .. i]

			if cf and MoveAny:IsEnabled("CHAT" .. i, false) and (_G["ChatFrame" .. i .. "Tab"]:GetParent() ~= GeneralDockManager or i == 1) then
				MoveAny:RegisterWidget({
					["name"] = "ChatFrame" .. i,
					["lstr"] = "LID_CHAT",
					["lstri"] = i
				})
			end
		end

		if MoveAny:IsEnabled("QUESTTRACKER", false) then
			C_Timer.After(0, function()
				if ObjectiveTrackerFrame == nil then
					ObjectiveTrackerFrame = CreateFrame("Frame", "ObjectiveTrackerFrame", MoveAny:GetMainPanel())
					ObjectiveTrackerFrame:SetSize(224, 600)
					ObjectiveTrackerFrame:SetPoint("TOPRIGHT", MoveAny:GetMainPanel(), "TOPRIGHT", -85, -180)

					if QuestWatchFrame then
						hooksecurefunc(QuestWatchFrame, "SetPoint", function(sel, ...)
							if sel.qwfsetpoint then return end
							sel.qwfsetpoint = true
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							sel:SetParent(ObjectiveTrackerFrame)
							sel:ClearAllPoints()
							sel:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
							sel.qwfsetpoint = false
						end)

						QuestWatchFrame:SetMovable(true)

						if QuestWatchFrame.SetUserPlaced and QuestWatchFrame:IsMovable() then
							QuestWatchFrame:SetUserPlaced(false)
						end

						QuestWatchFrame:SetParent(ObjectiveTrackerFrame)
						QuestWatchFrame:ClearAllPoints()
						QuestWatchFrame:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
						QuestWatchFrame:SetSize(ObjectiveTrackerFrame:GetSize())
					end

					if WatchFrame then
						hooksecurefunc(WatchFrame, "SetPoint", function(sel, ...)
							if sel.wfsetpoint then return end
							sel.wfsetpoint = true
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							sel:SetParent(ObjectiveTrackerFrame)
							sel:ClearAllPoints()
							sel:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
							sel.wfsetpoint = false
						end)

						WatchFrame:SetMovable(true)

						if WatchFrame.SetUserPlaced and WatchFrame:IsMovable() then
							WatchFrame:SetUserPlaced(false)
						end

						WatchFrame:SetParent(ObjectiveTrackerFrame)
						WatchFrame:ClearAllPoints()
						WatchFrame:SetPoint("TOPLEFT", ObjectiveTrackerFrame, "TOPLEFT", 0, 0)
						WatchFrame:SetSize(ObjectiveTrackerFrame:GetSize())
					end
				end

				if ObjectiveTrackerFrame then
					ObjectiveTrackerFrame:SetHeight(600)

					MoveAny:RegisterWidget({
						["name"] = "ObjectiveTrackerFrame",
						["lstr"] = "LID_QUESTTRACKER",
						["sh"] = 600,
						["userplaced"] = true,
						["secure"] = true,
					})
				end
			end)
		end

		if MoveAny:IsEnabled("PARTYFRAME", false) then
			if PartyFrame then
				MoveAny:RegisterWidget({
					["name"] = "PartyFrame",
					["lstr"] = "LID_PARTYFRAME",
					["sw"] = 120,
					["sh"] = 244
				})
			else
				for i = 1, 4 do
					MoveAny:RegisterWidget({
						["name"] = "PartyMemberFrame" .. i,
						["lstr"] = "LID_PARTYMEMBERFRAME",
						["lstri"] = i
					})
				end
			end
		end
	end

	if MoveAny:IsEnabled("MAPETFRAME", false) then
		MAPetFrame = CreateFrame("FRAME", "MAPetFrame", MoveAny:GetMainPanel())
		MAPetFrame:SetSize(PetFrame:GetSize())
		MAPetFrame:SetPoint(PetFrame:GetPoint())
		PetFrame:SetParent(MAPetFrame)
		PetFrame:ClearAllPoints()
		PetFrame:SetPoint("CENTER", MAPetFrame, "CENTER", 0, 0)

		MoveAny:RegisterWidget({
			["name"] = "MAPetFrame",
			["lstr"] = "LID_PETFRAME",
			["userplaced"] = true
		})
	end

	if MoveAny:IsEnabled("TARGETFRAMESPELLBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "TargetFrameSpellBar",
			["lstr"] = "LID_TARGETFRAMESPELLBAR",
			["userplaced"] = true
		})
	end

	if MoveAny:IsEnabled("FOCUSFRAMESPELLBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "FocusFrameSpellBar",
			["lstr"] = "LID_FOCUSFRAMESPELLBAR",
			["userplaced"] = true
		})
	end

	if MoveAny:IsEnabled("TARGETOFTARGETFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "TargetFrameToT",
			["lstr"] = "LID_TARGETOFTARGETFRAME",
			["userplaced"] = true
		})
	end

	if FocusFrameToT and MoveAny:IsEnabled("TARGETOFFOCUSFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "FocusFrameToT",
			["lstr"] = "LID_TARGETOFFOCUSFRAME",
			["userplaced"] = true
		})
	end

	if CompactRaidFrameManager and MoveAny:IsEnabled("COMPACTRAIDFRAMEMANAGER", false) then
		MACompactRaidFrameManager = CreateFrame("Frame", "MACompactRaidFrameManager", MoveAny:GetMainPanel())
		MACompactRaidFrameManager:SetSize(20, 135)
		MACompactRaidFrameManager:SetPoint("TOPLEFT", MoveAny:GetMainPanel(), "TOPLEFT", 0, -250)

		hooksecurefunc(CompactRaidFrameManager, "SetPoint", function(sel, ...)
			if sel.crfmsetpoint then return end
			sel.crfmsetpoint = true
			sel:SetMovable(true)

			if sel.SetUserPlaced and sel:IsMovable() then
				sel:SetUserPlaced(false)
			end

			if not InCombatLockdown() then
				sel:ClearAllPoints()
				sel:SetPoint("RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0)
			end

			sel.crfmsetpoint = false
		end)

		CompactRaidFrameManager:SetPoint("RIGHT", MACompactRaidFrameManager, "RIGHT", 0, 0)

		hooksecurefunc(CompactRaidFrameManager, "SetParent", function(sel, ...)
			sel:SetFrameStrata("LOW")
		end)

		CompactRaidFrameManagerToggleButton:HookScript("OnClick", function(sel, ...)
			if not InCombatLockdown() then
				if CompactRaidFrameManager.collapsed then
					MACompactRaidFrameManager:SetSize(20, 135)
				else
					MACompactRaidFrameManager:SetSize(200, 135)
				end
			end
		end)

		MoveAny:RegisterWidget({
			["name"] = "MACompactRaidFrameManager",
			["lstr"] = "LID_COMPACTRAIDFRAMEMANAGER"
		})
	end

	if MoveAny:IsEnabled("MAFPSFrame", false) then
		MoveAny:RegisterWidget({
			["name"] = "MAFPSFrame",
			["lstr"] = "LID_MAFPSFrame"
		})
	end

	if IAPingFrame and MoveAny:IsEnabled("IAPingFrame", false) then
		MoveAny:RegisterWidget({
			["name"] = "IAPingFrame",
			["lstr"] = "LID_IAPingFrame"
		})
	end

	if IACoordsFrame and MoveAny:IsEnabled("IACoordsFrame", false) then
		MoveAny:RegisterWidget({
			["name"] = "IACoordsFrame",
			["lstr"] = "LID_IACoordsFrame"
		})
	end

	if IASkills and MoveAny:IsEnabled("IASKILLS", false) and MoveAny:GetWoWBuild() ~= "RETAIL" then
		MoveAny:RegisterWidget({
			["name"] = "IASkills",
			["lstr"] = "LID_IASKILLS"
		})
	end

	if IsAddOnLoaded("!KalielsTracker") and MoveAny:IsEnabled("!KalielsTrackerButtons", false) then
		C_Timer.After(1, function()
			local ktb = _G["!KalielsTrackerButtons"]

			if ktb then
				local MAKTB = CreateFrame("FRAME", "MAKTB", MoveAny:GetMainPanel())
				local size = 28
				local br = 6
				MAKTB:SetSize(size, size * 3 + br * 2)

				hooksecurefunc(ktb, "SetPoint", function(sel, ...)
					if sel.ma_ktb_setpoint then return end
					sel.ma_ktb_setpoint = true
					sel:ClearAllPoints()
					sel:SetPoint("TOP", MAKTB, "TOP", 0, br)
					sel.ma_ktb_setpoint = false
				end)

				ktb:SetPoint("TOP", MAKTB, "TOP", 0, br)

				MoveAny:RegisterWidget({
					["name"] = "MAKTB",
					["lstr"] = "LID_!KalielsTrackerButtons",
				})
			else
				MoveAny:MSG("FAILED TO ADD !KalielsTrackerButtons")
			end
		end)
	end

	-- TOP
	if MoveAny:IsEnabled("ZONETEXTFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "ZoneTextFrame",
			["lstr"] = "LID_ZONETEXTFRAME",
			["userplaced"] = true
		})
	end

	if ObjectiveTrackerBonusBannerFrame and MoveAny:IsEnabled("OBJECTIVETRACKERBONUSBANNERFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "ObjectiveTrackerBonusBannerFrame",
			["lstr"] = "LID_OBJECTIVETRACKERBONUSBANNERFRAME",
			["userplaced"] = true
		})
	end

	if RaidBossEmoteFrame and MoveAny:IsEnabled("RAIDBOSSEMOTEFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "RaidBossEmoteFrame",
			["lstr"] = "LID_RAIDBOSSEMOTEFRAME",
			["userplaced"] = true
		})
	end

	if MoveAny:IsEnabled("UIWIDGETTOPCENTER", false) then
		MoveAny:RegisterWidget({
			["name"] = "UIWidgetTopCenterContainerFrame",
			["lstr"] = "LID_UIWIDGETTOPCENTER",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
		})
	end

	if MoveAny:IsEnabled("MIRRORTIMER1", false) then
		MoveAny:RegisterWidget({
			["name"] = "MirrorTimer1",
			["lstr"] = "LID_MIRRORTIMER1",
		})
	end

	-- TOPRIGHT
	if MoveAny:IsEnabled("UIWIDGETBELOWMINIMAP", false) then
		--UIWidgetBelowMinimapContainerFrame:SetParent( UIParent )
		MoveAny:RegisterWidget({
			["name"] = "UIWidgetBelowMinimapContainerFrame",
			["lstr"] = "LID_UIWIDGETBELOWMINIMAP",
			["sw"] = 36 * 5,
			["sh"] = 36 * 2,
			["userplaced"] = true
		})
	end

	if QueueStatusButton and MoveAny:IsEnabled("QUEUESTATUSBUTTON", false) then
		MoveAny:RegisterWidget({
			["name"] = "QueueStatusButton",
			["lstr"] = "LID_QUEUESTATUSBUTTON"
		})
	end

	if QueueStatusFrame and MoveAny:IsEnabled("QUEUESTATUSFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "QueueStatusFrame",
			["lstr"] = "LID_QUEUESTATUSFRAME"
		})
	end

	if BNToastFrame and MoveAny:IsEnabled("BNToastFrame", false) then
		MoveAny:RegisterWidget({
			["name"] = "BNToastFrame",
			["lstr"] = "LID_BNToastFrame"
		})
	end

	if MoveAny:IsEnabled("VEHICLESEATINDICATOR", false) then
		MoveAny:RegisterWidget({
			["name"] = "MAVehicleSeatIndicator",
			["lstr"] = "LID_VEHICLESEATINDICATOR"
		})
	end

	if MoveAny:IsEnabled("DURABILITY", false) then
		if DurabilityFrame.SetAlerts ~= nil then
			DurabilityFrame:SetAlerts()
		elseif DurabilityFrame_SetAlerts ~= nil then
			DurabilityFrame_SetAlerts()
		end

		MoveAny:RegisterWidget({
			["name"] = "DurabilityFrame",
			["lstr"] = "LID_DURABILITY",
			["userplaced"] = true
		})
	end

	if Arena_LoadUI then
		if MoveAny:IsEnabled("ARENAENEMYFRAMES", false) then
			MoveAny:RegisterWidget({
				["name"] = "MAArenaEnemyFrames",
				["lstr"] = "LID_ARENAENEMYFRAMES",
				["userplaced"] = true,
				["secure"] = true
			})
		end

		if MoveAny:IsEnabled("ARENAPREPFRAMES", false) then
			MoveAny:RegisterWidget({
				["name"] = "MAArenaPrepFrames",
				["lstr"] = "LID_ARENAPREPFRAMES",
				["userplaced"] = true,
				["secure"] = true
			})
		end
	end

	if MoveAny:IsEnabled("BOSSTARGETFRAMECONTAINER", false) then
		MoveAny:RegisterWidget({
			["name"] = "BossTargetFrameContainer",
			["lstr"] = "LID_BOSSTARGETFRAMECONTAINER",
			["userplaced"] = true,
			["secure"] = true
		})
	end

	if MoveAny:IsEnabled("TICKETSTATUSFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "TicketStatusFrame",
			["lstr"] = "LID_TICKETSTATUSFRAME",
			["userplaced"] = true,
			["secure"] = true
		})
	end

	-- RIGHT
	-- BOTTOMRIGHT
	if MoveAny:IsEnabled("MICROMENU", false) then
		MoveAny:RegisterWidget({
			["name"] = "MAMenuBar",
			["lstr"] = "LID_MICROMENU"
		})
	end

	if MoveAny:IsEnabled("BAGS", false) then
		C_Timer.After(4, function()
			MoveAny:RegisterWidget({
				["name"] = "BagsBar",
				["lstr"] = "LID_BAGS"
			})
		end)
	end

	if IAMoneyBar and MoveAny:IsEnabled("MONEYBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "IAMoneyBar",
			["lstr"] = "LID_MONEYBAR"
		})
	end

	if IATokenBar and MoveAny:IsEnabled("TOKENBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "IATokenBar",
			["lstr"] = "LID_TOKENBAR"
		})
	end

	if IAILVLBar and MoveAny:IsEnabled("IAILVLBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "IAILVLBar",
			["lstr"] = "LID_IAILVLBAR"
		})
	end

	if MoveAny:IsEnabled("MINIMAP", false) then
		MoveAny:RegisterWidget({
			["name"] = "Minimap",
			["lstr"] = "LID_MINIMAP"
		})
	end

	local gtp4 = nil
	local gtp5 = nil

	function MANearNumber(num1, num2, near)
		if num1 + near >= num2 and num1 - near <= num2 then return true end

		return false
	end

	function MAGameTooltipOnDefaultPosition()
		local p1, p2, p3, p4, p5 = GameTooltip:GetPoint()

		if p1 and p2 and p3 and p4 and p5 then
			if p2 == MAGameTooltip then
				return true
			elseif p2 == UIParent or p2 == UIParent then
				if gtp4 == nil and gtp5 == nil then
					_, _, _, gtp4, gtp5 = GameTooltip:GetPoint()
					gtp4 = floor(gtp4)
					gtp5 = floor(gtp5)
				end

				if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
					p4 = floor(p4)
					p5 = floor(p5)
					if MANearNumber(p4, gtp4, 1) and MANearNumber(p5, gtp5, 1) then return true end
				end
			elseif p2 == GameTooltipDefaultContainer then
				if p1 == "BOTTOMRIGHT" and p3 == "BOTTOMRIGHT" then
					p4 = floor(p4)
					p5 = floor(p5)
					if MANearNumber(p4, 0, 1) and MANearNumber(p5, 0, 1) then return true end
				end
			end
		end

		return false
	end

	function MAThinkGameTooltip()
		if EditModeManagerFrame ~= nil and EditModeManagerFrame.IsShown and EditModeManagerFrame:IsShown() then
			C_Timer.After(0.1, MAThinkGameTooltip)

			return
		end

		if MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) then
			local owner = GameTooltip:GetOwner()

			if owner and owner == UIParent or owner == UIParent then
				local scale = GameTooltip:GetEffectiveScale()
				local mX, mY = GetCursorPosition()
				mX = mX / scale
				mY = mY / scale
				GameTooltip:ClearAllPoints()
				GameTooltip:SetPoint("BOTTOMLEFT", MoveAny:GetMainPanel(), "BOTTOMLEFT", mX + 22, mY + 22)
				GameTooltip.default = 1
			end

			C_Timer.After(0.01, MAThinkGameTooltip)
		else
			C_Timer.After(1, MAThinkGameTooltip)
		end
	end

	MAThinkGameTooltip()
	GameTooltip:SetMovable(true)
	GameTooltip:SetUserPlaced(false)

	if MoveAny:IsEnabled("GAMETOOLTIP", false) or MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) then
		MAGameTooltip = CreateFrame("Frame", "MAGameTooltip", MoveAny:GetMainPanel())
		MAGameTooltip:SetSize(100, 100)
		MAGameTooltip:SetPoint("BOTTOMRIGHT", MoveAny:GetMainPanel(), "BOTTOMRIGHT", -100, 100)

		hooksecurefunc(GameTooltip, "SetScale", function(sel, ...)
			if sel.gtsetscale then return end
			sel.gtsetscale = true
			sel:SetScale(MAGameTooltip:GetScale())
			sel.gtsetscale = false
		end)

		hooksecurefunc(MAGameTooltip, "SetScale", function(sel, ...)
			if sel.gtsetscale2 then return end
			sel.gtsetscale2 = true
			GameTooltip:SetScale(sel:GetScale())
			sel.gtsetscale2 = false
		end)

		GameTooltip:SetScale(MAGameTooltip:GetScale())

		hooksecurefunc(GameTooltip, "SetAlpha", function(sel, ...)
			if sel.gtsetalpha then return end
			sel.gtsetalpha = true
			sel:SetAlpha(MAGameTooltip:GetAlpha())
			sel.gtsetalpha = false
		end)

		hooksecurefunc(MAGameTooltip, "SetAlpha", function(sel, ...)
			if sel.gtsetalpha2 then return end
			sel.gtsetalpha2 = true
			GameTooltip:SetAlpha(sel:GetAlpha())
			sel.gtsetalpha2 = false
		end)

		GameTooltip:SetAlpha(MAGameTooltip:GetAlpha())

		hooksecurefunc(GameTooltip, "SetPoint", function(sel, ...)
			if sel.gtsetpoint then return end
			sel.gtsetpoint = true
			sel:SetMovable(true)
			sel:SetUserPlaced(false)
			local p1, _, p3, _, _ = MAGameTooltip:GetPoint()

			if MAGameTooltipOnDefaultPosition() and not MoveAny:IsEnabled("GAMETOOLTIP_ONCURSOR", false) then
				sel:ClearAllPoints()
				sel:SetPoint(p1, MAGameTooltip, p3, 0, 0)
			end

			sel.gtsetpoint = false
		end)
	end

	-- BOTTOM
	if ZoneAbilityFrame and MoveAny:IsEnabled("ZONEABILITYFRAME", false) then
		ZoneAbilityFrame:SetParent(MoveAny:GetMainPanel())
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 200)

		MoveAny:RegisterWidget({
			["name"] = "ZoneAbilityFrame",
			["lstr"] = "LID_ZONEABILITYFRAME",
			["userplaced"] = true
		})
	end

	if UIWidgetPowerBarContainerFrame and MoveAny:IsEnabled("UIWIDGETPOWERBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "UIWidgetPowerBarContainerFrame",
			["lstr"] = "LID_UIWIDGETPOWERBAR",
			["sw"] = 36 * 6,
			["sh"] = 36 * 1
		})
	end

	if PlayerPowerBarAlt and MoveAny:IsEnabled("POWERBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "PlayerPowerBarAlt",
			["lstr"] = "LID_POWERBAR",
			["sw"] = 36 * 6,
			["sh"] = 36 * 1
		})
	end

	if EventToastManagerFrame and MoveAny:IsEnabled("EventToastManagerFrame", false) then
		MoveAny:RegisterWidget({
			["name"] = "EventToastManagerFrame",
			["lstr"] = "LID_EventToastManagerFrame",
			["sw"] = 36 * 2,
			["sh"] = 36 * 2
		})
	end

	if MoveAny:GetWoWBuild() == "RETAIL" then
		LoadAddOn("Blizzard_ArchaeologyUI")
	end

	if ArcheologyDigsiteProgressBar and MoveAny:IsEnabled("ARCHEOLOGYDIGSITEPROGRESSBAR", false) then
		MoveAny:RegisterWidget({
			["name"] = "ArcheologyDigsiteProgressBar",
			["lstr"] = "LID_ARCHEOLOGYDIGSITEPROGRESSBAR",
		})
	end

	if UIErrorsFrame and MoveAny:IsEnabled("UIERRORSFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "UIErrorsFrame",
			["lstr"] = "LID_UIERRORSFRAME",
		})
	end

	if MoveAny:IsEnabled("BOSSBANNER", false) and BossBanner then
		MoveAny:RegisterWidget({
			["name"] = "BossBanner",
			["lstr"] = "LID_BOSSBANNER",
		})
	end

	if GroupLootContainer then
		if MoveAny:IsEnabled("GROUPLOOTCONTAINER", false) and GroupLootFrame1 then
			local glfsw, glfsh = GroupLootFrame1:GetSize()

			MoveAny:RegisterWidget({
				["name"] = "GroupLootContainer",
				["lstr"] = "LID_GROUPLOOTCONTAINER",
				["sw"] = glfsw,
				["sh"] = glfsh,
			})
		end
	else
		if MoveAny:IsEnabled("GROUPLOOTFRAME1", false) then
			local glfsw, glfsh = 244, 84

			if GroupLootFrame1 then
				glfsw, glfsh = GroupLootFrame1:GetSize()

				for i = 2, 10 do
					local glf = _G["GroupLootFrame" .. i]

					if glf then
						hooksecurefunc(glf, "SetPoint", function(sel, ...)
							if sel.glfsetpoint then return end
							sel.glfsetpoint = true
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(false)
							end

							sel:ClearAllPoints()
							sel:SetPoint("BOTTOM", _G["GroupLootFrame" .. (i - 1)], "TOP", 0, 4)
							sel.glfsetpoint = false
						end)

						hooksecurefunc(GroupLootFrame1, "SetScale", function(sel, scale)
							glf:SetScale(scale)
						end)

						hooksecurefunc(GroupLootFrame1, "SetAlpha", function(sel, alpha)
							glf:SetAlpha(alpha)
						end)
					end
				end
			end

			MoveAny:RegisterWidget({
				["name"] = "GroupLootFrame1",
				["lstr"] = "LID_GROUPLOOTFRAME1",
				["sw"] = glfsw,
				["sh"] = glfsh,
				["px"] = 0,
				["py"] = 200,
				["an"] = "BOTTOM",
				["re"] = "BOTTOM"
			})
		end
	end

	if MoveAny:IsEnabled("BONUSROLLFRAME", false) and BonusRollFrame then
		MoveAny:RegisterWidget({
			["name"] = "BonusRollFrame",
			["lstr"] = "LID_BONUSROLLFRAME",
		})
	end

	if MainStatusTrackingBarContainer and MoveAny:IsEnabled("MainStatusTrackingBarContainer", false) then
		MoveAny:RegisterWidget({
			["name"] = "MainStatusTrackingBarContainer",
			["lstr"] = "LID_MainStatusTrackingBarContainer",
		})
	end

	if SecondaryStatusTrackingBarContainer and MoveAny:IsEnabled("SecondaryStatusTrackingBarContainer", false) then
		MoveAny:RegisterWidget({
			["name"] = "SecondaryStatusTrackingBarContainer",
			["lstr"] = "LID_SecondaryStatusTrackingBarContainer",
		})
	end

	if StatusTrackingBarManager and MoveAny:IsEnabled("STATUSTRACKINGBARMANAGER", false) then
		-- StatusTrackingBarManager:EnableMouse( true ) -- destroys tooltip
		local sw, sh = StatusTrackingBarManager:GetSize()

		MoveAny:RegisterWidget({
			["name"] = "StatusTrackingBarManager",
			["lstr"] = "LID_STATUSTRACKINGBARMANAGER",
			["sw"] = sw - 6,
			["sh"] = sh - 8,
			["cleft"] = 0,
			["cright"] = 2,
			["ctop"] = 4,
			["cbottom"] = 4,
			["posx"] = 1,
			["posy"] = 4,
		})
	end

	if MainMenuExpBar and ReputationWatchBar then
		if MoveAny:IsEnabled("MAINMENUEXPBAR", false) then
			MainMenuExpBar:SetParent(MoveAny:GetMainPanel())
			--MainMenuExpBar.StatusBar:SetParent(MoveAny:GetMainPanel())
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 140)

			MoveAny:RegisterWidget({
				["name"] = "MainMenuExpBar",
				["lstr"] = "LID_MAINMENUEXPBAR"
			})
		end

		if MoveAny:IsEnabled("REPUTATIONWATCHBAR", false) then
			ReputationWatchBar:SetParent(MoveAny:GetMainPanel())
			--ReputationWatchBar.StatusBar:SetParent(MoveAny:GetMainPanel())
			ReputationWatchBar:ClearAllPoints()
			ReputationWatchBar:SetPoint("BOTTOM", MoveAny:GetMainPanel(), "BOTTOM", 0, 130)

			MoveAny:RegisterWidget({
				["name"] = "ReputationWatchBar",
				["lstr"] = "LID_REPUTATIONWATCHBAR"
			})
		end
	end

	if MoveAny:IsEnabled("TOTEMBAR", false) and MoveAny:GetWoWBuild() == "WRATH" and class == "SHAMAN" then
		if MultiCastActionBarFrame then
			MultiCastActionBarFrame:SetParent(MoveAny:GetMainPanel())
		end

		MoveAny:RegisterWidget({
			["name"] = "MultiCastActionBarFrame",
			["lstr"] = "LID_TOTEMBAR",
			["userplaced"] = true,
			["secure"] = true
		})
	end

	if AlertFrame and MoveAny:IsEnabled("ALERTFRAME", false) then
		local afsw, afsh = 276, 68

		MoveAny:RegisterWidget({
			["name"] = "AlertFrame",
			["lstr"] = "LID_ALERTFRAME",
			["sw"] = afsw,
			["sh"] = afsh
		})

		if AlertFrame and AlertFrame.AddAlertFrame then
			hooksecurefunc(AlertFrame, "AddAlertFrame", function(se, frame)
				if frame.ma_setup == nil then
					frame.ma_setup = true

					hooksecurefunc(AlertFrame, "SetScale", function(sel, scale)
						frame:SetScale(scale)
					end)

					frame:SetScale(AlertFrame:GetScale())

					hooksecurefunc(AlertFrame, "SetAlpha", function(sel, alpha)
						frame:SetAlpha(alpha)
					end)

					frame:SetAlpha(AlertFrame:GetAlpha())
				end
			end)
		end
	end

	-- BOTTOMLEFT
	for i = 1, 10 do
		local cf = _G["ChatFrame" .. i]

		if cf then
			local left = nil

			if MoveAny:IsEnabled("CHATBUTTONFRAME", false) then
				left = 0
			end

			local bottom = nil

			if MoveAny:IsEnabled("CHATEDITBOX", false) then
				bottom = 0
			end

			if left or bottom then
				local l = left or -35
				local b = bottom or -35

				hooksecurefunc(cf, "SetClampRectInsets", function(sel, oL, oR, oT, oB)
					if sel.setclamprectinsets_ma then return end
					sel.setclamprectinsets_ma = true
					local le = left or -35
					local bo = bottom or -35
					sel:SetClampRectInsets(le, 25, 25, bo)
					sel.setclamprectinsets_ma = false
				end)

				cf:SetClampRectInsets(l, 25, 25, b)
			end

			if i > 1 then
				if MoveAny:IsEnabled("CHATBUTTONFRAME", false) then
					local cbf = _G["ChatFrame" .. i .. "ButtonFrame"]

					if cbf then
						hooksecurefunc(cbf, "SetPoint", function(sel, ...)
							if sel.cbfsetpoint then return end
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(true)
							end

							sel.cbfsetpoint = true

							C_Timer.After(0.0, function()
								local sw, _ = _G["ChatFrame" .. 1 .. "ButtonFrame"]:GetSize()
								sel:SetSize(sw, sw * 6)
								sel:ClearAllPoints()
								sel:SetPoint("BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0)
								sel.cbfsetpoint = false
							end)
						end)

						cbf:SetMovable(true)

						if cbf.SetUserPlaced and cbf:IsMovable() then
							cbf:SetUserPlaced(true)
						end

						cbf:ClearAllPoints()
						cbf:SetPoint("BOTTOM", _G["ChatFrame" .. 1 .. "ButtonFrame"], "BOTTOM", 0, 0)
					end

					function MoveAny:UpdateActiveTab()
						local selectedId = 1

						if SELECTED_CHAT_FRAME then
							selectedId = SELECTED_CHAT_FRAME:GetID()
						end

						for x = 1, 10 do
							local cbff = _G["ChatFrame" .. x .. "ButtonFrame"]

							if cbff then
								if x == selectedId then
									cbff:Show()
								else
									cbff:Hide()
								end
							end
						end

						C_Timer.After(0.1, MoveAny.UpdateActiveTab)
					end

					MoveAny:UpdateActiveTab()
				end

				if MoveAny:IsEnabled("CHATEDITBOX", false) then
					local ceb = _G["ChatFrame" .. i .. "EditBox"]

					if ceb then
						hooksecurefunc(ceb, "SetPoint", function(sel, ...)
							if sel.cebsetpoint then return end
							sel:SetMovable(true)

							if sel.SetUserPlaced and sel:IsMovable() then
								sel:SetUserPlaced(true)
							end

							sel.cebsetpoint = true

							if _G["ChatFrame" .. 1 .. "EditBox"] then
								sel:SetSize(_G["ChatFrame" .. 1 .. "EditBox"]:GetSize())
								sel:ClearAllPoints()
								sel:SetPoint("CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0)
							end

							sel.cebsetpoint = false
						end)

						ceb:SetMovable(true)

						if ceb.SetUserPlaced and ceb:IsMovable() then
							ceb:SetUserPlaced(true)
						end

						ceb:ClearAllPoints()
						ceb:SetPoint("CENTER", _G["ChatFrame" .. 1 .. "EditBox"], "CENTER", 0, 0)
					end
				end
			end
		end
	end

	if MoveAny:IsEnabled("CHATBUTTONFRAME", false) then
		local cbf = _G["ChatFrame" .. 1 .. "ButtonFrame"]
		cbf:EnableMouse(true)

		MoveAny:RegisterWidget({
			["name"] = "ChatFrame" .. 1 .. "ButtonFrame",
			["lstr"] = "LID_CHATBUTTONFRAME",
		})

		if ChatFrameMenuButton then
			function ChatFrameMenuButton:GetMAEle()
				return cbf
			end
		end

		if ChatFrameChannelButton then
			function ChatFrameChannelButton:GetMAEle()
				return cbf
			end
		end
	end

	if MoveAny:IsEnabled("CHATEDITBOX", false) then
		local ceb = _G["ChatFrame" .. 1 .. "EditBox"]

		if ceb then
			hooksecurefunc(ceb, "SetClampRectInsets", function(sel)
				if sel.setclamprectinsets_ma then return end
				sel.setclamprectinsets_ma = true
				sel:SetClampRectInsets(2, 2, 2, 2)
				sel.setclamprectinsets_ma = false
			end)

			ceb:SetClampRectInsets(2, 2, 2, 2)
		end

		MoveAny:RegisterWidget({
			["name"] = "ChatFrame" .. 1 .. "EditBox",
			["lstr"] = "LID_CHATEDITBOX",
		})
	end

	if QuickJoinToastButton and MoveAny:IsEnabled("CHATQUICKJOIN", false) then
		MoveAny:RegisterWidget({
			["name"] = "QuickJoinToastButton",
			["lstr"] = "LID_CHATQUICKJOIN"
		})
	end

	-- LEFT
	-- CENTER
	if SpellActivationOverlayFrame and MoveAny:IsEnabled("SPELLACTIVATIONOVERLAYFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "SpellActivationOverlayFrame",
			["lstr"] = "LID_SPELLACTIVATIONOVERLAYFRAME"
		})
	end

	if LossOfControlFrame and MoveAny:IsEnabled("LOSSOFCONTROLFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "LossOfControlFrame",
			["lstr"] = "LID_LOSSOFCONTROLFRAME"
		})
	end

	if GhostFrame and MoveAny:IsEnabled("GHOSTFRAME", false) then
		MoveAny:RegisterWidget({
			["name"] = "GhostFrame",
			["lstr"] = "LID_GHOSTFRAME",
			["sw"] = 130,
			["sh"] = 45,
		})
	end

	if UIPARENT_MANAGED_FRAME_POSITIONS and UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] then
		ArenaEnemyFrames:SetMovable(true)
		ArenaEnemyFrames:SetUserPlaced(true)
		UIPARENT_MANAGED_FRAME_POSITIONS["ArenaEnemyFrames"] = nil
	end

	MoveAny:InitMALock()

	if MoveAny:IsEnabled("EDITMODE", MoveAny:GetWoWBuildNr() < 100000) then
		if MoveAny.InitMinimap then
			MoveAny:InitMinimap()
		end

		if MoveAny.InitBuffBar then
			MoveAny:InitBuffBar()
		end

		if MoveAny.InitDebuffBar then
			MoveAny:InitDebuffBar()
		end
	end

	if MoveAny.InitMicroMenu then
		MoveAny:InitMicroMenu()
	end

	if MoveAny.InitBags then
		MoveAny:InitBags()
	end

	if MoveAny.InitMAFPSFrame then
		MoveAny:InitMAFPSFrame()
	end

	if MoveAny.InitMultiCastActionBar then
		MoveAny:InitMultiCastActionBar()
	end

	if MoveAny.InitPartyFrame then
		MoveAny:InitPartyFrame()
	end

	if MoveAny.MoveFrames then
		MoveAny:MoveFrames()
	end

	if MoveAny.InitMAVehicleSeatIndicator then
		MoveAny:InitMAVehicleSeatIndicator()
	end

	if WorldMapFrame then
		if WorldMapFrame.Minimize then
			hooksecurefunc(WorldMapFrame, "Minimize", function(sel)
				sel:SetScale(1)
			end)

			hooksecurefunc(WorldMapFrame, "Maximize", function(sel)
				sel:SetScale(1)
			end)
		end

		if MoveAny:GetWoWBuild() ~= "RETAIL" then
			WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
				local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
				local scale = WorldMapFrame:GetScale()

				if not IsAddOnLoaded("Mapster") then
					return x / scale, y / scale
				else
					local reverseEffectiveScale = 1 / UIParent:GetEffectiveScale()

					return x / scale * reverseEffectiveScale, y / scale * reverseEffectiveScale
				end
			end
		end
	end

	MoveAnyMinimapIcon = LibStub("LibDataBroker-1.1"):NewDataObject("MoveAnyMinimapIcon", {
		type = "data source",
		text = "MoveAnyMinimapIcon",
		icon = 135994,
		OnClick = function(sel, btn)
			if btn == "LeftButton" then
				MoveAny:ToggleMALock()
			elseif IsShiftKeyDown() and btn == "RightButton" then
				MoveAny:HideMinimapButton()
			end
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("MoveAny")
			tooltip:AddLine(MoveAny:GT("LID_MMBTNLEFT"))
			tooltip:AddLine(MoveAny:GT("LID_MMBTNRIGHT"))
		end,
	})

	if MoveAnyMinimapIcon then
		MAMMBTN = LibStub("LibDBIcon-1.0", true)

		if MAMMBTN then
			MAMMBTN:Register("MoveAnyMinimapIcon", MoveAnyMinimapIcon, MoveAny:GetMinimapTable())
		end
	end

	if MAMMBTN then
		if MoveAny:IsEnabled("SHOWMINIMAPBUTTON", true) then
			MAMMBTN:Show("MoveAnyMinimapIcon")
		else
			MAMMBTN:Hide("MoveAnyMinimapIcon")
		end
	end

	if MoveAny:IsEnabled("MALOCK", false) then
		MoveAny:ShowMALock()
	end

	if MoveAny:IsEnabled("MAPROFILES", false) then
		MoveAny:ShowProfiles()
	end

	C_Timer.After(1, function()
		MoveAny:CheckAlphas()
	end)

	MoveAny:UpdateMALock()
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", MoveAny.Event)
f:RegisterEvent("PLAYER_LOGIN")