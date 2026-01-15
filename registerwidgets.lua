local _, MoveAny = ...
local hooksecurefunc = getglobal("hooksecurefunc")
local CreateFrame = getglobal("CreateFrame")
local InCombatLockdown = getglobal("InCombatLockdown")
local getn = getglobal("getn")
local tinsert = getglobal("tinsert")
local format = getglobal("format")
local framelevel = 1100
local btnsize = 24
local ses = {}
local runSelectedReset = false
local fnt = {}
local MACurrentEle = nil
local MAEF = {}
local startRegisterWidget = false
local missingWidgets = {}
local retryFrame = CreateFrame("Frame")
MoveAny:OnEvent(
	retryFrame,
	function(sel, event, ...)
		MoveAny:SafeRetryRegisterWidgets()
	end, "retryFrame"
)

function MoveAny:GetMissingWidgets()
	return missingWidgets
end

function MoveAny:RetryRegisterWidgets()
	for name, tab in pairs(MoveAny:GetMissingWidgets()) do
		MoveAny:RegisterWidget(tab)
	end
end

function MoveAny:SafeRetryRegisterWidgets()
	if not startRegisterWidget then return end
	MoveAny:RetryRegisterWidgets()
end

hooksecurefunc(
	"CreateFrame",
	function(...)
		if not startRegisterWidget then return end
		MoveAny:SafeRetryRegisterWidgets()
	end
)

MoveAny:After(
	2,
	function()
		MoveAny:RetryRegisterWidgets()
	end, "Init startRegisterWidget 1"
)

MoveAny:After(
	7,
	function()
		startRegisterWidget = true
		MoveAny:RegisterEvent(retryFrame, "ADDON_LOADED")
		MoveAny:RetryRegisterWidgets()
	end, "Init startRegisterWidget 2"
)

function MoveAny:GetEleFrames()
	return MAEF
end

function MoveAny:GetCurrentEle()
	return MACurrentEle
end

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

local function SelectTab(sel)
	PanelTemplates_SetTab(MoveAny:GetParent(sel), sel:GetID())
	local content = MoveAny:GetParent(sel).currentcontent
	if content then
		content:Hide()
	end

	MoveAny:GetParent(sel).currentcontent = sel.content
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

		frame.tabs[i] = MoveAny:CreateButton(MoveAny:GetName(frame) .. "Tab" .. i, frame, false, template)
		local tab = frame.tabs[i]
		tab:SetID(i)
		tab:SetText(args[i])
		tab:SetScript(
			"OnClick",
			function(sel)
				SelectTab(sel)
			end
		)

		tab.content = CreateFrame("Frame", MoveAny:GetName(frame) .. "Tab" .. i .. "Content", frame)
		tab.content.name = args[i]
		tab.content:SetSize(sw - 12, sh - 26 - 6)
		tab.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -26)
		tab.content:Hide()
		PanelTemplates_TabResize(tab, 0)
		if i == 1 then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 2)
		else
			tab:SetPoint("TOPLEFT", _G[MoveAny:GetName(frame) .. "Tab" .. (i - 1)], "TOPRIGHT", 4, 0)
		end
	end

	SelectTab(frame.tabs[1])

	return frame.tabs
end

local function MAMoveButton(parent, name, ofsx, ofsy, x, y, texNor, texPus)
	local btn = MoveAny:CreateButton("MOVE" .. x .. y, parent, true)
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

