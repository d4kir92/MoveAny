local _, D4 = ...
local UI = D4.UI
local WIDTH = 140
local IGNOREKEYS = {
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LALT"] = true,
	["RALT"] = true,
	["LMETA"] = true,
	["RMETA"] = true,
	["UNKNOWN"] = true
}

local function GetModifiers()
	local prefix = ""
	if IsAltKeyDown() then prefix = prefix .. "ALT-" end
	if IsControlKeyDown() then prefix = prefix .. "CTRL-" end
	if IsShiftKeyDown() then prefix = prefix .. "SHIFT-" end

	return prefix
end

local function GetMouseKey(button)
	if button == "LeftButton" then return nil end
	if button == "RightButton" then return nil end
	if button == "MiddleButton" then return "BUTTON3" end
	local index = button:match("^Button(%d+)$")
	if index then return "BUTTON" .. index end

	return nil
end

function UI.WindowMixin:AddKeybind(tab)
	tab = tab or {}
	local win = self
	local name = UI:NextName(win, "Keybind")
	local text = UI:Text(tab.label)
	local width = tab.width or WIDTH
	local holder = CreateFrame("Frame", name, win.content)
	holder:SetSize(math.max(1, win.contentWidth - 8), UI.ROW)
	local button = D4:CreateButton(name .. "Button", holder)
	button:SetSize(width, UI.ROW)
	button:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	button:RegisterForClicks("LeftButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")
	holder.Label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	holder.Label:SetPoint("LEFT", button, "RIGHT", 8, 0)
	holder.Label:SetText(text)
	holder.value = tab.value
	local recording = false
	local function Display()
		if recording then
			button:SetText(D4:Trans("LID_KEYBINDPRESS"))

			return
		end

		if holder.value == nil or holder.value == "" then
			button:SetText(D4:Trans("LID_KEYBINDNOTSET"))

			return
		end

		button:SetText(holder.value)
	end

	local function StopRecording()
		recording = false
		button:EnableKeyboard(false)
		button:SetPropagateKeyboardInput(true)
		Display()
	end

	local function Apply(key)
		holder.value = key
		StopRecording()
		if tab.func then tab.func(key) end
	end

	function holder:SetValue(newValue)
		holder.value = newValue
		Display()
	end

	function holder:GetValue()
		return holder.value
	end

	button:SetScript(
		"OnClick",
		function(sel, mouseButton)
			if recording == false then
				recording = true
				sel:EnableKeyboard(true)
				sel:SetPropagateKeyboardInput(false)
				Display()

				return
			end

			local key = GetMouseKey(mouseButton)
			if key then Apply(GetModifiers() .. key) end
		end
	)

	button:SetScript(
		"OnKeyDown",
		function(sel, key)
			if recording == false then return end
			if IGNOREKEYS[key] then return end
			if key == "ESCAPE" then
				StopRecording()

				return
			end

			if key == "DELETE" or key == "BACKSPACE" then
				Apply(nil)

				return
			end

			Apply(GetModifiers() .. key)
		end
	)

	button:SetScript("OnHide", function() if recording then StopRecording() end end)
	Display()
	UI:Add(win, holder, UI.ROW, text, true, tab.search)

	return holder
end
