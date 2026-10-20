local addonName, MoveAny = ...
local P = {}
MoveAny.Profiler = P
local enabled = false
local stats = {}
local depth = 0
local childTime = {}
local frameStamp = nil
local frameTotal = 0
local frameSelf = {}
local frameCount = {}
local spikes = {}
local spikeLimit = 3
local maxSpikes = 40
local startTime = 0
local function OnError(err)
	local handler = geterrorhandler and geterrorhandler()
	if handler then handler(err) end
end

local function FlushFrame()
	if frameStamp and frameTotal >= spikeLimit then
		local top = {}
		for label, ms in pairs(frameSelf) do
			table.insert(top, {label, ms, frameCount[label] or 0})
		end

		table.sort(top, function(a, b) return a[2] > b[2] end)
		local parts = {}
		for i = 1, math.min(5, #top) do
			table.insert(parts, string.format("%s %.2fms x%d", top[i][1], top[i][2], top[i][3]))
		end

		table.insert(spikes, string.format("t=%.1f %.2fms: %s", frameStamp - startTime, frameTotal, table.concat(parts, " | ")))
		if #spikes > maxSpikes then table.remove(spikes, 1) end
	end

	frameTotal = 0
	wipe(frameSelf)
	wipe(frameCount)
end

local function Record(label, incl, own)
	local s = stats[label]
	if s == nil then
		s = {
			n = 0,
			incl = 0,
			own = 0,
			max = 0,
			o1 = 0,
			o5 = 0
		}

		stats[label] = s
	end

	s.n = s.n + 1
	s.incl = s.incl + incl
	s.own = s.own + own
	if incl > s.max then s.max = incl end
	if incl > 1 then s.o1 = s.o1 + 1 end
	if incl > 5 then s.o5 = s.o5 + 1 end
	frameSelf[label] = (frameSelf[label] or 0) + own
	frameCount[label] = (frameCount[label] or 0) + 1
	frameTotal = frameTotal + own
end

local function Run(label, fn, ...)
	local stamp = GetTime()
	if stamp ~= frameStamp then
		FlushFrame()
		frameStamp = stamp
	end

	depth = depth + 1
	local myDepth = depth
	childTime[myDepth] = 0
	local t0 = debugprofilestop()
	xpcall(fn, OnError, ...)
	local incl = debugprofilestop() - t0
	depth = myDepth - 1
	if depth > 0 then childTime[depth] = childTime[depth] + incl end
	Record(label, incl, incl - childTime[myDepth])
end

function P.Wrap(label, fn)
	if type(fn) ~= "function" then return fn end

	return function(...)
		if not enabled then return fn(...) end
		Run(label, fn, ...)
	end
end

local wrapCache = {}
function P.WrapOnce(label, fn)
	if type(fn) ~= "function" then return fn end
	local key = label .. tostring(fn)
	if wrapCache[key] == nil then wrapCache[key] = P.Wrap(label, fn) end

	return wrapCache[key]
end

function P.WrapEvent(label, fn)
	if type(fn) ~= "function" then return fn end

	return function(sel, event, ...)
		if not enabled then return fn(sel, event, ...) end
		Run(label .. " " .. tostring(event), fn, sel, event, ...)
	end
end

local function Caller()
	local stack = debugstack and debugstack(3, 4, 0) or ""
	local file, line = string.match(stack, "([%w_]+%.lua)[^:\n]*:(%d+)")
	if file then return file .. ":" .. line end

	return "?"
end

local function ObjName(obj)
	if type(obj) ~= "table" then return tostring(obj) end
	if type(obj.IsObjectType) == "function" and type(obj.GetName) == "function" then
		local ok, name = pcall(obj.GetName, obj)
		if ok and type(name) == "string" then return name end
	end

	return "table"
end

function MoveAny.hooksecurefunc(a, b, c)
	if type(a) == "string" then return hooksecurefunc(a, P.Wrap("hook " .. a .. " @" .. Caller(), b)) end

	return hooksecurefunc(a, b, P.Wrap("hook " .. ObjName(a) .. ":" .. tostring(b) .. " @" .. Caller(), c))
end

local origOnEvent = MoveAny.OnEvent
function MoveAny:OnEvent(frame, callback, from)
	return origOnEvent(self, frame, P.WrapEvent("event " .. tostring(from), callback), from)
end

local origAfter = MoveAny.After
function MoveAny:After(time, callback, from)
	if enabled then callback = P.Wrap("timer " .. tostring(from), callback) end

	return origAfter(self, time, callback, from)
end

local logLines = {}
local maxLogLines = 1500
local win = nil
local lastView = nil
local statusTicker = nil
local function RefreshLog(toEnd)
	if win == nil or not win:IsShown() then return end
	win.logText = table.concat(logLines, "\n")
	win.log:SetText(win.logText)
	if toEnd then
		C_Timer.After(0, function() win.scroll:SetVerticalScroll(win.scroll:GetVerticalScrollRange()) end)
	else
		win.scroll:SetVerticalScroll(0)
	end
end

local function AddLine(line)
	table.insert(logLines, line)
	while #logLines > maxLogLines do
		table.remove(logLines, 1)
	end
end

local function Out(...)
	local parts = {}
	for i = 1, select("#", ...) do
		parts[i] = tostring(select(i, ...))
	end

	AddLine(table.concat(parts, " "))
	if P.ShowWindow then P.ShowWindow() end
	RefreshLog(true)
end

function P.Reset()
	wipe(stats)
	wipe(spikes)
	FlushFrame()
	frameStamp = nil
	startTime = GetTime()
end

function P.SetEnabled(on)
	enabled = on and true or false
	if enabled then P.Reset() end
	MATAB = MATAB or {}
	MATAB["PROFILER"] = MATAB["PROFILER"] or {}
	MATAB["PROFILER"].enabled = enabled
end

function P.IsEnabled()
	return enabled
end

function P.BuildReport(count, sortKey)
	FlushFrame()
	sortKey = sortKey or "own"
	local list = {}
	for label, s in pairs(stats) do
		table.insert(list, {label, s})
	end

	table.sort(list, function(a, b) return a[2][sortKey] > b[2][sortKey] end)
	local seconds = math.max(GetTime() - startTime, 0.001)
	local lines = {}
	table.insert(lines, string.format("%.1fs measured, %d entries, sorted by %s (ms = self time without nested MoveAny calls)", seconds, #list, sortKey))
	for i = 1, math.min(count or 15, #list) do
		local label, s = list[i][1], list[i][2]
		table.insert(lines, string.format("%2d. %8.2fms self %8.2fms incl %6dx avg %.3f max %.2f >1ms %d >5ms %d %.2fms/s  %s", i, s.own, s.incl, s.n, s.incl / s.n, s.max, s.o1, s.o5, s.own / seconds, label))
	end

	return lines
end

function P.BuildSpikes(count)
	FlushFrame()
	count = count or 10
	local lines = {}
	if #spikes == 0 then
		table.insert(lines, string.format("No frame above %.1fms MoveAny time yet.", spikeLimit))

		return lines
	end

	for i = math.max(1, #spikes - count + 1), #spikes do
		table.insert(lines, spikes[i])
	end

	return lines
end

local views = {
	top = {"Top - self time", function() return P.BuildReport(30, "own") end},
	calls = {"Calls - most frequent", function() return P.BuildReport(30, "n") end},
	max = {"Max - biggest single call", function() return P.BuildReport(30, "max") end},
	spikes = {"Spikes - frames above the limit", function() return P.BuildSpikes(30) end},
}

local function AddView(view)
	local v = views[view]
	if v == nil then return end
	AddLine(" ")
	AddLine("|cffffd100== " .. v[1] .. " ==|r")
	for _, line in ipairs(v[2]()) do
		AddLine(line)
	end
end

local function CountStats()
	local count = 0
	for _ in pairs(stats) do
		count = count + 1
	end

	return count
end

local function UpdateStatus()
	if win == nil then return end
	local seconds = enabled and GetTime() - startTime or 0
	win.status:SetText(string.format("%s   %.0fs measured   %d entries   %d spikes   spike limit %.1fms", enabled and "|cff00ff00Running|r" or "|cffff4040Stopped|r", seconds, CountStats(), #spikes, spikeLimit))
	win.toggle:SetText(enabled and "Stop" or "Start")
end

function P.ShowView(view, live)
	lastView = view
	if live then wipe(logLines) end
	AddView(view)
	if P.ShowWindow then P.ShowWindow() end
	RefreshLog(not live)
	UpdateStatus()
end

local function Help()
	AddLine("|cffffd100== MoveAny Profiler ==|r")
	AddLine("Start: measure CPU time of MoveAny events, timers, hooks and functions (stays on after /reload).")
	AddLine("Top / Calls / Max / Spikes: add that view to the log. Live: refresh the last view every second.")
	AddLine("Spike limit: a frame where MoveAny used more than this many ms is logged under Spikes.")
	AddLine("The log can be selected and copied (Ctrl+A, Ctrl+C). Data is also saved to MATAB.PROFILER on /reload.")
	AddLine("Chat: /maprof on|off|reset|top|calls|max|spikes|limit <ms>")
end

local function OnTick()
	if win == nil or not win:IsShown() then return end
	if win.live:GetChecked() and lastView then P.ShowView(lastView, true) end
	UpdateStatus()
end

local function MakeButton(text, width, onClick)
	local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
	b:SetSize(width, 22)
	b:SetText(text)
	b:SetScript("OnClick", onClick)

	return b
end

function P.CreateWindow()
	if win then return win end
	win = MoveAny:CreateUIWindowFrame("MAProfilerWindow", UIParent)
	win:SetSize(860, 480)
	win:SetPoint("CENTER")
	win:SetFrameStrata("HIGH")
	win:SetToplevel(true)
	win:EnableMouse(true)
	win:SetMovable(true)
	win:RegisterForDrag("LeftButton")
	win:SetScript("OnDragStart", win.StartMoving)
	win:SetScript("OnDragStop", win.StopMovingOrSizing)
	win:SetResizable(true)
	if win.SetResizeBounds then
		win:SetResizeBounds(700, 280)
	elseif win.SetMinResize then
		win:SetMinResize(700, 280)
	end

	local title = win.TitleText or win.TitleContainer and win.TitleContainer.TitleText
	if title then title:SetText("MoveAny Profiler") end
	if UISpecialFrames then tinsert(UISpecialFrames, "MAProfilerWindow") end
	local row = {}
	win.toggle = MakeButton("Start", 70, function()
		P.SetEnabled(not enabled)
		AddLine(enabled and "|cff00ff00Started|r" or "|cffff4040Stopped|r")
		RefreshLog(true)
		UpdateStatus()
	end)

	table.insert(row, win.toggle)
	table.insert(row, MakeButton("Reset", 64, function()
		P.Reset()
		AddLine("Data reset")
		RefreshLog(true)
		UpdateStatus()
	end))

	table.insert(row, MakeButton("Top", 64, function() P.ShowView("top", win.live:GetChecked()) end))
	table.insert(row, MakeButton("Calls", 64, function() P.ShowView("calls", win.live:GetChecked()) end))
	table.insert(row, MakeButton("Max", 64, function() P.ShowView("max", win.live:GetChecked()) end))
	table.insert(row, MakeButton("Spikes", 70, function() P.ShowView("spikes", win.live:GetChecked()) end))
	table.insert(row, MakeButton("Clear log", 84, function()
		wipe(logLines)
		RefreshLog(false)
	end))

	for i, b in ipairs(row) do
		if i == 1 then
			b:SetPoint("TOPLEFT", win, "TOPLEFT", 12, -30)
		else
			b:SetPoint("LEFT", row[i - 1], "RIGHT", 4, 0)
		end
	end

	win.live = CreateFrame("CheckButton", nil, win, "UICheckButtonTemplate")
	win.live:SetSize(24, 24)
	win.live:SetPoint("LEFT", row[#row], "RIGHT", 10, 0)
	win.liveText = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	win.liveText:SetPoint("LEFT", win.live, "RIGHT", 2, 0)
	win.liveText:SetText("Live")
	win.limitText = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	win.limitText:SetPoint("LEFT", win.liveText, "RIGHT", 16, 0)
	win.limitText:SetText("Spike ms")
	win.limit = CreateFrame("EditBox", nil, win, "InputBoxTemplate")
	win.limit:SetSize(40, 20)
	win.limit:SetPoint("LEFT", win.limitText, "RIGHT", 10, 0)
	win.limit:SetAutoFocus(false)
	win.limit:SetText(tostring(spikeLimit))
	win.limit:SetScript("OnEnterPressed", function(sel)
		local num = tonumber(sel:GetText())
		if num and num > 0 then spikeLimit = num end
		sel:SetText(tostring(spikeLimit))
		sel:ClearFocus()
		UpdateStatus()
	end)

	win.limit:SetScript("OnEscapePressed", function(sel)
		sel:SetText(tostring(spikeLimit))
		sel:ClearFocus()
	end)

	win.status = win:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	win.status:SetPoint("TOPLEFT", win, "TOPLEFT", 16, -60)
	win.status:SetJustifyH("LEFT")
	win.scroll = CreateFrame("ScrollFrame", "MAProfilerWindowScroll", win, "UIPanelScrollFrameTemplate")
	win.scroll:SetPoint("TOPLEFT", win, "TOPLEFT", 14, -78)
	win.scroll:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -32, 24)
	if win.Inset then
		win.Inset:ClearAllPoints()
		win.Inset:SetPoint("TOPLEFT", win.scroll, "TOPLEFT", -6, 6)
		win.Inset:SetPoint("BOTTOMRIGHT", win.scroll, "BOTTOMRIGHT", 26, -6)
	end

	win.log = CreateFrame("EditBox", nil, win.scroll)
	win.log:SetMultiLine(true)
	win.log:SetAutoFocus(false)
	win.log:SetFontObject(ChatFontNormal)
	win.log:SetWidth(800)
	win.log:SetScript("OnEscapePressed", win.log.ClearFocus)
	win.log:SetScript("OnTextChanged", function(sel, userInput) if userInput then sel:SetText(win.logText or "") end end)
	win.scroll:SetScrollChild(win.log)
	win.scroll:SetScript("OnSizeChanged", function(sel, width) win.log:SetWidth(math.max(1, width)) end)
	win.grip = CreateFrame("Button", nil, win)
	win.grip:SetSize(16, 16)
	win.grip:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -4, 4)
	win.grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	win.grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	win.grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	win.grip:SetScript("OnMouseDown", function() win:StartSizing("BOTTOMRIGHT") end)
	win.grip:SetScript("OnMouseUp", function() win:StopMovingOrSizing() end)
	win:HookScript("OnShow", function()
		if statusTicker == nil then statusTicker = C_Timer.NewTicker(1, OnTick) end
		RefreshLog(true)
		UpdateStatus()
	end)

	win:HookScript("OnHide", function()
		if statusTicker then
			statusTicker:Cancel()
			statusTicker = nil
		end
	end)

	win:Hide()
	if #logLines == 0 then Help() end

	return win
end

function P.ShowWindow()
	P.CreateWindow()
	if not win:IsShown() then win:Show() end
end

function P.ToggleWindow()
	P.CreateWindow()
	if win:IsShown() then
		win:Hide()
	else
		win:Show()
	end
end

local function OnSlash(msg)
	local cmd, arg = string.match(msg or "", "^%s*(%S*)%s*(.-)%s*$")
	cmd = string.lower(cmd or "")
	local num = tonumber(arg)
	if cmd == "on" then
		P.SetEnabled(true)
		Out("|cff00ff00Started|r")
	elseif cmd == "off" then
		P.SetEnabled(false)
		Out("|cffff4040Stopped|r")
	elseif cmd == "reset" then
		P.Reset()
		Out("Data reset")
	elseif views[cmd] then
		P.ShowView(cmd, false)
	elseif cmd == "limit" and num and num > 0 then
		spikeLimit = num
		if win then win.limit:SetText(tostring(spikeLimit)) end
		Out("Spike limit " .. spikeLimit .. "ms")
	else
		P.ToggleWindow()
	end

	UpdateStatus()
end

MoveAny:AddSlash("maprof", OnSlash)
local svFrame = CreateFrame("Frame")
svFrame:RegisterEvent("ADDON_LOADED")
svFrame:RegisterEvent("PLAYER_LOGOUT")
svFrame:SetScript("OnEvent", function(sel, event, name)
	if event == "ADDON_LOADED" then
		if name ~= addonName then return end
		sel:UnregisterEvent("ADDON_LOADED")
		for _, method in ipairs({"UpdateAuraDurations", "StyleAuraDuration", "LayoutAuraGrid", "TryHookAuraDuration", "HookAuraFrames", "UpdateActionBar", "DoUpdateMicroBarNow"}) do
			if type(MoveAny[method]) == "function" then MoveAny[method] = P.Wrap("func " .. method, MoveAny[method]) end
		end
		if MATAB and MATAB["PROFILER"] and MATAB["PROFILER"].enabled then
			P.SetEnabled(true)
			print("|cff55d2ff[MoveAny Profiler]|r running - /maprof opens the window")
		end
	elseif event == "PLAYER_LOGOUT" then
		if not MATAB or not MATAB["PROFILER"] then return end
		if not enabled then
			MATAB["PROFILER"].report = nil
			MATAB["PROFILER"].spikes = nil

			return
		end

		MATAB["PROFILER"].report = P.BuildReport(60, "own")
		FlushFrame()
		MATAB["PROFILER"].spikes = {unpack(spikes)}
	end
end)