function MoveAny:CreateSliderOld(parent, x, y, name, key, value, steps, vmin, vmax, func, lanArray)
	local slider = nil
	if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
		slider = CreateFrame("Slider", nil, parent, "MinimalSliderWithSteppersTemplate")
	elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
		slider = CreateFrame("Slider", nil, parent, "UISliderTemplate")
	else
		slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
	end

	slider:SetSize(parent:GetWidth() - 20 - x, 16)
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	if slider.Low == nil then
		slider.Low = slider:CreateFontString(nil, nil, "GameFontNormal")
		slider.Low:SetPoint("BOTTOMLEFT", slider, "BOTTOMLEFT", 0, -12)
		MoveAny:SetFontSize(slider.Low, 10, "THINOUTLINE")
		slider.Low:SetTextColor(1, 1, 1)
	end

	if slider.High == nil then
		slider.High = slider:CreateFontString(nil, nil, "GameFontNormal")
		slider.High:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, -12)
		MoveAny:SetFontSize(slider.High, 10, "THINOUTLINE")
		slider.High:SetTextColor(1, 1, 1)
	end

	if slider.Text == nil then
		slider.Text = slider:CreateFontString(nil, nil, "GameFontNormal")
		slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
		MoveAny:SetFontSize(slider.Text, 12, "THINOUTLINE")
		slider.Text:SetTextColor(1, 1, 1)
	end

	slider.Low:SetText(vmin)
	slider.High:SetText(vmax)
	if lanArray then
		slider.Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. lanArray[MoveAny:GetEleOption(name, key, value)])
	else
		slider.Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. MoveAny:GetEleOption(name, key, value))
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
					slider.Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. lanArray[val])
				else
					slider.Text:SetText(MoveAny:Trans("LID_" .. key) .. ": " .. val)
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
	local optionFrame = frame
	if frame == StanceBarAnchor then
		frame = StanceBar
	end

	if frame == nil then
		MoveAny:MSG("FRAME NOT FOUND")

		return
	end

	local name = MoveAny:GetFrameName(optionFrame)
	local opts = MoveAny:GetEleOptions(name, "MenuOptions")
	local tabs = {GENERAL}
	if string.find(name, "MAActionBar") or string.find(name, "MultiBar") or name == "MainActionBar" or name == "MainMenuBar" or name == "MAMenuBar" or name == "PetActionBar" or name == "MAPetBar" or name == "StanceBarAnchor" then
		table.insert(tabs, ACTIONBARS_LABEL)
	end

	if string.find(name, "MABuffBar") or string.find(name, "BuffFrame") then
		table.insert(tabs, MoveAny:Trans("LID_BUFFS"))
	end

	if string.find(name, "MADebuffBar") or string.find(name, "DebuffFrame") then
		table.insert(tabs, MoveAny:Trans("LID_DEBUFFS"))
	end

	if string.find(name, "TargetFrameBuffMover") then
		table.insert(tabs, MoveAny:Trans("LID_BUFFS"))
	end

	if string.find(name, "TargetFrameDebuffMover") then
		table.insert(tabs, MoveAny:Trans("LID_DEBUFFS"))
	end

	if string.find(name, "FocusFrameBuffMover") then
		table.insert(tabs, MoveAny:Trans("LID_BUFFS"))
	end

	if string.find(name, "FocusFrameDebuffMover") then
		table.insert(tabs, MoveAny:Trans("LID_DEBUFFS"))
	end

	if string.find(name, "MainMenuExpBar") then
		table.insert(tabs, MoveAny:Trans("LID_MAINMENUEXPBAR"))
	end

	if string.find(name, "ReputationWatchBar") then
		table.insert(tabs, MoveAny:Trans("LID_REPUTATIONWATCHBAR"))
	end

	if string.find(name, "BagsBar") then
		table.insert(tabs, MoveAny:Trans("LID_BAGEXTRAS"))
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
			local sup = MoveAny:CreateButton("sup", content, true)
			sup:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
			sup:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			sup:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sup:SetSize(btnsize, btnsize)
			sup:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -24)
			sup:SetScript(
				"OnClick",
				function()
					local val = tonumber(string.format("%.1f", optionFrame:GetScale() + 0.1))
					MoveAny:SetEleScale(name, val)
					content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
				end
			)

			local sup2 = MoveAny:CreateButton("sup2", content, true)
			sup2:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Up")
			sup2:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollUp-Down")
			sup2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sup2:SetSize(btnsize, btnsize)
			sup2:SetPoint("TOPLEFT", content, "TOPLEFT", 220, -24)
			sup2:SetScript(
				"OnClick",
				function()
					local val = tonumber(string.format("%.2f", optionFrame:GetScale() + 0.01))
					MoveAny:SetEleScale(name, val)
					content.scale:SetText(format("Scale: %0.2f", MoveAny:GetEleScale(name)))
				end
			)

			local sdn = MoveAny:CreateButton("sdn", content, true)
			sdn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			sdn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			sdn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sdn:SetSize(btnsize, btnsize)
			sdn:SetPoint("TOPLEFT", content, "TOPLEFT", 200, -48)
			sdn:SetScript(
				"OnClick",
				function()
					if frame:GetScale() > 0.2 then
						local val = tonumber(string.format("%.1f", optionFrame:GetScale() - 0.1))
						MoveAny:SetEleScale(name, val)
						content.scale:SetText(format("Scale: %0.1f", MoveAny:GetEleScale(name)))
					end
				end
			)

			local sdn2 = MoveAny:CreateButton("sdn2", content, true)
			sdn2:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
			sdn2:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
			sdn2:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			sdn2:SetSize(btnsize, btnsize)
			sdn2:SetPoint("TOPLEFT", content, "TOPLEFT", 220, -48)
			sdn2:SetScript(
				"OnClick",
				function()
					if frame:GetScale() > 0.2 then
						local val = tonumber(string.format("%.2f", optionFrame:GetScale() - 0.01))
						MoveAny:SetEleScale(name, val)
						content.scale:SetText(format("Scale: %0.2f", MoveAny:GetEleScale(name)))
					end
				end
			)

			local resetDB = MoveAny:CreateButton("resetdb", content)
			resetDB:SetText(MoveAny:Trans("LID_RESETELEMENT"))
			resetDB:SetSize(btnsize * 6, btnsize)
			resetDB:SetPoint("TOPLEFT", content, "TOPLEFT", 300, -8)
			resetDB:SetScript(
				"OnClick",
				function()
					MoveAny:ResetElement(name)
					MoveAny:TrySaveEditMode()
					if C_UI then
						C_UI.Reload()
					else
						ReloadUI()
					end
				end
			)

			local hide = MoveAny:CreateCheckButton("hide", content)
			hide:SetSize(btnsize, btnsize)
			hide:SetPoint("TOPLEFT", content, "TOPLEFT", 150, -110)
			hide:SetChecked(MoveAny:GetEleOption(name, "Hide", false, "Hide1"))
			hide:SetText(HIDE)
			hide:SetScript(
				"OnClick",
				function()
					local checked = hide:GetChecked()
					MoveAny:SetEleOption(name, "Hide", checked)
					local dragf = _G[name .. "_MA_DRAG"]
					if checked then
						MoveAny:HideFrame(optionFrame)
						dragf.t:SetVertexColor(MoveAny:GetColor("hidden"))
						if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
							dragf:Hide()
						else
							dragf:Show()
						end
					else
						MoveAny:ShowFrame(optionFrame)
						if MACurrentEle == optionFrame then
							dragf.t:SetVertexColor(MoveAny:GetColor("se"))
						else
							dragf.t:SetVertexColor(MoveAny:GetColor("el"))
						end
					end
				end
			)

			hide.text = hide:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			MoveAny:SetFontSize(hide.text, 12, "THINOUTLINE")
			hide.text:SetPoint("LEFT", hide, "RIGHT", 0, 0)
			hide.text:SetText(getglobal("HIDE"))
			local clickthrough = MoveAny:CreateCheckButton("clickthrough", content)
			clickthrough:SetSize(btnsize, btnsize)
			clickthrough:SetPoint("TOPLEFT", content, "TOPLEFT", 150, -140)
			clickthrough:SetChecked(MoveAny:GetEleOption(name, "ClickThrough", false, "ClickThrough1"))
			clickthrough:SetText(MoveAny:Trans("LID_CLICKTHROUGH"))
			clickthrough:SetScript(
				"OnClick",
				function()
					local checked = clickthrough:GetChecked()
					MoveAny:SetEleOption(name, "ClickThrough", checked)
					local dragf = _G[name .. "_MA_DRAG"]
					if checked then
						if optionFrame then
							dragf:Show()
							dragf.t:SetVertexColor(MoveAny:GetColor("clickthrough"))
							optionFrame:EnableMouse(false)
							if optionFrame.AuraContainer then
								MoveAny:ForeachChildren(
									optionFrame.AuraContainer,
									function(child)
										if C_Widget.IsWidget(child) then
											child:EnableMouse(false)
										end
									end, "clickthrough 2"
								)
							else
								MoveAny:ForeachChildren(
									optionFrame,
									function(child)
										if C_Widget.IsWidget(child) then
											child:EnableMouse(false)
										end
									end, "clickthrough 1"
								)
							end
						else
							dragf:Hide()
						end
					else
						if optionFrame then
							dragf.t:SetVertexColor(MoveAny:GetColor("el"))
							optionFrame:EnableMouse(true)
							if optionFrame.AuraContainer then
								MoveAny:ForeachChildren(
									optionFrame.AuraContainer,
									function(child)
										if C_Widget.IsWidget(child) then
											child:EnableMouse(true)
										end
									end, "clickthrough 2"
								)
							else
								MoveAny:ForeachChildren(
									optionFrame,
									function(child)
										if C_Widget.IsWidget(child) then
											child:EnableMouse(true)
										end
									end, "clickthrough 1"
								)
							end
						else
							dragf:Hide()
						end
					end
				end
			)

			clickthrough.text = clickthrough:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			MoveAny:SetFontSize(clickthrough.text, 12, "THINOUTLINE")
			clickthrough.text:SetPoint("LEFT", clickthrough, "RIGHT", 0, 0)
			clickthrough.text:SetText(MoveAny:Trans("LID_CLICKTHROUGH"))
			if MoveAny:GetWoWBuildNr() < 120000 then
				local fullhp = MoveAny:CreateCheckButton("FULLHPENABLED", content)
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
			end

			local space = -30
			local Y = -190
			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAINCOMBAT", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
			Y = Y + space
			if MoveAny:GetWoWBuildNr() < 120000 then
				MoveAny:CreateSliderOld(content, 30, Y, name, "ALPHAISFULLHEALTH", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
				Y = Y + space
			end

			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAINVEHICLE", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
			Y = Y + space
			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAISMOUNTED", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
			Y = Y + space
			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAINRESTEDAREA", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
			Y = Y + space
			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAISSTEALTHED", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
			Y = Y + space
			if C_PetBattles then
				MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAISINPETBATTLE", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
				Y = Y + space
			end

			if DragonridingUtil then
				MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHAISSKYRIDING", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
				Y = Y + space
			end

			MoveAny:CreateSliderOld(content, 10, Y, name, "ALPHANOTINCOMBAT", 1, 0.1, 0, 1, MoveAny.SafeUpdateAlphas)
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
			local MAActionBar1 = getglobal("MAActionBar1")
			local vmin = 1
			if frame == MAActionBar1 or frame == MainActionBar or frame == MainMenuBar then
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
			if frame ~= MAMenuBar and optionFrame ~= StanceBarAnchor then
				if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
					slides.sliderCount = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
				elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
					slides.sliderCount = CreateFrame("Slider", nil, content, "UISliderTemplate")
				else
					slides.sliderCount = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				end

				local sliderCount = slides.sliderCount
				sliderCount:SetSize(content:GetWidth() - 110, 16)
				sliderCount:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				if sliderCount.Low == nil then
					sliderCount.Low = sliderCount:CreateFontString(nil, nil, "GameFontNormal")
					sliderCount.Low:SetPoint("BOTTOMLEFT", sliderCount, "BOTTOMLEFT", 0, -12)
					MoveAny:SetFontSize(sliderCount.Low, 10, "THINOUTLINE")
					sliderCount.Low:SetTextColor(1, 1, 1)
				end

				if sliderCount.High == nil then
					sliderCount.High = sliderCount:CreateFontString(nil, nil, "GameFontNormal")
					sliderCount.High:SetPoint("BOTTOMRIGHT", sliderCount, "BOTTOMRIGHT", 0, -12)
					MoveAny:SetFontSize(sliderCount.High, 10, "THINOUTLINE")
					sliderCount.High:SetTextColor(1, 1, 1)
				end

				if sliderCount.Text == nil then
					sliderCount.Text = sliderCount:CreateFontString(nil, nil, "GameFontNormal")
					sliderCount.Text:SetPoint("TOP", sliderCount, "TOP", 0, 16)
					MoveAny:SetFontSize(sliderCount.Text, 12, "THINOUTLINE")
					sliderCount.Text:SetTextColor(1, 1, 1)
				end

				sliderCount.Low:SetText("")
				sliderCount.High:SetText("")
				sliderCount.Text:SetText(MoveAny:Trans("LID_COUNT") .. ": " .. count)
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
							sel.Text:SetText(MoveAny:Trans("LID_COUNT") .. ": " .. val)
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

			if #items >= 1 and optionFrame ~= StanceBarAnchor then
				if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
					slides.sliderRows = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
				elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
					slides.sliderRows = CreateFrame("Slider", nil, content, "UISliderTemplate")
				else
					slides.sliderRows = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				end

				local sliderRows = slides.sliderRows
				sliderRows:SetSize(content:GetWidth() - 110, 16)
				sliderRows:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				if sliderRows.Low == nil then
					sliderRows.Low = sliderRows:CreateFontString(nil, nil, "GameFontNormal")
					sliderRows.Low:SetPoint("BOTTOMLEFT", sliderRows, "BOTTOMLEFT", 0, -12)
					MoveAny:SetFontSize(sliderRows.Low, 10, "THINOUTLINE")
					sliderRows.Low:SetTextColor(1, 1, 1)
				end

				if sliderRows.High == nil then
					sliderRows.High = sliderRows:CreateFontString(nil, nil, "GameFontNormal")
					sliderRows.High:SetPoint("BOTTOMRIGHT", sliderRows, "BOTTOMRIGHT", 0, -12)
					MoveAny:SetFontSize(sliderRows.High, 10, "THINOUTLINE")
					sliderRows.High:SetTextColor(1, 1, 1)
				end

				if sliderRows.Text == nil then
					sliderRows.Text = sliderRows:CreateFontString(nil, nil, "GameFontNormal")
					sliderRows.Text:SetPoint("TOP", sliderRows, "TOP", 0, 16)
					MoveAny:SetFontSize(sliderRows.Text, 12, "THINOUTLINE")
					sliderRows.Text:SetTextColor(1, 1, 1)
				end

				sliderRows.Low:SetText("")
				sliderRows.High:SetText("")
				sliderRows.Text:SetText(MoveAny:Trans("LID_ROWS") .. ": " .. rows)
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
							sel.Text:SetText(MoveAny:Trans("LID_ROWS") .. ": " .. value)
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

			if optionFrame ~= StanceBarAnchor then
				if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
					slides.offset = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
				elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
					slides.offset = CreateFrame("Slider", nil, content, "UISliderTemplate")
				else
					slides.offset = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				end

				local sliderOffset = slides.offset
				sliderOffset:SetSize(content:GetWidth() - 110, 16)
				sliderOffset:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				if sliderOffset.Low == nil then
					sliderOffset.Low = sliderOffset:CreateFontString(nil, nil, "GameFontNormal")
					sliderOffset.Low:SetPoint("BOTTOMLEFT", sliderOffset, "BOTTOMLEFT", 0, -12)
					MoveAny:SetFontSize(sliderOffset.Low, 10, "THINOUTLINE")
					sliderOffset.Low:SetTextColor(1, 1, 1)
				end

				if sliderOffset.High == nil then
					sliderOffset.High = sliderOffset:CreateFontString(nil, nil, "GameFontNormal")
					sliderOffset.High:SetPoint("BOTTOMRIGHT", sliderOffset, "BOTTOMRIGHT", 0, -12)
					MoveAny:SetFontSize(sliderOffset.High, 10, "THINOUTLINE")
					sliderOffset.High:SetTextColor(1, 1, 1)
				end

				if sliderOffset.Text == nil then
					sliderOffset.Text = sliderOffset:CreateFontString(nil, nil, "GameFontNormal")
					sliderOffset.Text:SetPoint("TOP", sliderOffset, "TOP", 0, 16)
					MoveAny:SetFontSize(sliderOffset.Text, 12, "THINOUTLINE")
					sliderOffset.Text:SetTextColor(1, 1, 1)
				end

				sliderOffset.Low:SetText("-4")
				sliderOffset.High:SetText("8")
				sliderOffset.Text:SetText(MoveAny:Trans("LID_OFFSET") .. ": " .. offset)
				sliderOffset:SetMinMaxValues(-4, 8)
				sliderOffset:SetObeyStepOnDrag(true)
				sliderOffset:SetValueStep(1)
				sliderOffset:SetValue(offset)
				sliderOffset:SetScript(
					"OnValueChanged",
					function(sel, value)
						value = tonumber(string.format("%" .. 0 .. "f", value))
						if value and value ~= opts["OFFSET"] then
							opts["OFFSET"] = value
							sel.Text:SetText(MoveAny:Trans("LID_OFFSET") .. ": " .. value)
							if MoveAny.UpdateActionBar then
								MoveAny:UpdateActionBar(frame)
							end
						end
					end
				)

				PY = PY - 30
				local flipped = MoveAny:CreateCheckButton("flipped", content)
				flipped:SetSize(btnsize, btnsize)
				flipped:SetPoint("TOPLEFT", content, "TOPLEFT", 4, PY)
				flipped:SetChecked(MoveAny:GetEleOption(name, "FLIPPED", false, "Flipped1"))
				flipped:SetText(MoveAny:Trans("LID_FLIPPED"))
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

				flipped.text = flipped:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				MoveAny:SetFontSize(flipped.text, 12, "THINOUTLINE")
				flipped.text:SetPoint("LEFT", flipped, "RIGHT", 0, 0)
				flipped.text:SetText(MoveAny:Trans("LID_FLIPPED"))
				PY = PY - 40
			end

			opts["SPACING"] = opts["SPACING"] or 2
			if true then
				local slider = nil
				if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
					slider = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
				elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
					slider = CreateFrame("Slider", nil, content, "UISliderTemplate")
				else
					slider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
				end

				slider:SetSize(content:GetWidth() - 110, 16)
				slider:SetPoint("TOPLEFT", content, "TOPLEFT", 10, PY)
				if slider.Low == nil then
					slider.Low = slider:CreateFontString(nil, nil, "GameFontNormal")
					slider.Low:SetPoint("BOTTOMLEFT", slider, "BOTTOMLEFT", 0, -12)
					MoveAny:SetFontSize(slider.Low, 10, "THINOUTLINE")
					slider.Low:SetTextColor(1, 1, 1)
				end

				if slider.High == nil then
					slider.High = slider:CreateFontString(nil, nil, "GameFontNormal")
					slider.High:SetPoint("BOTTOMRIGHT", slider, "BOTTOMRIGHT", 0, -12)
					MoveAny:SetFontSize(slider.High, 10, "THINOUTLINE")
					slider.High:SetTextColor(1, 1, 1)
				end

				if slider.Text == nil then
					slider.Text = slider:CreateFontString(nil, nil, "GameFontNormal")
					slider.Text:SetPoint("TOP", slider, "TOP", 0, 16)
					MoveAny:SetFontSize(slider.Text, 12, "THINOUTLINE")
					slider.Text:SetTextColor(1, 1, 1)
				end

				slider.Low:SetText(0)
				slider.High:SetText(16)
				slider.Text:SetText(MoveAny:Trans("LID_SPACING") .. ": " .. opts["SPACING"])
				slider:SetMinMaxValues(0, 16)
				slider:SetObeyStepOnDrag(true)
				slider:SetValueStep(1)
				slider:SetValue(opts["SPACING"])
				slider:SetScript(
					"OnValueChanged",
					function(sel, valu)
						valu = tonumber(string.format("%" .. 0 .. "f", valu))
						if valu and valu ~= opts["SPACING"] then
							opts["SPACING"] = valu
							slider.Text:SetText(MoveAny:Trans("LID_SPACING") .. ": " .. valu)
							if MoveAny.UpdateActionBar then
								MoveAny:UpdateActionBar(frame)
							end
						end
					end
				)

				PY = PY - 30
			end

			if frame == MAActionBar1 or frame == MainActionBar then
				local catstealth = MoveAny:CreateCheckButton("catstealth", content)
				catstealth:SetSize(btnsize, btnsize)
				catstealth:SetPoint("TOPLEFT", content, "TOPLEFT", 4, PY)
				catstealth:SetChecked(MoveAny:IsEnabled("CHANGEONCATSTEALTH", true))
				catstealth:SetScript(
					"OnClick",
					function()
						local checked = catstealth:GetChecked()
						MoveAny:SetEnabled("CHANGEONCATSTEALTH", checked)
						if C_UI then
							C_UI.Reload()
						else
							ReloadUI()
						end
					end
				)

				catstealth.text = catstealth:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				MoveAny:SetFontSize(catstealth.text, 12, "THINOUTLINE")
				catstealth.text:SetPoint("LEFT", catstealth, "RIGHT", 0, 0)
				catstealth.text:SetText(MoveAny:Trans("LID_CHANGEONCATSTEALTH"))
				PY = PY - 30
			end

			if optionFrame == StanceBarAnchor then
				PY = PY - 30
				opts["ORIENTATION"] = opts["ORIENTATION"] or "CENTERED"
				MoveAny:SetAppendTab(opts)
				local dropdown = MoveAny:CreateDropdown(
					"ORIENTATION",
					"CENTERED",
					{
						["LEFTALIGNED"] = "LEFTALIGNED",
						["CENTERED"] = "CENTERED",
						["RIGHTALIGNED"] = "RIGHTALIGNED"
					},
					content,
					function(valu)
						StanceBar:ClearAllPoints()
						StanceBar:SetPoint("CENTER", StanceBarAnchor, "CENTER", 0, 0)
					end
				)

				dropdown:SetPoint("TOPLEFT", content, "TOPLEFT", 4, PY)
				PY = PY - 30
			end
		elseif string.find(content.name, MoveAny:Trans("LID_BUFFS")) then
			--MoveAny:CreateSliderOld(parent, x, y, name, key, value, steps, vmin, vmax, func)
			local y = -20
			if name == "MABuffBar" then
				if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
					MoveAny:CreateSliderOld(
						content,
						10,
						y,
						name,
						"MABUFFMODE",
						0,
						1,
						0,
						5,
						function()
							if MoveAny.UpdateBuffs then
								MoveAny:UpdateBuffs()
							end

							if MoveAny.UpdateTargetBuffs then
								MoveAny:UpdateTargetBuffs()
							end

							if MoveAny.UpdateTargetToTBuffs then
								MoveAny:UpdateTargetToTBuffs()
							end

							if MoveAny.UpdateFocusBuffs then
								MoveAny:UpdateFocusBuffs()
							end

							if MoveAny.UpdateFocusToTBuffs then
								MoveAny:UpdateFocusToTBuffs()
							end
						end,
						{
							[0] = "AUTO",
							[1] = "TOPRIGHT",
							[2] = "TOPLEFT",
							[3] = "BOTTOMRIGHT",
							[4] = "BOTTOMLEFT",
							[5] = "CENTER",
						}
					)

					y = y - 40
				end
			else
				MoveAny:CreateSliderOld(
					content,
					10,
					y,
					name,
					"MABUFFMODE",
					0,
					1,
					0,
					1,
					function()
						if MoveAny.UpdateBuffs then
							MoveAny:UpdateBuffs()
						end

						if MoveAny.UpdateTargetBuffs then
							MoveAny:UpdateTargetBuffs()
						end

						if MoveAny.UpdateTargetToTBuffs then
							MoveAny:UpdateTargetToTBuffs()
						end

						if MoveAny.UpdateFocusBuffs then
							MoveAny:UpdateFocusBuffs()
						end

						if MoveAny.UpdateFocusToTBuffs then
							MoveAny:UpdateFocusToTBuffs()
						end
					end,
					{
						[0] = "DOWN",
						[1] = "TOP",
					}
				)

				y = y - 40
			end

			MoveAny:CreateSliderOld(
				content,
				10,
				y,
				name,
				"MABUFFLIMIT",
				10,
				1,
				2,
				20,
				function()
					if MoveAny.UpdateBuffs then
						MoveAny:UpdateBuffs()
					end

					if MoveAny.UpdateTargetBuffs then
						MoveAny:UpdateTargetBuffs()
					end

					if MoveAny.UpdateTargetToTBuffs then
						MoveAny:UpdateTargetToTBuffs()
					end

					if MoveAny.UpdateFocusBuffs then
						MoveAny:UpdateFocusBuffs()
					end

					if MoveAny.UpdateFocusToTBuffs then
						MoveAny:UpdateFocusToTBuffs()
					end
				end
			)

			y = y - 40
			MoveAny:CreateSliderOld(
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
					if MoveAny.UpdateBuffs then
						MoveAny:UpdateBuffs()
					end

					if MoveAny.UpdateTargetBuffs then
						MoveAny:UpdateTargetBuffs()
					end

					if MoveAny.UpdateTargetToTBuffs then
						MoveAny:UpdateTargetToTBuffs()
					end

					if MoveAny.UpdateFocusBuffs then
						MoveAny:UpdateFocusBuffs()
					end

					if MoveAny.UpdateFocusToTBuffs then
						MoveAny:UpdateFocusToTBuffs()
					end
				end
			)

			y = y - 40
			MoveAny:CreateSliderOld(
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
					if MoveAny.UpdateBuffs then
						MoveAny:UpdateBuffs()
					end

					if MoveAny.UpdateTargetBuffs then
						MoveAny:UpdateTargetBuffs()
					end

					if MoveAny.UpdateTargetToTBuffs then
						MoveAny:UpdateTargetToTBuffs()
					end

					if MoveAny.UpdateFocusBuffs then
						MoveAny:UpdateFocusBuffs()
					end

					if MoveAny.UpdateFocusToTBuffs then
						MoveAny:UpdateFocusToTBuffs()
					end
				end
			)

			y = y - 40
		elseif string.find(content.name, MoveAny:Trans("LID_DEBUFFS")) then
			local y = -20
			if name == "MADebuffBar" then
				if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
					MoveAny:CreateSliderOld(
						content,
						10,
						y,
						name,
						"MADEBUFFMODE",
						0,
						1,
						0,
						5,
						function()
							MoveAny:UpdateDebuffs("MenuOptions")
						end,
						{
							[0] = "AUTO",
							[1] = "TOPRIGHT",
							[2] = "TOPLEFT",
							[3] = "BOTTOMRIGHT",
							[4] = "BOTTOMLEFT",
							[5] = "CENTER",
						}
					)

					y = y - 40
				end
			else
				MoveAny:CreateSliderOld(
					content,
					10,
					y,
					name,
					"MADEBUFFMODE",
					0,
					1,
					0,
					1,
					function()
						if MoveAny.UpdateTargetDebuffs then
							MoveAny:UpdateTargetDebuffs()
						end

						if MoveAny.UpdateTargetToTDebuffs then
							MoveAny:UpdateTargetToTDebuffs()
						end

						if MoveAny.UpdateFocusDebuffs then
							MoveAny:UpdateFocusDebuffs()
						end

						if MoveAny.UpdateFocusToTDebuffs then
							MoveAny:UpdateFocusToTDebuffs()
						end
					end,
					{
						[0] = "DOWN",
						[1] = "TOP",
					}
				)

				y = y - 40
			end

			MoveAny:CreateSliderOld(
				content,
				10,
				y,
				name,
				"MADEBUFFLIMIT",
				10,
				1,
				2,
				20,
				function()
					if MoveAny.UpdateDebuffs then
						MoveAny:UpdateDebuffs("CreateSlider1")
					end

					if MoveAny.UpdateTargetDebuffs then
						MoveAny:UpdateTargetDebuffs()
					end

					if MoveAny.UpdateTargetToTDebuffs then
						MoveAny:UpdateTargetToTDebuffs()
					end

					if MoveAny.UpdateFocusDebuffs then
						MoveAny:UpdateFocusDebuffs()
					end

					if MoveAny.UpdateFocusToTDebuffs then
						MoveAny:UpdateFocusToTDebuffs()
					end
				end
			)

			y = y - 40
			MoveAny:CreateSliderOld(
				content,
				10,
				y,
				name,
				"MADEBUFFSPACINGX",
				4,
				1,
				0,
				30,
				function()
					if MoveAny.UpdateDebuffs then
						MoveAny:UpdateDebuffs("CreateSlider2")
					end

					if MoveAny.UpdateTargetDebuffs then
						MoveAny:UpdateTargetDebuffs()
					end

					if MoveAny.UpdateTargetToTDebuffs then
						MoveAny:UpdateTargetToTDebuffs()
					end

					if MoveAny.UpdateFocusDebuffs then
						MoveAny:UpdateFocusDebuffs()
					end

					if MoveAny.UpdateFocusToTDebuffs then
						MoveAny:UpdateFocusToTDebuffs()
					end
				end
			)

			y = y - 40
			MoveAny:CreateSliderOld(
				content,
				10,
				y,
				name,
				"MADEBUFFSPACINGY",
				10,
				1,
				0,
				30,
				function()
					MoveAny:UpdateDebuffs("CreateSlider3")
					if MoveAny.UpdateTargetDebuffs then
						MoveAny:UpdateTargetDebuffs()
					end

					if MoveAny.UpdateTargetToTDebuffs then
						MoveAny:UpdateTargetToTDebuffs()
					end

					if MoveAny.UpdateFocusDebuffs then
						MoveAny:UpdateFocusDebuffs()
					end

					if MoveAny.UpdateFocusToTDebuffs then
						MoveAny:UpdateFocusToTDebuffs()
					end
				end
			)

			y = y - 40
		elseif string.find(content.name, MoveAny:Trans("LID_MAINMENUEXPBAR")) or string.find(content.name, MoveAny:Trans("LID_REPUTATIONWATCHBAR")) then
			opts["WIDTH"] = opts["WIDTH"] or 1024
			local width = opts["WIDTH"]
			opts["HEIGHT"] = opts["HEIGHT"] or 15
			local height = opts["HEIGHT"]
			local sliderW = nil
			if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
				sliderW = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
			elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
				sliderW = CreateFrame("Slider", nil, content, "UISliderTemplate")
			else
				sliderW = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			end

			sliderW:SetSize(content:GetWidth() - 30, 16)
			sliderW:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -30)
			if sliderW.Low == nil then
				sliderW.Low = sliderW:CreateFontString(nil, nil, "GameFontNormal")
				sliderW.Low:SetPoint("BOTTOMLEFT", sliderW, "BOTTOMLEFT", 0, -12)
				MoveAny:SetFontSize(sliderW.Low, 10, "THINOUTLINE")
				sliderW.Low:SetTextColor(1, 1, 1)
			end

			if sliderW.High == nil then
				sliderW.High = sliderW:CreateFontString(nil, nil, "GameFontNormal")
				sliderW.High:SetPoint("BOTTOMRIGHT", sliderW, "BOTTOMRIGHT", 0, -12)
				MoveAny:SetFontSize(sliderW.High, 10, "THINOUTLINE")
				sliderW.High:SetTextColor(1, 1, 1)
			end

			if sliderW.Text == nil then
				sliderW.Text = sliderW:CreateFontString(nil, nil, "GameFontNormal")
				sliderW.Text:SetPoint("TOP", sliderW, "TOP", 0, 16)
				MoveAny:SetFontSize(sliderW.Text, 12, "THINOUTLINE")
				sliderW.Text:SetTextColor(1, 1, 1)
			end

			sliderW.Low:SetText(100)
			sliderW.High:SetText(1024)
			sliderW.Text:SetText(MoveAny:Trans("LID_WIDTH") .. ": " .. width)
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
						sel.Text:SetText(MoveAny:Trans("LID_WIDTH") .. ": " .. valu)
						if frame and frame.UpdateSize then
							frame:UpdateSize()
						end
					end
				end
			)

			local sliderH = nil
			if DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate") then
				sliderH = CreateFrame("Slider", nil, content, "MinimalSliderWithSteppersTemplate")
			elseif DoesTemplateExist and DoesTemplateExist("UISliderTemplate") then
				sliderH = CreateFrame("Slider", nil, content, "UISliderTemplate")
			else
				sliderH = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
			end

			sliderH:SetSize(content:GetWidth() - 30, 16)
			sliderH:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -60)
			if sliderH.Low == nil then
				sliderH.Low = sliderH:CreateFontString(nil, nil, "GameFontNormal")
				sliderH.Low:SetPoint("BOTTOMLEFT", sliderH, "BOTTOMLEFT", 0, -12)
				MoveAny:SetFontSize(sliderH.Low, 10, "THINOUTLINE")
				sliderH.Low:SetTextColor(1, 1, 1)
			end

			if sliderH.High == nil then
				sliderH.High = sliderH:CreateFontString(nil, nil, "GameFontNormal")
				sliderH.High:SetPoint("BOTTOMRIGHT", sliderH, "BOTTOMRIGHT", 0, -12)
				MoveAny:SetFontSize(sliderH.High, 10, "THINOUTLINE")
				sliderH.High:SetTextColor(1, 1, 1)
			end

			if sliderH.Text == nil then
				sliderH.Text = sliderH:CreateFontString(nil, nil, "GameFontNormal")
				sliderH.Text:SetPoint("TOP", sliderH, "TOP", 0, 16)
				MoveAny:SetFontSize(sliderH.Text, 12, "THINOUTLINE")
				sliderH.Text:SetTextColor(1, 1, 1)
			end

			sliderH.Low:SetText(2)
			sliderH.High:SetText(64)
			sliderH.Text:SetText(MoveAny:Trans("LID_HEIGHT") .. ": " .. height)
			sliderH:SetMinMaxValues(2, 64)
			sliderH:SetObeyStepOnDrag(true)
			sliderH:SetValueStep(1)
			sliderH:SetValue(height)
			sliderH:SetScript(
				"OnValueChanged",
				function(sel, valu)
					valu = tonumber(string.format("%" .. 0 .. "f", valu))
					if valu and valu ~= opts["HEIGHT"] then
						opts["HEIGHT"] = valu
						sel.Text:SetText(MoveAny:Trans("LID_HEIGHT") .. ": " .. valu)
						if frame and frame.UpdateSize then
							frame:UpdateSize()
						end
					end
				end
			)
		elseif string.find(content.name, MoveAny:Trans("LID_BAGEXTRAS")) then
			local hide = MoveAny:CreateCheckButton("HideSmallBags", content)
			hide:SetSize(btnsize, btnsize)
			hide:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
			hide:SetChecked(MoveAny:GetEleOption(name, "HideSmallBags", false, "Hide1"))
			hide:SetScript(
				"OnClick",
				function()
					local checked = hide:GetChecked()
					MoveAny:SetEleOption(name, "HideSmallBags", checked)
					MoveAny:UpdateBags()
				end
			)

			hide.text = hide:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			MoveAny:SetFontSize(hide.text, 12, "THINOUTLINE")
			hide.text:SetPoint("LEFT", hide, "RIGHT", 0, 0)
			hide.text:SetText(HIDE .. " (" .. MoveAny:Trans("LID_HIDESMALLBAGS") .. ")")
			local KeyRingButton = getglobal("KeyRingButton")
			if KeyRingButton then
				local hide2 = MoveAny:CreateCheckButton("HideKeyBag", content)
				hide2:SetSize(btnsize, btnsize)
				hide2:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
				hide2:SetChecked(MoveAny:GetEleOption(name, "HideKeyBag", false, "Hide1"))
				hide2:SetScript(
					"OnClick",
					function()
						local checked = hide2:GetChecked()
						MoveAny:SetEleOption(name, "HideKeyBag", checked)
						MoveAny:UpdateBags()
					end
				)

				hide2.text = hide2:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				MoveAny:SetFontSize(hide2.text, 12, "THINOUTLINE")
				hide2.text:SetPoint("LEFT", hide2, "RIGHT", 0, 0)
				hide2.text:SetText(HIDE .. " (" .. MoveAny:Trans("LID_HIDEKEYBAG") .. ")")
			end
		end
	end
end

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
		MACurrentEle.desc:Hide()
	end

	MACurrentEle = nil
	if MoveAny.GridFrameThink then
		MoveAny:GridFrameThink()
	end
end

function MoveAny:SelectEle(ele)
	if ele == nil then return end
	if MACurrentEle and MACurrentEle.t then
		MACurrentEle.t:SetVertexColor(MoveAny:GetColor("el"))
		MACurrentEle.name:Hide()
		MACurrentEle.desc:Hide()
	end

	MACurrentEle = ele
	if MoveAny.GridFrameThink then
		MoveAny:GridFrameThink()
	end

	if MACurrentEle and MACurrentEle.t then
		MACurrentEle.t:SetVertexColor(MoveAny:GetColor("se"))
		MACurrentEle.name:Show()
		MACurrentEle.desc:Show()
	end
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
	if C_Widget.IsWidget(EditModeManagerFrame) then
		if not EditModeManagerFrame:IsInitialized() or EditModeManagerFrame.layoutApplyInProgress then return true end
		local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
		local isPresetLayout = layoutInfo.layoutType == Enum.EditModeLayoutType.Preset

		return isPresetLayout
	end

	return true
end

if MoveAny:GetWoWBuild() == "RETAIL" or MoveAny:GetWoWBuild() == "TBC" then
	MoveAny:After(
		1,
		function()
			local lastCheck = false
			local wasPreset = MoveAny:IsPresetProfileActive()
			function MoveAny:ThinkHelpFrame()
				local isPreset = MoveAny:IsPresetProfileActive()
				if lastCheck ~= isPreset then
					lastCheck = isPreset
					if isPreset then
						MoveAny:MSG(MoveAny:Trans("LID_PLEASESWITCHPROFILE1") .. " " .. MoveAny:Trans("LID_PLEASESWITCHPROFILE2") .. " " .. MoveAny:Trans("LID_PLEASESWITCHPROFILE3"))
					elseif wasPreset then
						MoveAny:MSG("ALL GOOD.")
					end
				end

				if isPreset then
					MoveAny:After(0.5, MoveAny.ThinkHelpFrame, "ThinkHelpFrame 1")
				else
					MoveAny:After(1.1, MoveAny.ThinkHelpFrame, "ThinkHelpFrame 2")
				end
			end

			MoveAny:ThinkHelpFrame()
		end, "ThinkHelpFrame 3"
	)
end

function MoveAny:ToggleElementOptions(name, fram, dragframe)
	if dragframe.opt == nil then
		dragframe.opt = MoveAny:CreateFrame(name .. ".opt", MoveAny:GetMainPanel())
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
		MoveAny:SetClampedToScreen(dragframe.opt, true, "RegisterWidget 2")
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

function MoveAny:RegisterWidget(tab)
	local name = tab.name
	local lstr = tab.lstr
	local lstri = tab.lstri
	MoveAny:RegisterSelectEle(lstr, name)
	if lstri then
		lstr = format(MoveAny:Trans(lstr), lstri)
	else
		lstr = MoveAny:Trans(lstr)
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
	local soft = tab.soft
	tab.delay = tab.delay or 0.2
	local enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
	if (enabled1 or enabled2) and (not forced1 and not forced2) then
		MoveAny:MSG(format(MoveAny:Trans("LID_HELPTEXT"), lstr))

		return
	end

	local frame = MoveAny:GetFrameByName(name)
	if frame then
		MoveAny:AddFrameName(frame, name)
	end

	if _G[name .. "_MA_DRAG"] == nil then
		_G[name .. "_MA_DRAG"] = CreateFrame("FRAME", name .. "_MA_DRAG", MoveAny:GetMainPanel())
		local dragframe = _G[name .. "_MA_DRAG"]
		MoveAny:SetClampedToScreen(dragframe, true, "RegisterWidget 1")
		dragframe:SetFrameStrata("MEDIUM")
		dragframe:SetFrameLevel(99)
		dragframe:Hide()
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
		do
			dragframe.name = dragframe:CreateFontString(nil, nil, "GameFontHighlightLarge")
			dragframe.name:SetPoint("CENTER", dragframe, "CENTER", 0, 6)
			local font, _, fontFlags = dragframe.name:GetFont()
			dragframe.name:SetFont(font, 15, fontFlags)
			local enab, forc = MoveAny:IsInEditModeEnabled(name)
			if enab and not forc then
				lstr = lstr .. " |cFFFFFF00" .. MoveAny:Trans("LID_ISENABLEDINEDITMODE")
			end

			dragframe.name:SetText(lstr)
			dragframe.name:Hide()
		end

		do
			dragframe.desc = dragframe:CreateFontString(nil, nil, "GameFontHighlightLarge")
			dragframe.desc:SetPoint("CENTER", dragframe, "CENTER", 0, -9)
			local font2, _, fontFlags2 = dragframe.name:GetFont()
			dragframe.desc:SetFont(font2, 10, fontFlags2)
			dragframe.desc:SetText(MoveAny:Trans("LID_RIGHTCLICKFOROPTIONS"))
			dragframe.desc:Hide()
		end

		dragframe:SetScript(
			"OnEnter",
			function()
				if dragframe ~= MACurrentEle then
					dragframe.name:Show()
					dragframe.desc:Show()
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
					dragframe.desc:Hide()
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
					MoveAny:ToggleElementOptions(name, fram, dragframe)
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
		if missingWidgets[name] == nil then
			missingWidgets[name] = tab
		end

		return false
	end

	if missingWidgets[name] then
		missingWidgets[name] = nil
	end

	MoveAny:After(
		1,
		function()
			enabled1, forced1 = MoveAny:IsInEditModeEnabled(name)
			enabled2, forced2 = MoveAny:IsInEditModeEnabled(lstr)
			if (enabled1 or enabled2) and (not forced1 and not forced2) then
				MoveAny:MSG(format(MoveAny:Trans("LID_HELPTEXT"), lstr))

				return
			end
		end, "RegisterWidget 1"
	)

	--MoveAny:TrySetParent(frame, MoveAny:GetMainPanel())
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
	if MoveAny.SafeUpdateAlphas then
		MoveAny:SafeUpdateAlphas(MoveAny:GetEnumAlpha().ADDED)
	end

	if frame and frame.GetChildren then
		MoveAny:ForeachChildren(
			frame,
			function(child)
				function child:GetMAEle()
					return frame
				end
			end, "GetMAEle 1"
		)
	end

	if frame.SetMovable then
		frame:SetMovable(true)
		if frame.SetUserPlaced and frame:IsMovable() then
			frame:SetUserPlaced(userplaced or false)
		end
	end

	if frame.SetDontSavePosition then
		frame:SetDontSavePosition(true)
	end

	MoveAny:SetClampedToScreen(frame, true, "RegisterWidget 3")
	if frame ~= TalkingHeadFrame and frame ~= Minimap and frame ~= MinimapCluster and frame.SetIgnoreParentAlpha ~= nil and MoveAny:GetParent(frame) ~= UIParent and MoveAny:GetParent(frame) ~= MoveAny:GetMainPanel() then
		frame:SetIgnoreParentAlpha(true)
	end

	local MABuffBar = getglobal("MABuffBar")
	local MADebuffBar = getglobal("MADebuffBar")
	if not MoveAny:GetEleOption(name, "Hide", false, "Hide2") then
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
								return MABuffBar or BuffFrame
							end

							bb:EnableMouse(false)
						end

						if not MoveAny:IsEnabled("DEBUFFS", false) then
							local db = _G["DebuffButton" .. i]
							if db then
								function db:GetMAEle()
									return MABuffBar or BuffFrame
								end

								db:EnableMouse(false)
							end
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "player")
				MoveAny:OnEvent(
					bbf,
					function()
						frame:UpdateBuffMouse()
					end, "bbf 12"
				)

				frame:UpdateBuffMouse()
			elseif frame == MoveAny:GetDebuffBar() then
				function frame:UpdateDebuffMouse()
					for i = 1, 32 do
						local db = _G["DebuffButton" .. i]
						if db then
							function db:GetMAEle()
								return MADebuffBar or DebuffFrame
							end

							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "player")
				MoveAny:OnEvent(
					bbf,
					function()
						frame:UpdateDebuffMouse()
					end, "bbf 11"
				)

				frame:UpdateDebuffMouse()
			elseif frame == getglobal("TargetFrameBuffMover") then
				function frame:UpdateBuffMouse()
					for i, bb in pairs(MoveAny:UpdateTargetFrameBuffs()) do
						if bb then
							bb:EnableMouse(false)
						end
					end

					for i, db in pairs(MoveAny:UpdateTargetFrameDebuffs()) do
						if db then
							db:EnableMouse(false)
						end
					end
				end

				local bbf = CreateFrame("FRAME")
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "target")
				MoveAny:OnEvent(
					bbf,
					function()
						frame:UpdateBuffMouse()
					end, "bbf 10"
				)

				frame:UpdateBuffMouse()
			elseif frame == getglobal("FocusFrameBuffMover") then
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
				MoveAny:RegisterEvent(bbf, "UNIT_AURA", "focus")
				MoveAny:OnEvent(
					bbf,
					function()
						frame:UpdateBuffMouse()
					end, "bbf 9"
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
				if sel.AuraContainer then
					MoveAny:ForeachChildren(
						sel.AuraContainer,
						function(child)
							if C_Widget.IsWidget(child) then
								child:EnableMouse(false)
							end
						end, "EnableMouse 2"
					)
				else
					MoveAny:ForeachChildren(
						sel,
						function(child)
							if C_Widget.IsWidget(child) then
								child:EnableMouse(false)
							end
						end, "EnableMouse 1"
					)
				end

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
		function(sel, p1, p2, p3, p4, p5)
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

				if sel == MAMenuBar then
					MoveAny:UpdateActionBar(sel)
				end

				sel.elesetpoint = false
			end
		end
	)

	if not frame.ma_secure then
		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint(name)
		if dbp1 and dbp3 then
			if noreparent then
				MoveAny:SetPoint(frame, dbp1, MoveAny:GetParent(frame), dbp3, dbp4, dbp5)
			else
				MoveAny:SetPoint(frame, dbp1, MoveAny:GetMainPanel(), dbp3, dbp4, dbp5)
			end
		end
	end

	hooksecurefunc(
		frame,
		"SetScale",
		function(sel, scale)
			if InCombatLockdown() and sel:IsProtected() then return false end
			if sel.masetscale_ele then return end
			sel.masetscale_ele = true
			local newScale = MoveAny:GetEleScale(name) or 1
			if MoveAny:CheckIfMicroMenuInVehicle(frame) then
				newScale = 1
			end

			if newScale and type(newScale) == "number" and newScale > 0 and scale ~= newScale and not InCombatLockdown() then
				sel:SetScale(newScale)
			end

			local dragframe = _G[name .. "_MA_DRAG"]
			if dragframe then
				dragframe:SetScale(newScale)
			end

			sel.masetscale_ele = false
		end
	)

	hooksecurefunc(
		frame,
		"SetSize",
		function(sel, w, h)
			if InCombatLockdown() and sel:IsProtected() then return false end
			local isToSmall = false
			local df = _G[name .. "_MA_DRAG"]
			if df.SetSize then
				df:SetSize(w, h)
			end

			if w < sw then
				w = sw
				isToSmall = true
			end

			if h < sh then
				h = sh
				isToSmall = true
			end

			if bToSmall and isToSmall then
				if df.SetSize then
					df:SetSize(w, h)
				end

				if sel.SetSize then
					sel:SetSize(w, h)
				end
			end
		end
	)

	MoveAny:SafeExec(
		frame,
		function()
			frame:SetSize(sw, sh)
			if MoveAny:GetEleScale(name) and MoveAny:GetEleScale(name) > 0 then
				frame:SetScale(MoveAny:GetEleScale(name))
			end
		end, "RegisterWidget SetScale"
	)

	local dragframe = _G[name .. "_MA_DRAG"]
	dragframe:SetSize(sw, sh)
	dragframe:ClearAllPoints()
	dragframe:SetPoint("CENTER", frame, "CENTER", posx, posy)
	if MoveAny:GetEleOption(name, "Hide", false, "Hide3") then
		MoveAny:HideFrame(frame, soft)
		dragframe.t:SetVertexColor(MoveAny:GetColor("hidden"))
		if MoveAny:IsEnabled("HIDEHIDDENFRAMES", false) then
			dragframe:Hide()
		else
			if MoveAny:IsEnabled("MALOCK", false) then
				dragframe:Show()
			else
				dragframe:Hide()
			end
		end
	else
		if MoveAny:IsEnabled("MALOCK", false) then
			dragframe:Show()
		else
			dragframe:Hide()
		end
	end

	if setup then
		setup()
	end
end

function MoveAny:AnyActionbarEnabled()
	if MoveAny:GetWoWBuild() ~= "RETAIL" and MoveAny:GetWoWBuild() ~= "TBC" then
		return MoveAny:IsEnabled("ACTIONBARS", false) or MoveAny:IsEnabled("ACTIONBAR1", false) or MoveAny:IsEnabled("ACTIONBAR3", false) or MoveAny:IsEnabled("ACTIONBAR4", false) or MoveAny:IsEnabled("ACTIONBAR7", false) or MoveAny:IsEnabled("ACTIONBAR8", false) or MoveAny:IsEnabled("ACTIONBAR9", false) or MoveAny:IsEnabled("ACTIONBAR10", false)
	else
		return false
	end
end
